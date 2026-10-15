[原文链接](http://mp.weixin.qq.com/s?__biz=MzA4NDM2MjAwNw==&mid=2650576114&idx=1&sn=ed5569ba7beb408817b6a964bc9833b8&mpshare=1&scene=1&srcid=1011mwA2h5DuAgDwgeKoZ6HE#rd)

事件分发是Android中非常重要的机制，是用户与界面交互的基础。这篇文章将通过示例打印出的Log，绘制出事件分发的流程图，让大家更容易的去理解Android的事件分发机制。

### 一、必要的基础知识

> 相关方法

Android中与事件分发相关的方法主要包括dispatchTouchEvent、onInterceptTouchEvent、onTouchEvent三个方法，而事件分发一般会经过三种容器，分别为Activity、ViewGroup、View。下表对这三种容器分别拥有的事件分发相关方法进行了整理。

| 事件相关方法|     方法功能|   Activity|   ViewGroup|   View|
| :-------- | --------:| :------: | :------: | :------: |
| dispatchTouchEvent|   事件分发|  Yes| Yes| Yes|
| onInterceptTouchEvent|   事件拦截|  No| Yes| No|
| onTouchEvent|   事件消费|  Yes| Yes| Yes|

- 分发: dispatchTouchEvent如果返回true，则表示在当前View或者其子View(子子…View)中，找到了处理事件的View；反之，则表示没有寻找到
- 拦截: onInterceptTouchEvent如果返回true，则表示这个事件由当前View进行处理，不管处理结果如何，都不会再向子View传递这个事件；反之，则表示当前View不主动处理这个事件，除非他的子View返回的事件分发结果为false
- 消费: onTouchEvent如果返回true，则表示当前View就是事件传递的终点；反之，则表示当前View不是事件传递的终点

### 二、示例的默认情况

我们可以从示例代码的xml中看出，图片都是可点击的。

```
<?xml version="1.0" encoding="utf-8"?>
<com.idtk.customscroll.ParentView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="10dp"
    tools:context="com.idtk.customscroll.MainActivity">

    <com.idtk.customscroll.ChildView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/zhiqinchun"
        android:clickable="true"/>

    <com.idtk.customscroll.ChildView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/hanzhan"
        android:clickable="true"/>

    <com.idtk.customscroll.ChildView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/shengui"
        android:clickable="true"/>

    <com.idtk.customscroll.ChildView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/dayu"
        android:clickable="true"/>

</com.idtk.customscroll.ParentView>
```

我们现在来点击一下，查看下打印出的日志。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_touch_event_log.jpg)

根据打印出的log来绘制一张事件传递的流程图

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_touch_event_process.jpg)

我们来整理下这个事件序列的流程：

- ACTION_DOWN事件的传递与之前相同，不同的地方在于，返回值的传递
- 因为不可点击，View#onTouchEvent返回值为false，将其传递给自己的dispatchTouchEvent方法，之后传递到ViewGroup#dispatchTouchEvent方法，再传递到ViewGroup#onTouchEvent方法
- ViewGroup返回false之后，ACTION_DOWN事件交由Activity#onTouchEvent方法进行处理，然而依旧返回false，最后ACTION_DOWN事件的返回结果即为false
- ACTION_UP事件在发现View、ViewGroup并不处理ACTION_DOWN事件后，直接将其传递给了Activity#onTouch方法处理，处理返回false，ACTION_UP事件的返回结果即为false

这里使用工作中的情况来模拟：依旧是老板(Activity)、项目经理(ViewGroup)、软件工程师(View) 从老板交任务给项目经理，项目经理交任务给工程师，这一段流程和之前的例子相同。不同之处是软件工程师没有完成这个任务(View#onTouchEvent返回false)，告诉项目经理我没有完成，然后项目经理自己进行了尝试，同样没有完成(ViewGroup#onTouchEvent返回false)，项目经理告诉了老板，我没有完成，然后老板自己试了下也没有完成这个任务(Activity#onTouchEvent返回false),但之后的也有项目的二期、三期，不过老板知道你们完成不了，所以都是他自己进行尝试，不过很惨都没完成。(这段有点与正常情况不同，不过只是打个比方)

通过结合上面两个例子，可以得出一些结论:

- 某个View如果onTouchEvent返回false，表示事件没有被消费，则事件将传递给其父View的onTouchEvent进行处理
- 某个View如果它不消耗ACTION_DOWN事件，那么这个序列的后续事件也不会再交由它来处理
- 如果事件没有View对其进行处理，那么最后将有Activity进行处理
- View默认的onTouchEvent在View可点击的情况下，将会消耗事件，返回true；不可点击的情况下，则不消耗事件，返回false(longClickable的情况，读者可以自行测试，结果与clickable相同)

### 四、在ViewGroup中拦截事件

事件分发中拦截的情况，这里我把它分为2种，一种是在ACTION_DOWN事件时，就进行拦截的；另一种是在ACTION_DOWN之后的事件序列中，对事件进行了拦截。

> 在事件开始时拦截

为了达到在ViewGroup中，一开始就拦截触摸事件的效果，我们需要进行修改，在ParentView#onInterceptTouchEvent方法的最后部分，我注释掉的intercept=true;进行恢复，然后为activity_main.xml中的ParentView增加android:clickable="true"属性。

```
<?xml version="1.0" encoding="utf-8"?>
<com.idtk.customscroll.ParentView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="10dp"
    tools:context="com.idtk.customscroll.MainActivity"
    >

    <com.idtk.customscroll.ChildView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/zhiqinchun"
        android:clickable="true"/>

    <com.idtk.customscroll.ChildView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/hanzhan"
        android:clickable="true"/>

    <com.idtk.customscroll.ChildView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/shengui"
        android:clickable="true"/>

    <com.idtk.customscroll.ChildView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/dayu"
        android:clickable="true"/>

</com.idtk.customscroll.ParentView>
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_touch_event_log_2.jpg)

我们现在来看下拦截情况下的事件流程图

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_touch_event_prcess_2.jpg)

这里大部分和之前的例子相同

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_touch_event_process_3.jpg)

主要的区别是在于ViewGroup#onInterceptTouchEvent方法中，对传递的事件进行了拦截，返回true，ACTION_DOWN事件就传递到了ViewGroup#onTouchEvent中进行处理，ACTION_DOWN事件之后的传递就与之前的例子相同了。另一点重要的区别是，在ViewGroup拦截下事件之后，此事件序列的其余事件，在进入ViewGroup#dispatchTouchEvent方法之后，不在需要进行是否拦截事件的判断，而是直接进入了onTouchEvent方法之中。

使用工作中的情况来模拟：老板(Activity)、项目经理(ViewGroup)、软件工程师(View) 老板吧任务交给项目经理，项目经理认为这个项目比较难，所以决定自己处理(ViewGroup#onInterceptTouchEvent,return true)，项目经理比较厉害他把任务完成了(ViewGroup#onTouchEvent,return true)，然后他告诉老板他完成了(return true,ViewGroup#dispatchTouchEvent→Activity#dispatchTouchEvent)。之后老板依旧会把任务交给项目经理，项目经理知道这个任务难度，所以不假思索(也就是这个事件序列中的其余事件没有经过ViewGroup#onInterceptTouchEvent)的自己来做。

通过上面的例子，可以得出一些结论:

- 某个ViewGroup如果onInterceptTouchEvent返回为true，则ViewGroup拦截事件，将事件传递给其onTouchEvent方法进行处理
- 某个ViewGroup如果它的onInterceptTouchEvent返回为true，那么这个事件序列中的后续事件，不会在进行onInterceptTouchEvent的判断，而是由它的dispatchTouchEvent方法直接传递给onTouchEvent方法进行处理

> 在事件序列中拦截

这里把使用的示例恢复到初始状态，然后把我在ParentView#onInterceptTouchEvent方法，switch内的两个注释掉的intercept = true;代码进行恢复，最后部分intercept = true;再次注释掉。

```
<?xml version="1.0" encoding="utf-8"?>
<com.idtk.customscroll.ParentView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="10dp"
    tools:context="com.idtk.customscroll.MainActivity"
    >

    <com.idtk.customscroll.ChildView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/zhiqinchun"
        android:clickable="true"/>

    <com.idtk.customscroll.ChildView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:src="@drawable/hanzhan"
        android:clickable="true"/>

    <com.idtk.customscroll.ChildView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/shengui"
        android:clickable="true"/>

    <com.idtk.customscroll.ChildView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/dayu"
        android:clickable="true"/>

</com.idtk.customscroll.ParentView>
```

重新运行之后，滑动一个图片，来看看Log

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_touch_event_log_3.jpg)

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_touch_event_log_4.jpg)

这里分成两张图片，是因为中间有很多ACTION_MOVE，为了方便观察，所以只截取了Log的首尾部分。 这里的关键部分，就是红框中的ACTION_CANCEL,可以看到ACTION_DOWN事件的传递时onInterceptTouchEvent并没有拦截，返回false，在其后的事件ACTION_MOVE再次进入onInterceptTouchEvent时，ViewGroup对事件进行了拦截，这样将会对View传递一个ACTION_CANCEL事件，之后的ACTION_MOVE事件就不再传递给View了。

使用工作中的情况来模拟：老板(Activity)、项目经理(ViewGroup)、软件工程师(View) 这里的情况就是，一期的任务和第一个例子一样的情况一样，由软件工程师完成，不过忽然项目经理觉得二期的任务有点难，然后决定自己完成。这时就给工程师说，这个项目的后续任务，不要你来完成了(ACTION_CANCEL)。

从这里也可以得出一个结论:

某个View接收了ACTION_DOWN之后，这个序列的后续事件中，如果在某一刻被父View拦截了，则这个字View会收到一个ACTION_CANCEL事件，并且也不会再收到这个事件序列中的后续事件。

### 四、onTouch()、onClick()
onTouch()和onClick()函数都在View.dispatchTouchEvent()中调用

```
public boolean dispatchTouchEvent(MotionEvent event) {
    ListenerInfo li = mListenerInfo;
    if (li != null && li.mOnTouchListener != null
        && (mViewFlags & ENABLED_MASK) == ENABLED
        && li.mOnTouchListener.onTouch(this, event)) 
    {
        result = true;
    }

    if (!result && onTouchEvent(event)) {
        result = true;
    }
    
    return result;
}
```
可以第一个if判断，事件对象不为空&&touch事件不为空&&view可点击&&onTouch()返回true，则dispatchTouchEvent()返回值为true。
第二个if判断，如果onTouchEvent()返回值为true则dispatchTouchEvent()返回值为true。说明onTouchEvent()和onTouch()都会被调用，任何一个返回true则dispatchTouchEvent()返回值为true。

```
    public boolean onTouchEvent(MotionEvent event) {
        final float x = event.getX();
        final float y = event.getY();
        final int viewFlags = mViewFlags;
        final int action = event.getAction();

        final boolean clickable = ((viewFlags & CLICKABLE) == CLICKABLE
                || (viewFlags & LONG_CLICKABLE) == LONG_CLICKABLE)
                || (viewFlags & CONTEXT_CLICKABLE) == CONTEXT_CLICKABLE;

        if ((viewFlags & ENABLED_MASK) == DISABLED) {
            if (action == MotionEvent.ACTION_UP && (mPrivateFlags & PFLAG_PRESSED) != 0) {
                setPressed(false);
            }
            mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
            // A disabled view that is clickable still consumes the touch
            // events, it just doesn't respond to them.
            return clickable;
        }
        if (mTouchDelegate != null) {
            if (mTouchDelegate.onTouchEvent(event)) {
                return true;
            }
        }

        if (clickable || (viewFlags & TOOLTIP) == TOOLTIP) {
            switch (action) {
                case MotionEvent.ACTION_UP:
                    mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
                    if ((viewFlags & TOOLTIP) == TOOLTIP) {
                        handleTooltipUp();
                    }
                    if (!clickable) {
                        removeTapCallback();
                        removeLongPressCallback();
                        mInContextButtonPress = false;
                        mHasPerformedLongPress = false;
                        mIgnoreNextUpEvent = false;
                        break;
                    }
                    boolean prepressed = (mPrivateFlags & PFLAG_PREPRESSED) != 0;
                    if ((mPrivateFlags & PFLAG_PRESSED) != 0 || prepressed) {
                        // take focus if we don't have it already and we should in
                        // touch mode.
                        boolean focusTaken = false;
                        if (isFocusable() && isFocusableInTouchMode() && !isFocused()) {
                            focusTaken = requestFocus();
                        }

                        if (prepressed) {
                            // The button is being released before we actually
                            // showed it as pressed.  Make it show the pressed
                            // state now (before scheduling the click) to ensure
                            // the user sees it.
                            setPressed(true, x, y);
                        }

                        if (!mHasPerformedLongPress && !mIgnoreNextUpEvent) {
                            // This is a tap, so remove the longpress check
                            removeLongPressCallback();

                            // Only perform take click actions if we were in the pressed state
                            if (!focusTaken) {
                                // Use a Runnable and post this rather than calling
                                // performClick directly. This lets other visual state
                                // of the view update before click actions start.
                                if (mPerformClick == null) {
                                    mPerformClick = new PerformClick();
                                }
                                if (!post(mPerformClick)) {
                                    performClick();
                                }
                            }
                        }

                        if (mUnsetPressedState == null) {
                            mUnsetPressedState = new UnsetPressedState();
                        }

                        if (prepressed) {
                            postDelayed(mUnsetPressedState,
                                    ViewConfiguration.getPressedStateDuration());
                        } else if (!post(mUnsetPressedState)) {
                            // If the post failed, unpress right now
                            mUnsetPressedState.run();
                        }

                        removeTapCallback();
                    }
                    mIgnoreNextUpEvent = false;
                    break;

                case MotionEvent.ACTION_DOWN:
                    if (event.getSource() == InputDevice.SOURCE_TOUCHSCREEN) {
                        mPrivateFlags3 |= PFLAG3_FINGER_DOWN;
                    }
                    mHasPerformedLongPress = false;

                    if (!clickable) {
                        checkForLongClick(0, x, y);
                        break;
                    }

                    if (performButtonActionOnTouchDown(event)) {
                        break;
                    }

                    // Walk up the hierarchy to determine if we're inside a scrolling container.
                    boolean isInScrollingContainer = isInScrollingContainer();

                    // For views inside a scrolling container, delay the pressed feedback for
                    // a short period in case this is a scroll.
                    if (isInScrollingContainer) {
                        mPrivateFlags |= PFLAG_PREPRESSED;
                        if (mPendingCheckForTap == null) {
                            mPendingCheckForTap = new CheckForTap();
                        }
                        mPendingCheckForTap.x = event.getX();
                        mPendingCheckForTap.y = event.getY();
                        postDelayed(mPendingCheckForTap, ViewConfiguration.getTapTimeout());
                    } else {
                        // Not inside a scrolling container, so show the feedback right away
                        setPressed(true, x, y);
                        checkForLongClick(0, x, y);
                    }
                    break;

                case MotionEvent.ACTION_CANCEL:
                    if (clickable) {
                        setPressed(false);
                    }
                    removeTapCallback();
                    removeLongPressCallback();
                    mInContextButtonPress = false;
                    mHasPerformedLongPress = false;
                    mIgnoreNextUpEvent = false;
                    mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
                    break;

                case MotionEvent.ACTION_MOVE:
                    if (clickable) {
                        drawableHotspotChanged(x, y);
                    }

                    // Be lenient about moving outside of buttons
                    if (!pointInView(x, y, mTouchSlop)) {
                        // Outside button
                        // Remove any future long press/tap checks
                        removeTapCallback();
                        removeLongPressCallback();
                        if ((mPrivateFlags & PFLAG_PRESSED) != 0) {
                            setPressed(false);
                        }
                        mPrivateFlags3 &= ~PFLAG3_FINGER_DOWN;
                    }
                    break;
            }

            return true;
        }

        return false;
    }
```

DOWN时：
- 首先设置标志为PREPRESSED，设置mHasPerformedLongPress=false ;然后发出一个115ms后的mPendingCheckForTap；
- 如果115ms内没有触发UP，则将标志置为PRESSED，清除PREPRESSED标志，同时发出一个延时为500-115ms的，检测长按任务消息；
- 如果500ms内（从DOWN触发开始算），则会触发LongClickListener:

此时如果LongClickListener不为null，则会执行回调，同时如果LongClickListener.onClick返回true，才把mHasPerformedLongPress设置为true;否则mHasPerformedLongPress依然为false;

MOVE时：
- 主要就是检测用户是否划出控件，如果划出了：
- 115ms内，直接移除mPendingCheckForTap；
- 115ms后，则将标志中的PRESSED去除，同时移除长按的检查：removeLongPressCallback();

UP时：
- 如果115ms内，触发UP，此时标志为PREPRESSED，则执行UnsetPressedState，setPressed(false);会把setPress转发下去，可以在View中复写dispatchSetPressed方法接收；
- 如果是115ms-500ms间，即长按还未发生，则首先移除长按检测，执行onClick回调；
- 如果是500ms以后，那么有两种情况：
- 设置了onLongClickListener，且onLongClickListener.onClick返回true，则点击事件OnClick事件无法触发；
- 没有设置onLongClickListener或者onLongClickListener.onClick返回false，则点击事件OnClick事件依然可以触发；
- 最后执行mUnsetPressedState.run()，将setPressed传递下去，然后将PRESSED标识去除；


特别看一下performClick

```
public boolean performClick() {  
    sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_CLICKED);  
    if (mOnClickListener != null) {  
        playSoundEffect(SoundEffectConstants.CLICK);  
        mOnClickListener.onClick(this);  
        return true;  
    }  
    return false;  
}
```
可以看到，只要mOnClickListener不是null，就会去调用它的onClick方法。这里的mOnClickListener就是当初注册的OnClickListener。
也说明了OnClick方法是在OnTouchEvent里处理的。

### 五、小结

本文通过示例打印出的各种Log对Android的事件分发机制进行，得出如下结论。

- 一个事件序列是指从手指触摸屏幕开始，到手指离开屏幕结束，这个过程中产生的一系列事件。一个事件序列以ACTION_DOWN事件开始，中间可能经过若干个MOVE，以ACTION_UP事件结束。
- 事件的传递过程是由外向内的，即事件总是由父元素分发给子元素
- 如果某个View消费了ACTION_DOWN事件，那么通常情况下，这个事件序列中的后续事件也将交由其进行处理，但可以通过调用其父View的onInterceptTouchEvent方法，对后续事件进行拦截
- 如果某个View它不消耗ACTION_DOWN事件，那么这个序列的后续事件也不会再交由它来处理
- 如果事件没有View对其进行处理，那么最后将有Activity进行处理
- 如果事件传递的结果为true，回传的结果直接通过不断调用父View#dispatchTouchEvent方法，传递给Activity；如果事件传递的结果为false，回传的结果不断调用父View#onTouchEvent方法，获取返回结果。
- View默认的onTouchEvent在View可点击的情况下，将会消耗事件，返回true；不可点击的情况下，则不消耗事件，返回false(longClickable的情况，读者可以自行测试，结果与clickable相同)
- 如果某个ViewGroup的onInterceptTouchEvent返回为true，那么这个事件序列中的后续事件，不会在进行onInterceptTouchEvent的判断，而是由它的dispatchTouchEvent方法直接传递给onTouchEvent方法进行处理
- 如果某个View接收了ACTION_DOWN之后，这个序列的后续事件中，在某一刻被父View拦截了，则这个字View会收到一个ACTION_CANCEL事件，并且也不会再收到这个事件序列中的后续事件

| 事件相关方法|     方法功能|   Activity|   ViewGroup|   View|
| :-------- | --------:| :------: | :------: | :------: |
| dispatchTouchEvent|   事件分发|  Yes| Yes| Yes|
| onInterceptTouchEvent|   事件拦截|  No| Yes| No|
| onTouchEvent|   事件消费|  Yes| Yes| Yes|

### 问题

#### ACTION_CANCEL 什么时候触发

如果某一个子View处理了Down事件，那么随之而来的Move和Up事件也会交给它处理。但是交给它处理之前，父View还是可以拦截事件的，如果拦截了事件，那么子View就会收到一个Cancel事件，并且不会收到后续的Move和Up事件。常见场景就是ListView中Item内部有一个Button，我们让ACTION_DOWN落在这个Button上，然后上下滑动，此时MOVE事件就会被ListView拦截，那么Button就会收到ACTION_CANCEL事件了。

#### MotionEvent的传递顺序

从上面可以看到，MotionEvent最开始是从DecorView传递到Activity的，那么Activity中又是怎样处理的

```
// Activity.java
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            onUserInteraction();
        }
        if (getWindow().superDispatchTouchEvent(ev)) {
            return true;
        }
        return onTouchEvent(ev);
    }
```

Activity又调用了getWindow().superDispatchTouchEvent(ev)也就是PhoneWindow。

```
// PhoneWindow.java
    @Override
    public boolean superDispatchTouchEvent(MotionEvent event) {
        return mDecor.superDispatchTouchEvent(event);
    }
```

这里又调用了DecorView的superDispatchTouchEvent(event)，这里面其实就是直接继承自ViewGroup的dispatchTouchEvent(MotionEvent ev)方法，也就是说，事件从DecorView传递到Activity，最终又回到DecorView，最后按照分发机制分发到ViewGroup再到所有的子View。

所以完整的事件分发顺序应该是：
```
IMS -->
WindowInputEventReceiver(ViewRoot) -->
DecorView -->
Activity -->
Window -->
DecorView -->
ViewGroup -->
View
```

#### 点击事件被拦截，但是想传到下面的View，如何操作

```
// ViewGroup.java
public boolean dispatchTouchEvent(MotionEvent ev) {
    
    ...
    final boolean disallowIntercept = (mGroupFlags & FLAG_DISALLOW_INTERCEPT) != 0;
    if (!disallowIntercept) {
        intercepted = onInterceptTouchEvent(ev);
        ev.setAction(action); // restore action in case it was changed
    } else {
        intercepted = false;
    }
    ...
}
```

`disallowIntercept`：不允许拦截，当 `mGroupFlags` 中含有 `FLAG_DISALLOW_INTERCEPT` 标识时不会调用 `onInterceptTouchEvent` 拦截事件。在 `requestDisallowInterceptTouchEvent` 函数内：

```
@Override
public void requestDisallowInterceptTouchEvent(boolean disallowIntercept) {

    if (disallowIntercept == ((mGroupFlags & FLAG_DISALLOW_INTERCEPT) != 0)) {
        // We're already in this state, assume our ancestors are too
        return;
    }

    if (disallowIntercept) {
        mGroupFlags |= FLAG_DISALLOW_INTERCEPT;
    } else {
        mGroupFlags &= ~FLAG_DISALLOW_INTERCEPT;
    }

    // 结果回传到 ParentView
    if (mParent != null) {
        mParent.requestDisallowInterceptTouchEvent(disallowIntercept);
    }
}
```

`mGroupFlags` 添加或去除 `FLAG_DISALLOW_INTERCEPT`，并将结果传递到父 `View`, 所以要想事件不被父类拦截，那么可以重写 `requestDisallowInterceptTouchEvent` 函数：

```
@Override
public void requestDisallowInterceptTouchEvent(boolean disallowIntercept) {

    mGroupFlags |= FLAG_DISALLOW_INTERCEPT;

    // 结果回传到 ParentView
    if (mParent != null) {
        mParent.requestDisallowInterceptTouchEvent(disallowIntercept);
    }
}
```

> 只有 `ViewGroup` 中有 `requestDisallowInterceptTouchEvent` 函数。

#### ViewGroup分发时会遍历ViewGroup的子元素，有多个子元素如何判断那个子元素接收点击事件？

```
// ViewGroup.java
public boolean dispatchTouchEvent(MotionEvent ev) {
    ...
    for (int i = childrenCount - 1; i >= 0; i--) {
        ...
        final int childIndex = getAndVerifyPreorderedIndex(
                childrenCount, i, customOrder);
        final View child = getAndVerifyPreorderedView(
                preorderedList, children, childIndex);
           
        ...
        if (!child.canReceivePointerEvents()
                || !isTransformedTouchPointInView(x, y, child, null)) {
            ev.setTargetAccessibilityFocus(false);
            continue;
        }   
        ...
    }
    ...
}

// View.java
protected boolean canReceivePointerEvents() {
    return (mViewFlags & VISIBILITY_MASK) == VISIBLE || getAnimation() != null;
}
```

首先遍历所有子元素，然后判断子元素是否能够接收到点击事件。是否能够接收由两点来衡量：

- 子 `View` 可点击（可见 || 未执行动画）。
- 点击坐标在子 `View` 坐标范围内。

#### onTouch() 和 onTouchEvent()

```
// View.java
public boolean dispatchTouchEvent(MotionEvent event) {
    ...
    if (li != null && li.mOnTouchListener != null
            && (mViewFlags & ENABLED_MASK) == ENABLED
            && li.mOnTouchListener.onTouch(this, event)) {
        result = true;
    }

    if (!result && onTouchEvent(event)) {
        result = true;
    }
    ...
}
```

`onTouch` 函数是 `OnTouchListener` 接口的唯一抽象函数。

#### onTouchListener,onTouchEvent和onClick的优先级别

这个从View的onTouchEvent源码可以看到整个过程，如果mTouchListener.onTouch()方法返回true，那么事件就会被onTouchListener.onTouch消费掉，而onClick是在onTouchEvent()的ACTION_UP中处理的，所以优先级是：

> onTouchListener > onTouchEvent > onclick

#### 如何解决View的事件冲突？举个开发中遇到的例子？

常见开发中事件冲突的有ScrollView与RecyclerView的滑动冲突、RecyclerView内嵌同时滑动同一方向。
滑动冲突的处理规则：

* 对于由于外部滑动和内部滑动方向不一致导致的滑动冲突，可以根据滑动的方向判断谁来拦截事件。
* 对于由于外部滑动方向和内部滑动方向一致导致的滑动冲突，可以根据业务需求，规定何时让外部View拦截事件，何时由内部View拦截事件。

对于上面两种情况的嵌套，相对复杂，可同样根据需求在业务上找到突破点。
滑动冲突的实现方法：

* 外部拦截法：指点击事件都先经过父容器的拦截处理，如果父容器需要此事件就拦截，否则就不拦截。具体方法：需要重写父容器的 `onInterceptTouchEvent` 方法，在内部做出相应的拦截。
* 内部拦截法：指父容器不拦截任何事件，而将所有的事件都传递给子容器，如果子容器需要此事件就直接消耗，否则就交由父容器进行处理。具体方法：需要配合 `requestDisallowInterceptTouchEvent` 方法。
