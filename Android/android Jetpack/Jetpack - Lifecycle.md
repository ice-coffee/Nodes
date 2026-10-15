[toc]

`Lifecycle`：

* 发布订阅模式
* 线程不安全
* 同一被观察者可以被多次订阅

### 如何监听生命周期
`androidx.lifecycle` 软件包提供了可用于构建生命周期感知型组件的类和接口。要使用 `lifecycle` 需要先声明依赖：

``` java
implementation “androidx.lifecycle:lifecycle-runtime-ktx:$lifecycle_version”
```

#### 监听 Activity 生命周期
监听 `Activity` 生命周期非常简单：

- 实现生命周期观察者接口
- 注册生命周期观察者

创建自定义生命周期观察者：

``` java
class CustomObserver(val level: String): LifecycleObserver {

    @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
    fun onCreate() {
        Log.e("lifecycle", "${level}_onCreate")
    }
    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    fun onDestroy() {
        Log.e("lifecycle", "${level}_onDestroy")
    }
    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    fun onResume() {
        Log.e("lifecycle", "${level}_onResume")
    }
    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    fun onPause() {
        Log.e("lifecycle", "${level}_onPause")
    }
    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    fun onStart() {
        Log.e("lifecycle", "${level}_onStart")
    }
    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    fun onStop() {
        Log.e("lifecycle", "${level}_onStop")
    }
}
```

注册生命周期观察者

``` java
class LifecycleActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        ...
        lifecycle.addObserver(CustomObserver("activity"))
    }
}
```

#### 监听 Fragment 生命周期

监听 `Fragment` 生命周期和 `Activity` 的方式一模一样。

``` java
class LifecycleFragment : Fragment() {
    ...
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        ...
        lifecycle.addObserver(CustomObserver("fragment"))
    }
}
```

#### 监听 Application 生命周期

监听 `Application` 生命周期首先需要其他包的支持：

``` java
implementation “androidx.lifecycle:lifecycle-process:$lifecycle_version”
```

然后也是一样的步骤：

- 实现生命周期观察者接口
- 注册生命周期观察者

但是不同的是要通过 `ProcessLifecycleOwner` 来注册。

``` java
ProcessLifecycleOwner.get().lifecycle.addObserver(CustomObserver("app"))
```

### 生命周期监听解析

`lifecycle` 包中监听生命周期有两个重要的类：

- `ReportFragment`：监听 `Activity` 的生命周期
- `LifecycleRegistry`：注册监听、分发生命周期事件

#### 监听 Activity 生命周期原理

监听 `Activity` 声明周期原理其实很简单，我们知道当 `Fragment` 被添加到 `Activity` 中后它们的生命周期将会绑定。生命周期函数调用顺序如下：

``` java
 -Fragment: onCreate
 -Fragment: onCreateView 
 -Fragment: onViewCreated
 -Activity: onCreate
 -Fragment: onActivityCreated
 -Activity: onStart
 -Fragment: onStart
 -Activity: onResume
 -Fragment: onResume
 -Fragment: onPause
 -Activity: onPause
 -Fragment: onStop
 -Activity: onStop
 -Fragment: onDestroyView
 -Fragment: onDestroy
 -Fragment: onDetach
 -Activity: onDestroy
```

那通过监听添加到 `Activity` 中 `Fragment` 的生命周期也就相当于监听了 `Activity` 的生命周期。

在 `ComponentActivity` 中就添加了这样一个 `ReportFragment`。

``` java
@Override
@SuppressWarnings("RestrictedApi")
protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    ReportFragment.injectIfNeededIn(this);
}
```

转到 `ReportFragment` 类中，删除了部分代码：

``` java
public class ReportFragment extends Fragment {
    private static final String REPORT_FRAGMENT_TAG = "androidx.lifecycle"
            + ".LifecycleDispatcher.report_fragment_tag";

    public static void injectIfNeededIn(Activity activity) {
        if (Build.VERSION.SDK_INT >= 29) {
            activity.registerActivityLifecycleCallbacks(
                    new LifecycleCallbacks());
        }
        
        android.app.FragmentManager manager = activity.getFragmentManager();
        if (manager.findFragmentByTag(REPORT_FRAGMENT_TAG) == null) {
            manager.beginTransaction().add(new ReportFragment(), REPORT_FRAGMENT_TAG).commit();
            // Hopefully, we are the first to make a transaction.
            manager.executePendingTransactions();
        }
    }

    @SuppressWarnings("deprecation")
    static void dispatch(@NonNull Activity activity, @NonNull Lifecycle.Event event) {
        if (activity instanceof LifecycleRegistryOwner) {
            ((LifecycleRegistryOwner) activity).getLifecycle().handleLifecycleEvent(event);
            return;
        }

        if (activity instanceof LifecycleOwner) {
            Lifecycle lifecycle = ((LifecycleOwner) activity).getLifecycle();
            if (lifecycle instanceof LifecycleRegistry) {
                ((LifecycleRegistry) lifecycle).handleLifecycleEvent(event);
            }
        }
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        dispatch(Lifecycle.Event.ON_CREATE);
    }

    @Override
    public void onStart() {
        super.onStart();
        dispatch(Lifecycle.Event.ON_START);
    }

    @Override
    public void onResume() {
        super.onResume();
        dispatch(Lifecycle.Event.ON_RESUME);
    }

    @Override
    public void onPause() {
        super.onPause();
        dispatch(Lifecycle.Event.ON_PAUSE);
    }

    @Override
    public void onStop() {
        super.onStop();
        dispatch(Lifecycle.Event.ON_STOP);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        dispatch(Lifecycle.Event.ON_DESTROY);
    }

    private void dispatch(@NonNull Lifecycle.Event event) {
        if (Build.VERSION.SDK_INT < 29) {
            dispatch(getActivity(), event);
        }
    }

    static class LifecycleCallbacks implements Application.ActivityLifecycleCallbacks {

        @Override
        public void onActivityPostCreated(@NonNull Activity activity,
                @Nullable Bundle savedInstanceState) {
            dispatch(activity, Lifecycle.Event.ON_CREATE);
        }

        @Override
        public void onActivityPostStarted(@NonNull Activity activity) {
            dispatch(activity, Lifecycle.Event.ON_START);
        }

        @Override
        public void onActivityPostResumed(@NonNull Activity activity) {
            dispatch(activity, Lifecycle.Event.ON_RESUME);
        }

        @Override
        public void onActivityPrePaused(@NonNull Activity activity) {
            dispatch(activity, Lifecycle.Event.ON_PAUSE);
        }

        @Override
        public void onActivityPreStopped(@NonNull Activity activity) {
            dispatch(activity, Lifecycle.Event.ON_STOP);
        }

        @Override
        public void onActivityPreDestroyed(@NonNull Activity activity) {
            dispatch(activity, Lifecycle.Event.ON_DESTROY);
        }
    }
}
```

`ReportFragment` 生命周期变化时调用`LifecycleRegistry.handleLifecycleEvent()` 方法通知 `LifecycleRegistry` 改变状态，`LifecycleRegistry` 内部调用 `moveToState()` 改变状态，并调用每个 `LifecycleObserver.onStateChange()` 方法通知生命周期变化。
可以看到，`SupportActivity` 添加了一个没有页面的 `ReportFragment`，在 `ReportFragment` 的生命周期函数中，调用了 `LifecycleRegistry.handleLifecycleEvent()`方法来分发生命周期事件。

这样就达到了监听 `Activity` 生命周期的目的。

#### 监听 Fragment 生命周期原理

查看androidx.fragment.app.Fragment的代码，

``` java
void performStart() {
	mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START);
}

void performResume() {
	mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
}
```

这些函数中直接调用了 `LifecycleRegistry.handleLifecycleEvent` 通知状态改变，查看是谁调用了这些方法可以看到是 `FramentManager` 的 `moveToState()` 函数

``` java
void moveToState(Fragment f, int newState, int transit, int transitionStyle, boolean keepActive)
```

`moveToState()` 函数都是调用与 `Fragment` 的各个生命周期节点。

#### 监听 Applicationn 生命周期原理
在 `lifecycle-process` 包中定义了一个 `ProcessLifecycleOwnerInitializer` 它是 `ContentProvider`，在 `AndroidManifest.xml` 中注册。

``` java
<provider
    android:name="androidx.lifecycle.ProcessLifecycleOwnerInitializer"
    android:authorities="com.jide.jetpack.lifecycle-process"
    android:exported="false"
    android:multiprocess="true" />
```

文件地址如下：

``` java
app/build/intermediates/bundle_manifest/debug/processDebugManifest/bundle-manifest/AndroidManifest.xml
```

在 `ProcessLifecycleOwnerInitializer` 中对 `LifecycleDispatcher`、`ProcessLifecycleOwner` 进行了初始化操作。

关于 `ProcessLifecycleOwner` 注释是这样介绍的：
> `ProcessLifecycleOwner` 用于监听整个应用的声明周期，生命周期调用规则如下：
> - `Lifecycle.Event.ON_CREATE` 仅被调用一次。
> - `Lifecycle.Event.ON_DESTROY` 不会被调用。
> - `Lifecycle.Event.ON_START、Lifecycle.Event.ON_RESUME` 在第一个 `Activity` 被添加时调用。
> - `Lifecycle.Event.ON_PAUSE，Lifecycle.Event.ON_STOP` 在最后一个 `Activity` 被移除时调用。

``` java
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public class ProcessLifecycleOwnerInitializer extends ContentProvider {
    @Override
    public boolean onCreate() {
        LifecycleDispatcher.init(getContext());
        ProcessLifecycleOwner.init(getContext());
        return true;
    }
}
```

`ProcessLifecycleOwner` 中的代码比较简单就不贴出来了。
