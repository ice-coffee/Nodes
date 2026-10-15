[toc]

[Java 7 种阻塞队列详解](https://cloud.tencent.com/developer/article/1706970)

[Java并发编程：阻塞队列 ](https://www.cnblogs.com/dolphin0520/p/3932906.html)

### 队列 - Queue

|  | 失败抛出异常 | 失败返回 false |
| --- | --- | --- |
| 添加（尾元素） | `add(e)` | `offer(e)` |
| 移除（首元素） | `remove()` | `poll()` |
| 查看（首元素） | `element()` | `peek()` |

### 双向队列 - Deque

**`首端元素：`**
|  | 失败抛出异常 | 失败返回 false |
| --- | --- | --- |
| 添加 | `addFirst(e)` | `offerFirst(e)` |
| 移除 | `removeFirst()` | `pollFirst()` |
| 查看 | `elementFirst()` | `peekFirst()` |

**`尾端元素：`**
|  | 失败抛出异常 | 失败返回 false |
| --- | --- | --- |
| 添加 | `addLast(e)` | `offerLast(e)` |
| 移除 | `removeLast()` | `pollLast()` |
| 查看 | `elementLast()` | `peekLast()` |

`Queue`、`Deque` 等价方法对比：
|  | Queue | Deque | Queue | Deque |
| --- | --- | --- | --- | --- |
| 添加（尾元素） | `add(e)` | `addLast(e)` | `offer(e)` | `offerLast(e)` |
| 移除（首元素） | `remove()` | `removeFirst()` | `poll()` | `pollFirst()` |
| 查看（首元素） | `element()` | `elementFirst()` | `peek()` | `peekFirst()` |

```java
public class LinkedBlockingDeque<E>
    public boolean add(E e) {
        addLast(e);
        return true;
    }
}
```

`Deque` 实现数据栈（Last-In-Fist-Out）：

|  | 新增方法 | 替代方法 |
| --- | --- | --- |
| 入栈 | `push(e)` | `addFirst(e)` |
| 出栈 | `pop()` | `removeFirst()` |
| 查看 | `peek()` | `peekFirst()` |

### 阻塞队列 - BlockingQueue
> **阻塞队列是`线程安全`的**；

|  | 失败抛出异常 | 失败返回 false | **`阻塞`** | 超时 |
| --- | --- | --- | --- | --- |
| 添加 | `add(e)` | `offer(e)` | `put(e) throws InterruptedException` | `offer(e, time, unit)` |
| 移除 | `remove()` | `poll()` | `take() throws InterruptedException` | `poll(time, unit)` |
| 查看 | `element()` | `peek()` | / | / |

**`常见阻塞队列简介：`**

| 阻塞队列 | 底层数据结构 | 是否有界 | 简介 |
| --- | --- | --- | --- |
| `ArrayBlockingQueue` | 数组 | 有界 | 需要指定容量 |
| `LinkedBlockingQueue` | 链表 | 有界/无界 | 默认容量是 `Integer.MAX_VALUE`，不指定容量时视为无界队列 |
| `PriorityBlockingQueue` | 数组 | 无界 | 要么传入 `Comparator` 要么元素为 `Comparable` 的子类 |
| `DelayQueue` | 数组 | 无界 | 根据时间排序的队列 |
| `SynchronousQueue` | 链表 | 无界 | 同步队列，元素的入队和出队是同步操作，如果相应动作没有准备好则阻塞当前线程等待 |
| `LinkedTransferQueue` | 链表 | 无界 | 入队、出队操作都可以选择是同步还是非同步 |

#### ArrayBlockingQueue

```java
// 单一锁
final ReentrantLock lock;

// 阻塞
private final Condition notEmpty;

// 阻塞
private final Condition notFull;
    
public void put(E e) throws InterruptedException {
    // 判断是否为空
    Objects.requireNonNull(e);
    // 使用可中断锁 - 加锁
    final ReentrantLock lock = this.lock;
    lock.lockInterruptibly();
    try {
        while (count == items.length)
            // 队列已满，阻塞当前线程
            notFull.await();
        enqueue(e);
    } finally {
        // 解锁
        lock.unlock();
    }
}

public E take() throws InterruptedException {
    final ReentrantLock lock = this.lock;
    lock.lockInterruptibly();
    try {
        while (count == 0)
            // 空队列，阻塞当前线程
            notEmpty.await();
        return dequeue();
    } finally {
        lock.unlock();
    }
}
```

#### LinkedBlockingQueue

```java
/**
 * 构造 LinkedBlockingQueue，容量为 Integer#MAX_VALUE.
 */
public LinkedBlockingQueue() {
    this(Integer.MAX_VALUE);
}

/**
 * 构造 LinkedBlockingQueue
 *
 * @param capacity 队列容量
 * @throws 容量小于 1 抛出错误 IllegalArgumentException。
 */
public LinkedBlockingQueue(int capacity) {
    if (capacity <= 0) throw new IllegalArgumentException();
    this.capacity = capacity;
    last = head = new Node<E>(null);
}
```
> **`注意`**：构造 `LinkedBlockingQueue` 时，若没有传入容量，则变为无界队列。
```java
// 出队锁
private final ReentrantLock takeLock = new ReentrantLock();

// 阻塞
private final Condition notEmpty = takeLock.newCondition();

// 入队锁
private final ReentrantLock putLock = new ReentrantLock();

// 阻塞
private final Condition notFull = putLock.newCondition();
```

**`稍微对比一下这两种阻塞队列：`**
相同点：

* 并发安全方式：`ReentrantLock`；
* 阻塞线程方式：`Condition`；

不同点：

* `ArrayBlockingQueue`：数组实现，内存消耗少。
* `LinkedBlockingQueue`：链表实现，内存消耗多，使用分离锁的方式分别控制元素的入队和出队，在高并发场景下性能更好。

**`使用选择`**：
判断内存和并发情况进行选择。

> **`ArrayBlockingQueue` 应该也可以派生一个子类，通过分离锁的方式实现高并发性**。

#### LinkedBlockingDeque
~~

#### PriorityBlockingQueue
`PriorityBlockingQueue` 是一种内部有数组实现的无界阻塞队列。

```java
/**
 * 数组最大大小.
 * 有些虚拟机在数组中保留一些头字。尝试分配更大的数组可能会导致OutOfMemoryError。
 */
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

/**
 * PriorityBlockingQueue 的构造函数之一。
 *
 * @param initialCapacity 数组初始容量
 * @param  comparator 比较器，用于判断元素之间的优先级。若为空，则元素需要实现 `Comparable<T>` 接口，不然将会抛出错误。
 * @throws IllegalArgumentException 初始值小于1时抛出错误。
 */
public PriorityBlockingQueue(int initialCapacity,
                             Comparator<? super E> comparator)
```

**`使用：`**
```java
PriorityBlockingQueue<Student> priorityBlockingQueue = new PriorityBlockingQueue<>();

private static class Student implements Comparable<Student> {
    public String name;
    public int age;

    @Override
    public int compareTo(Student o) {
        //从大到小排队
        return this.age - o.getAge();
    }
}
```

或：

```java
private final Comparator<Student> comparable = new Comparator<Student>() {
    @Override
    public int compare(Student o1, Student o2) {
        return o1.age - o2.age;
    }
};
    
PriorityBlockingQueue<Student> priorityBlockingQueue = new PriorityBlockingQueue<>();

public class Student {
    public String name;
    public int age;
}
```

**`有界阻塞队列和无界阻塞队列的选择：`**
选择无界阻塞队列的情况：

* **不确定容量需求**；
* **避免阻塞生产者**；
* **优先级任务调度**：对于有界队列来说，在队列已满的情况下新的高优任务无法保证优先执行。

选择有界阻塞队列的情况：

* **资源管理**：如果您希望限制队列占用的内存或其他资源，或者想要确保队列不会无限制地增长，有界队列是一个更好的选择。
* **流量控制**：有界队列可以用于控制流量，防止生产者生产速度过快，以适应消费者的处理能力。当队列已满时，生产者会被阻塞。

**`有界队列数据容量的选择：`**
......

#### DelayQueue
`DelayQueue` 是以时间排序的无界阻塞队列，内部由 `PriorityQueue` 实现。
根据类定义可知，入队 `DelayQueue` 的元素必须是 `Delayed` 的派生类。

```java
public class DelayQueue<E extends Delayed> extends AbstractQueue<E>
    implements BlockingQueue<E> { }
```

```java
public interface Delayed extends Comparable<Delayed> {

    /**
     * 返回给定时间单位的剩余延迟。
     *
     * @param unit TimeUnit 枚举
     * @return 剩余的延迟，0或负值表示延迟已经过去。
     */
    long getDelay(TimeUnit unit);
}
```

**`使用：`**

```java
DelayQueue<DelayedUser> delayQueue = new DelayQueue();

public class DelayedUser implements Delayed {
    private String name;
    private long avaibleTime;

    public DelayedUser(String name, long delayTime){
        this.name=name;
        //avaibleTime = 当前时间+ delayTime
        this.avaibleTime=delayTime + System.currentTimeMillis();
    }

    @Override
    public long getDelay(TimeUnit unit) {
        //判断avaibleTime是否大于当前系统时间，并将结果转换成MILLISECONDS
        long diffTime= avaibleTime- System.currentTimeMillis();
        return unit.convert(diffTime,TimeUnit.MILLISECONDS);
    }

    @Override
    public int compareTo(Delayed o) {
        //compareTo用在DelayedUser的排序
        return (int)(this.avaibleTime - ((DelayedUser) o).getAvaibleTime());
    }
}
```

#### SynchronousQueue
[并发编程之 SynchronousQueue 核心源码分析](https://segmentfault.com/a/1190000011207824)

**`特点：`**

* 容量为0；
* 内部有队列、栈两种实现方式；
* 数据生产、消费操作会阻塞当前线程，直到收到相应匹配的操作后一起退出；

`内部为0；` 的结论个人看来并不是说内部不存储元素，而是 `size()` 等查看内部元素个数的返回固定返回 `0`。理由：
```java
static final class QNode {
    volatile QNode next;
    volatile Object item;
    volatile Thread waiter;
    final boolean isData;
    
    // 如果内部容量为 0 的话就不需要 casNext 方法了
    boolean casNext(QNode cmp, QNode val) {
        return next == cmp &&
            U.compareAndSwapObject(this, NEXT, cmp, val);
    }
} 
```

**`使用场景：`**
```java
public class Excutors {
    /**
     * 使用这种方式创建的线程池，如果新入队的任务没有空闲线程处理就会创建新线程处理任务
     */
    public static ExecutorService newCachedThreadPool() {
        return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                      60L, TimeUnit.SECONDS,
                                      new SynchronousQueue<Runnable>());
    }
}   
```

根据 `newCachedThreadPool` 可以知道使用 `SynchronousQueue` 队列时 `java` 希望每一个入队的任务都可以被立即处理而不需要等待。

#### LinkedTransferQueue
[并发编程—— LinkedTransferQueue](https://www.jianshu.com/p/ae6977886cec)

新增方法：
`tryTransfer(E)`：非阻塞方法，当有消费者线程等待时立即将数据传输给消费者线程，否者返回false；
`transfer(E)`：阻塞方法，当有消费者线程等待时立即将数据传输给消费者线程，否者阻塞当前线程等待消费线程；

| 操作类型 | 作用 | 对应方法 |
| --- | --- | --- |
| NOW | 立即返回结果 | E poll()、tryTransfer(E) |
| ASYNC | 异步操作 | offer(E)、put(E)、add(E) |
| SYNC | 同步操作 | E take()、transfer(E) |
| TIMED | 限时操作 | E poll(Long, TimeUtil)、tryTransfer(E, Long, TimeUtil) |

* 出队（消费者）：NOW、SYNC、TIMED；
* 入队（生产者）：ASYNC；

按照源码来看只有当操作类型为 `SYNC`、`TIMED` 时会阻塞当前线程。根据是否阻塞线程区分方法，入队、出队都提供了阻塞和非阻塞的方法，这是不是说明 `LinkedTransferQueue` 的可用场景更多呢？

```java
private E xfer(E e, boolean haveData, int how, long nanos) {
    if (haveData && (e == null))
        throw new NullPointerException();
    Node s = null;                        // the node to append, if needed

    retry:
    for (;;) {                            // restart on append race
        // 从  head 开始
        for (Node h = head, p = h; p != null;) { // find & match first node
            // head 的类型。false 表示这是一个请求数据的节点。
            boolean isData = p.isData;
            // head 的数据
            Object item = p.item;
            // item != null 有 2 种情况,一是 put 操作, 二是 take 的 itme 被修改了(匹配成功)
            // (itme != null) == isData 要么表示 p 是一个 put 操作, 要么表示 p 是一个还没匹配成功的 take 操作
            if (item != p && (item != null) == isData) { 
                // 如果当前操作和 head 操作相同，就没有匹配上，结束循环，进入下面的 if 块。
                if (isData == haveData)   // can't match
                    break;
                // 如果操作不同,匹配成功, 尝试替换 item 成功,
                if (p.casItem(item, e)) { // match
                    // 更新 head
                    for (Node q = p; q != h;) {
                        Node n = q.next;  // update by 2 unless singleton
                        if (head == h && casHead(h, n == null ? q : n)) {
                            h.forgetNext();
                            break;
                        }                 // advance and retry
                        if ((h = head)   == null ||
                            (q = h.next) == null || !q.isMatched())
                            break;        // unless slack < 2
                    }
                    // 唤醒原 head 线程.
                    LockSupport.unpark(p.waiter);
                    return LinkedTransferQueue.<E>cast(item);
                }
            }
            // 找下一个
            Node n = p.next;
            p = (p != n) ? n : (h = head); // Use head if p offlist
        }
        // 如果这个操作不是立刻就返回的类型    
        if (how != NOW) {                 // No matches available
            // 且是第一次进入这里
            if (s == null)
                // 创建一个 node
                s = new Node(e, haveData);
            // 尝试将 node 追加对队列尾部，并返回他的上一个节点。
            Node pred = tryAppend(s, haveData);
            // 如果返回的是 null, 表示不能追加到 tail 节点,因为 tail 节点的模式和当前模式相反.
            if (pred == null)
                // 重来
                continue retry;           // lost race vs opposite mode
            // 如果不是异步操作(即立刻返回结果)
            if (how != ASYNC)
                // 阻塞等待匹配值
                return awaitMatch(s, pred, e, (how == TIMED), nanos);
        }
        return e; // not waiting
    }
}
```
