[toc]

[JAVA中创建线程池的五种方法及比较](https://www.cnblogs.com/pcheng/p/13540619.html)

## 使用

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/Java_Executor_%E7%B1%BB%E5%9B%BE.png)

## ThreadPoolExecutor

``` java
public ThreadPoolExecutor(
    int corePoolSize,
    int maximumPoolSize,
    long keepAliveTime,
    TimeUnit unit,
    BlockingQueue<Runnable> workQueue,
    ThreadFactory threadFactory,
    RejectedExecutionHandler handler) 
```

线程池构造函数共有 `7` 个参数：

* `corePoolSize`：核心线程数，线程池中始终存活的线程数；
* `maximumPoolSize`：最大线程数，线程池中允许的最大线程数；
* `keepAliveTime`：存活时间，线程没有任务执行时最多保持多久时间会终止；
* `unit`：单位，参数 `keepAliveTime` 的时间单位；
* `workQueue`：一个阻塞队列，用来存储等待执行的任务，均为线程安全；
* `threadFactory`：线程工厂，主要用来创建线程，默认正常优先级、非守护线程；
* `handler`：拒绝策略，拒绝处理任务时的策略；

#### 常用线程池类型

* `Executors.newCachedThreadPool`：创建一个可缓存的线程池，若线程数超过处理所需，缓存一段时间后会回收，若线程数不够，则新建线程。
* `Executors.newFixedThreadPool`：创建一个固定大小的线程池，可控制并发的线程数，超出的线程会在队列中等待。
* `Executors.newScheduledThreadPool`：创建一个周期性的线程池，支持定时及周期性执行任务。
* `Executors.newSingleThreadExecutor`：创建一个单线程的线程池，可保证所有任务按照指定顺序(`FIFO`, `LIFO`, 优先级)执行。

Q：为什么不建议使用 `Executors` 创建线程池。
A：因为 `Executors` 提供的线程池较为固化，无法适应千变万化的需求，所以建议根据需求实际创建线程池。

#### 阻塞队列
[数据结构 - 阻塞队列](https://app.yinxiang.com/shard/s58/nl/10744683/78362159-f78d-4d66-8503-c731ff6cf47a/)

#### 拒绝策略
[Java 线程池拒绝策略](https://cloud.tencent.com/developer/article/1520860)：说明 `Java` 内置拒绝策略和一些第三方拒绝策略实现。

`Java` 线程池内置了四种拒绝策略：

* `CallerRunsPolicy`：如果线程池未关闭，则在 `execute` 方法调用的线程中执行任务。
* `AbortPolicy`：直接上抛 `RejectedExecutionException` 异常。
* `DiscardOldestPolicy`：移除等待队列首元素后再次调用 `execute`。
* `DiscardPolicy`：丢弃任务，不做任何处理。

自定义拒绝策略举例：

* `dubbo` 中的线程拒绝策略

```java
public class AbortPolicyWithReport extends ThreadPoolExecutor.AbortPolicy {

    protected static final Logger logger = LoggerFactory.getLogger(AbortPolicyWithReport.class);

    private final String threadName;

    private final URL url;

    private static volatile long lastPrintTime = 0;

    private static Semaphore guard = new Semaphore(1);

    public AbortPolicyWithReport(String threadName, URL url) {
        this.threadName = threadName;
        this.url = url;
    }

    @Override
    public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
        String msg = String.format("Thread pool is EXHAUSTED!" +
                        " Thread Name: %s, Pool Size: %d (active: %d, core: %d, max: %d, largest: %d), Task: %d (completed: %d)," +
                        " Executor status:(isShutdown:%s, isTerminated:%s, isTerminating:%s), in %s://%s:%d!",
                threadName, e.getPoolSize(), e.getActiveCount(), e.getCorePoolSize(), e.getMaximumPoolSize(), e.getLargestPoolSize(),
                e.getTaskCount(), e.getCompletedTaskCount(), e.isShutdown(), e.isTerminated(), e.isTerminating(),
                url.getProtocol(), url.getIp(), url.getPort());
        logger.warn(msg);
        dumpJStack();
        throw new RejectedExecutionException(msg);
    }

    private void dumpJStack() {
       //省略实现
    }
}
```
可以看到，当dubbo的工作线程触发了线程拒绝后，主要做了三个事情，原则就是尽量让使用者清楚触发线程拒绝策略的真实原因。

1. **输出了一条警告级别的日志**，日志内容为线程池的详细设置参数，以及线程池当前的状态，还有当前拒绝任务的一些详细信息。可以说，这条日志，使用dubbo的有过生产运维经验的或多或少是见过的，这个日志简直就是日志打印的典范，其他的日志打印的典范还有spring。得益于这么详细的日志，可以很容易定位到问题所在
2. **输出当前线程堆栈详情**，这个太有用了，当你通过上面的日志信息还不能定位问题时，案发现场的dump线程上下文信息就是你发现问题的救命稻草。
3. **继续抛出拒绝执行异常**，使本次任务失败，这个继承了JDK默认拒绝策略的特性

* `Netty` 中的线程池拒绝策略

```java
private static final class NewThreadRunsPolicy implements RejectedExecutionHandler {
        NewThreadRunsPolicy() {
            super();
        }

        public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
            try {
                final Thread t = new Thread(r, "Temporary task executor");
                t.start();
            } catch (Throwable e) {
                throw new RejectedExecutionException(
                        "Failed to start a new thread", e);
            }
        }
    }
```

Netty中的实现很像JDK中的CallerRunsPolicy，舍不得丢弃任务。不同的是，CallerRunsPolicy是直接在调用者线程执行的任务。而 Netty是新建了一个线程来处理的。

所以，Netty的实现相较于调用者执行策略的使用面就可以扩展到支持高效率高性能的场景了。但是也要注意一点，Netty的实现里，在创建线程时未做任何的判断约束，也就是说只要系统还有资源就会创建新的线程来处理，直到new不出新的线程了，才会抛创建线程失败的异常

* `activeMq` 中的线程池拒绝策略

```java
new RejectedExecutionHandler() {
                @Override
                public void rejectedExecution(final Runnable r, final ThreadPoolExecutor executor) {
                    try {
                        executor.getQueue().offer(r, 60, TimeUnit.SECONDS);
                    } catch (InterruptedException e) {
                        throw new RejectedExecutionException("Interrupted waiting for BrokerService.worker");
                    }

                    throw new RejectedExecutionException("Timed Out while attempting to enqueue Task.");
                }
            });
```

activeMq中的策略属于最大努力执行任务型，当触发拒绝策略时，在尝试一分钟的时间重新将任务塞进任务队列，当一分钟超时还没成功时，就抛出异常

* `pinpoint` 中的线程池拒绝策略

```java
public class RejectedExecutionHandlerChain implements RejectedExecutionHandler {
    private final RejectedExecutionHandler[] handlerChain;

    public static RejectedExecutionHandler build(List<RejectedExecutionHandler> chain) {
        Objects.requireNonNull(chain, "handlerChain must not be null");
        RejectedExecutionHandler[] handlerChain = chain.toArray(new RejectedExecutionHandler[0]);
        return new RejectedExecutionHandlerChain(handlerChain);
    }

    private RejectedExecutionHandlerChain(RejectedExecutionHandler[] handlerChain) {
        this.handlerChain = Objects.requireNonNull(handlerChain, "handlerChain must not be null");
    }

    @Override
    public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
        for (RejectedExecutionHandler rejectedExecutionHandler : handlerChain) {
            rejectedExecutionHandler.rejectedExecution(r, executor);
        }
    }
}
```

pinpoint的拒绝策略实现很有特点，和其他的实现都不同。他定义了一个拒绝策略链，包装了一个拒绝策略列表，当触发拒绝策略时，会将策略链中的rejectedExecution依次执行一遍。

### 常用方法

#### `execute(Runnable): Void`

```java
public void execute(Runnable command) {
    if (command == null)
        throw new NullPointerException();
    /*
     * 三个步骤
     *
     * 1. 如果当前工作线程数小于核心线程数，那么通过原子函数
     *    addWorker 创建新的线程并运行。创建工作线程成功后直
     *    直接返回。
     *
     * 2. 如果当前工作线程数不小于核心线程数，那么检查当前
     *    线程池状态并将任务入队。入队成功后需再次检查线程池
     *    状态，非 RUNNING 则将任务回退。
     *
     * 3. 如果当前工作线程数不小于核心线程数，且入队失败，
     *    那么尝试执行 addWorker 函数执行任务（因为入队失
     *    败可能是队列策略的问题），如果失败触发拒绝策略。
     */
    int c = ctl.get();
    if (workerCountOf(c) < corePoolSize) {
        if (addWorker(command, true))
            return;
        c = ctl.get();
    }
    boolean isRunning = isRunning(c);
    boolean offered = workQueue.offer(command);
    Log.e("aaaaaa", isRunning + "_" + offered);
    if (isRunning && offered) {
        int recheck = ctl.get();
        if (! isRunning(recheck) && remove(command))
            reject(command);
        else if (workerCountOf(recheck) == 0)
            addWorker(null, false);
    }
    else if (!addWorker(command, false))
        reject(command);
}
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/thread_pool_execute.jpg)

通过分析可知，工作线程数

#### `submit(...): Future<T>`

```java
public Future<?> submit(Runnable task)

public <T> Future<T> submit(Runnable task, T result)

public <T> Future<T> submit(Callable<T> task)
```

`submit` 和 `execute` 都是用于向任务池中添加任务，不同的是 `submit` 方法会返回 `Future` 对象，使用它可以操作任务，例如：查看状态、取消任务、获取任务计算结果等。

#### `shutdown、shutdownNow`
它们的作用都是用于关闭线程池，线程池关闭后将不在接收新的任务，它们区别在于：

* `shutdown`：正在运行的任务和已经入队等待的任务会继续执行完毕。
* `shutdownNow`：对正在执行的工作线程执行中断操作并清空队列中等待执行的任务。

#### 线程状态

* `getActiveCount()`：当前活跃工作线程数。
* `getCompletedTaskCount()`：`getActiveCount()` + 已完成任务数。
* `getTaskCount()`：`getCompletedTaskCount()` + 等待任务数。

> 这几个方法的作用是可以通过它们监控线程池状态。

### 常见问题

1. 使用无界队列时若线程阻塞会使创建线程数量过多，导致OOM。
2. 线程池默认拒绝策略是上抛 `Exception`，未合理处理会导致程序 `crash`。

## ForkJoinPool
[UC线程池: Fork/Join框架详解](https://pdai.tech/md/java/thread/java-thread-x-juc-executor-ForkJoinPool.html)

`ForkJoinPool` 是 `JDK 7` 加入的一个线程池类。`Fork/Join` 技术是分治算法(Divide-and-Conquer)的并行实现，它是一项可以获得良好的并行性能的简单且高效的设计技术。目的是为了帮助我们更好地利用多处理器带来的好处，使用所有可用的运算能力来提升应用的性能。

## ScheduledThreadPoolExecutor
调度线程池。对比 `ThreadPoolExecutor` 新增如下方法：

* `schedule(Runnable command, long delay, TimeUnit unit)`：延迟执行任务；
* `schedule(Callable<V> callable, long delay, TimeUnit unit)`：同上；
* `scheduleAtFixedRate(Runnable command, long initialDelay, long period, TimeUnit unit)`：以固定的频率执行，`period`（周期）指的是两次成功执行之间的时间。上一个任务开始的时间计时，一个 `period` 后，检测上一个任务是否执行完毕，如果上一个任务执行完毕，则当前任务立即执行，如果上一个任务没有执行完毕，则需要等上一个任务执行完毕后立即执行；
* `scheduleWithFixedDelay(Runnable command, long initialDelay, long delay, TimeUnit unit)`：以固定的延时执行，`delay`（延时）指的是一次执行终止和下一次执行开始之间的延迟。

## 源码分析

### 数据结构

工作线程：`HashSet`

``` java
private final HashSet<Worker> workers = new HashSet<>();
```

任务队列：`阻塞队列`

``` java
private final BlockingQueue<Runnable> workQueue;
```

### 线程池状态
`Java` 线程池中的状态是通过 `AtomicInteger` 保持，它将一个 32 位的 int 型数据由高 3 位表示状态，低 29 表示工作线程数量。

| 31 ~ 29 | 28 ~ 0 |
|----|-----|
| 状态 | 数量 |

通过这种方式可以有效防止多线程状态下竞态条件的发生保证两个数据的安全性。

```java
private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));
private static final int COUNT_BITS = Integer.SIZE - 3;
private static final int COUNT_MASK = (1 << COUNT_BITS) - 1;

// runState is stored in the high-order bits
private static final int RUNNING    = -1 << COUNT_BITS;
private static final int SHUTDOWN   =  0 << COUNT_BITS;
private static final int STOP       =  1 << COUNT_BITS;
private static final int TIDYING    =  2 << COUNT_BITS;
private static final int TERMINATED =  3 << COUNT_BITS;

// Packing and unpacking ctl
private static int runStateOf(int c)     { return c & ~COUNT_MASK; }
private static int workerCountOf(int c)  { return c & COUNT_MASK; }
private static int ctlOf(int rs, int wc) { return rs | wc; }
```

`Java` 中的线程池状态主要包括以下几种：

* **`RUNNING（运行中）`**：

初始状态或者线程池被创建后的正常运行状态。在这个状态下，线程池可以接受新的任务，并且会尽力执行提交的任务。

* **`SHUTDOWN（关闭中）`**：

线程池进入关闭状态，不再接受新的任务，但会继续执行已经提交的任务，包括等待队列中的任务。

触发方式：调用 `shutdown` 方法。

* **`STOP（停止）`**：

线程池进入停止状态，不再接受新的任务，也不会执行已经提交的任务。正在执行的任务会被中断，等待队列中的任务会被移除。

触发方式：调用 `shutdownNow` 方法。

* **`TIDYING（整理中）`**：

所有的任务都已经终止，工作线程数量为零，线程池进入 TIDYING 状态。在这个状态下，线程池会执行一些清理操作，例如调用 terminated 钩子方法。

* **`TERMINATED（已终止）`**：

线程池已经完全终止，不再处理任何任务。

触发方式：当进入 `TIDYING` 状态的清理操作完成后，线程池会进入 `TERMINATED` 状态。

这些状态之间的转换是有规律的，通常是按照 RUNNING -> SHUTDOWN -> STOP -> TIDYING -> TERMINATED 的顺序。其中，SHUTDOWN、STOP、TIDYING 这几个中间状态是过渡状态，用于表示线程池正在关闭的过程中。

状态的变化通常是由线程池的关闭方法触发的，比如 shutdown 和 shutdownNow 方法。调用这些方法会改变线程池的状态，并触发相应的状态转换。在状态转换的过程中，线程池会根据不同的状态执行相应的操作，保证任务的正确执行和资源的正确释放。

### 线程池如何保证核心线程不被销毁
[线程池如何保证核心线程不被销毁](https://blog.csdn.net/smile_from_2015/article/details/105259789)

这是由于 `workQueue` 是阻塞队列，当通过 `take` 移除元素，如果当前队列为空，则阻塞当前队列。

``` java
private Runnable getTask() {
    for (;;) {
        // timed == false 代表队列中没有任务时，阻塞当前线程
        // Are workers subject to culling?
        boolean timed = allowCoreThreadTimeOut || wc > corePoolSize;
        try {
            Runnable r = timed ?
                workQueue.poll(keepAliveTime, TimeUnit.NANOSECONDS) :
                workQueue.take();
            if (r != null)
                return r;
        } catch (InterruptedException retry) {
            
        }
    }
}
```

### 线程数设置
[合理配置线程池的线程数量](https://juejin.cn/post/7072281409053786120)
[什么是CPU密集型、IO密集型？](https://zhuanlan.zhihu.com/p/62766037)
[面试问我，创建多少个线程合适？我该怎么说](https://juejin.cn/post/6844904117547057159)
[线程池的数量和线程池中线程数量如何设置-理论篇](https://juejin.cn/post/7066675779966337031)
[线程池的数量和线程池中线程数量如何设置-实践篇](https://juejin.cn/post/7067183465224994852)

如果创建的线程池是针对于项目整体，那么可以创建两种线程池，一种处理CPU密集型任务，一种处理IO密集型任务。

* **`CPU密集型 (CPU-bound)`**：

CPU密集型任务是指主要需要大量计算操作的任务。这些任务的执行主要受限于计算能力，而不是外部的I/O操作。在这种情况下，CPU的运算能力是决定任务执行速度的瓶颈。

特点：

1. 对CPU的计算资源需求较高。
2. 任务的执行时间主要由CPU的计算能力决定。
3. 通常在处理数学运算、图形处理、科学模拟等方面表现出色。

核心线程数量推荐：CPU核心数 + 1。

> 博客中说明核心线程数量值要 +1 的作用在于`线程恰好在某时因为发生一个页错误或者因其他原因而暂停，刚好有一个“额外”的线程，可以确保在这种情况下CPU周期不会中断工作`。个人认为是如果出现线程阻塞等情况可以有一个额外的线程继续执行，以保证执行性能不受影响。

* **`IO密集型 (I/O-bound)`**：

IO密集型任务是指主要需要进行输入/输出操作的任务。这些任务的执行主要受限于I/O设备（如磁盘、网络、数据库等）的读写速度，而不是CPU的计算能力。

特点：

1. 对I/O资源（如磁盘、网络）的需求较高。
2. 任务的执行时间主要由I/O操作的速度决定，而不是CPU的计算速度。
3. 通常在处理文件操作、网络通信、数据库查询等方面表现出色。

核心线程数量推荐：CPU核心数的2倍。



## 线程池使用总结
使用线程池时应根据业务需求配置线程池。

如果创建的线程池仅用于一个功能组件，那么可以根据功能特点判断：

* `核心线程数`：保证不频繁创建线程。
* `缓存队列大小`：会同时入队的最多任务数量。
* `最大线程数`：当某个线程被阻塞有额外线程来执行缓存队列中的任务，所以一般是核心线程数 + 1。
