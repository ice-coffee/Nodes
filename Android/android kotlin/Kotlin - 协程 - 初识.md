
[toc]
[Kotlin Coroutines\(协程\) 完全解析](https://johnnyshieh.me/posts/kotlin-coroutine-introduction/)

[最全面的Kotlin协程: Coroutine/Channel/Flow 以及实际应用](https://juejin.cn/post/6844904037586829320#heading-44)

[硬核万字解读：Kotlin 协程原理解析](https://toutiao.io/posts/vtq5kjj/preview)

[Kotlin协程-Scheduler的优秀设计](https://www.codenong.com/cs106222533/)

## 初识协程

### 什么是协程
`Kotlin 1.3` 添加了协程 `Coroutine` 的概念，文档中介绍协程是一种并发设计模式，可以在 `Android` 平台上使用它来简化异步执行的代码。

协程具有如下特点：

- **异步代码同步化**：使用编写同步代码的方式编写异步代码。
- **轻量**：您可以在单个线程上运行多个协程，因为协程支持挂起，不会使正在运行协程的线程阻塞。挂起比阻塞节省内存，且支持多个并行操作。
- **内存泄漏更少**：使用结构化并发机制在一个作用域内执行多项操作。
- **内置取消支持**：取消操作会自动在运行中的整个协程层次结构内传播。
- **`Jetpack` 集成**：许多 Jetpack 库都包含提供全面协程支持的扩展。某些库还提供自己的协程作用域，可供您用于结构化并发。

### 协程的挂起和恢复
`Kotlin` 协程的挂起和恢复本质上是挂起函数(或`lambda`)的挂起和恢复。

```kotlin
suspend fun suspendFun() {}
```

`挂起函数`：`suspend` 关键字修饰的普通函数。如果在协程体内调用了挂起函数，那么调用处就被称为 `挂起点`。挂起点如果出现 `异步调用`，那么当前协程就会被挂起，直到对应的 `Continuation.resume()` 函数被调用才会恢复执行。

挂起函数和普通函数的区别在于：

- 挂起函数只能在协程体内或其他挂起函数内调用；
- 挂起函数可以调用任何函数，普通函数只能调用普通函数。

`suspend` 除用于修饰函数外还可用于修饰 `lambda` 表达式，在源码分析的章节会详细分析它们的区别。

## Gradle 引入
```gradle
dependencies {
    // Kotlin Coroutines
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.4.2'
    // 使用 `Dispatchers.Main` 需要添加如下依赖
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.4.2'
}
```

## 启动协程
`kotlin` 协程框架为我们提供了两种便捷的方式启动协程：

- `GlobalScop.launch`
- `GlobalScope.async`

分别来使用两种方式输出 `Hello World!`：

```kotlin
fun main() {
    GlobalScope.launch { // 使用 GlobalScope.launch 启动协程
        delay(1000L) // 非阻塞的等待 1 秒钟（默认时间单位是毫秒）
        println("World!") // 在延迟后打印输出
    }
    print("Hello ") // 协程已在等待时主线程还在继续
    Thread.sleep(2000L) // 阻塞主线程 2 秒钟来保证 JVM 存活
}

fun main() {
    GlobalScope.async { // 使用 GlobalScope.async 启动协程
        delay(1000L)
        println("World!")
    }
    print("Hello ")
    Thread.sleep(2000L)
}
```

从上面的例子里看这两种方式好像并没有什么区别，其实区别在他们的返回值上

- `GlobalScop.launch`：返回值 `Job`
- `GlobalScope.async`：返回值 `Deferred<T>`

点开 `GlobalScop.launch` 的源码来看一下：

```kotlin
public fun CoroutineScope.launch(
    context: CoroutineContext = EmptyCoroutineContext,
    start: CoroutineStart = CoroutineStart.DEFAULT,
    block: suspend CoroutineScope.() -> Unit
): Job {
    ...
}
```

从这段代码中可以看到，一个协程主要包含如下几个部分：

* **返回值：`Job`**
* **协程上下文：`CoroutineContext`**
* **启动模式：`CoroutineStart`**
* **协程作用域：`CoroutineScope`**
* **执行代码块：`block`**

下面来依次介绍。

### **`Job`**
通过了解协程的两种启动方式，我们知道 `GlobalScop.launch、GlobalScop.async` 的返回值都是 `Job` 对象或其子类对象。那 `Job` 是什么呢？ 又有哪些功能。

`Job` 是一个可取消的后台任务，用于操作协程的执行并记录执行过程中协程的状态，所以一般来说 `Job` 实例也代表了协程。

`Job` 具有如下几种状态：

| **State** | [isActive] | [isCompleted] | [isCancelled] |
| --------------------- | -------- | ---------- | ------------ |
| _New_ (可选初始状态)   | `false`    | `false`  | `false` |
| _Active_ (默认初始状态) | `true`    | `false`  | `false` |
| _Completing_ (瞬态)   | `true`     | `false` | `false` |
| _Cancelling_ (瞬态)   | `false`    | `false` | `true`  |
| _Cancelled_ (最终状态) | `false`    | `true`  | `true`  |
| _Completed_ (最终状态) | `false`    | `true`  | `false` |

通常情况下，创建 `Job` 时会自动启动，状态默认为 `_Active_`，但是如果创建时添加参数 `CoroutineStart.Lazy` 则状态为 `_NEW_`，可以通过 `start()` 或 `join()` 等函数激活。

`Job` 状态流程图：

```
                                      wait children
+-----+ start  +--------+ complete   +-------------+  finish  +-----------+
| New | -----> | Active | ---------> | Completing  | -------> | Completed |
+-----+        +--------+            +-------------+          +-----------+
                 |  cancel / fail       |
                 |     +----------------+
                 |     |
                 V     V
             +------------+                           finish  +-----------+
             | Cancelling | --------------------------------> | Cancelled |
             +------------+                                   +-----------+
```

`Job` 的可用方法：

| 方法 | 是否是挂起函数 | 说明 |
| --- | --- | --- |
| `cancel(CancellationException)` | 否 | 取消 `Job` 对应的协程并发送协程取消错误 (`CancellationException`) | 
| `invokeOnCompletion(xxx)` | 否 | 注册当此 `Job` 状态更新为 `Completed` 时同步调用的处理程序 | 
| `join()` | 是 | 挂起 `Job` 对应的协程，当协程完成时，外层协程恢复 | 
| `start()` | 否 | 如果创建 `Job` 对象时使用的启动模式为 `CoroutineStart.Lazy`，需要通过它启动协程 | 

扩展函数：
| 方法 | 是否是挂起函数 | 说明 |
| --- | --- | --- |
| `cancelAndJoin()` | 否 | 取消 `Job` 并挂起当前协程，直到 `Job` 被取消 | 

`Deferred<T>` 是 `Job` 的子类，它新增的方法如下：

| 方法 | 是否是挂起函数 | 说明 |
| --- | --- | --- |
| `await(): T` | 是 | 挂起当前协程，等待结果返回。等待过程中 `Job` 被取消则协程抛出 `CancellationException` 异常，并继续执行 |

`Deferred<T>` 是 `Job` 的子类，并且可以通过调用 `await` 函数获取协程的返回值。上面   `GlobalScope.async` 的例子改造一下：

```kotlin
GlobalScope.launch {
    val result = GlobalScope.async { // 使用 GlobalScope.async 启动协程
        delay(1000L)
        "World!"
    }
    println("Hello ${result.await()}")
}
Thread.sleep(2000L)

//输出：Hello World!
```

上面的示例把 `async` 嵌套在了 `launch` 函数体内部，这是因为 `await` 是一个挂起函数，而挂起函数不同于普通函数的就是它必须在协程体或其他挂起函数内部调用。

在协程体内 (`{}` 内) 可以隐藏 `GlobalScope` 直接使用 `async、launch` 启动协程，所以上面的示例可以修改如下：

```kotlin
GlobalScope.launch {
    val result = async { // 使用 GlobalScope.async 启动协程
        ...
    }
    ...
}
...
```

当要取消正在运行的协程：

```kotlin
val job = launch {
    repeat(1000) { i ->
        println("job: I'm sleeping $i ...")
        delay(500L)
    }
}
delay(1300L) // 延迟一段时间
println("main: I'm tired of waiting!")
job.cancel() // 取消该作业
job.join() // 等待作业执行结束
println("main: Now I can quit.")
```
```
// 输出
job: I'm sleeping 0 ...
job: I'm sleeping 1 ...
job: I'm sleeping 2 ...
main: I'm tired of waiting!
main: Now I can quit.
```

上面示例中可以使用 `cancelAndJoin` 函数它合并了对 `cancel` 以及 `join` 函数的调用。

> 注意：如果在协程执行过程中没有挂起点，那么协程是不可被取消的。

```kotlin
val startTime = System.currentTimeMillis()
val job = launch(Dispatchers.Default) {
    var nextPrintTime = startTime
    var i = 0
    while (i < 5) { // 一个执行计算的循环，只是为了占用 CPU
        // 每秒打印消息两次
        if (System.currentTimeMillis() >= nextPrintTime) {
            println("job: I'm sleeping ${i++} ...")
            nextPrintTime += 500L
        }
    }
}
delay(1300L) // 等待一段时间，并保证协程开始执行
println("main: I'm tired of waiting!")
job.cancelAndJoin() // 取消一个作业并且等待它结束
println("main: Now I can quit.")
```
```
// 输出
job: I'm sleeping 0 ...
job: I'm sleeping 1 ...
job: I'm sleeping 2 ...
main: I'm tired of waiting!
job: I'm sleeping 3 ...
job: I'm sleeping 4 ...
main: Now I can quit.
```

简单来说，如果协程体内没有挂起点的话，**已开始执行**的协程是无法取消的。

### **`协程上下文 `**
`CoroutineStart`：协程启动模式。协程内提供了四种启动模式：

- `DEFAULT`：协程创建后，立即开始调度，在执行前如果协程被取消，其将直接进入取消相应的状态。
- `ATOMIC`：协程创建后，立即开始调度，协程执行到第一个挂起点之前不响应取消。
- `LAZY`：只有协程被需要时，包括主动调用协程的 `start()、join()、await()` 等函数时才会开始调度，如果调度前就被取消，那么该协程将直接进入异常结束状态。
- `UNDISPATCHED`：协程创建后立即执行，直到遇到第一个真正挂起的点。

立即调度和立即执行的区别：立即调度表示协程的调度器会立即接收到调度指令，但具体执行的时机以及在那个线程上执行，还需要根据调度器的具体情况而定，也就是说立即调度到立即执行之间通常会有一段时间。因此，我们得出以下结论：

- `DEFAULT` 虽然是立即调度，但也有可能在执行前被取消。
- `UNDISPATCHED` 是立即执行，因此协程一定会执行。
- `ATOMIC` 虽然是立即调度，但其将调度和执行两个步骤合二为一了，就像它的名字一样，其保证调度和执行是原子操作，因此协程也一定会执行。
- `UNDISPATCHED` 和 `ATOMIC` 虽然都会保证协程一定执行，但在第一个挂起点之前，前者运行在协程创建时所在的线程，后者则会调度到指定的调度器所在的线程上执行。

### **`CoroutineContext`**
`CoroutineContext`：协程上下文。用于控制协程的行为，上文提到的 `Job` 和准备介绍的调度器都属于协程上下文的子类。协程上下文的特点在于上下文对象可以使用 `+` 进行功能累加，这点在源码分析中详细介绍。

#### 协程调度器
协程默认提供了四种调度器：

- `Dispatchers.Default`：默认调度器，适用于 CPU 密集型的任务，例如计算或密集的算法。它会使用共享的线程池，线程数量通常等于 CPU 核心数量。
- `Dispatchers.IO`：适用于 `IO` 操作，例如文件读写、网络请求等。它使用共享的线程池，适用于异步和非阻塞的操作。
- `Dispatchers.Main`：`UI` 调度器，会将协程调度到主线程中执行。
- `Dispatchers.Unconfined`：非受限调度器，不绑定到特定的线程池，会在调用它的线程启动协程，但它仅仅只是运行到第一个挂起点。此时挂起恢复后运行在什么线程上取决于恢复操作调用在那个线程。

```kotlin
runBlocking {
    launch { // 运行在父协程的上下文中，即 runBlocking 主协程
        println("main runBlocking      : I'm working in thread ${Thread.currentThread().name}")
    }
    launch(Dispatchers.Unconfined) { // 不受限的——将工作在主线程中
        println("Unconfined            : I'm working in thread ${Thread.currentThread().name}")
    }
    launch(Dispatchers.Default) { // 将会获取默认调度器
        println("Default               : I'm working in thread ${Thread.currentThread().name}")
    }
}
```
```
//输出结果
Unconfined            : I'm working in thread main @coroutine#3
Default               : I'm working in thread DefaultDispatcher-worker-1 @coroutine#4
main runBlocking      : I'm working in thread main @coroutine#2
```

#### withContext
除了可以在 `GlobalScope.launch {}、GlobalScope.async {}` 创建协程时设置协程上下文，还可以使用 `withContext` 在协程内新增协程上下文。

```kotlin
/**
 * withContext 函数由 suspend 关键字修饰，所以它会使当前协程挂起。
 * 它的作用是将入参 CoroutineContext 添加到当前协程的协程上下文，
 * 并等待 block 代码块返回执行结果。
 */
public suspend fun <T> withContext(
    context: CoroutineContext,
    block: suspend CoroutineScope.() -> T
): T {...}
```

**`async {...}.await()` vs `withContext`**
与 `async {...}.await()` 相比 `withContext` 的内存开销更低，因此对于使用 `async` 之后立即调用 `await` 的情况，应当优先使用 `withContext`。

`kotlin` 还提供了其他的方式

#### withTimeout
`Kotlin` 协程提供了 `withTimeout` 函数设置超时取消。如果运行超时，取消后会抛出 `TimeoutCancellationException` 异常。抛出异常的情况下回影响到其他协程，这时候可以使用 `withTimeoutOrNull` 函数，它会在超时的情况下返回 `null` 而不抛出异常。

```kotlin
runBlocking {
    val result = withContext(coroutineContext) {
        withTimeoutOrNull(500) {
            delay(1000)
            "hello"
        }
    }
    println(result)
}

// 输出结果
null
```

#### yield
如果想要解决上面示例中的问题可以使用 `yield` 函数。它的作用在于检查所在协程的状态，如果已经取消，则抛出取消异常予以响应。此外它还会尝试出让线程的执行权，给其他协程提供执行机会。

在上面示例中添加 `yield` 函数：

```kotlin
if (System.currentTimeMillis() >= nextPrintTime) {
    yield()
    println("job: I'm sleeping ${i++} ...")
    nextPrintTime += 500L
}
```
```
// 输出结果
job: I'm sleeping 0 ...
job: I'm sleeping 1 ...
job: I'm sleeping 2 ...
main: I'm tired of waiting!
main: Now I can quit.
```

### **`CoroutineScope`**
协程作用域：协程作用域主要用于明确协程之间的父子关系，以及对于取消或者异常处理等方面的传播行为。
协程作用域包括以下三种：

- `顶级作用域`：没有父协程的协程所在的作用域为顶级作用域。
- `协同作用域`：协程中启动新的协程，新协程为所在协程的子协程，这种情况下子协程所在的作用域默认为协同作用域。此时子协程抛出的未捕获异常将传递给父协程处理，父协程同时也会被取消。
- `主从作用域`：与协同作用域在协程的父子关系上一致，区别在于处于该作用域下的协程出现未捕获的异常时不会将异常向上传递给父协程。

父子协程间的关系：

- 父协程被取消，则所有子协程均被取消。
- 父协程需要等待子协程执行完毕之后才会最终进入完成状态，不管父协程自身的协程体是否已经执行完毕。
- 子协程会继承父协程的协程上下文元素，如果自身有相同 `key` 的成员，则覆盖对应的 `key`，覆盖的效果仅限自身范围内有效。

声明顶级作用域：`GlobalScope.launch {}`、`runBlocking {}`
声明协同作用域：`coroutineScope {}`
声明主从作用域：`supervisorScope {}`

`coroutineScope {}` 和 `supervisorScope {}` 是挂起函数所以它们只能在协程作用域中或挂起函数中调用。

`coroutineScope {}` 和 `supervisorScope {}` 的区别在于 `SupervisorCoroutine` 重写了 `childCancelled()` 函数使异常不会向父协程传递。 

## 高级用法

### 自定义协程上下文

## 协程并发
通过上文的介绍可以了解到协程其实就是执行在线程上的代码片段，所以线程的并发处理都可以用在协程上，比如 `synchorinzed`、`CAS` 等。而协程本身也提供了两种方式处理并发：

- `Mutex`：互斥锁；
- `Semaphore`：信号量。

#### Mutex
`Mutex` 类似于 `synchorinzed`，协程竞争时将协程包装为 `LockWaiter` 使用双向链表存储。`Mutex` 还提供了 `withLock` 扩展函数，以简化使用：

```kotlin
runBlocking<Unit> {
    val mutex = Mutex()
    var counter = 0
    repeat(10000) {
        GlobalScope.launch {
            mutex.withLock {
                counter ++
            }
        }
    }
    
    Thread.sleep(500) //暂停一会儿等待所有协程执行结束
    println("The final count is $counter")
}
```

#### Semaphore
`Semaphore` 用以限制访问特定资源的协程数量。

```kotlin
runBlocking<Unit> {
    val semaphore = Semaphore(1)
    var counter = 0
    repeat(10000) {
        GlobalScope.launch {
            semaphore.withPermit {
                counter ++
            }
        }
    }
    
    Thread.sleep(500) //暂停一会儿等待所有协程执行结束
    println("The final count is $counter")
}
```

> 注意：只有在 `permits = 1` 时才和 `Mutex` 功能相同。

## 协程异常处理



## 协程通讯
