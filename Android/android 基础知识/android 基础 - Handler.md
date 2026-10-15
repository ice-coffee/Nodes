[toc]

#### Handler 的实现原理
`Handler` 机制中有四个重要对象：

- `Handler`：负责发送以及处理消息。
- `MessageQueue`：消息队列，负责存储消息。
- `Looper`：轮训器，负责从 `MessageQueue` 中取出消息，并交给发送消息的 `Handler` 处理。
- `Message`：消息本身。

它们之间的关系如下：
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_handler.jpg)

`Handler` 发送 `Message` 给 `MessageQueue` 存储，`Looper` 不断轮询从 `MessageQueue` 中取出 `Message`，交给 `Message` 中保存的 `Handler` 对象调用处理。

#### 子线程中能不能直接 new 一个 Handler，为什么主线程可以
子线程中不可以直接创建 `Handler` 实例，因为在 `Handler` 创建时会判断是否添加 `Looper`：

```
mLooper = Looper.myLooper();
if (mLooper == null) {
    throw new RuntimeException(
        "Can't create handler inside thread " + Thread.currentThread()
                + " that has not called Looper.prepare()");
}
```

主线程中因为在创建时就已经创建了 `Looper`。

#### 主线程的 Looper 第一次调用 loop 方法,什么时候,哪个类
在 `ActivityThread` 创建时的 `main` 方法中：

```
public static void main(String[] args) {
    ...
    Looper.prepareMainLooper();
    ...
    Looper.loop();
    ...
}
```

#### Handler 导致的内存泄露原因及其解决方案
`Handler` 导致内存泄漏一般发生在发送延迟消息的时候，当 `Activity` 关闭之后，延迟 `Message` 还未处理，主线程中的 `MessageQueue` 依然持有这个 `Message` 的引用，而这个消息是持有 `Handler` 的引用，而 `Handler` 作为匿名内部类持有了 `Activity` 的引用，所以就有了以下的一条引用链。

```
主线程 —> threadlocal —> Looper —> MessageQueue —> Message —> Handler —> Activity
```

`Handler` 导致的内存泄露根本原因是主线程是不会被回收的，所以导致 `Activity` 无法被回收，出现内存泄漏。

解决方案：使用静态内部类 + 弱引用

```c++
private static class MyHandler extends Handler{
    //持有弱引用HandlerActivity,GC回收时会被回收掉.
    private final WeakReference<HandlerActivity> mActivty;
    public MyHandler(HandlerActivity activity){
        mActivty =new WeakReference<HandlerActivity>(activity);
    }
    @Override
    public void handleMessage(Message msg) {
        HandlerActivity activity=mActivty.get();
        super.handleMessage(msg);
        if(activity!=null){
            //执行业务逻辑
        }
    }
}
```

> 注意：
> 1. 非静态内部类会隐式持有外部类的引用。
> 2. 对于 `Kotlin` 来说未显示添加 `inner` 关键字修饰的内部类都是静态内部类。
> 3. 如果是在主线程，那么延迟消息总会得到执行，这时要注意的就是 `Activity` 为空，这样的报错。如果是在子线程那么在退出子线程时可以使用 `quit\quitSafely` 清理队列中的消息。

#### 使用 removeCallbacksAndEqualMessages 清理

#### 一个线程可以有几个 Handler，几个 Looper，几个 MessageQueue 对象
`Handler` 实例的创建没有限制，但是新建 `Handler` 实例时会从 `ThreadLocal` 中获取线程对应的 `Looper` 对象，`Looper` 对象和线程是一对一的关系，而 `MessageQueue` 仅在 `Looper` 构造时创建。所以一个线程可以有多个 `Handler`，但 `Looper` 和 `MessageQueue` 仅有一个。

并且 `Looper` 的构造函数为 `private`，仅能通过 `Looper.prepare()` 创建，并由 `ThreadLocal` 管理。

#### Message 对象创建的方式有哪些 & 区别？

- `new Message()`
- `Message.obtain(...)`

使用 `Message.obtain()` 创建消息对象更节省内存。

#### MessageQueue 的数据结构
`MessageQueue` 是一个消息队列，队列节点是 `Message` 类，`Message` 的 `next` 属性代表队列的队列指针。

#### Message.obtain() 怎么维护消息池的
`Message` 中维护了一个单链表的消息池，最大容量为 `50`，`Message.obtain()` 从消息池链表头获取已存在的空消息并返回，当消息处理完成后将消息回收添加到消息池的链表头。

```java
public final class Message implements Parcelable {
    
    Message next;

    public static final Object sPoolSync = new Object();
    private static Message sPool;
    private static int sPoolSize = 0;

    private static final int MAX_POOL_SIZE = 50;
        public static Message obtain() {
        synchronized (sPoolSync) {
            if (sPool != null) {
                Message m = sPool;
                sPool = m.next;
                m.next = null;
                m.flags = 0; // clear in-use flag
                sPoolSize--;
                return m;
            }
        }
        return new Message();
    }
    
    void recycleUnchecked() {
        synchronized (sPoolSync) {
            if (sPoolSize < MAX_POOL_SIZE) {
                next = sPool;
                sPool = this;
                sPoolSize++;
            }
        }
    }
}
```

#### Handler 有哪些发送消息的方法


#### Handler 的 post 与 sendMessage 的区别和应用场景
`post` 和 `sendMessage` 本质上是没有区别，都是发送一个消息到消息队列中，区别在于

- `post` 更方便使用。
- 处理 `Message`  的回调不同，`post` 是在 `runnable` 的 `run` 方法中，`sendMessage` 是在 `handleMessage` 方法中。

#### Handler 消息入队
`Handler` 的 `enqueueMessage` 方法处理消息入队：

- `MessageQueue` 消息队列中的消息按处理时间从先到后依次排列。
- `synchronized` 加锁保证线程安全。

```
boolean enqueueMessage(Message msg, long when) {
synchronized (this) {

    Message p = mMessages;

    if (p == null || when == 0 || when < p.when) {
        // 如果当前消息队列为空，或新插入的消息时间戳 早于 消息队列首位消息的时间戳
        msg.next = p;
        mMessages = msg;
    } else {

        // 插入延迟延迟消息，遍历消息列表
        Message prev;
        for (;;) {
            prev = p;
            p = p.next;
            if (p == null || when < p.when) {
                break;
            }
            if (needWake && p.isAsynchronous()) {
                needWake = false;
            }
        }
        msg.next = p; // invariant: p == prev.next
        prev.next = msg;
    }
}
return true;
}
```

#### Handler 消息出队


#### HandlerThread 是什么 & 好处 & 原理 & 使用场景
`HandlerThread` 继承自 `Thread`，也就是说它就是一个线程，当 `HandlerThread` 运行时在 `run` 函数内调用了 `Looper.prepare()`、`Looper.loop()` 函数，便与创建新的子线程并启动 `Handler`。

#### 消息同步屏障机制
[Handler同步屏障](https://zhuanlan.zhihu.com/p/361508626)

`Handler` 发送的消息分为普通消息、屏障消息、异步消息，一旦 `Looper` 在处理消息时遇到屏障消息，那么就不再处理普通的消息，而仅仅处理异步的消息。不再使用屏障后，需要撤销屏障，不然就再也执行不到普通消息了。

为什么需要这样？它是设计来为了让某些特殊的消息得以更快被执行的机制。比如绘制界面，这种消息可能会明显的被用户感知到，稍有不慎就会引起卡顿、掉帧之类的，所以需要及时处理（可能消息队列中有大量的消息，如果像平时一样挨个进行处理，那绘制界面这个消息就得等很久，这是不想看到的）。

发送一个屏障消息：

```java
public int postSyncBarrier() {
    return postSyncBarrier(SystemClock.uptimeMillis());
}

private int postSyncBarrier(long when) {
    synchronized (this) {
        final int token = mNextBarrierToken++;
        final Message msg = Message.obtain();
        msg.markInUse();
        msg.when = when;
        msg.arg1 = token;

        return token;
    }
}
```

屏障消息仅仅是起一个屏障的作用，本身一般不附带其他东西，没有 `target` 不需要执行，`when` 是当前时间表示插入到消息队列的链表头，也就是说它会立即得到执行。

```
Message next() {
    for (;;) {
        synchronized (this) {
            final long now = SystemClock.uptimeMillis();
            Message prevMsg = null;
            Message msg = mMessages;
            if (msg != null && msg.target == null) {
                // ① 表示发现屏障消息
                do {
                    prevMsg = msg;
                    msg = msg.next;
                } while (msg != null && !msg.isAsynchronous());
            }
            
            if (msg != null) {
                if (now < msg.when) {
                    ...
                } else {
                    mBlocked = false;
                    if (prevMsg != null) {
                        // ② mMessages 不会赋新值，所以它还是屏障消息
                        prevMsg.next = msg.next;
                    } else {
                        mMessages = msg.next;
                    }
                    msg.next = null;
                    return msg;
                }
            }
        }
    }
}
```

从上面标注的 `①②` 可以看出，消息队列遇到屏障消息后会依次执行消息队列中所有的异步消息。

屏障消息和普通消息的区别：

* 屏障消息和普通消息区别在于屏幕没有 `target`，普通消息有 `target` 是因为它需要将消息分发给对应的 `target`，而屏幕不需要被分发，它就是用来挡住普通消息来保证异步消息优先处理的。
* 屏障和普通消息一样可以根据时间来插入到消息队列中的适当位置，并且只会挡住它后面的同步消息的分发
* `postSyncBarrier` 会返回一个 `token`，利用这个 `token` 可以撤销屏障。
* 插入普通消息会唤醒消息队列，但插入屏障不会。

#### Android 中为什么主线程不会因为 Looper.loop() 里的死循环卡死
[链接](https://www.zhihu.com/question/34652589)

首先说 `Looper` 中死循环存在的意义，线程是一段可执行的代码，当可执行代码执行完成后，线程生命周期便该终止了，线程退出。而对于主线程，我们是绝不希望会被运行一段时间，自己就退出，那么如何保证能一直存活呢？简单做法就是可执行代码是能一直执行下去的，死循环便能保证不会被退出，当然并非简单地死循环，无消息时会休眠。所以真正会卡死主线程的操作是在回调方法 `onCreate/onStart/onResume` 等操作时间过长，会导致掉帧，甚至发生 `ANR`，`looper.loop` 本身不会导致应用卡死。

```
// 休眠
private native void nativePollOnce(long ptr, int timeoutMillis);
// 唤醒
private native static void nativeWake(long ptr);
```

`MessageQueue` 中使用休眠和唤醒操作，当没有消息时主线程会休眠，当有新消息入队时唤醒主线程。

#### 子线程能不能更新UI，为什么Android系统不建议子线程访问UI
[震惊！Android子线程也能修改UI？](https://blog.csdn.net/c10WTiybQ1Ye3/article/details/112210503)

首先子线程可以更新 `UI`，但需要满足一定条件，如下方式可以在子线程中更新 `UI`：

- `onCreate` 函数内，`setContentView` 函数调用后。
- 在子线程中向主线程 `Looper` 发送消息。
- 在子线程中更新 `TextView` 的 `text` 属性。

如果正常在子线程更新 `UI` 会报错，这是因为更新 `UI` 都会调用 `ViewRootImpl`，在 `ViewRootImpl` 中会进行线程检查：

```
public void requestLayout() {
    if (!mHandlingLayoutInLayoutRequest) {
        checkThread();
        mLayoutRequested = true;
        scheduleTraversals();
    }
}

void checkThread() {
    if (mThread != Thread.currentThread()) {
        throw new CalledFromWrongThreadException(
                "Only the original thread that created a view hierarchy can touch its views.");
    }
}
```

所以如果在 `ViewRootImpl` 创建前是可以在子线程更新 `UI` 的。

第二种方式就不用说了。

第三种方式是 `TextView` 的特例，具体原因是因为在更新 `text` 属性时，会通过 `checkForRelayout` 判断组件宽高属性是否发生变化，如果没有变化那说明不需要重新测量布局，仅重新绘制就行。

`Android` 系统不建议子线程访问 `UI` 因为 `Android` 的 `UI` 线程是不安全的，如果在多线程中并发访问可能会导致 `UI` 控件处于不可预期的状态。那么为什么不对 `UI` 控件的访问加上锁机制呢？缺点有两个：

- 首先加上锁机制会让 `UI` 访问逻辑变的复杂；
- 其次锁机制会降低 `UI` 的访问效率，因为锁机制会阻塞某些线程的执行。

#### Looper.quit/quitSafely 的区别
> 主线程执行 `quit/quitSafely` 无效。

- `quit`：回收消息队列中所有的 `Message`。
- `quitSafely`：仅回收消息队列中的延迟消息，对于正在执行的和非延迟消息依然会得到执行。
