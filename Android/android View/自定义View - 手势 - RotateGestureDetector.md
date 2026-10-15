[toc]

不知道什么原因 `Android` 提供了缩放手势检测 `ScaleGestureDetector` 但是没有旋转手势检测。
没有也没关系，自己来写一个好了。

### 关联地址
[处理多点触控手势](https://developer.android.com/training/gestures/multi?hl=zh-cn)

[安卓自定义View进阶-多点触控详解](https://www.gcssloop.com/customview/multi-touch)

[Github - GestureDemo](https://github.com/qiwenming/GestureDemo)

[Github - ViewSample](https://github.com/ice-coffee/ViewSample)

### 多点触控
在开始之前需要先学习一个知识点 - `如何处理多点触控`。
`多点触控` 是指多个指针（手指）同时轻触屏幕。

多点触控和单点触控都是在 `onTouchEvent(MotionEvent)` 方法中处理，如下：
```
@Override
public boolean onTouchEvent(MotionEvent event) {
    switch (event.getActionMasked()) {
        case MotionEvent.ACTION_DOWN:
            break;
        case MotionEvent.ACTION_POINTER_DOWN:
            break;
        case MotionEvent.ACTION_MOVE:
            break;
        case MotionEvent.ACTION_POINTER_UP:
            break;
        case MotionEvent.ACTION_UP:
            break;
    }
    return super.onTouchEvent(event);
}
```
和单点触控不同的是多点触控需要通过 `getActionMasked()` 来获取事件类型，`getAction()` 是无法检测到 `ACTION_POINTER` 事件的。

可以通过 `MotionEvent.actionToString()` 来打印触摸事件，当屏幕上有多个指针轻触屏幕是输出如下：
```
@Override
public boolean onTouchEvent(MotionEvent event) {
    Log.e(TAG, MotionEvent.actionToString(event.getAction()));
    return super.onTouchEvent(event);
}
```
```
ACTION_DOWN
ACTION_POINTER_DOWN(1)
ACTION_POINTER_DOWN(2)
ACTION_POINTER_UP(2)
ACTION_POINTER_UP(1)
ACTION_UP
```
使用 `getActionMasked()` 输出如下：
```
ACTION_DOWN
ACTION_POINTER_DOWN(0)
ACTION_POINTER_DOWN(0)
ACTION_POINTER_UP(0)
ACTION_POINTER_UP(0)
ACTION_UP
```
但是通过 `getActionMasked()` 无法获取事件的索引，但可以通过 `getActionIndex()` 来获取索引。

在多点触控中事件的含义和单点触控也略有不同：
* `ACTION_DOWN`：针对轻触屏幕的第一个指针。这是手势的起点。此指针的指针数据始终位于 MotionEvent 中的索引 0 处。
* `ACTION_POINTER_DOWN`：针对除第一个指针以外进入屏幕的其他指针。此指针的指针数据位于 getActionIndex() 返回的索引处。
* `ACTION_MOVE`：在执行按下手势的过程中发生了变化。
* `ACTION_POINTER_UP`：当非主要指针抬起时发送。
* `ACTION_UP`：当最后一个指针离开屏幕时发送。

可以通过每个指针的索引和 `ID` 跟踪 `MotionEvent` 中的各个指针：

* `索引`：`MotionEvent` 会有效地将关于每个指针的信息存储在数组中。指针的索引就是指针在此数组中的位置。用于与指针进行交互的大多数 `MotionEvent` 方法都使用触控点索引（而非指针 `ID`）作为参数。
* `ID`：每个指针还有一个 `ID` 映射，该映射在触摸事件之间保持不变，让您能够在整个手势中跟踪单个指针。

根据 `索引` 的介绍，指针信息是通过数组存储，指针索引就是指针在此数组中的位置，`DOWN` 相当于 `add` 添加新的指针到数组尾部，`UP` 相当于 `remove` 移除指针，其后依次向前补位。因此，不同事件中的触控点索引可能会不一样，但只要指针保持活动状态，其指针 ID 就会保持不变。可以使用 `getPointerId()` 方法获取指针的 `ID`，并在手势中的所有后续动作事件中跟踪指针。然后，对于连续动作事件，可以使用 `findPointerIndex()` 方法获取给定指针 `ID` 在相应动作事件中的触控点索引。

`Google` 推荐使用 `getActionMasked()` 来检索 `MotionEvent` 的操作，以防止多点触控可能对用户操作产生的影响。

### RotateGestureDetector
当了解了多点触控后，就知道如何去获取用户在屏幕上多个触摸点的位置了，那么通过计算多个触摸点的手势操作，不管是缩放手势还是旋转手势都可以进行处理了。
当然，缩放手势 `Android` 已经提供了 `ScaleGestureDetector` 给我们。

那么旋转手势怎么处理呢？

在开始之前还要先介绍两个很有帮助的方法：
* `View.setRotation(float rotation)`：视图中心点旋转，正值顺时针，负值逆时针。
* `Math.atan2(double y, double x)`：将矩形坐标 (x, y) 转换成极坐标 (r, theta)，返回所得角 theta。该方法通过计算 y/x 的反正切值来计算相角 theta，范围为从 -pi 到 pi。

有了这两个方法那只需要获取屏幕上两个指针的坐标那就可以让视图根据手势实现旋转了。

获取指针坐标可以通过：
* `getX(int pointerIndex)`：根据指针索引获取指针的 `X` 轴坐标。
* `getY(int pointerIndex)`：根据指针索引获取指针的 `Y` 轴坐标。

```
protected float mPrevFingerDiffX;
protected float mPrevFingerDiffY;
protected float mCurrFingerDiffX;
protected float mCurrFingerDiffY;

// Previous
final float px0 = prev.getX(0);
final float py0 = prev.getY(0);
final float px1 = prev.getX(1);
final float py1 = prev.getY(1);
final float pvx = px1 - px0;
final float pvy = py1 - py0;
mPrevFingerDiffX = pvx;
mPrevFingerDiffY = pvy;

// Current
final float cx0 = curr.getX(0);
final float cy0 = curr.getY(0);
final float cx1 = curr.getX(1);
final float cy1 = curr.getY(1);
final float cvx = cx1 - cx0;
final float cvy = cy1 - cy0;
mCurrFingerDiffX = cvx;
mCurrFingerDiffY = cvy;
```

获取坐标信息之后可以通过 `Math.atan2` 计算旋转的角度：
```
double diffRadians = Math.atan2(mPrevFingerDiffY, mPrevFingerDiffX) - Math.atan2(mCurrFingerDiffY, mCurrFingerDiffX);
double rotationDegrees = diffRadians * 180 / Math.PI;
```

拿到旋转角度之后就可以执行 `View.setRotation` 旋转视图了：
```
private float mRotationDegrees = 0.f;

mRotationDegrees = -detector.getRotationDegreesDelta()+mRotationDegrees;
mRotationDegrees = mRotationDegrees % 360;
mView.setRotation(mRotationDegrees);
```

好了大致的实现的思路就是这样了，更详细的可以去查看上面的示例代码了 `^_^`。
