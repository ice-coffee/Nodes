转载自 `《深入理解 Android III》`

[TOC]

### 深入理解 WindowManager
`WindowManager` 的主要功能是提供简单的 `API` 使得使用者可以方便的将一个控件作为一个窗口添加到系统中。

`WindowManager` 继承自 `ViewManager` 接口。`ViewManager` 定义了三个函数，分别用于添加、删除和更新控件布局。

``` java
public interface ViewManager
{
    public void addView(View view, ViewGroup.LayoutParams params);
    public void updateViewLayout(View view, ViewGroup.LayoutParams params);
    public void removeView(View view);
}
```

`ViewManager` 的另一个实现者是 `ViewGroup`，可以将 `WindowManager` 与 `ViewGroup` 对比：
设想 `WindowManager` 是一个 `ViewGroup`，其区域为整个屏幕，而其中各个窗口就是一个一个的 `View`。`WindowManager` 通过 `WMS` 的帮助将这些 `View` 按照其布局参数（`LayoutParams`）显示到屏幕的特定位置。二者的核心工作是一样的，因此 `WindowManager` 和 `ViewGroup` 都集成自 `ViewManager`。

#### 获取 WindowManager
`WindowManager` 的实例可以通过如下方式获取：

``` java
Context.getSystemService(Context.WINDOW_SERVICE)
```

`getSystemService()` 在 `Cotext` 的实现类 `ContextImpl` 中的实现如下：

``` java
@Override
public Object getSystemService(String name) {
    return SystemServiceRegistry.getSystemService(this, name);
}
```

`SystemServiceRegistry` 是用以管理所有的系统服务，可通过 `ContextImpl.getSystemService(String)` 获取相应的服务。在 `SystemServiceRegistry` 的静态初始化函数中通过 `registerService()` 注册了所有的系统服务，`WINDOW_SERVICE` 服务注册如下：

``` java
static {
    ...
    registerService(Context.WINDOW_SERVICE, WindowManager.class,
            new CachedServiceFetcher<WindowManager>() {
        @Override
        public WindowManager createService(ContextImpl ctx) {
            return new WindowManagerImpl(ctx);
        }});
    ...
}
```

可见，通过 `Context.getSystemService()` 获取的 `WindowManager` 是 `WindowManagerImpl` 类的一个实例。

看一下 `WindowManagerImpl` 的构造函数：

``` java
public WindowManagerImpl(Context context) {
    this(context, null);
}

private WindowManagerImpl(Context context, Window parentWindow) {
    mContext = context;
    mParentWindow = parentWindow;
}

public WindowManagerImpl createLocalWindowManager(Window parentWindow) {
    return new WindowManagerImpl(mContext, parentWindow);
}

public WindowManagerImpl createPresentationWindowManager(Context displayContext) {
    return new WindowManagerImpl(displayContext, mParentWindow);
}
```

构造函数很简单，仅初始化了两个成员变量：

* `mContext`：通过其可获得 `Display` 对象，它代表了显示窗口的信息（大小、密度等）。
* `mParentWindow`：添加的窗口将作为那个窗口的子窗口

来看 `WindowManagerImpl.addView()` 函数：

``` java
@Override
public void addView(@NonNull View view, @NonNull ViewGroup.LayoutParams params) {
    applyDefaultToken(params);
    mGlobal.addView(view, params, mContext.getDisplay(), mParentWindow);
}
```

`WindowManagerImpl.addView()` 将实际操作委托给了 `mGlobal` 只读变量来完成：

``` java
private final WindowManagerGlobal mGlobal = WindowManagerGlobal.getInstance();
```

可见 `mGlobal` 的类型是 `WindowManagerGlobal`，并且 `WindowManagerGlobal` 是一个单例模式，即一个 `进程` 中最多仅有一个 `WindowManagerGlobal` 实例。`WindowManagerImpl` 中所有的操作都交由 `WindowManagerGlobal` 的实例代理。

此时，便对 `WindowManager` 的体系结构有了一个清晰的认识。

#### WindowManager 体系

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/windowmanager.jpg)

* `ViewManager` 接口：`WindowManager` 体系中最基本的接口。`WindowManager` 继承自这个接口同时 `ViewGroup` 实现了这个接口这说明了 `WindowManager` 与 `ViewGroup` 本质上的一致性。
* `WindowManager`：接口：`WindowManager` 接口继承自 `ViewManager` 的同时，根据窗口的一些特殊性增加了两个新的接口。`getDefaultDisplay()` 用以得知这个 `WindowManager` 的实例会将窗口添加到哪个屏幕上（屏幕信息：大小、密度等）。而 `removeViewImmediate()` 则要求 `WindowManager` 必须在这个回调返回之前完成所有销毁工作。
* `WindowManagerImpl` 类：`WindowManager` 接口的实现者。它自身没有什么实际的实现逻辑，`WindowManager` 所定义的接口都是交由 `WindowManagerGlobal` 完成的。但是它保存了两个重要的只读成员：`mDisPlay`、`mParentWindow`，他们分别指明了通过这个 `WindowManagerImpl` 实例所管理的窗口将被显示在那个屏幕上，以及将会作为你那个窗口的子窗口。（在最新的版本 `mDisPlay` 通过 `ContextImpl` 获取）。
* `WindowManagerGlobal` 类：它没有继承上述任何一个接口，但它是 `WindowManager` 的最终实现者。它维护了当前进程中所有已经添加到系统中的窗口的信息。另外，在一个进程中仅有一个 `WindowManagerGlobal` 的实例。

#### WindowManagerGlobal 添加窗口
`WindowManagerGlobal` 添加窗口代码如下：

``` java
public void addView(View view, ViewGroup.LayoutParams params,
        Display display, Window parentWindow) {
    
    // 1. 如果当前窗口需要被添加为另一个窗口的附属窗口（子窗口），则需要让父窗口视自己的情况对当前窗口的布局参数（LayoutParams）进行一些修改。
    final WindowManager.LayoutParams wparams = (WindowManager.LayoutParams) params;
    if (parentWindow != null) {
        parentWindow.adjustLayoutParamsForSubWindow(wparams);
    }

    ViewRootImpl root;
    View panelParentView = null;

    synchronized (mLock) {
        
        // WindowManager 不予许同一个 View 被添加两次
        int index = findViewLocked(view, false);
        if (index >= 0) {
            if (mDyingViews.contains(view)) {
                // Don't wait for MSG_DIE to make it's way through root's queue.
                mRoots.get(index).doDie();
            } else {
                throw new IllegalStateException("View " + view
                        + " has already been added to the window manager.");
            }
            // The previous removeView() had not completed executing. Now it has.
        }

        // 2. 创建一个 ViewRootImpl 对象并保存在 root 变量中
        root = new ViewRootImpl(view.getContext(), display);

        view.setLayoutParams(wparams);

        // 3. 将作为窗口的控件、布局参数、以及新建的 ViewRootImpl 以相同的索引值保存在三个数组中。到这步为止，我们可以认为完成了窗口信息的添加工作。
        mViews.add(view);
        mRoots.add(root);
        mParams.add(wparams);

        try {
            // 4. 将作为窗口的控件设置给 ViewRootImpl。这个动作将导致 ViewRootImpl 向 WMS 添加新的窗口、申请 Surface 以及托管控件在 Surface 上的重绘动作。这才是真正意义上完成了窗口的添加操作。
            root.setView(view, wparams, panelParentView);
        } catch (RuntimeException e) {
        }
    }
}
```

* 父窗口修改新窗口的布局参数。可能修改的只有 `LayoutParams.token` 和 `LayoutParams.mTitle` 两个属性。每一个新窗口必须通过 `LayoutParams.token` 向 `WMS` 出示相应的令牌才可以。开发者不需要关心 `token` 到底应该被设置为什么值，只须将 `LayoutParams` 丢给一个 `WindowManager`，剩下的事情就不用再关心了。
* 为新窗口创建一个 `ViewRootImpl` 对象。顾名思义，`ViewRootImpl` 实现了一个控件树的根。它负责与 `WMS` 直接通信，负责管理 `Surface`，负责触发控件的测量与布局，负责触发控件的绘制，同时也是输入事件的中转站。总之，`ViewRootImpl` 是整个控件系统正常运转的动力所在，无疑是本章最关键的一个组件。
* 将控件、布局参数以及新建的 `ViewRootImpl` 以相同的索引值添加到三个对应的数组 `mViews`、`mParams`、`mRoots`中，以供之后的查询之需。控件、布局参数以及 `ViewRootImpl` 三者共同组成了客户端的一个窗口。或者说，在控件系统中的窗口就是控件、布局参数与 `ViewRootImpl` 对象的一个三元组。
* 调用 `ViewRootImpl.setView` 函数，将控件交给 `ViewRootImpl` 进行托管。这个动作将使得 `ViewRootImpl` 向 `WMS` 添加窗口、获取 `Surface` 以及重绘等一系列操作。这一个是控件能够作为一个窗口显示在屏幕上的根本原因！

> 这里作者认为使用数组的方式保存窗口信息，并不合理，因为会伴随有扩容操作产生额外开销。
> 个人感觉在应用的生命周期中基本不会添加太多的窗口，而且查找操作更加频繁，所以这里数组也就可以理解了。

#### 更新窗口布局
当窗口发生变化时，如 `LayoutParams.width` 从 `100 ~ 200`，则需要将这个变化通知给 `WMS` 使其调整 `Surface` 的大小，并让窗口进行重绘。这个工作在 `WindowManagerGlobal.updateViewLayout()` 函数中完成。

``` java
public void updateViewLayout(View view, ViewGroup.LayoutParams params) {

    final WindowManager.LayoutParams wparams = (WindowManager.LayoutParams)params;

    // 将布局保存到控件中
    view.setLayoutParams(wparams);

    synchronized (mLock) {
        // 更新 params
        int index = findViewLocked(view, true);
        ViewRootImpl root = mRoots.get(index);
        mParams.remove(index);
        mParams.add(index, wparams);
        // 调用 ViewRootImpl.setLayoutParams() 使新布局生效
        root.setLayoutParams(wparams, false);
    }
}
```

窗口更新布局的操作很简单。

#### 删除窗口
在了解了 `WindowManagerGlobal` 管理窗口的方式后应该可以很容易地推断出删除窗口所需要做的工作：

* 从三个数组中删除此窗口所对应的元素，包括控件、布局参数以及 `ViewRootImpl`。
* 要求 `ViewRootImpl` 从 `WMS` 中删除对应的窗口（`IWindow`），并释放一切需要回收的资源。

这里就不贴代码了。只说明一点：要求 `ViewRootImpl` 从 `WMS` 中删除窗口并释放资源的方法是调用 `ViewRootImpl.die()` 函数。因此可以得出结论：`ViewRootImpl` 的生命周期从 `setView()` 开始，到 `die()` 结束。

#### 总结

* 鉴于窗口布局和控件布局的一致性，`WindowManager` 继承并实现了接口 `ViewManager`。
* 使用者可以通过 `Context.getSystemService(Context.WINDOW_SERVICE)` 来获取一个 `WindowManager` 的实例。这个实例的真实类型是 `WindowManagerImpl`。`WindowManagerImpl` 一旦被创建就确定了通过它所创建的窗口所属屏幕属性、那个父窗口。
* `WindowManagerImpl` 除了保存窗口所属屏幕属性以及父窗口以外，没有任何实质性的工作。窗口管理都交由 `WindowManagerGlobal` 的实例完成。
* `WindowManagerGlobal` 在一个进程中只有一个实例。
* `WindowManagerGlobal` 在三个数组中统一管理整个进程中所有窗口的信息。这些信息包括控件、布局参数以及 `ViewRootImpl` 三个元素。
* 除了管理窗口的上述三个元素外，`WindowManagerGlobal` 将窗口的创建、销毁与布局更新等任务交给 `ViewRootImpl` 完成。

### 我的总结
`WindowManagerImpl` 使用了 `单例模式`，并添加了 `类锁`。

这里可以有扩展 `跨进程单例模式` 和 `类锁、对象锁`。

[支持跨进程单例的一种实现方案](https://cloud.tencent.com/developer/article/1032274)

`WindowManager.LayoutParmas.gravity` 属性。
