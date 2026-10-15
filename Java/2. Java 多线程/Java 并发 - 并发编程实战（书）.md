[toc]

### 文章

* [Java 并发编程 78 讲](https://learn.lianglianglee.com/%E4%B8%93%E6%A0%8F/Java%20%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B%2078%20%E8%AE%B2-%E5%AE%8C)
* [Java并发编程实战](https://learn.lianglianglee.com/%E4%B8%93%E6%A0%8F/Java%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B%E5%AE%9E%E6%88%98)
* [通过线程提升性能](https://developer.android.com/topic/performance/threads?hl=zh-cn)
* [抖音是怎么做线程治理的](https://juejin.cn/post/7212446354920407096)

### 并发能力
* `volatile`：变量只涉及原子运算时使用。
* `Atomic`：变量涉及先判断后赋值等非原子操作时使用。
* `synchorinzed/Lock`：需要线程安全的代码范围较大时使用。

原子操作：
* 常见原子操作：非 `long、double` 变量赋值（`boolean`、`byte`、`char`、`short`、`int`、`float` 和引用类型）
* 非原子操作：`long` 变量赋值、`double` 变量赋值、自增（++）、自减（--）

### 第二章 数据安全性（Java 同步机制）

编写线程安全的代码，其核心在于要对状态访问操作进行管理，特别是对**共享的**和**可变的**状态的访问。

**`竞态条件`**：
是指多个线程或进程在并发执行时，由于执行顺序和时机的不确定性而导致的程序结果依赖于线程执行的具体时序。常见竞态条件“**先检查后执行**”：

```java
// 线程不安全的单例模式
public class MySingleton {  
    private static MySingleton mySingleton = null;  
    private MySingleton(){}    
    public static MySingleton getInstance()
    {  
        if(mySingleton == null)
        {
            mySingleton = new MySingleton();  
        }
        return mySingleton;  
    }  
}  
```

#### 1. 线程安全的三要素
* **原子性**：指一系列操作作为一个整体被执行，不会被其他线程操作干扰。
* **可见性**：多个线程之间对内存写入操作可见，总是可以读取变量最新的值。
* **有序性**：在多线程环境中，程序执行的结果与代码的顺序相符。由于现代计算机体系结构对指令进行了重排序优化，因此在多线程环境下，可能会出现看似乱序的执行顺序。

**64位变量的非原子操作问题：**
对于 `long` 和 `double` 变量，JVM允许将64位读 / 写操作分解为两个32位的操作。也就是说当读取线程不安全的64位变量时很可能会读取到某个值的高32位和另一个值的低32位。

#### 2. Java 同步机制
Java 主要的同步机制有：

* **内置锁（`synchronized`）**：原子性、可见性、有序性。
* **显示锁（`Lock`）**：原子性、可见性、有序性。
* **`volatile` 变量**：可见性、有序性。
* **原子变量**：原子性、可见性、有序性。

锁使用注意事项：

* 每个共享的和可变的变量应该由同一个锁维护
* 不要滥用锁
* 执行时间较长的操作一定不要持有锁

### 第三章 安全的共享对象（对象安全性）
> 以单个对象为目标。

在第二章介绍了在多线程场景下访问数据时需要保证数据的安全，针对数据安全的三要素，`Java` 提供了几种同步机制可以视情况选用。

#### 1、发布和溢出
当我们在编写多线程程序时，虽然可以通过同步机制保证数据的安全性，但是没有安全的发布数据对象，那么对象很容易被意外发布出去而产生 `逸出`，导致数据不再安全。

* **发布**: 使对象能够在当前作用域之外的代码中使用。
* **逸出**: 当某个不应该发布的对象被发布。

**常见逸出情况有：**

* 不安全的构造对象：在构造函数中错误使用内部类导致创建对象时 `this` 引用逸出（下方说明如何安全的构造对象）。
* 发布私有对象引用（`get` 方法返回对象引用）。

`this` 引用逸出示例：
```java
public class ThisEscape {
    public ThisEscape(EventSource source) {
        source.registerListener(
            new Eventlistener() {
                public void onEvent(Event e) {
                    doSomething(e);
                }
            });
    }
}
```

上面的示例在构造函数中创建了匿名内部类对象，导致 `ThisEscape` 还未初始化完全的实例被发布到 `Eventlistener` 中。若 `doSomething()` 函数在调用时机在初始化函数结束之前并调用 `ThisEscape` 实例执行了一些操作，那么将会产生无法预知的后果。下面来看针对这种情况如何安全的构造对象。
> **`注意`**：在构造函数中创建匿名内部类对象并非不允许，但是需要保证外部类对象初始化完全后再访问外部类。

##### 1.1 安全构造对象，防止 `This` 引用溢出

在构造函数中构造内部类对象，防止 `This` 引用溢出的方式：

* 在静态代码块中构造类对象。

```java
public class MyClass {
    private static MyClass instance;

    static {
        // 在静态代码块中构造对象
        instance = new MyClass();
    }

    private MyClass() {
        // 私有的构造函数，确保不能在类外部直接创建对象
    }

    public static MyClass getInstance() {
        return instance;
    }
}
```

* 使用工厂方法模式：

```java
public class SafeListener {
    private final Eventlistener listener;
    private SafeListener() {
        listener = new Eventlistener() {
            public void onEvent(Event e) {
                doSomething(e);
            }
        };
    }
    
    public static SafeListener newInstance(EventSource source) {
        SafeListener safe = new SafeListener();
        source.registerListener(safe.listener);
        return safe;
    }
}
```

> **`总结`**：保证类对象的访问在初始化完全之后。

##### 1.2 不可变对象
> `不可变对象一定是线程安全的。`

利用 `final` 关键字特性创建不可变对象。不可变对象需要满足以下条件：

* 对象创建之后其状态（也就是对象内字段）就不能修改。
* 对象的所有域都是 `final` 类型（如果域是引用对象那其内部的所有域也必须是 `final` 类型）。
* 对象是正确创建的（没有 `this` 逸出）。

示例：
```java
public class ImmutableObject {
    private final int id;
    private final String name;

    public ImmutableObject(int id, String name) {
        this.id = id;
        this.name = name;
    }
}
```

**`final关键字`** 在多线程中的特性：

* `final` 关键字修饰的变量具有<u>**内存可见性**</u>，当一个线程对 final 变量进行初始化后，其他线程可以立即看到该变量的值，而不需要额外的同步措施。
* `final` 关键字修饰的变量具有<u>**不可变性**</u>，即一旦赋值后就无法再改变引用的对象。在多线程环境下，不可变对象的状态是线程安全的。
* `final` 关键字修饰的变量初始化时顺序<u>**不会被重排序**</u>，即保证了初始化安全性。在多线程环境下，可以避免一些潜在的线程安全问题。

#### 2、安全发布对象
安全发布对象是指对象可以被发布到任意线程且可以保证数据安全。安全发布对象包括如下方式：

1. 不需要额外处理就可以保证对象安全的方式：

* **`不可变对象`**
* **`仅暴露只读方法`**

2. 依赖外部保证对象安全：

* **`线程封闭`**：线程封闭的对象只能由一个线程拥有，对象被封闭在该线程中，并且只能由这个线程修改。例如局部变量，或者可以利用 `Handler`、`ThreadLocal` 等方式保证对象仅在单个线程中访问。
* **`保护对象`**：被保护的对象只能通过持有特定的锁来访问。保护对象包括封装在其他线程安全对象中的对象，以及已发布的并且由某个特定锁保护的对象。仅推荐使用 `Java` 线程安全库中提供的容器类对对象提供安全保护，自己实现可能没有那么安全，例如：`CopyOnWriteAarrayList`、`Collection.synchronizedList()`、`ConcurrentHashMap` 等。

3. 依赖对象自身保证对象安全：
* **`线程安全共享`**：线程安全的对象在其内部通过同步机制实现同步，因此多个线程可以通过对象的公有接口来进行访问而不需要进一步的同步。

### 第四章 对象的组合

### 第五章 基础构建模块

有那些方式来保证程序的线程安全性：

1. 使用同步容器

* Vector
* HashTable
* Collections.synchroinzedXxx() 等工厂方法

2. 使用并发容器

* ConcurrentHashMap
* CopyOnWriteArrayList

3. 对于生产-消费模式使用阻塞队列
4. 阻塞方法和中断方法
5. 同步工具类

* 闭锁：CountDownLatch、FutureTask
* 信号量：Semaphore
* 栅栏：CyclicBarrier

### 第六章 任务框架：Executor
[Java 并发 - Executor](https://app.yinxiang.com/shard/s58/nl/10744683/6246a9fb-d70f-47bd-94b4-326df16c27e9/)

### 第七章 取消和关闭
在 Java 中没有一种安全的抢占方式来停止线程，因此也就没有安全的抢占方式来停止任务。只有一些协作式的机制，使请求取消的任务和代码都遵循一种协商好的协议。
强制停止线程可能会导致的问题：

* 资源泄漏
* 数据损坏
* 程序状态不一致等问题

#### 7.1 停止线程

两种方法：

1. 在程序中维护取消状态标志，任务定期查看该标志；
2. 调用中断方法；

`Thread` 中断相关方法:

* `void interrupt()`：用于中断`调用线程`，将线程的中断状态设置为 true；
* `boolean isInterrupted()`：返回`调用线程`的中断状态，调用此方法不会清除线程的中断状态；
* `static boolean interrupted()`：返回`当前线程`的中断状态，并清除中断状态；

```java
public boolean isInterrupted() {
    return this.isInterrupted(false);
}

public static boolean interrupted() {
    return currentThread().isInterrupted(true);
}
```

> **`注意`**：`interrupted()` 是静态方法，返回的是当前线程的中断状态，而 `isInterrupted()` 是实例方法，返回的调用线程的中断状态。

常见会抛出 `InterruptedException` 的方法:

- `Thread.sleep()`
- `Thread.join()`
- `Object.wait()`

中断响应策略：

1. 在线程中适当轮询判断线程中断状态。
2. 捕获线程中断异常。捕获中断异常后需要在 `finally` 中恢复中断状态，第一保证恢复策略一定可以执行，第二保证上层代码也可以捕获到中断异常。

```java
boolean interrupted = false;
try {
    Thread.sleep(1000);
} catch (InterruptedException e) {
    interrupted = true;
} finally {
    if (interrupted) {
        Thread.currentThread().interrupt();
    }
}
```

`Future` 中的取消操作就是通过中断实现的。

处理不可中断的阻塞：
java.io中的同步Socket I/O.通过关闭Socket可以使阻塞线程抛出异常
java.io中的同步 I/O.关闭一个InterruptibleChannel会抛出异常并关闭链路
Lock提供lockInterruptibly可以上抛InterruptedException异常

#### 7.2 停止基于线程的服务

尽量使用 `ExecutorService` 执行并发任务，

#### 7.3 处理非正常的线程终止
运行线程时，要持怀疑态度，任何代码都可能会抛出一个错误。

#### 7.4 JVM关闭
##### 钩子
在 `JVM` 正常关闭中，会调用所有通过 `Runtime.getRuntime().addShutdownHook()` 注册的但还没有开始的线程。这些线程叫做 `关闭钩子`。

`关闭钩子` 可以用于实现服务或应用程序的清理工作。例如：清理临时文件、关闭数据库等。

##### 守护线程
线程可分为两种：普通线程（用户线程）和守护线程。
在 `JVM` 启动过程中创建的线程除了主线程外都是守护线程，例如垃圾回收器以及其他执行辅助工作的线程。

当创建一个新线程时，新线程将继承创建它的线程的守护状态。所以在主线程中创建的线程都是普通线程。

普通线程和守护线程的区别：
当一个普通线程结束时，`JVM` 会检查其它正在运行的线程，如果这些线程都是守护线程，那么 `JVM` 会正常退出。守护线程会直接停止执行。
也就是说普通线程的生命周期是完整的，守护线程只有开始，当 `JVM` 退出时守护线程直接停止执行。

调用 `setDaemon` 方法可以设置新建线程为守护线程。如下：

```java
Thread t = new Thread();
t.setDaemon(true);
t.start();
```

对于 `Android` 开发者来说新建守护线程可能并不实用，因为应用销毁时会清理所有线程回收资源，这时守护线程和普通线程没有区别。而对于 `Java` 开发者来说如果普通线程未结束 `JVM` 将不会退出。只有当所有的非守护线程都结束后，`JVM` 才会终止。这是为了确保所有重要任务和操作都能在应用结束前完成。

使用场景：

* 后台定时任务
* 日志记录
* 心跳检测

### 第八章 线程池的使用

[Java 并发 - 线程池](https://app.yinxiang.com/shard/s58/nl/10744683/2d64ce92-ea6c-4ffa-a681-7c0b10097252/)

### 第九章 图形用户界面应用程序

### 第十章 活跃性危险

#### 10.1 死锁
原因：
当多个线程互相持有对方等待的锁，而又不释放自己持有的锁时会发生死锁。

规避：
* 加锁顺序：尽量保证线程同时只持有单个锁，如果一定要同时持有多个锁，那需要保证请求锁的顺序。但是在实际开发中很难保证。
* 加锁时限：使用定时锁：`Lock.tryLock(long time, TimeUnit unit);`。这种方式虽然没有办法确定获取锁失败的原因，因为可能发生了死锁或者超时导致失败。但是可以通过这次失败使程序有机会重新执行计算而不是一直等待下去。

分析：

* profiler
* 死锁检测 - 怎么做

#### 10.2 线程饥饿
说明：
线程饥饿是指由于无法获得所需的资源而无法继续执行的情况。

常见触发场景：

* 高优先级线程抢占低优先级线程cpu资源，导致低优先级线程长时间无法执行。
* 使用非公平锁导致等待的线程无法执行

规避：
[高性能解决线程饥饿的利器 StampedLock](https://www.51cto.com/article/638573.html)
合理设置线程优先级
合理使用非公平锁

#### 10.3 活锁
说明：
线程因为某些条件没有满足导致一直处于：执行 -> 失败 -> 执行 -> 失败 -> ...的循环中，而导致其它等待执行的线程得不到执行。

规避：

### 第十一章 性能与可伸缩性

可伸缩性: 当增加计算资源时（例如CPU、内存、存储容量或I/O带库），程序的吞吐量或者处理能力能相应的增加。

#### 线程引入的开销
上下文切换：
内存同步：
阻塞：

#### 减少锁竞争
有3种方式可以降低锁的竞争程度：
也可以说是提升并发性的方式：
1. 减少锁的持有时间。
	- 缩小锁的范围
2. 降低锁的请求频率。
	- 锁分解：不同变量使用不同锁保护
	- 锁分段：同一变量使用不同锁分段保护
3. 使用带有协调机制的独占锁，这些机制允许更高的并发性。
	- 读写锁
	- CAS
    - 原子类型

[JAVA8的ConcurrentHashMap为什么放弃了分段锁，有什么问题吗，如果你来设计，你如何设计](https://github.com/woniu201/interview-reference/blob/main/04.%E8%85%BE%E8%AE%AF%E7%AF%87/4.1.6%20JAVA8%E7%9A%84ConcurrentHashMap%E4%B8%BA%E4%BB%80%E4%B9%88%E6%94%BE%E5%BC%83%E4%BA%86%E5%88%86%E6%AE%B5%E9%94%81%EF%BC%8C%E6%9C%89%E4%BB%80%E4%B9%88%E9%97%AE%E9%A2%98%E5%90%97%EF%BC%8C%E5%A6%82%E6%9E%9C%E4%BD%A0%E6%9D%A5%E8%AE%BE%E8%AE%A1%EF%BC%8C%E4%BD%A0%E5%A6%82%E4%BD%95%E8%AE%BE%E8%AE%A1.md)

#### CPU监测
Android：profiler
非Android：

命令行：
top：
vmstat：
mpstat：

### 第十二章 并发程序的测试

### 第十三章 显示锁

[Java 并发 - Lock](https://app.yinxiang.com/shard/s58/nl/10744683/febd7b8d-8163-466e-84eb-d62d23e1b17d/)

**`公平锁和非公平锁性能差距：`**
当一个锁的持有时间很短，非公平锁的性能要高于公平锁。其中一个原因是：在恢复一个被挂起的线程与该线程真正开始运行之间存在着严重的延迟。假设线程A持有一个锁，并且线程B请求这个锁。由于这个锁已经被线程A持有，因此B将被挂起。当A释放锁时，B将被唤醒，一次会再次尝试获取锁。于此同时，如果C也请求这个锁，
那么C很可能会在B被完全唤醒之前获得、使用以及释放这个锁。这样的请求是一种“双赢”的局面：B获得锁的时刻并没有推迟，C更早地获得了锁，并且吞吐量也获得了提高。

**`使用场景：`**
非公平锁的高性能是由于额外的自旋操作在不影响等待线程的情况下避免了线程的挂起恢复所造成的损失。如果自旋的消耗是1，线程挂起恢复的消耗是2或者更多，那么使用非公平锁至少由1的性能收益这时建议使用，但是如果锁持有的时间很长那么使用非公平锁就没有收益，这时候推荐使用公平锁。

* 公平锁：持有锁时间长的场景使用公平锁，例如：`ReentrantLock`、`Semaphore`；
* 非公平锁：持有锁时间短的场景使用非公平锁，例如：`ReentrantLock`、`Semaphore`、`synchronized`。

> `ReentrantLock`、`Semaphore` 根据传参可以是公平或非公平锁。 

### 第十四章 构建自定义的同步工具
#### 使用内置锁（synchronized）构建同步工具
构建同步工具需要找到同步操作的执行条件（条件谓词），条件满足则执行，不满足则等待。执行条件是由类中各个状态变量构成的表达式，这些状态变量必须由一个锁保护，在验证执行条件时需要先持有这个锁。

##### 等待
当执行条件验证不通过时调用 `Object.wait()` 方法释放锁，并请求操作系统挂起当前线程，从而使其他线程能获得这个锁并修改对象的状态变量。

```java
void stateDependentMethod() throws InterruptedException {
    // 必须通过一个锁来保护执行条件相关的状态变量
    synchronized (lock) {
        while (!conditionPredicate()) {
            lock.wait();
        }
    }
}
```

使用条件等待时（例如 `Object.wait` 或 `Condition.await`）：

* 通常都有一个条件谓词 -- 包括一些对象状态的测试，线程在执行前必须首先通过这些测试。
* 在调用 `wait` 之前测试条件谓词，并且从 `wait` 中返回是再次进行测试。
* 在一个循环中调用 `wait`。
* 确保使用与条件队列相关的锁来保护构成条件谓词的各个状态变量。
* 当调用 `wait`、`notify` 或 `notifyAll` 等方法时，一定要持有与条件队列相关的锁。
* 在检查条件谓词之后以及开始执行相应的操作之前，不要释放锁。

##### 通知
当等待条件相关的类状态发生变化时，通过 `notify` 或 `notifyAll` 唤醒等待线程，重新执行条件测试。通常情况下 `notifyAll` 的使用频率更高，因为它可以唤醒等待队列中的所有线程，防止存在多种不同检查条件时（例如：`isFull` 和 `isEmpty`）通知信号丢失的情况。

`notify` 使用条件：

* **`所有等待线程的类型都相同`**。只有一个条件谓词与同步数据相关，并且每个线程在 `wait` 返回后将执行相同的操作。
* **`单进单出`**。在条件变量上的每次通知，最多只能唤醒一个线程来执行。

#### 使用显示锁（Lock）构建同步工具
使用 `Lock` 可以更加灵活的构建同步工具。使用 `Lock.newCondition` 创建 `Condition`，它继承了相关 `Lock` 对象的特性。针对同一个锁上多种条件判断做到更精细的处理，例如 `LinkedBlockingDeque` 的实现。

在 `Condition` 对象中，与 `wait`、`notify`、和 `notifyAll` 对应的方法分别是 `await`、`signal` 和 `signalAll`。

> **`注意`**：使用 `Lock` 构建的同步工具无法保证数据的可见性。

#### 现有同步工具类

* Semaphore
* CountDownLatch
* ReenGrantReadWriteLock
* ......

### 第十五章 原子变量与非阻塞同步机制

### 第十六章 内存模型
对非 `volatile` 共享变量进行写操作时，什么时候会刷新结果到主内存
