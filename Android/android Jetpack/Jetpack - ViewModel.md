[toc]

`ViewModel`：

* 工厂模式
* 反射
* `HashMap`

### 什么是 ViewModel
在 `Android` 中，`ViewModel` 的作用就是在 `UI` 控制器（如 `Activity`、`Fragment`）的生命周期中保存和管理 `UI` 相关的数据。`ViewModel` 保存的数据在配置更改（如屏幕旋转）后会依然存在，不会丢失。

### ViewModel 的使用场景

- 防止因屏幕旋转导致 `Activity` 重建而丢失数据
- 同一 `Activity` 中不同 `Fragment` 间数据共享
- 防止销毁的 `Activity` 中未完成的异步回调

### 生命周期
![image](https://developer.android.com/images/topic/libraries/architecture/viewmodel-lifecycle.png?hl=zh-CN)

### ViewModel 使用

#### 不配合 LiveData 使用

`ShareViewModel.kt`
```kotlin
class ShareViewModel: ViewModel() {
    val name = "张三"
}
```

`MainActivity.kt`
```kotlin
val model = ViewModelProvider(this).get(ShareViewModel::class.java)

tvContent.text = model.state

btClick.setOnClickListener {
    model.state = "newState"
    tvContent.text = model.state
}
```

#### 配合 LiveData 使用

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

以上也是同一 `Activity` 中不同 `Fragment` 间数据共享的实现。

### 源码分析

#### 为什么 ViewModel 可以防止因屏幕旋转导致 Activity 重建而丢失数据

获取 `ViewModel` 实例对象需要通过如下代码。

```kotlin
val model = ViewModelProvider(this).get(ShareViewModel::class.java)
```

在 `ViewModelProvider` 的构造函数中，主要是为 `ViewModelStore`、`Factory` 两个变量赋值。

先看下 `ViewModelStore`，其中包含一个 `HashMap` 存储 `ViewModel`，还有`put()`、`get()`、`clear()` 函数，`put` 和 `get` 函数都是在 `ViewModelProvider` 的 `get` 函数中调用，`clear` 函数是在 `ComponentActivity` 的构造函数中调用

```java
public ComponentActivity() {

    getLifecycle().addObserver(new LifecycleEventObserver() {
            @Override
            public void onStateChanged(@NonNull LifecycleOwner source,
                    @NonNull Lifecycle.Event event) {
                if (event == Lifecycle.Event.ON_DESTROY) {
                    if (!isChangingConfigurations()) {
                        getViewModelStore().clear();
                    }
                }
            }
        });
}
```

这里看到调用 `clear` 函数的前提非改变配置导致的页面重建 。这就解释了为什么 `ViewModel` 可以防止因屏幕旋转导致 `Activity` 重建而丢失数据了。

也就是说 `ViewModel` 的生命周期是由 `ViewModelStore` 管理的。

#### NonConfigurationInstances
但是 `ViewModelStore` 仅是 `ComponentActivity` 中的一个全局变量而已，它是如何在 `Activity` 销毁重建的情况下保证不会被销毁的呢。

```java
// ComponentActivity.java
public ViewModelStore getViewModelStore() {
    if (mViewModelStore == null) {
        NonConfigurationInstances nc =
                (NonConfigurationInstances) getLastNonConfigurationInstance();
        if (nc != null) {
            // Restore the ViewModelStore from NonConfigurationInstances
            mViewModelStore = nc.viewModelStore;
        }
        if (mViewModelStore == null) {
            mViewModelStore = new ViewModelStore();
        }
    }
    return mViewModelStore;
}
```

看注释的一句：

> 原文：`Restore the ViewModelStore from NonConfigurationInstances`
> 翻译：从 `NonConfigurationInstances` 恢复 `ViewModelStore`

```java
// ComponentActivity.java
static final class NonConfigurationInstances {
    Object custom;
    ViewModelStore viewModelStore;
}
```

类内部保存了两个对象：

- `Object`：自定义要保存的类实例
- `ViewModelStore`：保存 `ViewModelStore`

> 需要保存的类实例可以放到 `ViewModel`，从这方面来看 `Object` 在这里是比较多余的。而且它的赋值函数已经标注了 `过时`。

继续来看 `NonConfigurationInstances` 是如何存取的：

```java
// ActivityThread.java
ActivityClientRecord performDestroyActivity(IBinder token, boolean finishing,
        int configChanges, boolean getNonConfigInstance, String reason) {
    ActivityClientRecord r = mActivities.get(token);
    if (r != null) {
        performPauseActivityIfNeeded(r, "destroy");

        if (getNonConfigInstance) {
            try {
                r.lastNonConfigurationInstances
                        = r.activity.retainNonConfigurationInstances();
            } catch (Exception e) {
            }
        }
        try {
            r.activity.mCalled = false;
            mInstrumentation.callActivityOnDestroy(r.activity);
        } catch (SuperNotCalledException e) {
            throw e;
        } catch (Exception e) {
        }
        r.setState(ON_DESTROY);
    }
    return r;
}
```

```java
// Activity.java
NonConfigurationInstances retainNonConfigurationInstances() {
    Object activity = onRetainNonConfigurationInstance();
    HashMap<String, Object> children = onRetainNonConfigurationChildInstances();
    FragmentManagerNonConfig fragments = mFragments.retainNestedNonConfig();

    ...
    
    NonConfigurationInstances nci = new NonConfigurationInstances();
    nci.activity = activity;
    nci.children = children;
    nci.fragments = fragments;
    nci.loaders = loaders;
    if (mVoiceInteractor != null) {
        mVoiceInteractor.retainInstance();
        nci.voiceInteractor = mVoiceInteractor;
    }
    return nci;
}
```

```java
// ComponentActivity.java
public final Object onRetainNonConfigurationInstance() {
    NonConfigurationInstances nci = new NonConfigurationInstances();
    nci.custom = custom;
    nci.viewModelStore = viewModelStore;
    return nci;
}
```

看到在 `ActivityThread` 中 `Activity.onDestory` 调用前将 `NonConfigurationInstances` 保存在了 `ActivityClientRecord` 中。
在 `Activity` 恢复时，调用 `attach` 把 `NonConfigurationInstances` 回传给了 `Activity`。

```java
// ActivityThread.java
activity.attach(appContext, this, getInstrumentation(), r.token,
        r.ident, app, r.intent, r.activityInfo, title, r.parent,
        r.embeddedID, r.lastNonConfigurationInstances, config,
        r.referrer, r.voiceInteractor, window, r.configCallback);

```

> 可以发现在 `Activity` 中的 `retainNonConfigurationInstances` 方法内 `Fragment` 也通过是通过这种方式保存数据。

#### 同一 Activity 中不同 Fragment 间数据共享
不同 `Fragment` 间数据共享的重点是，获取他们所共同依赖的 `Activity` 中保存的 `ViewModelStore`，只有这样才可以得到 `ViewModel` 的同一实例对象，再配合 `LiveData` 即可实现数据变化的监听。代码在上方 `↑`。

#### 防止销毁的 Activity 中未完成的异步回调
其实来说 `ViewModel` 自身的功能只有两个

- 防止因屏幕旋转导致 `Activity` 重建而丢失数据
- 同一 `Activity` 中不同 `Fragment` 间数据共享v

防止销毁的 `Activity` 中未完成的异步回调，这个功能是配合 `LiveData` 实现的。异步回调结果修改 `LiveData` 数据，通过观察者监听 `LiveData` 数据的修改更新 `UI` 显示，在 `LiveData` 篇章中可以知道当页面销毁时观察者删除，如此防止调用销毁页面的 `UI`。

#### 注意
`ViewModel` 绝不能引用视图、`Lifecycle` 或可能存储对 `Activity` 上下文的引用的任何类。

如果 `ViewModel` 需要 `Application` 上下文（例如，为了查找系统服务），它可以扩展 `AndroidViewModel` 类并设置用于接收 `Application` 的构造函数。

修改一下 `ShareViewModel.kt` 代码。

```kotlin
class ShareViewModel(app: Application): AndroidViewModel(app) {
    val clickLiveData = MutableLiveData<Int>()
}
```

直接运行会报错，提示无法创建 `ViewModel`。在上文中我们知道，在 `ViewModelProvider` 的构造函数中主要是为 `ViewModelStore`、`Factory` 两个变量赋值。`ViewModelStore` 我们已经知道它是用来保存 `ViewModel` 的，下面来看 `Factory` 的作用。

`Factory` 是一个接口，只定义了一个 `create()` 函数。

```kotlin
public interface Factory {
    @NonNull
    <T extends ViewModel> T create(@NonNull Class<T> modelClass);
}
```

很清楚能想到 `Factory` 的作用就是创建 `ViewModel`。`Factory` 有一个子类 `NewInstanceFactory`，还有一个孙子类 `AndroidViewModelFactory`。他们都是通过反射获取 `ViewModel` 对象，区别在于 `AndroidViewModelFactory` 创建的是带 `Application` 参数的 `ViewModel` 对象。

那要获取 `AndroidViewModel` 的实例对象，需要使用 `AndroidViewModelFactory`, 如下：

```java
ViewModelProvider(activity!!, ViewModelProvider.AndroidViewModelFactory(BaseApplication.instance!!)).get(ShareViewModel::class.java)
```

这样的话，如果想自定义更多参数的 `ViewModel`，还需要自定义 `ViewModelFactory`。
