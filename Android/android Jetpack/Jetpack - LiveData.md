[toc]

### 参考
[一点点入坑JetPack：LiveData篇](https://juejin.im/post/5c56546ff265da2d9c384643)
[Jetpack 之 LiveData](https://www.loongwind.com/archives/369.html)

> 文中部分代码图片引用自文章：
> [Understanding LiveData made simple](https://www.littlecorgi.top/posts/b1488352.html)

`LiveData`：

* 观察者模式
* 可异步发送

### LiveData 是什么
`LiveData` 是一个可观察的数据持有者类。与常规 `observable` 不同，`LiveData` 是生命周期感知的，它可以感知他应用程序组件的生命周期，例如 `Activity`，`Fragment` 或者 `Service`。此感知确保 `LiveData` 仅更新处于活动生命周期状态的应用程序组件观察者。

`LiveData` 是一个可以在给定生命周期内观察到的数据持有者类。这意味着可以将一个`Observer` 与一个 `LifecycleOwner` 添加到一对中，并且只有当对应的`LifecycleOwner` 处于活动状态时，才会通知这个观察者包装数据的修改。如果`LifecycleOwner` 的状态是 `Lifecycle.state.STARTED` 或`Lifecycle.state.RESUMED`，那么它处于活动状态。通过 `observeForever` 函数添加的观察者被认为总是处于活动状态，因此总是会被通知修改。对于这些观察者，您应该手动调用 `removeObserver` 函数移除。

如果生命周期移动到销毁状态，相应的观察者将被自动删除。在 `Activity` 和 `Fragment` 中，它们可以安全地观察 `LiveData`，而不用担心泄漏：当它们被销毁时，将立即取消订阅。

LiveData有三个重要方法

- `onActive()`：当 `LiveData` 被激活时调用
- `onInactive()`：当 `LiveData` 被取消时调用
- `setValue(T)`：更新 `LiveData` 所持有的数据并通知观察者

`LiveData` 用于保存 `ViewModel` 的单个数据字段，但也可以用于以解耦的方式在应用程序中的不同模块之间共享数据。

### LiveData 的使用场景

- 保证UI状态和数据的统一：`LiveData` 采用了观察者设计模式。当生命周期状态改变时，`LiveData` 会通知 `Observer` 对象。每次应用程序数据更改时，都会通知观察者对象，从而更新 `UI`。
- 减少内存泄漏：`LiveData` 能够感知到组件的生命周期，观察者绑定到生命周期对象，并在其相关生命周期被破坏后自行清理。
- 防止崩溃：`LiveData` 可以防止当 `Activity` 销毁后执行未清理的回调时引起崩溃，这是因为组件处于非激活状态时，不会收到 `LiveData` 中数据变化的通知。
- 实时更新：组件在前台的时候能够实时收到数据改变的通知，这是可以理解的。当组件从后台到前台来时，`LiveData` 能够将最新的数据通知组件，这两点就保证了组件中和数据相关的内容能够实时更新。
- 资源共享：通过继承 `LiveData` 类，然后将该类定义成单例模式，在该类封装监听一些系统属性变化，然后通知 `LiveData` 的观察者。
- 支持异步：`LiveData` 提供了两种方法修改值：`setValue()`、`postValue()`，其中 `postValue()` 支持在子线程中调用。

### LiveData 的使用
#### 常用用法
`ShareViewModel.kt`
```kotlin
class ShareViewModel : ViewModel() {

    val clickLiveData = MutableLiveData<String>()
}
```

`MasterFragment.kt`
```kotlin
val model = ViewModelProvider(this).get(ShareViewModel::class.java)
class MasterFragment: Fragment() {

    private lateinit var viewModel: ShareViewModel

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_master, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel = ViewModelProvider(activity!!).get(ShareViewModel::class.java)

        button.setOnClickListener {
            val value = viewModel.clickLiveData.value
            viewModel.clickLiveData.value = value?.plus(1) ?: 0
        }
    }
}
```

`DetailsFragment.kt`
```kotlin
class DetailsFragment: Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_details, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val viewModel = ViewModelProvider(activity!!).get(ShareViewModel::class.java)
        viewModel.clickLiveData.observe(this, Observer {
            textView.text = "${viewModel.clickLiveData.value}"
        })
    }
}
```

#### 扩展LiveData - 监听网络状态

```kotlin
class NetworkLiveData(private val context: Context) : LiveData<Int>() {

    private val broadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(p0: Context?, p1: Intent?) {
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager?
            val networkInfo = connectivityManager!!.activeNetworkInfo

            value = if (networkInfo != null && networkInfo.isAvailable) 1 else 0
        }
    }

    override fun onInactive() {
        super.onInactive()

        context.unregisterReceiver(broadcastReceiver)
    }

    override fun onActive() {
        super.onActive()

        val intentFilter = IntentFilter()
        intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION)
        context.registerReceiver(broadcastReceiver, intentFilter)
    }

    companion object {
        private lateinit var sInstance: NetworkLiveData

        @MainThread
        fun get(context: Context): NetworkLiveData {
            sInstance = if (::sInstance.isInitialized) sInstance else NetworkLiveData(context.applicationContext)
            return sInstance
        }
    }
}
```

```kotlin
val networkLiveData = NetworkLiveData(this)
networkLiveData.observe(this, Observer {
    value ->
    if (value == 1){
        Toast.makeText(this, "is work", Toast.LENGTH_LONG).show()
    } else{
        Toast.makeText(this, "is not work", Toast.LENGTH_LONG).show()
    }
})
```

#### LiveData转换 - Transformations
`Transformations` 可以对 `LiveData` 进行变换操作，它提供了两个操作符 `map` 和 `switchMap` 他们的作用都是将一个 `LiveData` 转换为另一个 `LiveData` 对象，当一个 `LiveData` 里的值发生改变时另一个 `LiveData` 的值也随之发生改变。

在官方文档中对于 `map`、`switchMap` 的讲解实在是让人难以理解。有兴趣的可以看下 这篇文章 [Understanding LiveData made simple](https://www.littlecorgi.top/posts/b1488352.html)，作者对于这两者的区别和用法都做了详细的讲解。

对于 `map` 方法来说，它的目的在通过 `Function` 将 `LiveData` 参数的值进行转换并根据转换生成的值返回一个新的 `LiveData`，可以说返回值 `LiveData` 是由传参 `LiveData` 生成的。

对于 `switchMap` 方法来说，返回值 `LiveData` 和传参 `LiveData` 之间半毛钱关系也没有，传参 `LiveData` 可以看做一个开关或者选择器，而新 `LiveData` 根据选择器返回不同的实例。

下面是文章中的三幅图可用来加深理解：

不使用 `Transformations`
```kotlin
getLiveDataA().observe(this, changeObserver)
```

![image](https://miro.medium.com/max/640/1*5Miyyt5kK56IAAcPKpfTKw.gif)

使用 `Transformations.map()`
```kotlin
Transformations.map(getLiveDataA()) { "A:$it" }
```

![image](https://miro.medium.com/max/640/1*6cTWqtHlJgnzF701QFtZQg.gif)

使用 `Transformations.switchMap()`
```kotlin
Transformations.switchMap(getLiveDataSwitch()) { 
                switchToB ->
                if (switchToB) {
                     getLiveDataB()
                } else {
                     getLiveDataA()
                }
        }
```

![image](https://miro.medium.com/max/640/1*9RDrsXCBQhZmmc8XMQWw6Q.gif)

可以看到 `map` 注重的是数据的转换，而 `switchMap` 注重的是数据的选择，这就是这两者的区别。

#### MutableLiveData 、MediatorLiveData
`LiveData` 是一个抽象类，不可以直接使用，但是 `Google` 为我们提供了两个实现类，如下：

- `MutableLiveData`：可变的 `LiveData`，是我们最常用的 `LiveData` 子类。它的实现很简单，就是继承了 `LiveData` 然后向外暴露了 `setValue`、`postValue` 方法。
- `MediatorLiveData`：它继承自 `MutableLiveData` 可以监听多个 `LiveData` 数据源，或者调度多个 `LiveData` 数据源决定向观察者发送那个 `LiveData` 的数据更新。它新增了两个方法 `addSource` 、`removeSource` 用于添加和删除 `LiveData` 源。

```kotlin
class MediatorLiveDataFragment : Fragment() {

    private val changeObserver = Observer<String> { value ->
        value?.let { txt_fragment.text = it }
    }

    override fun onAttach(context: Context?) {
        super.onAttach(context)
        val mediatorLiveData = MediatorLiveData<String>()
        mediatorLiveData.addSource(getliveDataA())
              { mediatorLiveData.value = "A:$it" }
        mediatorLiveData.addSource(getliveDataB()) 
              { mediatorLiveData.value = "B:$it" }
        mediatorLiveData.observe(this, changeObserver)
    }
    // .. some other Fragment specific code ..
}
```

![image](https://miro.medium.com/max/640/1*eMsbIZVbY36kC2CmuWwOBQ.gif)

#### 资源共享
主要是通过单例模式实现的资源共享。

`ShareLiveData.kt`
```kotlin
class ShareLiveData : LiveData<Int>() {

    fun getNewValue() = value

    fun setNewValue(newValue: Int) {
        value = newValue
    }

    companion object {
        private lateinit var sInstance: ShareLiveData

        @MainThread
        fun get(): ShareLiveData {
            sInstance = if (::sInstance.isInitialized) sInstance else ShareLiveData()
            return sInstance
        }
    }
}
```

`MainActivity.kt`
```kotlin
val shareLiveData = ShareLiveData.get()
shareLiveData.observe(this, Observer {
    value -> tvNetState.text = "$value"
})

btJumpOther.setOnClickListener {
    startActivity(Intent(this, OtherActivity::class.java))
}
```

`OtherActivity.kt`
```kotlin
val shareLiveData = ShareLiveData.get()
shareLiveData.observe(this, Observer {
    value -> tvNetState.text = "$value"
})

btChangeNetState.setOnClickListener {
    shareLiveData.setNewValue(if (shareLiveData.getNewValue() == 1) 0 else 1)
}
```

### LiveData 源码解析

注册 `Observer`

```java
@MainThread
public void observe(@NonNull LifecycleOwner owner, @NonNull Observer<? super T> observer) {
    // 如果当前生命周期是DESTROYED，直接return
    if (owner.getLifecycle().getCurrentState() == DESTROYED) {
        return;
    }
    // 这个包装类，做了一件事情，在DESTROYED，移除Observer
    LifecycleBoundObserver wrapper = new LifecycleBoundObserver(owner, observer);
    // 防止重复调用 observe 方法
    ObserverWrapper existing = mObservers.putIfAbsent(observer, wrapper);
    if (existing != null && !existing.isAttachedTo(owner)) {
        throw new IllegalArgumentException("Cannot add the same observer"
                + " with different lifecycles");
    }
    if (existing != null) {
        return;
    }
    // 把Wrapper添加到LifecycleOwner上
    owner.getLifecycle().addObserver(wrapper);
}
```

`Observer` 如何被响应：

```java
public interface Observer<T> {
    /**
     * Called when the data is changed.
     * @param t  The new data
     */
    void onChanged(T t);
}
```

赋值代码触发的起点，很明显是我们在 `set/postValue` 的时候：

```java
@MainThread
protected void setValue(T value) {
    // 记住这个值，它是用来表示数据是否发生变化的
    mVersion++;
    mData = value;
    dispatchingValue(null);
}

void dispatchingValue(@Nullable ObserverWrapper initiator) {
    // 省略部分代码 
    for (Iterator<Map.Entry<Observer<? super T>, ObserverWrapper>> iterator =
        mObservers.iteratorWithAdditions(); iterator.hasNext(); ) {
        // 往里走
        considerNotify(iterator.next().getValue());
        if (mDispatchInvalidated) {
            break;
        }
    }
    // 省略部分代码
}

private void considerNotify(ObserverWrapper observer) {
    // 如果observer不在活动期，则直接return。也就是上述说observer不在前台，将不会接受回调。
    if (!observer.mActive) {
        return;
    }
    // 省略部分代码
    // 很直白的version对比
    if (observer.mLastVersion >= mVersion) {
        return;
    }
    observer.mLastVersion = mVersion;
    // 回调
    observer.mObserver.onChanged((T) mData);
}
```

赋值代码 `observer.mActive` 在哪被赋值？很多地方。除了一些边界条件的赋值外，一个比较正式的赋值，`ObserverWrapper` 中的 `void activeStateChanged(boolean newActive)` 方法：

```java
void activeStateChanged(boolean newActive) {
    if (newActive == mActive) {
        return;
    }
    mActive = newActive;
}
// 此方法最终会调到此方法
@Override
boolean shouldBeActive() {
    return mOwner.getLifecycle().getCurrentState().isAtLeast(STARTED);
}
public boolean isAtLeast(@NonNull State state) {
    return compareTo(state) >= 0;
}
```

赋值代码很简单，每次生命周期回调，`observer.mActive` 都会被赋值，而只有到 `Lifecycle` 是活动状态时 `mActive` 才会 `true`。因此只有在我们的 `Activity` 为前台时我们的 `LiveData` 才会被回调。

### postValue
``` java
protected void postValue(T value) {
    boolean postTask;
    // synchronized 防止在处理数据时，数据被修改
    synchronized (mDataLock) {
        postTask = mPendingData == NOT_SET;
        // 更新当前值
        mPendingData = value;
    }
    // 一次仅发送一次消息
    if (!postTask) {
        return;
    }
    ArchTaskExecutor.getInstance().postToMainThread(mPostValueRunnable);
}
```

通过查看 `postValue` 的源码发现，多次 `postValue` 调用，仅有最新的那次会执行观察者回调。

### 非粘性LiveData

```java
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;

import java.util.Objects;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * 非粘性LiveData
 * @author jianghui
 * @since 2022/9/7
 */
public class NoStickinessLiveData<T> extends MutableLiveData<T> {

    private static final String TAG = "NoStickinessLiveData";

    private static final int DEFAULT_VERSION = 0;

    private final AtomicInteger mValueVersion = new AtomicInteger(DEFAULT_VERSION);

    @Override
    public void observe(@NonNull LifecycleOwner owner, @NonNull Observer<? super T> observer) {
        int valueVersion = mValueVersion.get();
        super.observe(owner, createObserverWrapper(observer, valueVersion));
    }

    @MainThread
    public void setValue(@Nullable T t) {
        mValueVersion.getAndIncrement();
        int valueVersion = mValueVersion.get();

        super.setValue(t);
    }

    @Override
    public void removeObserver(@NonNull Observer<? super T> observer) {
        if (observer instanceof ObserverWrapper) {
            super.removeObserver(observer);
        } else {
            super.removeObserver(createObserverWrapper(observer, DEFAULT_VERSION));
        }
    }

    /**
     * 创建观察者包装类
     * @param observer 观察者
     * @param version 观察者版本
     * @return 创建观察者包装类对象
     */
    private ObserverWrapper<T> createObserverWrapper(Observer<? super T> observer, int version) {
        return new ObserverWrapper<T>(observer, version) {
            @Override
            public void onChanged(T t) {
                int valueVersion = mValueVersion.get();
                int observerVersion = getVersion();

                if (valueVersion > observerVersion) {
                    super.onChanged(t);
                }
            }
        };
    }

    /**
     * 创建观察者包装类
     * @param <T> 类型
     */
    private static class ObserverWrapper<T> implements Observer<T> {

        private final Observer<? super T> mObserver;
        private final int mVersion;

        public ObserverWrapper(@NonNull Observer<? super T> observer, int version) {
            this.mObserver = observer;
            this.mVersion = version;
        }

        @Override
        public void onChanged(T t) {
            mObserver.onChanged(t);
        }

        public int getVersion() {
            return mVersion;
        }

        @SuppressWarnings("unchecked")
        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj instanceof ObserverWrapper) {
                ObserverWrapper<T> that = (ObserverWrapper<T>) obj;
                return Objects.equals(mObserver, that.mObserver);
            }
            return false;
        }

        @Override
        public int hashCode() {
            return Objects.hash(mObserver);
        }
    }
}
```
