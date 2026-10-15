ViewConfiguration中包含用于UI中超时、大小和距离的标准常量的方法。

- `getDoubleTapTimeout`: 第一次互动的两次点击之间的持续时间（以毫秒为单位）；
- `getLongPressTimeout`：按下变成长按之前的持续时间（以毫秒为单位）；
- `getMaximumDrawingCacheSize`：View的绘图缓存的最大大小（以字节为单位）；
- `getScaledDoubleTapSlop`：第一次触摸和第二次触摸之间的像素距离仍被视为双击；
- `getScaledMaximumDrawingCacheSize`：View的绘图缓存的最大大小（以字节为单位）；
- `getScaledPagingTouchSlop`：在我们认为用户滚动整页之前，触摸可能会漂移的距离（以像素为单位）；
- `getScaledScrollBarSize`：水平滚动条的宽度和垂直滚动条的高度（以像素为单位）；
- `getScaledTouchSlop`：在我们认为用户正在滚动之前，触摸可以漂移的像素距离；
- `getScaledEdgeSlop`：获得一个触摸移动的最小像素值。也就是说，只有超过了这个值，才代表我们该滑屏处理；
- `getScaledMaximumFlingVelocity`：用户滑动时的最大速度，单位是每秒多少像素；
- `getScaledMinimumFlingVelocity`：用户滑动时的最小速度；
- `getTapTimeout`：持续时间（以毫秒为单位），我们将等待以查看触摸事件是轻击还是滚动。如果用户未在此间隔内移动，则将其视为轻拍；
- `getTouchSlop`：在我们认为用户正在滚动之前，触摸的距离可能会漂移；
