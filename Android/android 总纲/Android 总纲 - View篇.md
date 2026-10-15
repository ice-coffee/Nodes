### Android中的动画有哪些，区别是什么
1. 逐帧动画(Drawable Animation)： 加载一系列Drawable资源来创建动画，简单来说就是播放一系列的图片来实现动画效果，可以自定义每张图片的持续时间

2. 补间动画(Tween Animation)： Tween可以对View对象实现一系列简单的动画效果，比如位移，缩放，旋转，透明度等等。但是它并不会改变View属性的值，只是改变了View的绘制的位置，比如，一个按钮在动画过后，不在原来的位置，但是触发点击事件的仍然是原来的坐标。

3. 属性动画(Property Animation)： Android property animation 只有在Android 3.0(API 11)以上版本可用，不过好在已经有开源大神帮我们解决这个问题了。这个项目就是NineOldAndroids

### Scrollview怎么判断是否滑倒底部
### ViewPager 的怎么做性能优化
- setOffscreenPageLimit-防止fragment频繁销毁
- fragment精简布局
- 懒加载

### View 事件分发中 
- dispatchTouchEvent、interceptTouchEvent、onTouchEvent、onTouch、onClick的关系
- 自定义处理触摸事件时坐标相关

### 不使用动画，怎么实现一个动态的 View？
### 如何自定义ViewGroup？
### View的绘制流程
1. onMeasure() 为整个View树计算实际的大小，widthMeasureSpec、heightMeasureSpec，specSize、specMode，specMode类型

2. onLayout() 为将整个根据子视图的大小以及布局参数将View树放到合适的位置上。自定义ViewGroup必须重写此方法，比如LinearLayout

3. onDraw() 开始绘制图像，绘制的流程如下
- 首先绘制该View的背景
- 调用onDraw()方法绘制视图本身 (每个View都需要重载该方法，ViewGroup不需要实现该方法)
- 如果该View是ViewGroup，调用dispatchDraw ()方法绘制子视图
- 绘制滚动条

### 屏幕适配
[mipmap和drawable的区别](https://www.jianshu.com/p/ecf007710fae)
px：像素
分辨率
屏幕尺寸
dpi：像素密度，单位尺寸内包含的像素数。
像素密度 = 像素 / 尺寸 （dpi = px / in）
dp/dip：Android独有的尺寸，与像素密度相关。
density：密度，Android中用于dp与px的换算。
density = px / dp

### Android RecyclerView

#### 预取
预取就是在滑动过程中预先获取下一个将要展示到屏幕上的 `ViewHolder`。

`GapWorker`：实现预取功能的相关类。`GapWorker` 是 `Runnable` 的子类，在 `RecyclerView.post()` 时执行，`GapWorker` 通过 `ThreadLocal` 和 `Thread` 绑定。

`GapWorker` 会对可见的 `RecyclerView` 执行预取，并对每个预取任务设置优先级。滑动后立刻显示到屏幕上的任务优先级高。

预取是 `RecyclerView` 优化滑动效果的一种方式。

#### 缓存原理
`RecyclerView` 是 `三级缓存` 但有 `四种缓存方式`，分如下两种情况：

- 滑动：执行 `mCachedViews + RecycledViewPool` 的二级缓存方案，以优化滑动
- 重布局： 执行 `(mAttachedScrap + mChangedScrap) + mCachedViews + RecycledViewPool` 的三级缓存方案，以优化重布局过程。

`RecycledViewPool` 会根据 `ViewType` 进行存取，默认每种 `ViewType` 存储5条。

`mViewCacheExtension` 可由用户自定义缓存逻辑，但我认为基本用不到。因为在 `RecyclerView` 的缓存逻辑中并没有相关存储 `ViewHolder` 到 `mViewCacheExtension` 的逻辑。

#### 预布局、LayoutManager
预布局是 `RecyclerView` 为了执行 `Item` 动画而执行的操作。执行预布局的充要条件是：

- 第一次布局完毕；
- 设置了 `ItemAnimator`，默认已设置。

`RecyclerView` 整个布局分为三步：

- 1. 执行预布局，得到当前显示在屏幕上所有 `ViewHolder` 的位置信息。
- 2. 再次执行布局，得到 `ItemAnimator` 结束后，要显示在屏幕上所有 `ViewHolder` 的位置信息。
- 3. 执行 `ItemAnimator`，清理资源。

#### ItemDecoration

#### 局部刷新

#### getLayoutPosition()、getAdapterPosition()
大部分情况下这两者获取到的结果是一致的。但是当 `RecyclerView` 调用了 `notifyItem***()` 方法之后，在重新布局之前可能会出现不一致的问题。

- `getAdapterPosition()` 通过获取当前 `position` 的值，并根据要执行的 `add、remove` 等操作判断最终结果。
- `getLayoutPosition()` 方法只有在布局开始时才会更新。

#### 性能优化
- 优化布局;
- 局部刷新；
- 使用 `DiffUtil` 替代无脑调用 `notifyDataSetChanged()`;
- 如果不需要动画，可以关闭动画以提高效率;
- 如果 `Item` 高度是固定的话，可以设置 `RecyclerView.setHasFixedSize(true)`。当执行 `ItemAnimator` 时可以不用重新测量和布局;
- 通过 `RecycleView.setViewCacheSize(size)` 来加大 `RecyclerView` 的缓存，用空间换时间来提高滚动的流畅性;
- 相同数据的 `RecyclerView` 共用缓存池;
- 设置 `RecyclerView.addOnScrollListener(listener)` 来对快速滑动过程中停止加载的操作;
- 对 `ItemView` 设置监听器，不要对每个 `Item` 都调用 `addXxListener`，应该大家公用一个 `XxListener`，根据 `ID` 来进行不同的操作，优化了对象的频繁创建带来的资源消耗。
