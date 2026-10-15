[toc]

## Lock
![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/lock_uml.drawio.png)

## AQS
[从ReentrantLock的实现看AQS的原理及应用 - 美团技术团队](https://tech.meituan.com/2019/12/05/aqs-theory-and-apply.html)

[为什么需要 AQS](https://www.cnblogs.com/binarylei/p/12555166.html#1-%E4%B8%BA%E4%BB%80%E4%B9%88%E9%9C%80%E8%A6%81-aqs)

非公平锁都会产生线程饥饿吗

* synchronize 会出现
* AQS 非公平模式 ？

`AQS`（AbstractQueuedSynchronizer），它是一个同步队列，用于在线程竞争时将线程封装为节点并排队。`AQS` 是基于 `CLH` 的双向链表变体。双向链表可以更快速的处理已经取消的线程节点。还有一点不同的是 `CLH` 是通过自旋实现线程等待 `AQS` 是通过 `LockSupport` 实现线程的挂起和唤醒。

并且 `AQS` 的内部类实现了 `Condition` 接口，用于实现 `Object.wait()`、`Object.notify()`、`Object.notifyAll()`  能力。

`AQS` 提供了两种纬度的策略：

* **是否公平**
* **是否独占**

### CLH
`CLH`（Craig, Landin, and Hagersten）队列锁是一种高效的自旋锁实现，用于在多处理器系统中实现公平的锁机制。`CLH` 锁基于链表结构，确保锁的获取顺序与请求顺序一致，从而避免了线程饥饿问题。

`CLH` 自旋锁示例：

* 节点类：

```java
class CLHNode {
    // 锁状态标识：true 表示线程正在等待锁，false 表示线程已释放锁
    volatile boolean isLocked = true;
}
```

* CLH队列锁：

```java
import java.util.concurrent.atomic.AtomicReference;

public class CLHLock {
    // 尾节点，指向等待队列的最后一个节点
    private final AtomicReference<CLHNode> tail;
    // 当前线程的节点
    private final ThreadLocal<CLHNode> currentNode;
    // 当前线程的前驱节点
    private final ThreadLocal<CLHNode> predecessorNode;

    public CLHLock() {
        this.tail = new AtomicReference<>(new CLHNode());
        this.currentNode = ThreadLocal.withInitial(CLHNode::new);
        this.predecessorNode = ThreadLocal.withInitial(() -> null);
    }

    public void lock() {
        CLHNode node = currentNode.get();
        node.isLocked = true;
        CLHNode pred = tail.getAndSet(node);
        predecessorNode.set(pred);
        while (pred.isLocked) {
            // 自旋等待前驱节点释放锁
        }
    }

    public void unlock() {
        CLHNode node = currentNode.get();
        node.isLocked = false;
        // 当前节点变为前驱节点
        currentNode.set(predecessorNode.get());
    }

    public static void main(String[] args) {
        CLHLock lock = new CLHLock();

        Runnable task = () -> {
            lock.lock();
            try {
                // 临界区代码
                System.out.println(Thread.currentThread().getName() + " acquired the lock.");
            } finally {
                lock.unlock();
            }
        };

        // 启动多个线程测试CLH锁
        for (int i = 0; i < 5; i++) {
            new Thread(task, "Thread-" + i).start();
        }
    }
}
```


``` java
public void test() throw Exception {
    // 1.初始化选择公平锁、非公平锁
    ReentrantLock lock = new ReentrantLock(true);
    // 2.可用于代码块
    lock.lock();
    try {
        try {
            // 3.支持多种加锁方式，比较灵活; 具有可重入特性
            if(lock.tryLock(100, TimeUnit.MILLISECONDS)){

            }
        } finally {
            // 4.手动释放锁
            lock.unlock()
        }
    } finally {
        lock.unlock();
    }
}
```

`AQS` 全称 `AbstractQueuedSynchorinzer - 抽象同步队列`。

`AQS` 内部有两个重要变量：

* `state`：表示加锁状态
* 当前加锁的线程

`AQS` 核心思想是，如果被请求的共享资源空闲，那么就将当前请求资源的线程设置为有效的工作线程，将共享资源设置为锁定状态；如果共享资源被占用，就需要一定的阻塞等待唤醒机制来保证锁分配。这个机制主要用的是 `CLH` 队列的变体实现的，将暂时获取不到锁的线程加入到队列中。

`kotlin` 协程中 `Mutex` 的实现原理和 `AQS` 很相似。

相似：

- 都有状态值表示当前资源是否被占用。
- 都通过双向链表保存等待线程程（或协程）。
- 链表节点都封装了请求资源的线程（或协程）。
- 用法也相似。

不同：

- `AQS` 是可重入锁，`Mutex` 是不可重入锁。

### Condition
`Condition` 定义了线程等待和唤醒的接口，配合 `AQS` 可以实现 `Object` 的 `wait()` 和 `notify()` 方法能力。

线程等待：

* await()
* await(long time, TimeUnit unit)
* awaitNanos(long nanosTimeout)
* awaitUntil(Date deadline)
* awaitUninterruptibly()：不响应 `interrupt` 事件。

线程唤醒，从条件队列转入 `AQS` 队列：

* signal()：唤醒条件队列中的第一个线程。
* signalAll()：唤醒条件队列中的所有线程。

### 源码分析
节点类：
```java
static final class Node {
    /**
     * 0：当一个Node被初始化的时候的默认值
     * CANCELLED：为1，表示线程获取锁的请求已经取消了
     * SIGNAL：为-1，表示后续线程需要被唤醒（即前驱节点在释放锁或取消时需要唤醒其后继节点）。当节点进入等待队列时被设置为 SIGNAL。
     * CONDITION：为-2，表示节点在条件队列中等待。节点在等待某个条件（如在 Condition.await() 中调用）时，会进入此状态。
     * PROPAGATE：为-3，共享模式下用于传递唤醒信号的状态。它表明后续的节点需要被唤醒。
     */
    volatile int waitStatus;
    
    /**
     * AQS 队列中当前节点的前驱结点、后驱结点
     */
    volatile Node prev;
    volatile Node next;
    /**
     * 条件队列中指向下一个等待条件相同的节点，操作 nextWaiter 时当前线程已经获取了锁，所以是线程安全的
     */
    Node nextWaiter;
    
    /**
     * 当前节点关联的线程
     */
    volatile Thread thread;
}
```

队列类：
```java
// 同步状态，非零表示锁已被某线程持有，值代表重入次数
private volatile int state;
```

`AQS` 中实际包含两个队列：

1. `Lock` 队列，用于排队获取锁。
2. `Condition` 队列，用于在不满足条件时实现线程等待和唤醒。

两个队列间节点的运行示意如下：
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/lock_AQS.drawio.png)

### ReentrantLock

公平锁、非公平锁的区别：

```java
static final class NonfairSync extends Sync {

    /**
     * 立即尝试获取锁，获取失败时进入队列排队等待
     */
    final void lock() {
        if (compareAndSetState(0, 1))
            setExclusiveOwnerThread(Thread.currentThread());
        else
            acquire(1);
    }
}

static final class FairSync extends Sync {

	/**
     * 进入队列排队等待
     */
    final void lock() {
        acquire(1);
    }
}
```

### ReentrantReadWriteLock

读写锁
锁降级

线程饥饿问题：
`ReentrantReadWriteLock` 在沒有任何读写锁时，才可以取得写入锁。然而，如果读取执行情况很多，写入很少的情况下，使用 `ReentrantReadWriteLock` 可能会使写入线程遭遇饥饿问题，也就是写入线程迟迟无法竞争到锁定而一直处于等待状态。

这种场景下可以使用 `StempedLock` 的乐观读锁替代悲观读锁来解决。

## Lock vs synchronized
[ReentrantLock和synchronized两种锁定机制的对比](https://www.forxiu.cn/comparison-of-reentrantlock-and-synchronized-locking-mechanisms/)

`Lock` 锁提供了比 `synchorinzed` 更灵活的加锁方式。

|  | synchronized | Lock |
| --- | --- | --- |
| 超时 | 不支持 | 支持 |
| 中断 | 不支持 | 支持 |
| 公平 | 非公平 | 公平/非公平 |
| 共享 | 独占 | 独占/共享 |
| 原理 | 监视器（`monitor`） | `AQS` |

使用 `synchronized` 实现阻塞队列：
```java
import java.util.LinkedList;
import java.util.Queue;

public class BlockingQueue {
    private final Queue<Integer> queue = new LinkedList<>();
    private final int CAPACITY = 10;

    public void produce(int value) throws InterruptedException {
        synchronized (this) {
            while (queue.size() == CAPACITY) {
                wait();
            }
            queue.add(value);
            System.out.println("Produced " + value);
            notify();
        }
    }

    public int consume() throws InterruptedException {
        synchronized (this) {
            while (queue.isEmpty()) {
                wait();
            }
            int value = queue.poll();
            System.out.println("Consumed " + value);
            notify();
            return value;
        }
    }
}
```

使用 `AQS` 实现阻塞队列：
```java
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.LinkedList;
import java.util.Queue;

public class BlockingQueue {
    private final Queue<Integer> queue = new LinkedList<>();
    private final int CAPACITY = 10;
    private final Lock lock = new ReentrantLock();
    private final Condition notFull = lock.newCondition();
    private final Condition notEmpty = lock.newCondition();

    public void produce(int value) throws InterruptedException {
        lock.lock();
        try {
            while (queue.size() == CAPACITY) {
                notFull.await();
            }
            queue.add(value);
            System.out.println("Produced " + value);
            notEmpty.signal();
        } finally {
            lock.unlock();
        }
    }

    public int consume() throws InterruptedException {
        lock.lock();
        try {
            while (queue.isEmpty()) {
                notEmpty.await();
            }
            int value = queue.poll();
            System.out.println("Consumed " + value);
            notFull.signal();
            return value;
        } finally {
            lock.unlock();
        }
    }
}
```
