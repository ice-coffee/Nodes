`View.post()` 使用场景主要有如下两方面：

* 异步修改 `UI`。
* 监听 `View` 绘制结束。

#### 实现原理
首先看 `View.post()` 源码。
```
public boolean post(Runnable action) {
    final AttachInfo attachInfo = mAttachInfo;
    if (attachInfo != null) {
        return attachInfo.mHandler.post(action);
    }

    // Postpone the runnable until we know on which thread it needs to run.
    // Assume that the runnable will be successfully placed after attach.
    getRunQueue().post(action);
    return true;
}
```
这里判断 `attachInfo != null` 执行两种逻辑。

当 `attachInfo == null`，则执行 `getRunQueue().post(action);`。
```
private HandlerAction[] mActions;
private int mCount;

public void post(Runnable action) {
    postDelayed(action, 0);
}

public void postDelayed(Runnable action, long delayMillis) {
    final HandlerAction handlerAction = new HandlerAction(action, delayMillis);

    synchronized (this) {
        if (mActions == null) {
            mActions = new HandlerAction[4];
        }
        mActions = GrowingArrayUtils.append(mActions, mCount, handlerAction);
        mCount++;
    }
}
```
它会将 `Runnable` 存储在一个初始大小为 `4` 的数组中，`GrowingArrayUtils.append()` 方法中是动态扩容的逻辑。

存储在数组中的回调会在 `executeActions(Handler)` 方法被调用时通过参数 `Handler` 执行。
```
public void executeActions(Handler handler) {
    synchronized (this) {
        final HandlerAction[] actions = mActions;
        for (int i = 0, count = mCount; i < count; i++) {
            final HandlerAction handlerAction = actions[i];
            handler.postDelayed(handlerAction.action, handlerAction.delay);
        }

        mActions = null;
        mCount = 0;
    }
}
```
`executeActions(Handler)` 方法在两个地方被调用：

* `View.dispatchAttachedToWindow()`
* `ViewRootImpl.performTraversals()`

`dispatchAttachedToWindow()` 方法的调用源头其实也是在 `performTraversals()` 方法中。
```
private void performTraversals() {
    ...
    if (mFirst) {
        ...
        host.dispatchAttachedToWindow(mAttachInfo, 0);
        ...
    }
    
    ...
    getRunQueue().executeActions(mAttachInfo.mHandler);
    ...
}
```
但是只有在初次调用 `performTraversals()` 方法时才会调用。其余 `requestLayout()、invalidate()` 引发的调用都将执行之下的流程。

由于 `executeActions(Handler)` 方法中的 `Handler` 参数都是取自 `mAttachInfo.mHandler`，它是一个主线程的 `Handler` 所以其实并没有什么区别。都会被添加到主线程 `Handler` 中执行。通过在子线程中调用 `View.post()` 就可以达到修改 `UI` 的目的了，其实本质还是在主线程中执行。

而且，由于 `performTraversals()` 方法也是由主线程 `Handler` 执行的，而且它比 `executeActions(Handler)` 要更早调用，所以就可以把 `View.post()` 当做 `UI` 绘制结束的回调了。

然后当 `attachInfo != null`，则执行 `attachInfo.mHandler.post(action);`。直接发送到主线程 `Handler` 中，等待下一次 `performTraversals()` 调用时调用。

这就是 `View.post()` 的应用了，看下 `ViewRootImpl` 的源码可以帮助你更好的理解。
