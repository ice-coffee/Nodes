[toc]

### 关联地址
[ViewDragHelper 的基本使用](https://www.jianshu.com/p/a9e0a98e4d42)

[自定义控件辅助神器ViewDragHelper](https://www.jianshu.com/p/e4d1f88ca922)

[Github - DragView2Fill](https://github.com/jiang111/DragView2Fill)

[Github - ViewSample](https://github.com/ice-coffee/ViewSample)

### ViewDragHelper
`ViewdragHelper` 用于在自定义布局容器中帮助我们轻松实现子 `View` 拖动和重定位的功能。

在自定义布局容器中使用 `ViewdragHelper` 的简单步骤：
* 创建 `ViewDragHelper` 实例。
* 在 `onInterceptTouchEvent(MotionEvent)` 方法中调用 `ViewDragHelper` 实例的 `shouldInterceptTouchEvent(MotionEvent)` 方法。
* 在 `onTouchEvent(MotionEvent)` 方法中调用 `ViewDragHelper` 实例的 `processTouchEvent(MotionEvent)` 方法。

### 创建ViewdragHelper实例
`ViewDragHelper` 提供了两个 `create()` 方法来创建实例：

```
/**
 * 工厂方法创建新的 ViewDragHelper 的实例.
 *
 * @param forParent 与 ViewDragHelper 相关联的父 ViewGroup
 * @param cb 滑动和拖拽的事件的回调
 * @return 新的 ViewDragHelper 的实例
 */
public static ViewDragHelper create(ViewGroup forParent, Callback cb) {
}

/**
 * 工厂方法创建新的 ViewDragHelper 的实例.
 *
 * @param forParent 与 ViewDragHelper 相关联的父 ViewGroup
 * @param sensitivity 灵敏度，越大越灵敏，1.0f是正常值
 * @param cb 滑动和拖拽的事件的回调
 * @return 新的 ViewDragHelper 的实例
 */
public static ViewDragHelper create(ViewGroup forParent, float sensitivity, Callback cb) {
}
```

监听事件：
```
override fun onInterceptTouchEvent(ev: MotionEvent?): Boolean {
    return mDragHelper.shouldInterceptTouchEvent(ev!!)
}

override fun onTouchEvent(event: MotionEvent?): Boolean {
    mDragHelper.processTouchEvent(event!!)
    return super.onTouchEvent(event)
}
```

### ViewDragHelper.CallBack
`ViewDragHelper.CallBack` 的回调方法有 13 个这么多，下面按重要性依次讲解：

#### tryCaptureView
```
public abstract boolean tryCaptureView (View child, int pointerId)
```

对触摸 `view` 判断，如果需要当前触摸的子 `View` 进行拖拽移动就返回 `true`，否则返回 `false`。
如果已捕获的 `View` 再次被捕获扔会调用 `captureChildView` 方法。
如果此方法返回 `true` 会调用 `onViewCaptured` 方法。

此方法也是 `ViewDragHelper.CallBack` 唯一需要实现的方法。

| 参数 | 简介 |
| --- | --- |
| child | 被捕获的 View |
| pointerId | 指针ID |


#### clampViewPositionHorizontal
```
public int clampViewPositionHorizontal(@NonNull View child, int left, int dx) {
            return 0;
        }
```

限制被拖动的子视图沿水平轴的移动。默认实现不允许横向移动;
扩展类必须重写此方法并提供所需的范围控制。

| 参数 | 简介 |
| --- | --- |
| child | 拖拽的子 View |
| left | 子 View 即将到达的 X 轴坐标 |
| dx | 移动差值 |

#### clampViewPositionVertical
```
public int clampViewPositionVertical(@NonNull View child, int top, int dy) {
            return 0;
        }
```

限制被拖动的子视图沿竖直轴的移动。默认实现不允许纵向移动;
扩展类必须重写此方法并提供所需的范围控制。

| 参数 | 简介 |
| --- | --- |
| child | 拖拽的子 View |
| top | 子 View 即将到达的 Y 轴坐标 |
| dy | 移动差值 |

#### getViewHorizontalDragRange
```
public int getViewHorizontalDragRange(@NonNull View child) {
            return 0;
        }
```

返回拖拽子 `View` 在水平方向上可以被拖动的最远距离，默认为0，即子 `View` 在水平方向上不可滑动。

| 参数 | 简介 |
| --- | --- |
| child | 拖拽的子 View |

#### getViewVerticalDragRange
```
public int getViewVerticalDragRange(@NonNull View child) {
            return 0;
        }
```

返回拖拽子 `View` 在垂直方向上可以被拖动的最远距离，默认为0，即子 `View` 在垂直方向上不可滑动。

| 参数 | 简介 |
| --- | --- |
| child | 拖拽的子 View |

#### onViewReleased
```
onViewReleased(@NonNull View releasedChild, float xvel, float yvel) {}
```

当被捕获的子 `View` 被释放时调用。
在 `onViewReleased` 方法中需要调用 `ViewDragHelper.settleCapturedViewAt(int, int)` 或  `ViewDragHelper.flingCapturedView(int, int, int, int)` 让 `View` 执行一段抛出的运动。
如果调用了两个方法中的一个，那么直到 `View` 停止移动之前 `ViewDragHelper` 都是 `ViewDragHelper.STATE_SETTLING` 状态。如果两个方法都没有调用那么 `ViewDragHelper` 将进入 `ViewDragHelper.STATE_IDLE` 状态，并且 `View` 会立即停止。

| 参数 | 简介 |
| --- | --- |
| releasedChild | 被释放的 View |
| xvel | 指针离开屏幕时在 X 轴上的速度，以 `像素/秒` 为单位 |
| yvel | 指针离开屏幕时在 Y 轴上的速度，以 `像素/秒` 为单位 |

#### onViewCaptured
```
public void onViewCaptured (View capturedChild, int activePointerId)
```

当子 `View` 被捕获时此方法会被调用。

| 参数 | 简介 |
| --- | --- |
| capturedChild | 被捕获的 View |
| activePointerId | 指针ID |

#### onViewPositionChanged
```
public void onViewPositionChanged(@NonNull View changedView, int left, int top, @Px int dx, @Px int dy)
```

当捕获的 `View` 位置发生变化是回调此方法。

| 参数 | 简介 |
| --- | --- |
| changedView | 被移动的 View |
| left | View 左边缘距离父 View 左边缘的距离 |
| top | View 上边缘距离父 View 上边缘的距离 |
| dx | 距离上一次调用在 X 轴上移动的距离 |
| dy | 距离上一次调用在 Y 轴上移动的距离 |

#### onEdgeTouched
```
public void onEdgeTouched(int edgeFlags, int pointerId) {}
```

当未捕获任何子视图时，用户触摸了 `View` 的边缘时回调。

| 参数 | 简介 |
| --- | --- |
| edgeFlags | 被触摸的边缘 |
| pointerId | 指针ID |

#### onEdgeLock
```
public boolean onEdgeLock(int edgeFlags) {
    return false;
}
```
返回 `true` 则锁住当前的边界，`false` 则 `unLock`。锁定后的边缘就不会回调`onEdgeDragStarted()`。

| 参数 | 简介 |
| --- | --- |
| edgeFlags | 被触摸的边缘 |

#### onEdgeDragStarted
```
public void onEdgeDragStarted(int edgeFlags, int pointerId)
```

当未捕获子 `View` 且没有锁定边缘时触发，在此可手动调用 `captureChildView()` 触发从边缘拖动子 `View`。

| 参数 | 简介 |
| --- | --- |
| edgeFlags | 被触摸的边缘 |
| pointerId | 指针ID |

#### getOrderedChildIndex
```
public int getOrderedChildIndex(int index) {
    return index;
}
```

寻找当前触摸点View时回调此方法，如需改变遍历子view顺序可重写此方法。用户触摸子 `View` 时会对子 `View` 遍历寻找触摸的 `View`，遍历顺序是在父 `View` 中子 `View` 出现的顺序。此方法仅改变遍历顺序并不会对子 `View` 在 `Z` 轴上的位置产生影响。

| 参数 | 简介 |
| --- | --- |
| index | 子 View 在父 View 上的位置索引 |

### ViewdragHelper 常量

* `STATE_IDLE`：没有View被拖拽或在滑行；
* `STATE_DRAGGING`：有View正被跟手拖拽；
* `STATE_SETTLING`：有View正滑行到固定位置。

### ViewdragHelper API

设置允许父 `View` 的某个边缘可以用来响应托拽事件。
看源码应每次只能设置一个。

#### shouldInterceptTouchEvent
在父 `View` 的 `onInterceptTouchEvent` 方法中调用，检查是否需要拦截触摸事件。

#### processTouchEvent
在父 `View` 的 `onTouchEvent` 方法中调用，消费触摸事件。

#### captureChildView
```
public void captureChildView(@NonNull View childView, int activePointerId)
```

在父View内捕获指定的子view用于拖曳，会回调 `tryCaptureView()`。

#### smoothSlideViewTo
```
public boolean smoothSlideViewTo(@NonNull View child, int finalLeft, int finalTop)
```

某个View自动滚动到指定的位置，初速度为0，可在任何地方调用，动画移动会一直回调 `continueSettling(boolean)` 方法，直到结束。

| 参数 | 简介 |
| --- | --- |
| child | 要滑动的子 View |
| finalLeft | 子 View 最后要到达距离左侧的位置 |
| finalTop | 子 View 最后要到达距离顶部的位置 |

#### settleCapturedViewAt
```
public boolean settleCapturedViewAt(int finalLeft, int finalTop)
```

以松手前的滑动速度为初值，让捕获到的子View自动滚动到指定位置，只能在 `Callback` 的 `onViewReleased()` 中使用，其余同上。

#### flingCapturedView
```
public void flingCapturedView(int minLeft, int minTop, int maxLeft, int maxTop)
```

以松手前的滑动速度为初值，让捕获到的子View在指定范围内fling惯性运动，只能在 `Callback` 的 `onViewReleased()` 中使用，其余同上。

#### continueSettling
```
public boolean continueSettling(boolean deferCallbacks)
```
在调用 `settleCapturedViewAt()`、`flingCapturedView()` 和 `smoothSlideViewTo()` 时，该方法返回 `true`，一般重写父view的 `computeScroll` 方法，判断 `continueSettling(boolean)` 的返回值，来动态刷新界面：

```
override fun computeScroll() {
    super.computeScroll()
    if (mDragHelper.continueSettling(true)) {
        invalidate()
    }
}
```

#### abort
```
public void abort()
```

中断动画

#### setEdgeTrackingEnabled
```
public void setEdgeTrackingEnabled(int edgeFlags) {
    mTrackingEdges = edgeFlags;
}
```

### 滑动、点击事件冲突
使用倒推法，以点击事件为例，当目标 `View` 未添加任何事件，说明点击等事件未做处理，那么我们自定义的容器组件中 `onInterceptTouchEvent()` 的返回值应为 `false` 不拦截事件。当目标 `View` 添加点击事件后应对事件进行拦截，`onInterceptTouchEvent()`的返回值应为 `true`。

这时就需要 `shouldInterceptTouchEvent()` 方法的返回值为 `true`，也就是滑动状态必须为 `mDragState == STATE_DRAGGING`，如下：

在 `ViewDragHelper` 的源码中可以找到必须按如下调用才可以使得 `mDragState == STATE_DRAGGING`：

```
shouldInterceptTouchEvent -> tryCaptureViewForDrag -> captureChildView -> setDragState(STATE_DRAGGING)
```
`shouldInterceptTouchEvent` 源码如下：
```
    public boolean shouldInterceptTouchEvent(@NonNull MotionEvent ev) {
        switch (action) {
            case MotionEvent.ACTION_MOVE: {
                if (mInitialMotionX == null || mInitialMotionY == null) break;

                // First to cross a touch slop over a draggable view wins. Also report edge drags.
                final int pointerCount = ev.getPointerCount();
                for (int i = 0; i < pointerCount; i++) {
                
                    final View toCapture = findTopChildUnder((int) x, (int) y);
                    final boolean pastSlop = toCapture != null && checkTouchSlop(toCapture, dx, dy);

                    if (pastSlop && tryCaptureViewForDrag(toCapture, pointerId)) {
                        break;
                    }
                }
                saveLastMotion(ev);
                break;
            }
        }

        return mDragState == STATE_DRAGGING;
    }
```
要更新滑动状态为 `STATE_DRAGGING`，则必须调用 `tryCaptureViewForDrag()`，那么 `pastSlop` 必须为 `true`，那么来看 `pastSlop` 在什么情况下为 `true`：
1. 事件选中的View不可为空；
2. 事件发生区域在有效区域内。

再来看checkTouchSlop()如何判断滑动有效区域：
```
private boolean checkTouchSlop(View child, float dx, float dy) {
    if (child == null) {
        return false;
    }
    final boolean checkHorizontal = mCallback.getViewHorizontalDragRange(child) > 0;
    final boolean checkVertical = mCallback.getViewVerticalDragRange(child) > 0;

    if (checkHorizontal && checkVertical) {
        return dx * dx + dy * dy > mTouchSlop * mTouchSlop;
    } else if (checkHorizontal) {
        return Math.abs(dx) > mTouchSlop;
    } else if (checkVertical) {
        return Math.abs(dy) > mTouchSlop;
    }
    return false;
}
```
一目了然，`Callback.getViewHorizontalDragRange()`和`Callback.getViewVerticalDragRange()`返回值其一必须大于0。

由此可得出结论：
- 若可滑动子View未添加任何事件，则滑动正常；
- 若可滑动子View添加了事件，那么需要在Callback中重写`getViewHorizontalDragRange()`和`getViewVerticalDragRange()`设置滑动有效区域大于0。
