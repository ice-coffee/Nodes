[toc]

`ViewRootImpl` 有如下功能y`ViewRootImpl` 有如下功能：

* 一方面， `ViewRootImpl` 实现了 `ViewParent` 接口，作为整个控件树的根部，它是控件树正常运作的动力所在。`ViewRootImpl` 提供了控件的测量、布局、绘制以及输入事件的配发处理的功能。
* 另一方面，它是 `WindowManagerGlobal` 工作的实际实现者，因此它还需要负责与 `WMS` 交互通信以调整窗口的位置大小，以及对来自 `WMS` 的事件（如窗口尺寸改变等）做出相应的处理。

#### ViewRootImpl 的创建及其重要成员
`ViewRootImpl` 创建于 `WindowManagerGlobal` 的 `addView()` 方法中你那个，而调用 `addView()` 方法的线程就是此 `ViewRootImpl` 所掌控的控件树的 `UI` 线程。`ViewRootImpl` 的构造函数主要初始化了一些重要成员，如下：

``` java
public ViewRootImpl(Context context, Display display) {
    mContext = context;
    // 1
    mWindowSession = WindowManagerGlobal.getWindowSession();
    // 2
    mDisplay = display;
    mBasePackageName = context.getBasePackageName();
    // 3 
    mThread = Thread.currentThread();
    ......
    // 4 
    mDirty = new Rect();
    mTempRect = new Rect();
    mVisRect = new Rect();

    // 5
    mWinFrame = new Rect();

    // 6
    mWindow = new W(this);
    
    ......

    // 7
    mAttachInfo = new View.AttachInfo(mWindowSession, mWindow, display, this, mHandler, this, context);
    
    // 8
    mFallbackEventHandler = new PhoneFallbackEventHandler(context);

    // 9
    mChoreographer = Choreographer.getInstance();
    
    ......
}
```

1. 从 `WindowManagerGlobal` 中获取的一个 `IWindowSession` 的实例。它是 `ViewRootImpl` 和 `WMS` 进行通信的代理。
2. 保持参数 `mDisplay`，在后面 `setView()` 调用中将会把窗口添加到这个 `Diaplay` 上。
3. 保持当前线程到 `mThread`，这个赋值操作体现了创建 `ViewRootImpl` 的线程如何成为 `UI` 线程。这个 `UI` 线程就是 `ActivityThread` 运行的线程。
4. `mDirty` 用于收集窗口的无效区域。所谓无效区域是指由于数据或状态发生改变时而需要进行重绘的区域。举例说明，当应用程序修改了一个 `TextView` 的文字时，`TextView` 会将自己的区域标记为无效区域，并通过 `view.invalidate()` 方法将这块区域添加到这里的 `mDirty` 中。当下次绘制时，`TextView` 便可以将新的文字绘制在这块区域上。
5. `mWinFrame` 描述了当前窗口的位置和尺寸。与 `WMS` 中的 `WindowState.mFrame` 保持一致。
6. 创建一个 `W` 类型的实例，`W` 是 `IWindow.Stub` 的子类。即它将在 `WMS` 中作为新窗口的 `ID`，并接收来自 `WMS` 的回调。
7. 创建 `mAttachInfo`。`mAttachInfo` 是控件系统中很重要的对象。它存储了当前控件树所贴附的窗口的各种有用信息，并且会派发给控件树中的每一个控件。这些控件会将这个对象保存在自己的 `mAttachInfo` 变量中。`mAttachInfo` 中所保存的信息有 `WindowSession`、窗口的实例（即 `mWindow`）、`ViewRootImpl` 实例、窗口所属的 `Display`、窗口的 `Surface` 以及窗口在屏幕上的位置等。所以，当需要在一个 `View` 中查询与当前窗口相关的信息时，非常值得在 `mAttachInfo` 中搜索一下。
8. 创建 `FallbackEventHandler`。这个类同 `PhoneWindowManager` 一样，定义在 `android.policy` 包中，其实现为 `PhoneFallbackEventHandler`。`FallbackEventHandler` 是一个处理未经任何人消费的输入事件的场所。
9. 创建一个依附于当前线程，即主线程的 `Choreographer`，用于通过 `VSYNC` 特性安排重绘行为。

在构造函数之外，还有另外两个重要的成员被直接初始化：

1. `mHandler`：类型为 `ViewRootHandler`。一个依附于创建 `ViewRootImpl` 的线程，即主线程上的，用于将某些必须在主线程进行的操作调度主线程中执行。`mHandler` 与 `mChoreographer` 同时存在看似有些重复，其实它们拥有明确不同的分工与意义。由于 `mChoreographer` 处理消息时具有 `VSYNC` 特性，因此它主要用于处理与重绘相关的操作。但是由于 `mChoreographer` 需要等待 `VSYNC` 的垂直同步事件来触发对下一条消息的处理，因此它处理消息的即时性稍逊与 `mHandler`。
2. `mSurface`：类型为 `Surface`。采用无参构造函数创建的一个 `Surface` 实例。`mSurface` 此时是一个没有任何内容的空壳子，在 `WMS` 通过 `relayoutWindow()` 为其分配一块 `Surface` 之前尚不能使用。
3. `mWinFrame`、`mPendingContentInset`、`mPendingVisibleInset`：这几个成员存储了窗口布局相关的信息。其中 `mWinFrame`、`mPendingContentInset`、`mPendingVisibleInset` 与窗口在 `WMS` 中的 `Frame`、`ContentInsets`、`VisibleInsets` 是保持同步的。这是因为这三个成员不仅会作为 `relayoutWindow()` 的传出参数，而且 `ViewRootImpl` 在收到来自 `WMS` 的回调 `IWindow.Stub.resize()` 时，立即更新这三个成员的取值。因此这三个成员体现了窗口在 `WMS` 中的最新状态。

#### performTraversals()

* mAppVisibilityChanged：用于单独跟踪应用的可见性更新，以防我们得到双倍的变化。这将确保我们总是为相应的窗口调用relayout。

`performTraversals()` 方法可以分为如下几个阶段：

* `预测量阶段`：这是进入 `performTraversals()` 方法后的第一个阶段，它会对控件树进行第一次测量。测量结果可以通过 `mView.getMeasureWidth()/Height()` 获得。在此阶段中将会计算出控件树为显示其内容所需的尺寸，即期望的窗口尺寸。在这个阶段中，`View` 及其子类的 `onMeasure()` 方法将会沿着控件树依次得到回调。
* `布局窗口阶段`：根据预测量的结果，通过 `IWindowSession.relayout()` 方法向 `WMS` 请求调整窗口的尺寸等属性，这将引发 `WMS` 对窗口进行重新布局，并将布局结果返回给 `ViewRootImpl`。
* `最终测量阶段`：预测量结果是控件树所期望的窗口尺寸。然而由于在 `WMS` 中影响窗口布局的因素很多，`WMS` 不一定会将窗口准确地布局为控件树所要求的尺寸，而迫于 `WMS` 作为系统服务的强势地位，控件树不得不接受 `WMS` 的布局结果。因此在这个阶段，`performTraversals()` 将以窗口的实际尺寸对控件进行最终测量。在这个阶段中，`View` 及其子类的 `onMeasure()` 方法将会沿着控件树依次被回调。
* `布局控件树阶段`：完成最终测量之后便可以对控件树进行布局。测量确定的是控件的尺寸，而布局则是确定控件的位置。在这个阶段中，`View` 及其子类的 `onLayout()` 方法将会被回调。
* `绘制阶段`：这是 `performTraversals()` 的最终阶段。确定控件的位置和尺寸后，便可以对控件树进行绘制。在这个阶段中，`View` 及其子类的 `onDraw()` 方法将被调用。

> `performTraversals()` 过程中除了控件的 `测量`、`布局`、`绘制` 三个阶段外，还有控件树对窗口尺寸的期望、`WMS` 对窗口尺寸做出最终的确定、最后控件树以 `WMS` 给出的结果为准再次进行测量的协商过程。这个协商过程充分提现了 `ViewRootImpl` 作为 `WMS` 与控件树的中间人的角色。

##### 预测量和测量原理
###### 测量参数
预测量和最终测量的区别仅在于参数不同而已。实际的测量工作在 `View` 或其子类的 `onMeasure()` 方法中完成，并且其测量结果需要受限于其父控件的指示。这个指示由 `onMeasure()` 方法的两个参数传达：`widthSpec`、`heightSpec`。它们是被称为 `MeasureSpec` 的复合型整形变量，用于指导控件对自身进行测量。它有两个分量，结构如下：

![Image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/deap_android_viewrootimpl_spec.jpg)

其 `1 ~ 30` 位给出了父控件建议尺寸。建议尺寸对测量结果的影响依 `SPEC_MODE` 的不同而不同。`SPECE_MODE` 可取值如下：

* `MeasureSpec.UNSPECIFIED`：表示控件在进行测量时，可以无视 `SPEC_SIZE` 的值。控件可以是它所期望的任意尺寸。
* `MeasureSpec.EXACTLY`：表示子控件必须为 `SPEC_SIZE` 所指定的尺寸。当控件的 `LayoutParams.width/height` 为一确定值，或者是 `MATCH_PARENT` 时，对应的 `MeasureSpec` 参数会使用这个 `SPEC_MODE`。
* `MeasureSpec.AT_MOST`：表示子控件可以是它所期望的尺寸，但是不得大于 `SPEC_SIZE`。当控件的 `LayoutParams.width/height` 为 `WRAP_CONETENT` 时，对应的 `MeasureSpec` 参数会使用这个 `SPEC_MODE`。

###### 测量协商
预测量在 `measureHierarchy()` 方法中执行。在预测量过程中，若窗口的 `width` 或 `height` 被指定为 `WRAP_CONTENT`，表示这是一个悬浮窗口。这时为了不出现如下丑陋的窗口会进行测量协商。

![Image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/deap_android_viewrootimpl_ugly.jpg)

显然，对于非悬浮窗口，即当 `LayoutParams.width` 被设置为 `MATCH_PARENT` 时，不存在协商过程，直接使用给定的 `desiredWindowWidth/Height` 进行测量即可。而对于悬浮窗口 `measureHierarchy` 可以最多连续进行两次让步。在最不利的情况下，在 `ViewRootImpl` 的一次遍历中，控件树需要进行三次测量，即控件树中的每一个 `View.onMeasure()` 会被连续调用三次之多。所以相对于 `onLayout()`，`onMeasure()` 方法对性能的影响比较大。如下：

![Image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/deap_android_viewrootimpl_measure_hierarchy.jpg)

##### performTraversals() 方法总结
本节通过将 `performTraversals()` 方法拆分为五个阶段进行详细介绍。阶段关系如下：

![Image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/deap_android_viewrootimpl_performTraversals.jpg)

可见，前四个阶段以 `layoutRequested` 为执行条件，即在 `遍历` 之前调用了 `requestLayout()` 方法。这是由于前四个阶段的主要工作目的是确定控件的位置和尺寸。因此，仅当一个或多个控件有改变位置或尺寸的需求时（此时会调用 `requestLayout()`）才有执行的必要。

即使 `requestLayout()` 未被调用过，绘制阶段也会被执行。因为很多时候需要在不改变控件尺寸和位置的的情况下进行重绘，例如某个控件改变了其文字颜色或背景色。与 `requestLayout()` 方法相对，这种情况发生在控件调用了 `invalidate()` 方法的时候。

> 注意：即使 `requestLayout()` 没有被调用过，有可能由于 `LayoutParams`、`mView` 的可见性等与窗口有关的属性发生变化时，“遍历” 流程仍会进入第二阶段。由于这些属性与布局没有直接联系，因此上图并没有体现这一点。

#### invalidate 调用过程
``` java
View.class
View.invalidate();
-->View.invalidate(boolean invalidateCache)
-->View.invalidateInternal(int l, int t, int r, int b, boolean invalidateCache,boolean fullInvalidate)
    -->mPrivateFlags |= PFLAG_DIRTY;
    -->ViewParent.invalidateChild(View child, Rect r)

ViewGroup.class
invalidateChild(View child, Rect r)
-->如果启动了硬件加速 
    -->循环调用直到 ViewRootImpl.onDescendantInvalidated(View child, View target)
            ViewRootImpl.invalidate() 全局绘制
-->如果未启动硬件加速，一直循环到调用 ViewRootImpl.invalidateChildInParent()
    -->do {
         parent = ViewParent.invalidateChildInParent(int[] location, Rect r)
       } while (parent != null)

ViewRootImpl.class
invalidateChildInParent(int[] location, Rect dirty)
-->如果 dirty == null 
    -->调用 invalidate() 全局绘制
-->否则
    -->invalidateRectOnScreen(Rect dirty) 布局绘制
        -->更新 mDirty
        -->scheduleTraversals()
```

#### ViewRootImpl 总结
本节主要介绍了 `ViewRootImpl` 的创建，以及核心 `performTraversals()` 方法的实现原理。读者从中可以对 `ViewRootImpl` 架构与工作方式有深入理解。作为整个控件树管理者，`ViewRootImpl` 十分复杂与庞大，不过其很多工作都会落在本节所介绍的 `5` 个阶段中完成，所以深入理解这 `5` 个阶段的实现可以为学习 `ViewRootImpl` 的其他工作打下坚实的基础。在本章后面的内容中将介绍控件树的绘制与输入事件派发两个方面的内容，那时会重新回到 `ViewRootImpl`，探讨那些位于 `5` 个阶段之外的工作。

`ViewRootImpl` 是根视图 `DecorView` 的 `mParent`，任何一个控件都可以通过回溯 `getParent` 的方法得到。

### 我的总结
* 获取 `Display`。
``` java
val size = Point()
windowManager.defaultDisplay.getRealSize(size)
Log.e("screenwh", "${size.x}, ${size.y}")
```
这种方式可以获取屏幕的分辨率（屏幕上会亮的区域）。

[Android完美获取状态栏高度、标题栏高度、编辑区域高度的获取](https://blog.csdn.net/qq_27489007/article/details/89247230)

* `View.post()` 分析。
* `Java` 内存结构。
* 为什么 `RelativeLayout` 比 `LinearLayout` 性能差。
* Application.startActivity 和 Activity.startActivity 有什么区别（在浮窗点击跳转页面时未添加 `NEW_TASK` 报错）。
* clipChild
