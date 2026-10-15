[toc]

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/Java_Executor_%E7%B1%BB%E5%9B%BE.png)

### Executor
| 函数 | 返回值 | 说明 |
| --- | --- | --- |
|  `execute(Runnable command)` | void | 将一个 `Runnable` 任务提交给线程池执行，不返回任何结果，仅用于执行不需要返回值的任务 |

#### ExecutorService

| 函数 | 返回值 | 说明 |
| --- | --- | --- |
|  `submit(Runnable task)` | `Future<?>` | 将一个 `Runnable` 任务提交给线程池执行，返回一个 `Future` 对象，你可以通过这个 `Future` 对象来追踪任务的执行状态和获取结果 |
|  `submit(Callable<T> task)` | `<T> Future<T>` | 类似于 `submit(Runnable task)`，但是接受一个 `Callable` 任务作为参数，可以返回一个表示计算结果的 `Future` 对象 |
|  `invokeAll(Collection<? extends Callable<T>> tasks)` | `<T> List<Future<T>>` | 提交一个任务列表，返回一个包含所有任务结果的 `List<Future<T>>`，会等待所有任务执行完毕 |
|  `invokeAny(Collection<? extends Callable<T>> tasks)` | `<T> T` | 提交一个任务列表，返回第一个完成的任务的结果 |如果所有任务都抛出异常，那么会抛出 `ExecutionException` |
|  `shutdown()` | `void` | 平缓地关闭线程池，不再接受新任务，但会等待已提交的任务执行完成 |
|  `shutdownNow()` | `List<Runnable>` | 立即关闭线程池，并尝试中断所有正在执行的任务 |
|  `awaitTermination(long timeout, TimeUnit unit)` | `boolean` | 等待线程池中所有任务完成，或者达到指定的等待时间 |
|  `isShutdown()` | `boolean` | 判断线程池是否已经关闭 |
|  `isTerminated()` | `boolean` | 判断线程池是否已经完全终止 |

#### ThreadPoolExecutor
[Java 并发 - 框架 - 线程池](https://app.yinxiang.com/shard/s58/nl/10744683/2d64ce92-ea6c-4ffa-a681-7c0b10097252/)

#### ScheduledExecutorService
`ScheduledExecutorService` 继承了 `ExecutorService` 接口，用于在预定的时间间隔内执行任务。

| 函数 | 返回值 | 说明 |
| --- | --- | --- |
| `schedule(Runnable command, long delay, TimeUnit unit)` | `ScheduledFuture<?>` | 这个方法用于在指定的延迟后执行给定的任务。参数 command 是要执行的任务（Runnable 对象），delay 是延迟的时间数量，unit 是时间单位（例如，毫秒、秒等） |
| `schedule(Callable<V> callable, long delay, TimeUnit unit)` | `<V> ScheduledFuture<V>` | 类似于上一个方法，但是可以使用 Callable 对象作为任务，并且可以返回一个结果 |
| `scheduleAtFixedRate(Runnable command, long initialDelay, long period, TimeUnit unit)` | `ScheduledFuture<?>` | 这个方法用于按固定的时间间隔执行任务，从 initialDelay 开始，然后每隔 period 时间执行一次。参数 unit 指定了时间单位 |
| `scheduleWithFixedDelay(Runnable command, long initialDelay, long delay, TimeUnit unit)` | `ScheduledFuture<?>` | 类似于上一个方法，不同之处在于它在每次任务完成后等待 delay 时间，然后再次执行 |

### Future
`Future` 是并发任务结果的父类。

#### FutureTask
任务的初始状态都是 `New`，可能的状态转换流程有如下几种：

* `NEW -> COMPLETING -> NORMAL`
* `NEW -> COMPLETING -> EXCEPTIONAL`
* `NEW -> CANCELLED`
* `NEW -> INTERRUPTING -> INTERRUPTED`

| 函数 | 返回值 | 说明 |
| --- | --- | --- |
| `cancel(boolean mayInterruptIfRunning)` | `boolean` | 尝试取消任务执行。若任务已完成或已取消，则返回 `false`；如果任务正在执行，且 `mayInterruptIfRunning` 则尝试中断任务执行 |
| `get()` | `V` | 获取执行结果。如果任务没有执行完成，阻塞当前线程知道任务执行完成。`get` 方法会上抛 `Exception` |
| `get(long, TimeUnit)` | `V` | 有超时设置的 `get()` 方法 |
| `isCancelled` | `boolean` | 任务是否已取消 |
| `isDone` | `boolean` | 任务是否已执行，包含正在执行 |

#### CompletableFuture
[CompletableFuture使用大全，简单易懂](https://juejin.cn/post/6844904195162636295)

### CompletionService
`CompletionService` 是 `Java` 提供的并发工具类，它结合了 `Executor` 和 `BlcokingQueue` 的特性，用于处理大量异步任务并能够按完成顺序获取任务的结果。

一般场景下我们只能按任务提交顺序获取结果，`CompletionService` 提供了一种可以按完成顺序获取任务结果的方式，可以及时获取任务结果。

示例：
```java
void solve(Executor e, Collection<Callable<Result>> solvers) throws InterruptedException, ExecutionException {
    CompletionService<Result> ecs = new ExecutorCompletionService<Result>(e);
    for (Callable<Result> s : solvers) {
        ecs.submit(s);
    }
    int n = solvers.size();
    for (int i = 0; i < n; ++i) {
        Result r = ecs.take().get();
        if (r != null) {
            use(r);
        }
    }
}
```

源码：
```java
public class ExecutorCompletionService<V> implements CompletionService<V> {
	// 任务池
    private final Executor executor;
    private final AbstractExecutorService aes;
    // 阻塞队列
    private final BlockingQueue<Future<V>> completionQueue;

    private static class QueueingFuture<V> extends FutureTask<Void> {
        QueueingFuture(RunnableFuture<V> task,
                       BlockingQueue<Future<V>> completionQueue) {
            super(task, null);
            this.task = task;
            this.completionQueue = completionQueue;
        }
        private final Future<V> task;
        private final BlockingQueue<Future<V>> completionQueue;

        // 任务完成后将其加入 completionQueue 队列
        protected void done() { completionQueue.add(task); }
    }

    public Future<V> submit(Callable<V> task) {
        if (task == null) throw new NullPointerException();
        RunnableFuture<V> f = newTaskFor(task);
        // 使用 QueueingFuture 包装
        executor.execute(new QueueingFuture<V>(f, completionQueue));
        return f;
    }

    public Future<V> take() throws InterruptedException {
        return completionQueue.take();
    }
}
```
