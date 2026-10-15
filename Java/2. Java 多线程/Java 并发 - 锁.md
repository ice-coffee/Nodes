[toc]

### 锁分类
[不可不说的Java“锁”事](https://tech.meituan.com/2018/11/15/java-lock.html)

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/thread/lock.png)

#### 乐观锁 vs 悲观锁

* `悲观锁`：认为自己在使用数据的时候一定有别的线程来修改数据，因此在获取数据的时候会先加锁，确保数据不会被别的线程修改。
* `乐观锁`：认为自己在使用数据时不会有别的线程修改数据，所以不会添加锁，只是在更新数据的时候去判断之前有没有别的线程更新了这个数据。如果这个数据没有被更新，当前线程将自己修改的数据成功写入。如果数据已经被其他线程更新，则根据不同的实现方式执行不同的操作（例如报错或者自动重试）。

`悲观锁`：`synchronized`、`Lock`
`乐观锁`：`CAS`、`StampedLock 乐观读锁`

#### 自旋锁 vs 适应性自旋锁

两者的区别在于自旋次数是否动态适应。

#### 公平锁 vs 非公平锁

* `公平锁`：表示线程获取锁的顺序是按照加锁的顺序来分配的，及先来先得，先进先出的顺序。 
* `非公平锁`：表示获取锁的抢占机制，是随机获取锁的，和公平锁不一样的就是先来的不一定能拿到锁， 有可能一直拿不到锁，所以结果不公平。

#### 可重入锁 vs 非可重入锁
是否可重入是指在同一个线程在外层方法获取锁的时候，再进入该线程的内层方法会自动获取锁（前提锁对象得是同一个对象或者 `class` ），不会因为之前已经获取过还没释放而阻塞。

`可重入锁`：`synchronized`、`AQS`
`非可重入锁`：`Kotlin.Mutex`、`StampedLock`

#### 共享锁 vs 独占锁

* `独占锁又叫互斥锁`：是指该锁一次只能被一个线程所持有。如果线程T对数据A加上排它锁后，则其他线程不能再对A加任何类型的锁。获得排它锁的线程即能读数据又能修改数据。`JDK` 中的 `synchronized` 和 `JUC` 中 `Lock` 的实现类就是互斥锁。
* `共享锁`：是指该锁可被多个线程所持有。如果线程T对数据A加上共享锁后，则其他线程只能对A再加共享锁，不能加排它锁。获得共享锁的线程只能读数据，不能修改数据。

`共享锁`：`ReentrantReadWriteLock.ReadLock`
`互斥锁`：`synchronized`、`Lock`、`ReentrantLock`

### 死锁
[遇到过死锁问题吗？怎么发生的？如何解决呢？](https://mp.weixin.qq.com/s/qSkRtwH_jUjXHPxu0KDQxA)

#### 什么是死锁

死锁是指两个或两个以上的线程，在执行过程中，由于竞争资源或者由于彼此通信，而造成的一种阻塞的现象，若无外力作用，它们都将无法推进下去。此时称系统处于死锁状态或系统产生了死锁，这些永远在互相等待的进程称为死锁进程。

#### 什么情况下容易产生死锁

- 两个线程以不同的顺序请求两个锁时容易产生互相等待的情况，发生死锁。
- 当一个对象方法在持有锁期间调用外部方法，因为无法显示判断外部方法是否有其他锁，这时就有可能产生死锁。

#### 如何避免死锁

缩小锁的粒度：使得同步方法只用来保护真正需要保护的变量或者代码段。

#### Android 系统处理死锁方案

`Android` 内部使用了 `WatchDog` 来监听死锁。向监听线程的数据队列头中插入数据，如果执行超时，则判断线程超时。

```java
public class Watchdog extends Thread {
    public void run() {
        boolean waitedHalf = false;
        while (true) {//我们要在Android系统运行的整个过程中监控，当然我们需要一个死循环
            final List<HandlerChecker> blockedCheckers;
            final String subject;
            final boolean allowRestart;
            int debuggerWasConnected = 0;
            synchronized (this) {
                long timeout = CHECK_INTERVAL;
                //代码关键点1 - 向受监听线程的 Handler 发送消息
                for (int i=0; i<mHandlerCheckers.size(); i++) {
                    HandlerChecker hc = mHandlerCheckers.get(i);
                    hc.scheduleCheckLocked();
                }
      ....
                //代码关键点2 - WatchDog 线程等待 30s
                long start = SystemClock.uptimeMillis();
                while (timeout > 0) {
      ...
                    try {
                        wait(timeout);
                    } catch (InterruptedException e) {
                        Log.wtf(TAG, e);
                    }
      ...
                    timeout = CHECK_INTERVAL - (SystemClock.uptimeMillis() - start);
                }
      ...
                //代码关键点3
                boolean fdLimitTriggered = false;
                if (mOpenFdMonitor != null) {
                    fdLimitTriggered = mOpenFdMonitor.monitor();
                }
                //代码关键点4 - 评估受监听线程的阻塞状态
                if (!fdLimitTriggered) {
                    final int waitState = evaluateCheckerCompletionLocked();
                    if (waitState == COMPLETED) {
                        waitedHalf = false;
                        continue;
                    } else if (waitState == WAITING) {
                        continue;
                    } else if (waitState == WAITED_HALF) {
                        if (!waitedHalf) {
                            ArrayList<Integer> pids = new ArrayList<Integer>();
                            pids.add(Process.myPid());
                            ActivityManagerService.dumpStackTraces(true, pids, null, null,
                                    getInterestingNativePids());
                            waitedHalf = true;
                        }
                        continue;
                    }
                    blockedCheckers = getBlockedCheckersLocked();
                    subject = describeCheckersLocked(blockedCheckers);
                } else {
                    blockedCheckers = Collections.emptyList();
                    subject = "Open FD high water mark reached";
                }
                allowRestart = mAllowRestart;
            }
            //代码关键点5 - 代码运行到这里，说明系统已经卡死
            final File stack = ActivityManagerService.dumpStackTraces(
                    !waitedHalf, pids, null, null, getInterestingNativePids());
            doSysRq('w');
            doSysRq('l');
    ...
            IActivityController controller;
            if (controller != null) {
    ...
                int res =controller.systemNotResponding(subject);
                if (res >= 0) {
       ...
                    continue;
                }
            }
            // 代码关键点6
            if (Debug.isDebuggerConnected()) {
                debuggerWasConnected = 2;
            }
            if (debuggerWasConnected >= 2) {
            } else if (debuggerWasConnected > 0) {
            } else if (!allowRestart) {
            } else {
    ...
                //代码关键点6 - 只有这种情况下，杀死system_server
                Process.killProcess(Process.myPid());
                System.exit(10);
            }
            waitedHalf = false;
        }
    }
}
```

`WatchDog` 是一个线程继承 `Thread`，在 `run` 方法内通过死循环每隔 30 秒向需要监听的线程 `Looper` 内发送消息的方式判断目标线程的阻塞状态。如果阻塞超时则杀掉进程。
