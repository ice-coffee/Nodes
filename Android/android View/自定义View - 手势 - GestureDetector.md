[toc]
### 关联地址
[安卓自定义View进阶-MotionEvent详解](https://www.gcssloop.com/customview/motionevent)
ACTION_CANCEL：的含义。
gestureDetector.onTouchEvent(event)：返回值的含义。

[安卓自定义View进阶-多点触控详解](https://www.gcssloop.com/customview/multi-touch)

[安卓自定义View进阶-手势检测\(GestureDetector\)](https://www.gcssloop.com/customview/gestruedector)

[安卓自定义View进阶-缩放手势检测\(ScaleGestureDecetor\)](https://www.gcssloop.com/customview/scalegesturedetector)

### GestureDetector
`GestureDetector` 使用提供的 `MotionEvents` 检测各种手势和事件。当一个特定的事件发生时，`OnGestureListener` 回调将通知用户。

`GestureDetector` 的使用：
* 创建 `GestureDetector` 实例。
* 在 `onTouchEvent(MotionEvent)` 方法中调用 `GestureDetector` 实例的 `onTouchEvent(MotionEvent)` 方法。
* 如果侦听 `onContextClick()`，则必须在 `onGenericMotionEvent(MotionEvent)` 中调用 `GestureDetector` 实例的 `OnGenericMotionEvent(MotionEvent)` 方法。

示例如下：
```
//创建回调监听
private GestureDetector.SimpleOnGestureListener mSimpleOnGestureListener = new GestureDetector.SimpleOnGestureListener(){
    @Override
    public boolean onDoubleTap(MotionEvent e) {
        return super.onDoubleTap(e);
    }
};

//创建 GestureDetector 实例
GestureDetector mGestureDetector = new GestureDetector(this, mSimpleOnGestureListener);

//监听事件
@Override
public boolean onTouchEvent(MotionEvent event) {
    mGestureDetector.onTouchEvent(event);
    return super.onTouchEvent(event);
}
```

#### 创建 GestureDetector 实例
`GestureDetector` 的构造方法有两种：

```
/**
 * 创建 GestureDetector 实例, 但只能在 Looper 启动的线程中使用
 */
public GestureDetector(Context context, OnGestureListener listener)

/**
 * 创建 GestureDetector 实例, 通过 handler 参数处理事件消息
 */
public GestureDetector(Context context, OnGestureListener listener, Handler handler) 
```

两种构造方法的区别就是多了一个 `Handler` 参数。来看源码

```
public GestureDetector(Context context, OnGestureListener listener, Handler handler) {
    if (handler != null) {
        mHandler = new GestureHandler(handler);
    } else {
        mHandler = new GestureHandler();
    }
}
```

传入的 `Handler` 参数创建了 `GestureHandler` 对象。

```
private class GestureHandler extends Handler {
        GestureHandler() {
            super();
        }

        GestureHandler(Handler handler) {
            super(handler.getLooper());
        }

        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case SHOW_PRESS:
                    mListener.onShowPress(mCurrentDownEvent);
                    break;

                case LONG_PRESS:
                    recordGestureClassification(msg.arg1);
                    dispatchLongPress();
                    break;

                case TAP:
                    // If the user's finger is still down, do not count it as a tap
                    if (mDoubleTapListener != null) {
                        if (!mStillDown) {
                            recordGestureClassification(
                                    TOUCH_GESTURE_CLASSIFIED__CLASSIFICATION__SINGLE_TAP);
                            mDoubleTapListener.onSingleTapConfirmed(mCurrentDownEvent);
                        } else {
                            mDeferConfirmSingleTap = true;
                        }
                    }
                    break;

                default:
                    throw new RuntimeException("Unknown message " + msg); //never
            }
        }
    }
```
`GestureHandler` 是 `Handler` 的子类，源码也很简单，如果传入了 `Handler` 参数则使用 `Handler` 中的 `Looper` 来循环事件。那么如果在子线程中就必须使用第二种方式创建 `GestureDetector` 实例并且启动 `Looper`，不然就会报错。

可以看到在 `GestureHandler` 中回调了 `onShowPress` 和 `onLongPress` ，所以如果当前线程使用的是非主线程 `Looper` 那么 `onShowPress` 和 `onLongPress` 也会在非主线程调用，是不能更新 `UI` 的。

#### 监听器
目前 GestureDetecotr 有四种监听器。

| 监听器 | 简介 |
| --- | --- |
| OnContextClickListener | 这个很容易让人联想到ContextMenu，然而它和ContextMenu并没有什么关系，它是在Android6.0(API 23)才添加的一个选项，是用于检测外部设备上的按钮是否按下的，例如蓝牙触控笔上的按钮，一般情况下，忽略即可。 |
| OnDoubleTapListener | 双击事件，有三个回调类型：双击(DoubleTap)、单击确认(SingleTapConfirmed) 和 双击事件回调(DoubleTapEvent) |
| OnGestureListener | 手势检测，主要有以下类型事件：按下(Down)、 一扔(Fling)、长按(LongPress)、滚动(Scroll)、触摸反馈(ShowPress) 和 单击抬起(SingleTapUp) |
| SimpleOnGestureListener | 这个是上述三个接口的空实现，一般情况下使用这个比较多，也比较方便 |

> 注意：一些回调方法的返回值是 `boolean` 若返回值为 `true` 则代表事件被消费，响应的 `GestureDetecotr.onTouchEvent` 的返回值也为 `true`。这样在处理一些自定义控件时会很有用。

##### OnContextClickListener
`OnContextClickListener` 主要是用于检测外部设备按钮的，关于它需要注意一点，如果侦听 `onContextClick(MotionEvent)`，则必须在 `onGenericMotionEvent(MotionEvent)` 中调用 `GestureDetector` 的 `OnGenericMotionEvent(MotionEvent)`。

##### OnDoubleTapListener
用于监听双击事件和已确定的单击事件
`OnDoubleTapListener` 有如下方法：

| 方法 | 简介 |
| --- | --- |
| onSingleTapConfirmed(MotionEvent) | 单击事件回调 |
| onDoubleTap(MotionEvent) | 双击事件回调 |
| onDoubleTapEvent(MotionEvent) | 双击事件发生中产生的 event |

`onSingleTapConfirmed` 只有在确认用户不会触发双击操作时才会回调，也就是说当用户发生第一次点按操作时并不会立刻回调 `onSingleTapConfirmed` 而是会等待确认用户不会触发双击操作时才会回调。如果触发了双击操作那就会回调 `onDoubleTap`。

`onDoubleTapEvent` 回调发生在 `onDoubleTap` 回调发生之后的 DOWN、MOVE、UP事件。

```
case MotionEvent.ACTION_DOWN:
    if (mDoubleTapListener != null) {
        mIsDoubleTapping = true;
        mDoubleTapListener.onDoubleTap(mCurrentDownEvent);
        mDoubleTapListener.onDoubleTapEvent(ev);
    }
case MotionEvent.ACTION_MOVE:
    if (mIsDoubleTapping) {
        mDoubleTapListener.onDoubleTapEvent(ev);
    }
case MotionEvent.ACTION_UP:
    if (mIsDoubleTapping) {
        mDoubleTapListener.onDoubleTapEvent(ev);
    }   
```
输出如下：
```
E/GestureDetector: onDoubleTap - down
E/GestureDetector: onDoubleTapEvent - down
E/GestureDetector: onDoubleTapEvent - move
E/GestureDetector: onDoubleTapEvent - up
```

##### OnGestureListener
`OnGestureListener` 有如下方法：

| 方法 | 简介 |
| --- | --- |
| onDown(MotionEvent) | MotionEvent.ACTION_DOWN 事件触发 |
| onShowPress(MotionEvent) | 用户按下事件 |
| onSingleTapUp(MotionEvent) | MotionEvent.ACTION_UP 事件触发 |
| onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) | 滑动事件 |
| onLongPress | 长按事件 |
| onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) | 抛\掷\扔事件 |

* `onDown`

每次触发 `ActionEvent.ACTION_DOWN` 都会触发。

* `onShowPress`

用户按下事件的回调，当 `ACTION_DOWN` 触发时会发送一个延迟的 `SHOW_PRESS` 事件给 `Handler` 处理，`ACTION_UP` 事件触发的时间够快，`SHOW_PRESS` 时间将被移除，不会回调 `onShowPress` 。

* `onLongPress`

长按事件

* `onSingleTapUp`

每次触发 `ActionnEvent.ACTION_UP` 都会触发。
> 注意：两种情况下 `onSingleTapUp` 不会回调。
> * 如果设置了 `OnDoubleTapListener` 监听那么产生双击事件时第二次 `ActionnEvent.ACTION_UP` 不会回调 `onSingleTapUp` 。
> * 如果在 `ACTION_UP` 发生前产生 `ACTION_MOVE` (移动超过一定距离)那么 `onSingleTapUp` 也不会回调。

* `onScroll`

滑动事件参数介绍：
| 参数 | 介绍 |
| --- | --- |
| e1 | 滑动按下时的 `ACTION_DOWN` 事件 |
| e2 | 当前滑动的 `ACTION_MOVE` 事件 |
| distanceX | 距离上一次事件调用在 X 轴上滚动的距离，注意不是 e1 和 e2间的距离 |
| distanceY | 距离上一次事件调用在 Y 轴上滚动的距离，注意不是 e1 和 e2间的距离 |

* `onFling`

当 `ACTION_UP` 触发时如果 `X` 或 `Y` 轴上滑动的距离超过限值会触发 `onFling` 回调。
参数介绍：

| 参数 | 介绍 |
| --- | --- |
| e1 | 抛掷事件触发时的 `ACTION_DOWN` 事件 |
| e2 | 抛掷事件触发时的 `ACTION_MOVE` 事件 |
| velocityX | 在 x 轴上以像素每秒为单位测量的抛动速度 |
| velocityY | 在 y 轴上以像素每秒为单位测量的抛动速度 |

##### SimpleOnGestureListener
```
public static class SimpleOnGestureListener implements OnGestureListener, OnDoubleTapListener,
            OnContextClickListener
```

可以看到 `SimpleOnGestureListener` 是以上三种监听事件的空实现，这样需要处理那种事件就可以只实现某个回调了。这个监听也是最常用的了 `^_^`。

### ScaleGestureDetector
`ScaleGestureDetector` 是官方提供的检测缩放手势的工具，和 `GestureDetector` 一样也是通过 `MotionEvent` 来检测手势并回调触发时间内。

使用方式如下：
* 创建 `ScaleGestureDetector` 实例。
* 在 `onTouchEvent(MotionEvent)` 方法中调用 `ScaleGestureDetector` 实例的 `onTouchEvent(MotionEvent)` 方法。

```
//创建回调监听
private ScaleGestureDetector.OnScaleGestureListener mScaleGestureListener = new ScaleGestureDetector.OnScaleGestureListener() {
    @Override
    public boolean onScale(ScaleGestureDetector scaleGestureDetector) {
        return true;
    }

    @Override
    public boolean onScaleBegin(ScaleGestureDetector scaleGestureDetector) {
        return true;
    }

    @Override
    public void onScaleEnd(ScaleGestureDetector scaleGestureDetector) {
    }
};

//创建 ScaleGestureDetector 实例
ScaleGestureDetector mScaleGestureDetector = new ScaleGestureDetector(this,mScaleGestureListener);

//监听触摸事件
@Override
public boolean onTouchEvent(MotionEvent event) {
    mScaleGestureDetector.onTouchEvent(event);
    return super.onTouchEvent(event);
}
```

#### 创建 ScaleGestureDetector 实例
`ScaleGestureDetector` 的构造方法如下：
```
public ScaleGestureDetector(Context context, OnScaleGestureListener listener) 

public ScaleGestureDetector(Context context, OnScaleGestureListener listener, Handler handler)
```

区别只在于一个 `Handler` 参数，上面已经讲过了它的作用，在非主线程中创建手势实例需要用到。

#### OnScaleGestureListener 监听器
`OnScaleGestureListener` 监听有如下方法：

| 方法 | 简介 |
| --- | --- |
| onScale(ScaleGestureDetector) | 缩放事件回调 |
| onScaleBegin(ScaleGestureDetector) | 缩放操作开始 |
| onScaleEnd(ScaleGestureDetector) | 缩放操作结束 |

* `onScaleBegin`

在 `onScaleBegin` 的注释中写当新的 `ACTION_DOWN` 事件触发时会回调此方法，但是看源码却是不同：
```
if (!mInProgress && span >=  minSpan &&
        (wasInProgress || Math.abs(span - mInitialSpan) > mSpanSlop)) {

    mInProgress = mListener.onScaleBegin(this);
}
```

如源码所示，只有当缩放距离大于最小距离时才会触发 `onnScaleBegin` 回调。

可以看到回调事件的参数都是 `ScaleGestureDetector` 实例，那么来看一下 `ScaleGestureDetector` 实例可用的方法有哪些：

| 方法 | 简介 |
| --- | --- |
| getFocusX | 缩放中心点 X 轴坐标 |
| getFocusY | 缩放中心点 Y 轴坐标 |
| getScaleFactor | 获取缩放因子 |

* `getScaleFactor` 

`getScaleFactor` 的值表示比当前缩放了多少，一般会如下操作控件缩放：

```
private float mScaleFactor = 1.0f;

mScaleFactor  *= scaleGestureDetector.getScaleFactor();
mView.setScaleX(mScaleFactor);
mView.setScaleY(mScaleFactor);
```
