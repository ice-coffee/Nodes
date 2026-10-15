[toc]
### 关联地址
[Android CoordinatorLayout之自定义Behavior](https://www.jianshu.com/p/b987fad8fcb4)

[Material Design 之 Behavior的使用和自定义Behavior](https://www.jianshu.com/p/82d18b0d18f4)

[ViewSample](https://github.com/ice-coffee/ViewSample)

### Behavior 介绍
在上一篇文章 `View - AppBarLayout（一）使用` 中介绍了 `Behavior` 是 `CoordinatorLayout` 实现子 `View` 间交互的一种方式。通过属性 `app:layout_behavior` 设置。

示例如下：
```
<androidx.coordinatorlayout.widget.CoordinatorLayout
         xmlns:android="http://schemas.android.com/apk/res/android"
         xmlns:app="http://schemas.android.com/apk/res-auto"
         android:layout_width="match_parent"
         android:layout_height="match_parent">

     <androidx.core.widget.NestedScrollView
             android:layout_width="match_parent"
             android:layout_height="match_parent"
             app:layout_behavior="@string/appbar_scrolling_view_behavior">

         <!-- Your scrolling content -->

     </androidx.core.widget.NestedScrollView>

     <com.google.android.material.appbar.AppBarLayout
             android:layout_height="wrap_content"
             android:layout_width="match_parent">

         <androidx.appcompat.widget.Toolbar
                 ...
                 app:layout_scrollFlags="scroll|enterAlways"/>

         <com.google.android.material.tabs.TabLayout
                 ...
                 app:layout_scrollFlags="scroll|enterAlways"/>

     </com.google.android.material.appbar.AppBarLayout>

 </androidx.coordinatorlayout.widget.CoordinatorLayout>
```

根据属性 `app:layout_behavior="@string/appbar_scrolling_view_behavior"`，可以找到对应的值为`android.support.design.widget.AppBarLayout$ScrollingViewBehavior`，它指向AppBarLayout的内部类：`ScrollingViewBehavior`。查看继承关系可以看到最终继承于 `CoordinatorLayout.Behavior<V extends View>` 。

`CoordinatorLayout.Behavior<V extends View>` 是用户定义交互方式的基类，交互方式包括拖动、滑动、抛和其他手势。

首先介绍一下 `Behavior` 基类：
```
public abstract static class Behavior<V extends View> {}
```
基类声明中有一个 `泛型` ，它的作用是指定要使用这个 `Behavior` 的 `View` 的类型，可以是 `Button`、 `TextView` 等等。如果希望所有的 `View` 都可以使用则指定泛型为 `View` 即可。

下面是 `Behavior` 中一些重要和常用的方法：
```
公共参数：
/**
 * @param coordinatorLayout：coordinatorLayout		
 * @param child：Behavior 关联的 coordinatorLayout 子 View, child 类型为 Behavior 泛型指定类型
 * @param target：嵌套滑动的 coordinatorLayout 子 View
 * @param dependency：Behavior 依赖的 coordinatorLayout 子 View
 */
 
 //---------------------------------------------------------------
 
/**
 * 是否拦截触摸事件
 * @param ev 
 */
public boolean onInterceptTouchEvent(CoordinatorLayout parent, 
                V child, 
                MotionEvent ev)

/**
 * 处理触摸事件
 * @param ev 
 */
public boolean onTouchEvent(CoordinatorLayout parent,
                V child, 
                MotionEvent ev)

/**
 * 表示是否给应用了 Behavior 的 View 指定一个依赖的布局，通常，当依赖的View 布局发生变化时
 * onDependentViewChanged(CoordinatorLayout, View, View)将被调用。
 * @return 如果child 是依赖的指定的View 返回true,否则返回false
 */
public boolean layoutDependsOn(CoordinatorLayout parent, 
                V child, 
                View dependency)

/**
 * 当被依赖的View 状态（如：位置、大小）发生变化时，这个方法被调用
 * @return 如果应用此 Behavior 的 view 发生变化则返回 true，否则返回 false
 */
public boolean onDependentViewChanged(CoordinatorLayout parent, 
                V child, 
                View dependency)

/**
 * 确定使用Behavior的View位置。
 * 注意: 可能会被多次调用
 @param layoutDirection 布局解析方向，从左到右、从右到左
 */
public boolean onLayoutChild(CoordinatorLayout parent, 
                V child, 
                int layoutDirection)

/**
 * 测量使用Behavior的View尺寸。
 */
public boolean onMeasureChild(CoordinatorLayout parent, 
                V child, 
                int parentWidthMeasureSpec, 
                int widthUsed, 
                int parentHeightMeasureSpec, 
                int heightUsed)

/**
 *  当coordinatorLayout 的子View试图开始嵌套滑动的时候被调用。当返回值为true的时候表明
 *  coordinatorLayout 充当nested scroll parent 处理这次滑动，需要注意的是只有当返回值为true
 *  的时候，Behavior 才能收到后面的一些nested scroll 事件回调（如：onNestedPreScroll、onNestedScroll等）
 *  这个方法有个重要的参数nestedScrollAxes，表明处理的滑动的方向。
 * 
 * 注: 此方法的主要作用是判断是否处理某方向上的滑动操作。
 *
 * @param axes 嵌套滑动 应用的滑动方向： {@link ViewCompat#SCROLL_AXIS_HORIZONTAL}, {@link ViewCompat#SCROLL_AXIS_VERTICAL}
 */
public boolean onStartNestedScroll(CoordinatorLayout coordinatorLayout, 
                V child, 
                View directTargetChild, 
                View target, 
                int axes, 
                int type)

/**
 * 嵌套滚动发生之前被调用，嵌套滚动每次被nested scroll child更新都会调用onNestedPreScroll。用于处理滑动效果。
 * 注意有个重要的参数 consumed，可以修改这个数组表示coordinatorLayout在水平或竖直方向上消费了多少距离。
 * 假设coordinatorLayout嵌套RecyclerView,用户滑动RecyclerView手指在屏幕上位移了100px,
 * 这时把 consumed［1］的值改成90，这样coordinatorLayout就会消耗90px的滚动,而RecyclerView只会位移10px.
 *
 * @param dx  用户试图在水平方向的滚动距离
 * @param dy  用户试图在竖直方向的滚动距离
 * @param consumed consumed[0] coordinatorLayout将在水平方向上消耗的距离，consumed[1] coordinatorLayout将在竖直方向上消耗的距离
 */
public void onNestedPreScroll(CoordinatorLayout coordinatorLayout, 
                V child, 
                View target, 
                int dx, 
                int dy, 
                int[] consumed, 
                int type)

/**
 * 嵌套滚动控件(target) 进行嵌套滚动时被调用
 * @param dxConsumed target 已经消费的x方向的距离
 * @param dyConsumed target 已经消费的y方向的距离
 * @param dxUnconsumed x 方向剩下的滚动距离
 * @param dyUnconsumed y 方向剩下的滚动距离
 */
public void onNestedScroll(CoordinatorLayout coordinatorLayout, 
                V child, 
                View target, 
                int dxConsumed, 
                int dyConsumed, 
                int dxUnconsumed, 
                int dyUnconsumed, 
                int type, 
                int[] consumed)

/**
 * 嵌套滚动结束时被调用，这是一个清除滚动状态等的好时机。
 */
public void onStopNestedScroll(CoordinatorLayout coordinatorLayout, 
                V child, 
                View target, 
                int type)

/**
 * onStartNestedScroll返回true才会触发这个方法，接受滚动处理后回调，可以在这个
 * 方法里做一些准备工作，如一些状态的重置等。
 * @param nestedScrollAxes 嵌套滑动 应用的滑动方向： {@link ViewCompat#SCROLL_AXIS_HORIZONTAL}, {@link ViewCompat#SCROLL_AXIS_VERTICAL}
 */
public void onNestedScrollAccepted(CoordinatorLayout coordinatorLayout, 
                V child, 
                View directTargetChild, 
                View target, 
                int axes, 
                int type)

/**
 * 惯性运动
 *
 * @param velocityX x 方向的速度
 * @param velocityY y 方向的速度
 */
public boolean onNestedFling (CoordinatorLayout coordinatorLayout, 
                V child, 
                View target, 
                float velocityX, 
                float velocityY, 
                boolean consumed)

/**
 * 用户松开手指并且会发生惯性动作之前调用，参数提供了速度信息，可以根据这些速度信息
 * 决定最终状态，比如滚动Header，是让Header处于展开状态还是折叠状态。返回true 表
 * 示消费了fling.
 *
 * @param velocityX x 方向的速度
 * @param velocityY y 方向的速度
 */
public boolean onNestedPreFling(CoordinatorLayout coordinatorLayout, 
                V child, 
                View target, 
                float velocityX, 
                float velocityY)
```

### 自定义 Behavior
通过自定义 `Behavior` 来学习下各个方法的使用。

如果要实现如下效果要怎么做：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/appbar_custom_head_behavior.gif)

很简单：
```
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    xmlns:app="http://schemas.android.com/apk/res-auto">

    <com.google.android.material.appbar.AppBarLayout
        android:id="@+id/app_bar"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:elevation="0dp">

        <com.google.android.material.appbar.CollapsingToolbarLayout
            android:id="@+id/toolbar_layout"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            app:contentScrim="#00ffffff"
            app:layout_scrollFlags="scroll|exitUntilCollapsed">

            <ImageView
                android:layout_width="match_parent"
                android:layout_height="200dp"
                android:background="@mipmap/appbar_naruto"
                android:fitsSystemWindows="true"
                android:scaleType="fitXY" />

        </com.google.android.material.appbar.CollapsingToolbarLayout>

    </com.google.android.material.appbar.AppBarLayout>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/myList"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:layout_behavior="@string/appbar_scrolling_view_behavior" />

</androidx.coordinatorlayout.widget.CoordinatorLayout>
```
`CoordinatorLayout + ScrollView + scrolling_view_behavior` 的基本操作，都不需要额外的代码。

那如果自己来通过自定义 `behavior` 来实现这种效果怎么要怎么做呢，先写布局看下：
```
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <ImageView
        android:id="@+id/header"
        android:layout_width="match_parent"
        android:layout_height="200dp"
        android:background="@mipmap/appbar_naruto"
        android:scaleType="fitXY"
        android:gravity="center"/>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/myList"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"/>

</androidx.coordinatorlayout.widget.CoordinatorLayout>
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/appbar_custom_no_behavior.jpg)

`ImageView` 不见了，其实是被 `RecyclerView` 遮盖住了而已。在上篇中介绍了 `CoordinatorLayout` 在没有特殊处理的情况下可以看做 `FrameLayout` ，那就了解了。

那首先处理一下布局的问题，我们要实现的效果是：`RecyclerView` 在 `ImageView` 之下，并且滑动时也要保持这种关系。

可以发现这两者之间是一种位置依赖的关系，`RecyclerView` 的位置依赖于 `ImageView` 的位置。那可以首先创建 `RecyclerView` 的 `behavior` 用 `layoutDependsOn` 和 `onDependentViewChanged` 方法来处理他们之间的位置关系：

```
class RecyclerViewBehavior : CoordinatorLayout.Behavior<RecyclerView> {
    constructor() {}
    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs) {}

    override fun layoutDependsOn(parent: CoordinatorLayout, child: RecyclerView, dependency: View): Boolean {
        return dependency is ImageView
    }

    override fun onDependentViewChanged(parent: CoordinatorLayout, child: RecyclerView, dependency: View): Boolean {
        //计算列表y坐标，最小为0
        var y = dependency.height + dependency.translationY
        if (y < 0) {
            y = 0f
        }
        child.y = y
        return true
    }
}
```

要使用自定义的 `behavior` 需在 `value` 文件中声明其路径：
```
<string name="behavior_sample_two_recyclerview">com.sample.view.appbarLayout.RecyclerViewBehavior</string>
```

然年就可以通过 `layout_behavior` 使用了：
```
app:layout_behavior="@string/behavior_sample_two_recyclerview"
```

看下效果：
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/appbar_custom_rv_behavior.jpg)

有个样了，但是到这里触发滑动时顶部的 `ImageView` 并不会被顶上去。那现在就来处理下滑动，这里因为需要更新 `ImageView` 的位置，所以我们给它也加个 `behavior` 通过 `onStartNestedScroll` 和 `onNestedPreScroll` 方法处理滑动：
```
class SampleHeaderBehavior : CoordinatorLayout.Behavior<ImageView> {

    constructor() {}
    constructor(context: Context?, attrs: AttributeSet?) : super(context, attrs) {}

    override fun onStartNestedScroll(coordinatorLayout: CoordinatorLayout, child: ImageView, directTargetChild: View, target: View, axes: Int, type: Int): Boolean {
        return axes == ViewCompat.SCROLL_AXIS_VERTICAL
    }

    override fun onNestedPreScroll(coordinatorLayout: CoordinatorLayout, child: ImageView, target: View, dx: Int, dy: Int, consumed: IntArray, type: Int) {
        super.onNestedPreScroll(coordinatorLayout, child, target, dx, dy, consumed, type)
        if (target is RecyclerView) {
            val layoutManager = target.layoutManager
            if (layoutManager is LinearLayoutManager) {
                val pos = layoutManager.findFirstCompletelyVisibleItemPosition()

                if (pos == 0) {
                    var customY = 0f
                    var finalY = child.translationY - dy
                    if (finalY > -child.height && finalY < 0) {
                        customY = dy.toFloat()
                    } else if (finalY < -child.height) {
                        customY = finalY - (-child.height)
                        finalY = -child.height.toFloat()
                    } else if (finalY > 0) {
                        customY = finalY - 0
                        finalY = 0f
                    }

                    consumed[1] = customY.toInt()
                    child.translationY = finalY
                }
            }
        }
    }
}
```
如上代码所示在 `onStartNestedScroll` 方法中通过判断只处理竖直方向上的滑动事件，在 `onNestedPreScroll` 方法中处理滑动事件。可以看到代码中当 `ImageView` 未被推出布局时通过 `consumed` 参数让 `CoordinatorLayout` 来消耗滑动距离。效果如下：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/appbar_custom_head_behavior.gif)

这样看起来跟之前的就一模一样了！(实际这个和上面那个用的是一张动图，哈哈哈`^_^`)。

#### Behavior 子类
`Google` 也提供了一些特殊场景下的 `behavior`。

##### BottomSheetBehavior/BottomSheetDialog
通过BottomSheetBehavior/BottomSheetDialog实现底部弹窗，可下滑隐藏。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/bottom_sheet_behavior.gif)

BottomSheetBehavior使用如下：

```
.xml

<?xml version="1.0" encoding="utf-8"?>
<android.support.design.widget.CoordinatorLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
   <TextView
       android:id="@+id/btn_show_bottom_sheet"
       android:layout_width="wrap_content"
       android:layout_height="wrap_content"
       android:text="显示/隐藏 BottomSheet"
       android:background="@android:color/darker_gray"
       android:textColor="@color/black"
       android:padding="10dp"
       />
 <FrameLayout
     android:id="@+id/share_view"
     app:layout_behavior="@string/bottom_sheet_behavior"
     android:layout_width="match_parent"
     android:layout_height="wrap_content"
     android:background="@android:color/white"
     android:orientation="vertical"
     app:behavior_peekHeight="0dp"
     >
     <include layout="@layout/bottom_sheet_share_dialog"/>
 </FrameLayout>

</android.support.design.widget.CoordinatorLayout>

.java

//获取BottomSheetBehavior
val sheetBehavior = BottomSheetBehavior.from(shareView)
//设置折叠时的高度
//sheetBehavior.setPeekHeight(BottomSheetBehavior.PEEK_HEIGHT_AUTO);
//监听BottomSheetBehavior 状态的变化
sheetBehavior.addBottomSheetCallback(object : BottomSheetCallback() {
    override fun onStateChanged(bottomSheet: View, newState: Int) {}
    override fun onSlide(bottomSheet: View, slideOffset: Float) {}
})
//下滑的时候是否可以隐藏
sheetBehavior.isHideable = true
btn_show_bottom_sheet.setOnClickListener(View.OnClickListener {
    if (sheetBehavior.state != BottomSheetBehavior.STATE_EXPANDED) {
        sheetBehavior.setState(BottomSheetBehavior.STATE_EXPANDED)
    } else {
        sheetBehavior.setState(BottomSheetBehavior.STATE_HIDDEN)
    }
})
```

BottomSheetBehavior属性：
- app:behavior_peekHeight：底部折叠时的高度。
- app:behavior_hideable：设置底部表是否可以下滑隐藏。

BottomSheetDialog使用如下：

```
bottom_sheet_share_dialog.xml

<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="300dp">

    <TextView
        android:layout_width="match_parent"
        android:layout_height="300dp"
        android:layout_centerInParent="true"
        android:text="bottomDialog"
        android:textSize="32dp" />

</RelativeLayout>

.java

val dialog = BottomSheetDialog(context!!)
val view: View = LayoutInflater.from(context).inflate(R.layout.bottom_sheet_share_dialog, null)
dialog.setContentView(view)
dialog.setCancelable(true)
dialog.setCanceledOnTouchOutside(true)

val behavior = dialog.behavior
//下滑的时候是否可以隐藏
behavior.isHideable = true
btn_show_bottom_sheet.setOnClickListener(View.OnClickListener {
    if (dialog.isShowing) {
        dialog.hide()
    } else {
        dialog.show()
    }
})
```
##### SwipeDissmissBehavior
通过SwipeDissmissBehavior实现滑动消除功能。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/swipe_dissmiss_behavior.gif)

示例代码如下：

```
.xml

<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:id="@+id/swipLayout"
        android:layout_width="match_parent"
        android:layout_height="100dp"
        android:textColor="@android:color/black"
        android:background="@color/colorPrimary"/>

</androidx.coordinatorlayout.widget.CoordinatorLayout>

.java

val swipe = SwipeDismissBehavior<TextView>()
/**
 * 设置滑动的方向，有3个值
 *
 * 1，SWIPE_DIRECTION_ANY 表示向左像右滑动都可以，
 * 2，SWIPE_DIRECTION_START_TO_END，只能从左向右滑
 * 3，SWIPE_DIRECTION_END_TO_START，只能从右向左滑
 */
swipe.setSwipeDirection(SwipeDismissBehavior.SWIPE_DIRECTION_START_TO_END)
/**
 * 设置修改滑动组件透明度前滑动的最小距离
 */
swipe.setStartAlphaSwipeDistance(0f)
/**
 * 检测滑动开始的灵敏度
 */
swipe.setSensitivity(0.2f)
swipe.listener = object : SwipeDismissBehavior.OnDismissListener {
    override fun onDismiss(view: View) {
    }

    override fun onDragStateChanged(state: Int) {
    }
}

val layoutParams = swipLayout.layoutParams as CoordinatorLayout.LayoutParams
layoutParams.behavior = swipe
```
