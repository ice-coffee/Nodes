`StampedLock` 是 `Java1.8` 新增，`StampedLock` 控制锁有三种模式(`写`、`读`、`乐观读`)，一个 `StampedLock` 状态是一个 `long` 值，结构组成如下：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/stempedlock_status.drawio.png)

获取锁的方法会返回当前锁的状态作为票据 `stamp`。

对比 `ReentrantReadWriteLock` 在沒有任何读锁时，才可以取得写锁的场景，如果读取执行情况很多，写入很少的情况下，使用 `ReentrantReadWriteLock` 可能会使写入线程遭遇 **`饥饿问题`** ，也就是写入线程迟迟无法竞争到锁定而一直处于等待状态。

`StampedLock` 的乐观读模式，也就是若读的操作很多，写的操作很少的情况下，你可以乐观地认为，写入与读取同时发生几率很少，因此不悲观地使用完全的读取锁定，程序可以查看读取资料之后，是否遭到写入执行的变更，再采取后续的措施(重新读取变更信息，或者抛出异常) ，这一个小小改进，可大幅度提高程序的吞吐量。

**`示例`**：
```java
class Point {
    private double x, y;
    private final StampedLock sl = new StampedLock();

    /**
     * 独占锁
     */
    void move(double deltaX, double deltaY) {
        long stamp = sl.writeLock();
        try {
            x += deltaX;
            y += deltaY;
        } finally {
            sl.unlockWrite(stamp);
        }
    }

    /**
     * 乐观读锁
     */
    double distanceFromOrigin() {
        long stamp = sl.tryOptimisticRead(); //获得一个乐观读锁
        double currentX = x, currentY = y; //将两个字段读入本地局部变量
        if (!sl.validate(stamp)) { //检查发出乐观读锁后同时是否有其他写锁发生?
            stamp = sl.readLock(); //如果没有，我们再次获得一个读悲观锁
            try {
                currentX = x; // 将两个字段读入本地局部变量
                currentY = y; // 将两个字段读入本地局部变量
            } finally {
                sl.unlockRead(stamp);
            }
        }
        return Math.sqrt(currentX * currentX + currentY * currentY);
    }

    /**
     * 悲观读锁
     */
    void moveIfAtOrigin(double newX, double newY) {
        // Could instead start with optimistic, not read mode
        long stamp = sl.readLock();
        try {
            while (x == 0.0 && y == 0.0) { //循环，检查当前状态是否符合
                long ws = sl.tryConvertToWriteLock(stamp); //将读锁转为写锁
                if (ws != 0L) { //这是确认转为写锁是否成功
                    stamp = ws; //如果成功 替换票据
                    x = newX; //进行状态改变
                    y = newY; //进行状态改变
                    break;
                }
                else { //如果不能成功转换为写锁
                    sl.unlockRead(stamp); //我们显式释放读锁
                    stamp = sl.writeLock(); //显式直接进行写锁 然后再通过循环再试
                }
            }
        } finally {
            sl.unlock(stamp); //释放读锁或写锁
        }
    }
}
```

### 注意事项
对于读多写少的场景 `StampedLock` 性能很好，简单的应用场景基本上可以替代 `ReadWriteLock`，但是 `StampedLock` 的功能仅仅是 `ReadWriteLock` 的子集，在使用的时候，还是有几个地方需要注意一下：

* `StampedLock` 不支持重入。
* `StampedLock` 的悲观读锁、写锁都不支持条件变量。
* 如果线程阻塞在 `StampedLock` 的 `readLock()` 或者 `writeLock()` 上时，此时调用该阻塞线程的 `interrupt()` 方法，会导致 `CPU` 飙升。所以如果需要支持中断功能，一定使用 `readLockInterruptibly()` 和 `writeLockInterruptibly()`。

### 源码解析

用于维护锁状态的各种属性：
```java
// 可以用来表示读锁数量的位数
private static final int LG_READERS = 7;

// 读锁单位，表示每当一个线程获取读锁，锁的状态值加 `RUNIT`
private static final long RUNIT = 1L;
// 10000000：代表写锁所在的位置也就是第8位，第8位为1：表示有写锁，0：表示没有写锁
private static final long WBIT  = 1L << LG_READERS;
// 01111111：127，表示读锁最多可以获取的数量
private static final long RBITS = WBIT - 1L;
// 01111110：126，比读锁最多可以获取的数量 少1
private static final long RFULL = RBITS - 1L;
// 11111111：表示读锁和写锁的所有可能位
private static final long ABITS = RBITS | WBIT;
// ~RBITS（1...10000000）：-128，用于忽略读锁部分
private static final long SBITS = ~RBITS;

// 锁 status 初始值
private static final long ORIGIN = WBIT << 1;
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/stempedlock_status.drawio.png)

在一些组件设计中经常会看到按位操作的处理，值得学习。

#### 节点类

```java
static final class WNode {
    // 前一个节点
    volatile WNode prev;
    // 后一个节点
    volatile WNode next;
    // 读线程所用的链表(实际是一个栈结果)
    volatile WNode cowait;    // list of linked readers
    // 阻塞的线程
    volatile Thread thread;   // non-null while possibly parked
    // 状态
    volatile int status;      // 0, WAITING, or CANCELLED
    // 读模式还是写模式
    final int mode;           // RMODE or WMODE
    WNode(int m, WNode p) { mode = m; prev = p; }
}
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/stempedlock_CLH.drawio.png)

#### 写锁
获取写锁：
```java
public long writeLock() {
    long s, next;  // bypass acquireWrite in fully unlocked case only
    return ((((s = state) & ABITS) == 0L &&
             U.compareAndSwapLong(this, STATE, s, next = s + WBIT)) ?
            next : acquireWrite(false, 0L));
}
    
private long acquireWrite(boolean interruptible, long deadline) {
    // node:当前线程的等待节点
    // p:尾部节点
    WNode node = null, p;
    for (int spins = -1;;) {
        // m: 仅包含锁模式部分,也就是当前 statu 值的前 8 位
        // s: 当前锁状态
        // ns: 获取锁后的新状态
        long m, s, ns;
        if ((m = (s = state) & ABITS) == 0L) {
            // 1. ABITS 掩码用来提取读写锁的位信息。如果没有线程持有写锁（即 m == 0），尝试使用 CAS 操作获取写锁，并更新 state。
            if (U.compareAndSwapLong(this, STATE, s, ns = s + WBIT))
                return ns;
        }
        else if (spins < 0)
            // 2. 无法立即获取锁,即开始自旋
            spins = (m == WBIT && wtail == whead) ? SPINS : 0;
        else if (spins > 0) {
            // 随机控制自旋次数
            if (LockSupport.nextSecondarySeed() >= 0)
                --spins;
        }
        else if ((p = wtail) == null) {
            // 3. 自旋失败进入队列
            WNode hd = new WNode(WMODE, null);
            if (U.compareAndSwapObject(this, WHEAD, null, hd))
                wtail = hd;
        }
        else if (node == null)
            node = new WNode(WMODE, p);
        else if (node.prev != p)
            node.prev = p;
        else if (U.compareAndSwapObject(this, WTAIL, p, node)) {
            p.next = node;
            break;
        }
    }

    // 线程节点入队后处理
    for (int spins = -1;;) {
        // h:头节点
        // np:当前节点的前一个节点
        // pp:
        WNode h, np, pp; int ps;
        // 当前队列中只存在一个等待节点,也就是当前线程节点时尝试自旋获取锁
        if ((h = whead) == p) {
            if (spins < 0)
                spins = HEAD_SPINS;
            else if (spins < MAX_HEAD_SPINS)
                spins <<= 1;
            // 自旋取锁,自旋失败退出循环
            for (int k = spins;;) {
                long s, ns;
                if (((s = state) & ABITS) == 0L) {
                    if (U.compareAndSwapLong(this, STATE, s,
                            ns = s + WBIT)) {
                        whead = node;
                        node.prev = null;
                        return ns;
                    }
                }
                else if (LockSupport.nextSecondarySeed() >= 0 &&
                        --k <= 0)
                    break;
            }
        }
        else if (h != null) { // help release stale waiters
            WNode c; Thread w;
            while ((c = h.cowait) != null) {
                if (U.compareAndSwapObject(h, WCOWAIT, c, c.cowait) &&
                        (w = c.thread) != null)
                    U.unpark(w);
            }
        }
        if (whead == h) {
            if ((np = node.prev) != p) {
                if (np != null)
                    (p = np).next = node;   // stale
            }
            else if ((ps = p.status) == 0)
                U.compareAndSwapInt(p, WSTATUS, 0, WAITING);
            else if (ps == CANCELLED) {
                if ((pp = p.prev) != null) {
                    node.prev = pp;
                    pp.next = node;
                }
            }
            else {
                long time; // 0 argument to park means no timeout
                if (deadline == 0L)
                    time = 0L;
                else if ((time = deadline - System.nanoTime()) <= 0L)
                    return cancelWaiter(node, node, false);
                Thread wt = Thread.currentThread();
                U.putObject(wt, PARKBLOCKER, this);
                node.thread = wt;
                if (p.status < 0 && (p != h || (state & ABITS) != 0L) &&
                        whead == h && node.prev == p)
                    U.park(false, time);  // emulate LockSupport.park
                node.thread = null;
                U.putObject(wt, PARKBLOCKER, null);
                if (interruptible && Thread.interrupted())
                    return cancelWaiter(node, node, true);
            }
        }
    }
}
```

释放写锁：
```java
public void unlockWrite(long stamp) {
    WNode h;
    if (state != stamp || (stamp & WBIT) == 0L)
        throw new IllegalMonitorStateException();
    // 这行代码实际有两个作用：
    // 1. 更新版本号加1
    // 2. 释放写锁
    // stamp + WBIT实际会把state的第8位置为0，也就相当于释放了写锁
    // 同时会进1，也就是高24位整体加1了
    state = (stamp += WBIT) == 0L ? ORIGIN : stamp;
    // 如果头节点不为空，并且状态不为0，调用release方法唤醒它的下一个节点
    if ((h = whead) != null && h.status != 0)
        release(h);
}
```

##### 自旋锁热竞争

在 `StempedLock` 中对自旋使用比较有意思的一点是对自旋次数的随机控制：

```java
if (LockSupport.nextSecondarySeed() >= 0)
    --spins;
}
```

在高并发编程中，自旋锁是一种常用的锁实现方式，它通过让线程不断尝试获取锁来避免线程上下文切换的开销。然而，如果自旋时间太长，会浪费CPU资源；如果太短，则可能频繁进行线程切换，反而增加开销。

引入随机数来控制自旋次数的机制主要有以下几个作用：

1. `分散锁争用`：通过随机数调整自旋次数，可以避免多个线程在同一时间点进行相同次数的自旋尝试。这种分散可以减轻锁争用的“热点”效应，减少同时争用锁的线程数。
2. `动态调整自旋策略`：随机数的引入使得自旋策略变得动态，不同线程的自旋时间不完全相同。这种动态调整可以让一些线程更早退出自旋，转而进入阻塞状态；而其他线程则可能继续自旋等待锁的释放，从而在一定程度上平衡了自旋和阻塞的开销。
3. `避免自旋浪费`：通过随机化自旋次数，可以减少某些线程在无谓自旋中的浪费。对于一些情况下，例如锁竞争激烈的场景下，调整自旋策略可以避免大量线程长时间自旋而不获得锁，导致CPU资源浪费。


#### 乐观读锁
获取乐观读锁：

```java
public long tryOptimisticRead() {
    long s;
    return (((s = state) & WBIT) == 0L) ? (s & SBITS) : 0L;
}
```
如果没有写锁，就返回锁状态的高 **`25`** 位，这里把写所在位置一起返回了，是为了后面检测数据有没有被写过。

使用乐观读时访问受保护的数据需要先判断写状态是否发生过变化：

```java
public boolean validate(long stamp) {
    // 强制加入内存屏障，刷新数据
    U.loadFence();
    return (stamp & SBITS) == (state & SBITS);
}
```

### 参考

* [Java 8 - StampedLock](https://pdai.tech/md/java/java8/java8-stampedlock.html#stampedlock)
* [比读写锁更快的 StampedLock](https://ost.51cto.com/posts/15445)
* [Java同步器之StampedLock源码分析](https://www.cnblogs.com/ciel717/p/16228661.html)
