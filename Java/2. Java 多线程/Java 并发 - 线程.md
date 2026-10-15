[toc]

### 线程声明周期
[Java线程的6种状态及切换\(透彻讲解\)](https://blog.csdn.net/pange1991/article/details/53860651)

* 初始
* 运行
* 阻塞
* 等待
* 超时等待
* 终止

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/thread_state.jpg)

### Thread 常用方法

- `void start()`：启动线程；
- `void sleep(long millis)`：当前线程进入超时等待状态，不释放对象锁，`millis` 后线程自动苏醒进入就绪状态。作用：给其它线程执行机会的最佳方式。
- `void interrupt()`：用于中断`调用线程`，将线程的中断状态设置为 true；
- `boolean isInterrupted()`：返回`调用线程`的中断状态，调用此方法不会清除线程的中断状态；
- `static boolean interrupted()`：返回`当前线程`的中断状态，并清除中断状态；

#### yield

[多线程 Thread.yield 方法到底有什么用？](https://blog.csdn.net/youanyyou/article/details/84282668)

**`作用：`**
出让 `CPU` 使用权，不释放对象锁，但 `yield` 函数只有建议权，没有决定权，不保证成功；

**`使用场景：`**
`yield` 方法可以很好的控制多线程，如执行某项复杂的任务时，如果担心占用资源过多，可以在完成某个重要的工作后使用 `yield` 方法让掉当前 `CPU` 的调度权，等下次获取到再继续执行，这样不但能完成自己的重要工作，也能给其他线程一些运行的机会，避免一个线程长时间占有 `CPU` 资源。

**`yield vs sleep：`**

* `yield, sleep` 都能暂停当前线程，`sleep` 可以指定具体休眠的时间，而 `yield` 则依赖 `CPU` 的时间片划分。
* `yield, sleep` 两个在暂停过程中，如已经持有锁，则都不会释放锁资源。
* `yield` 不能被中断，而 `sleep` 则可以接受中断。

#### `run() vs start()`

`run()`：不启动线程，可以多次掉用；
`start()`：启动线程，仅可调用一次；多次掉用 `IllegalThreadStateException` 报错。

### Object 常用方法

- `notify()`：唤醒在此对象监视器上等待的单个线程，选择是任意性的。
- `notifyAll()`：唤醒在此对象监视器上等待的所有线程。

#### wait(long)
阻塞当前线程并释放对象锁，进入等待队列，直到其他线程调用此对象的 `notify、notifyAll` 方法，或等待时间超时。

唤醒线程的四种方式：

* 对象锁调用 `notify` 方法。
* 对象锁调用 `notifyAll` 方法。
* 线程调用 `interrupt` 方法。
* 等待时间超时。

当线程被唤醒时，将恢复到 `wait` 方法调用时的状态，也就是会接着执行 `wait` 方法后的逻辑。

线程也可能在没有通知、没有唤醒、没有超时的情况下唤醒，这叫做虚假唤醒。为了应对这种情况，需要在线程被唤醒后再次确认竞态条件，如果条件不足则继续 `wait`：

```java
synchronized (obj) {
   while (<condition does not hold>)
       obj.wait(timeout);
   ... // Perform action appropriate to condition
}
```

#### `notify() vs notifyAll()`
锁对象由 `ObjectMoniter` 实现，其内部有两个队列：

`EntryList`：保存竞争锁的线程；
`WaitSet`：保存调用 `wait()` 进入等待状态的线程；

* `notify()` 将随机在 `WaitSet` 内选择一个线程进入 `EntryList`，去竞争锁。
* `notifyAll()` 将把 `WaitSet` 内所有的线程放入 `EntryList`，去竞争锁。

> 锁竞争结果由 `JVM` 决定。

这样想象一下容器满了, 100个线程在等put, 一个线程要get, 无论怎么notify, 有可能总是唤醒put线程, 这时get总是执行不了, 因为运气不好轮不上它, 这时有活跃性问题, 虽然没有死锁但系统大部分时间在空转. 

所以一般会使用 `notifyAll` 去唤醒线程，提高安全性。

### 线程优先级（缺）

[杂谈Android线程优先级](https://cloud.tencent.com/developer/article/1427621)

### 创建线程的方式

- `Thread + Runnable`
- `Executors + Runnable`
- `Executors + Callable`
- `Executors + Future`

`Runnale`：
```
public interface Runnable {
    public abstract void run();
}
```

`Callable`：
```
public interface Callable<V> {
    /**
     * 获取线程执行结果
     */
    V call() throws Exception;
}
```

`Callable vs Runnable`：

- 执行方法不一样：`call()`、`run()`;
- `Callable` 任务执行后有返回值，`Runnale` 执行后没有返回值；
- `Callale` 会对异常

```java
public <T> Future<T> submit(Callable<T> task) {
    if (task == null) throw new NullPointerException();
    RunnableFuture<T> ftask = newTaskFor(task);
    execute(ftask);
    return ftask;
}
```

```java
public Future<?> submit(Runnable task) {
    if (task == null) throw new NullPointerException();
    RunnableFuture<Void> ftask = newTaskFor(task, null);
    execute(ftask);
    return ftask;
}
```
