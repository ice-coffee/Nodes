[toc]

### 参考
[Java并发编程：Synchronized及其实现原理](https://www.cnblogs.com/paddix/p/5367116.html)

[synchronized 实现原理](https://xiaomi-info.github.io/2020/03/24/synchronized/)

[深入分析Synchronized原理](https://www.cnblogs.com/aspirant/p/11470858.html)

[深入浅出synchronized关键字](https://juejin.cn/post/6960216459083513886#heading-7)

最近又看了一遍 `EventBus` 的源码，感叹优秀的库每次学习都能获得更多的知识。

先贴一段代码：

```java
public class HandlerPoster extends Handler implements Poster {

    private final PendingPostQueue queue;
    private final int maxMillisInsideHandleMessage;
    private final EventBus eventBus;
    private boolean handlerActive;

    protected HandlerPoster(EventBus eventBus, Looper looper, int maxMillisInsideHandleMessage) {
        super(looper);
        this.eventBus = eventBus;
        this.maxMillisInsideHandleMessage = maxMillisInsideHandleMessage;
        queue = new PendingPostQueue();
    }

    public void enqueue(Subscription subscription, Object event) {
        PendingPost pendingPost = PendingPost.obtainPendingPost(subscription, event);
        //①
        synchronized (this) {
            queue.enqueue(pendingPost);
            if (!handlerActive) {
                handlerActive = true;
                if (!sendMessage(obtainMessage())) {
                    throw new EventBusException("Could not send handler message");
                }
            }
        }
    }

    @Override
    public void handleMessage(Message msg) {
        boolean rescheduled = false;
        try {
            long started = SystemClock.uptimeMillis();
            while (true) {
                PendingPost pendingPost = queue.poll();
                if (pendingPost == null) {
                    //②
                    synchronized (this) {
                        // Check again, this time in synchronized
                        pendingPost = queue.poll();
                        if (pendingPost == null) {
                            handlerActive = false;
                            return;
                        }
                    }
                }
                eventBus.invokeSubscriber(pendingPost);
                long timeInMethod = SystemClock.uptimeMillis() - started;
                if (timeInMethod >= maxMillisInsideHandleMessage) {
                    if (!sendMessage(obtainMessage())) {
                        throw new EventBusException("Could not send handler message");
                    }
                    rescheduled = true;
                    return;
                }
            }
        } finally {
            handlerActive = rescheduled;
        }
    }
}
```

看过 `EventBus` 源码的同学都清楚 `HandlerPoster` 用于向主线程发送消息，在 `handleMessage()` 中做消息处理。可以看到在 `①②` 两处各有一个 `synchronized` 用于保证数据线程安全。到这里可以思考一个问题，如果拿掉 `②` 处的 `synchronized` 有没有问题，它是不是多余的？

`①` 处的关键字保证了数据入栈的操作的安全性。而且我们已知的是这里的 `handlerMessage()` 方法一定是在主线程中调用的，也就是出栈操作只涉及到一个线程，间接保证了数据出栈的安全性。这样来看的话 `②` 处的关键字就好像是多余的了。

如果你真的这么觉得话那就掉进陷阱里了，问题在于调用的时机，如果 `handlerMessage` 方法中第一次判空返回 `true` 而 `②` 处没有 `synchronized` 的话这时如果恰好另一个线程调用了 `enqueue()` 方法就可以入栈新的消息，结果就是新入栈的消息得不到及时执行。所以 `②` 处 `synchronized` 关键字不仅不多余还是必要的。

看到这里如果你对 `synchronized` 的用法和原理还有疑问的话，那就跟我一起深入学习吧。

> 以下内容是对 [深入分析Synchronized原理](https://www.cnblogs.com/aspirant/p/11470858.html)、[synchronized 实现原理](https://xiaomi-info.github.io/2020/03/24/synchronized/)两篇文章的摘录和调整。

### synchronized 使用
`Synchronized` 是 `Java` 中解决并发问题的一种最常用的方法，也是最简单的一种方法。`Synchronized` 的作用主要有三个：

- 原子性：确保线程互斥的访问同步代码块；
- 可见性：内存可见性，保证共享变量的修改能够及时可见，其实是通过 `Java` 内存模型中的 `对一个变量unlock操作之前，必须要同步到主内存中；如果对一个变量进行lock操作，则将会清空工作内存中此变量的值，在执行引擎使用此变量前，需要重新从主内存中load操作或assign操作初始化变量值` 来保证的；
- 有序性：有效解决重排序问题，即 `一个unlock操作先行发生(happen-before)于后面对同一个锁的lock操作`。

`synchronized` 有三种用法：

修饰实例方法：
```
public synchronized void method1() {
    System.out.println("method 1");
}
```

修饰静态方法：
```
public static synchronized void method2() {
    System.out.println("method 2");
}
```

修饰代码块：
```
public static void method3() {
    synchronized (this) {
        System.out.println("method 3");       
    }
}
```

三种用法的区别除了作用范围外最大的区别在于作用对象的不同：

- 修饰实例方法：当前访问此方法的实例对象；
- 修饰静态方法：当前类的 `class` 对象，因此静态方法锁也相当于该类的一个全局锁；
- 修饰代码块：() 中传入的对象。

### synchronized 实现原理
当一个线程访问 `synchronized` 同步代码块时，首先是需要得到锁才能执行同步代码，当退出或者抛出异常时必须要释放锁，那么它是如何来实现这个机制的呢？我们先看一段简单的代码：

```
package com.paddx.test.concurrent;
public class SynchronizedDemo {
    public void method() {
        synchronized (this) {
            System.out.println("Method 1 start");
        }
    }
}
```

查看反编译后结果： 

![image](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/02a342cc7c834c1b8af6538ae9299f20~tplv-k3u1fbpfcp-zoom-1.image)

添加 `synchronized` 关键字后，比普通方法多了两个指令：

- `monitorenter`：线程执行 `monitorenter` 指令时尝试获取 `monitor` 的所有权，当 `monitor` 被占用时对象就会处于锁定状态。
> 1. 如果 `monitor` 的进入数为0，则该线程进入 `monitor`，然后将进入数设置为1，该线程即为 `monitor` 的所有者；
> 2. 如果线程已经占有该 `monitor`，只是重新进入，则进入 `monitor` 的进入数加1；
> 3. 如果其他线程已经占用了 `monitor`，则该线程进入阻塞状态，直到 `monitor` 的进入数为0，再重新尝试获取 `monitor` 的所有权；
- `monitorexit`：执行 `monitorexit` 指令的必须是 `monitor` 的所有者。指令执行时，monitor的进入数减1，如果减1后进入数为0，那线程退出 `monitor`，不再是这个`monitor` 的所有者。其他被这个 `monitor` 阻塞的线程可以尝试去获取这个 `monitor` 的所有权。

> 可以看到编译结果中 `monitorexit` 指令出现了两次，第一次是程序正常退出执行，然后直接执行 `return` 指令，第二次是如果程序异常退出执行，这样就保证了锁一定会释放。

因为 `synchotinzed` 锁拥有可重入的特性，所以避免了当子类同步方法调用父类同步方法时发生死锁的情况。如果没有可重入的特性，那么当对象被锁时不释放锁就无法访问父类同步方法（调用子类同步方法和父类同步方法的是同一个对象），导致死锁。

再看下同步方法：

```
package com.paddx.test.concurrent;

public class SynchronizedMethod {
    public synchronized void method() {
        System.out.println("Hello World!");
    }
}
```

查看反编译后结果：

![image](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4a5a3ee06da345c08a05fd3abfaf11f5~tplv-k3u1fbpfcp-zoom-1.image)

从编译的结果来看，方法的同步并没有通过指令 `monitorenter` 和 `monitorexit` 来完成（理论上其实也可以通过这两条指令来实现），不过相对于普通方法，其常量池中多了 `ACC_SYNCHRONIZED` 标示符。JVM就是根据该标示符来实现方法的同步的：

> 当方法调用时，调用指令将会检查方法的 `ACC_SYNCHRONIZED` 访问标志是否被设置，如果设置了，执行线程将先获取 `monitor`，获取成功之后才能执行方法体，方法执行完后再释放`monitor`。在方法执行期间，其他任何线程都无法再获得同一个 `monitor` 对象。

两种同步方式本质上没有区别，只是方法的同步是一种隐式的方式来实现，无需通过字节码来完成。

通过对反编译代码的解读我们知道 `synchronized` 的实现原理是通过 `monitor` 的对象来完成，其实 `wait/notify` 等方法也依赖于 `monitor` 对象，这就是为什么只有在同步的块或者方法中才能调用 `wait/notify` 等方法，否则会抛出异常的原因。

### Monitor
那我们多次提到的 `monitor` 是什么呢？`monitor` 被翻译做管程或监视器。它是 `synchronized` 实现线程同步的基础。`monitor` 有两个作用：

- 互斥：即同一时刻只允许一个线程访问共享资源；
- 同步：即线程之间如何通信、协作。

在 `Java` 虚拟机（`HotSpot`）中，`Monitor` 是由 `ObjectMonitor` 实现的，其主要数据结构如下（位于 `HotSpot` 虚拟机源码 `ObjectMonitor.hpp` 文件，`C++` 实现的）：

```
ObjectMonitor() {
    _header       = NULL;
    _count        = 0; // 记录个数
    _waiters      = 0,
    _recursions   = 0;
    _object       = NULL;
    _owner        = NULL;
    _WaitSet      = NULL; // 处于wait状态的线程，会被加入到_WaitSet
    _WaitSetLock  = 0 ;
    _Responsible  = NULL ;
    _succ         = NULL ;
    _cxq          = NULL ;
    FreeNext      = NULL ;
    _EntryList    = NULL ; // 处于等待锁block状态的线程，会被加入到该列表
    _SpinFreq     = 0 ;
    _SpinClock    = 0 ;
    OwnerIsThread = 0 ;
  }
```

`ObjectMonitor` 中有两个队列，`_WaitSet` 和 `_EntryList`，用来保存 `ObjectWaiter` 对象列表（每个等待锁的线程都会被封装成 `ObjectWaiter` 对象）， `_owner`指向持有 `ObjectMonitor` 对象的线程，当多个线程同时访问一段同步代码时：
> 1. 首先会进入 `_EntryList` 集合，当线程获取到对象的 `monitor` 后，进入 `_Owner` 区域并把 `monitor` 中的 `owner` 变量设置为当前线程，同时 `monitor` 中的计数器 `count` 加1；
> 2. 若线程调用 `wait()` 方法，将释放当前持有的 `monitor`，`owner` 变量恢复为null，`count` 自减1，同时该线程进入 `_WaitSet` 集合中等待被唤醒；
> 3. 若当前线程执行完毕，也将释放 `monitor`（锁）并复位 `count` 的值，以便其他线程进入获取 `monitor`(锁)；

![image](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c4fe78ad48124ca286f72d32a9eca9e9~tplv-k3u1fbpfcp-zoom-1.image)

如上图所示，一个线程通过1号门进入Entry Set(入口区)，如果在入口区没有线程等待，那么这个线程就会获取监视器成为监视器的Owner，然后执行监视区域的代码。如果在入口区中有其它线程在等待，那么新来的线程也会和这些线程一起等待。线程在持有监视器的过程中，有两个选择，一个是正常执行监视器区域的代码，释放监视器，通过5号门退出监视器；还有可能等待某个条件的出现，于是它会通过3号门到Wait Set（等待区）休息，直到相应的条件满足后再通过4号门进入重新获取监视器再执行。
注意：
当一个线程释放监视器时，在入口区和等待区的等待线程都会去竞争监视器，如果入口区的线程赢了，会从2号门进入；如果等待区的线程赢了会从4号门进入。只有通过3号门才能进入等待区，在等待区中的线程只有通过4号门才能退出等待区，也就是说一个线程只有在持有监视器时才能执行wait操作，处于等待的线程只有再次获得监视器才能退出等待状态。

我们知道 `synchronized` 依赖于 `monitor` 实现，而 `monitor` 其实是依赖于 `JVM` 的 `Mutex Lock` 来实现的，但是使用 `Mutex Lock` 被阻塞的线程会被挂起、等待重新调度并从用户态切换到内核态，对性能有较大影响。而且 `HotSpot` 的作者发现 `大多数锁只会由同一线程并发申请`，基于此在 `JDK 6` 中对锁进行了重要改进，优化了其性能引入了偏向锁、轻量级锁、适应性自旋等实现。

所以目前锁主要存在四种状态：`无锁状态`、`偏向锁状态`、`轻量级锁状态`、`重量级锁状态`。锁可以从偏向锁升级到轻量级锁，再升级的重量级锁。但是锁的升级是单向的，也就是说只能从低到高升级，不会出现锁的降级。其实 `monitor` 机制只是锁升级到重量锁后的工作机制。那锁是如何升级的呢？偏向锁和轻量级锁是如何实现的呢？我们接着看。

> 在 JDK 1.6 中默认是开启偏向锁和轻量级锁的，可以通过-XX:-UseBiasedLocking来禁用偏向锁。

### Java 对象头
之前我们介绍过，当线程进入 `synchronized` 同步代码块时会去获取 `monitor` 锁，获取成功就可以执行此同步代码块。那是如何获取 `monitor` 的呢？其实每一个 `Java` 对象都默认携带 `monitor` 对象，线程获取 `monitor` 锁其实就是获取对象内部的 `monitor`。

在 `JVM` 中，对象在内存中的布局分为三块区域，如下图：

![image](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1fd4f6f30fb34869bf9ce8ae10079c84~tplv-k3u1fbpfcp-zoom-1.image)

- `实例数据`：存放类的属性数据信息，包括父类的属性信息；
- `对齐填充`：由于虚拟机要求 对象起始地址必须是8字节的整数倍。填充数据不是必须存在的，仅仅是为了字节对齐；
- `对象头`：`Java对象头一般占有2个机器码（在32位虚拟机中，1个机器码等于4字节，也就是32bit，在64位虚拟机中，1个机器码是8个字节，也就是64bit），但是 如果对象是数组类型，则需要3个机器码，因为JVM虚拟机可以通过Java对象的元数据信息确定Java对象的大小，但是无法从数组的元数据来确认数组的大小，所以用一块来记录数组长度。`

`Hotspot` 虚拟机的对象头主要包括两部分数据：

- `Mark Word`：存储对象自身的运行时数据，它是实现轻量级锁和偏向锁的关键；
- `Klass Pointer`：类型指针，指向它的类元数据的指针，虚拟机通过这个指针来确定这个对象是哪个类的实例；
- `Array Length`：数组长度。非必须，如果数据对象是数组用来保存数组长度。

64 位虚拟机 `Mark Word` 是 64 bit，在不同状态下其存储数据结构如下：

![image](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f094dfac87124addb79734bf9980f1f4~tplv-k3u1fbpfcp-zoom-1.image)

对象头的最后两位存储了锁的标志位，01是初始状态，未加锁，其对象头里存储的是对象本身的哈希码，随着锁级别的不同，对象头里会存储不同的内容。偏向锁存储的是当前占用此对象的线程ID；而轻量级则存储指向线程栈中锁记录的指针。从这里我们可以看到，“锁”这个东西，可能是个锁记录+对象头里的引用指针（判断线程是否拥有锁时将线程的锁记录地址和对象头里的指针地址比较)，也可能是对象头里的线程ID（判断线程是否拥有锁时将线程的ID和对象头里存储的线程ID比较）。 

下面来看 `synchronized` 锁状态升级流程：

### 偏向锁
#### 流程
当线程访问同步块并获取锁时处理流程如下：

1. 检查 `Mark Word` 的 `线程id`。
2. 如果为空则设置 `CAS` 替换当前 `线程id`。如果替换成功则获取锁成功，如果失败则撤销偏向锁。
3. 如果不为空则检查 `线程id` 为是否为本线程。如果是则获取锁成功，如果失败则撤销偏向锁。

持有偏向锁的线程以后每次进入这个锁相关的同步块时，只需比对一下 `Mark Word` 的 `线程id` 是否为本线程，如果是则获取锁成功。

如果发生线程竞争发生 2、3 步失败的情况则需要撤销偏向锁。

#### 偏向锁的撤销
1. 偏向锁的撤销动作必须等待全局安全点
2. 暂停拥有偏向锁的线程，判断锁对象是否处于被锁定状态
3. 撤销偏向锁恢复到无锁（标志位为 01）或轻量级锁（标志位为 00）的状态

#### 优缺点
优点：
- 只有一个线程执行同步块时进一步提高性能，适用于一个线程反复获得同一锁的情况。偏向锁可以提高带有同步但无竞争的程序性能。

缺点：
- 如果存在竞争会带来额外的锁撤销操作。

### 轻量级锁
##### 加锁
多个线程竞争偏向锁导致偏向锁升级为轻量级锁

1. `JVM` 在当前线程的栈帧中创建 `Lock Record`，并将对象头中的 `Mark Word` 复制到 `Lock Reocrd` 中。（Displaced Mark Word）
2. 线程尝试使用 `CAS` 将对象头中的 `Mark Word` 替换为指向 `Lock Reocrd` 的指针。如果成功则获得锁，如果失败则先检查对象的 `Mark Word` 是否指向当前线程的栈帧如果是则说明已经获取锁，否则说明其它线程竞争锁则膨胀为重量级锁。

#### 解锁
1. 使用 `CAS` 操作将 `Mark Word` 还原
2. 如果第 1 步执行成功则释放完成
3. 如果第 1 步执行失败则膨胀为重量级锁。

#### 优缺点
优点
- 其性能提升的依据是对于绝大部分的锁在整个生命周期内都是不会存在竞争。在多线程交替执行同步块的情况下，可以避免重量级锁引起的性能消耗。

缺点
- 在有多线程竞争的情况下轻量级锁增加了额外开销。

### 自旋锁
自旋是一种获取锁的机制并不是一个锁状态。在膨胀为重量级锁的过程中或重入时会多次尝试自旋获取锁以避免线程唤醒的开销，但是它会占用 `CPU` 的时间因此如果同步代码块执行时间很短自旋等待的效果就很好，反之则浪费了 `CPU` 资源。默认情况下自旋次数是 10 次用户可以使用参数 `-XX : PreBlockSpin` 来更改。那么如何优化来避免此情况发生呢？我们来看适应性自旋。

#### 适应性自旋锁
`JDK 6` 引入了自适应自旋锁，意味着自旋的次数不在固定，而是由前一次在同一个锁上的自旋时间及锁的拥有者的状态来决定。如果对于某个锁很少自旋成功那么以后有可能省略掉自旋过程以避免资源浪费。有了自适应自旋随着程序运行和性能监控信息的不断完善，虚拟机对程序锁的状况预测就会越来越准确，虛拟机就会变得越来越`聪明`了。

#### 优缺点
优点
- 竞争的线程不会阻塞挂起，提高了程序响应速度。避免重量级锁引起的性能消耗。

缺点
- 如果线程始终无法获取锁，自旋消耗 `CPU` 最终会膨胀为重量级锁。

### 重量级锁
在重量级锁中没有竞争到锁的对象会 `park` 被挂起，退出同步块时 `unpark` 唤醒后续线程。唤醒操作涉及到操作系统调度会有额外的开销。也就是上面介绍的 `monitor` 机制了。

锁升级的流程图如下：

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/lock_update_process.jpeg)

清楚了 `synchronized` 同步代码块是如何工作的以及和对象之间的关系，再来看最开始的问题就很清晰了。在 `BackgroundPoster` 中使用两个 `synchronized` 代码块，()中传入的是 `this` 实例对象，也就保证了当通过同一实例对象访问数据入队出队的安全性。

多线程问题是任何操作系统中都相当复杂的一部分，这里只摘录了一小部分，但是基本也可以保证我们在日常开发中能做到心中有数了 `^_^`。
