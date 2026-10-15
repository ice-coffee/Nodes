
[toc]
### suspend
我们来看 `suspend` 修饰函数和修饰 `lambda` 的区别。

挂起函数：

```kotlin
suspend fun suspendFun() {

}
```

编译成 `java` 代码如下：

```kotlin
@Nullable
public final Object suspendFun(@NotNull Continuation $completion) {
  return Unit.INSTANCE;
}
```

可以看到挂起函数其实隐藏着一个 `Continuation` 协程实例参数，而这个参数其实就来源于协程体或者其他挂起函数，因此挂起函数只能在协程体内或其他函数内调用了。

`suspend` 修饰 `lambda` 表达式：

```kotlin
suspend {}
```
```java
// 反编译结果如下
Function1 var2 = (Function1)(new Function1((Continuation)null) {
    int label;

    @Nullable
    public final Object invokeSuspend(@NotNull Object $result) {
       switch(this.label) {
       case 0:
          return Unit.INSTANCE;
       default:
       }
    }

    @NotNull
    public final Continuation create(@NotNull Continuation completion) {
       Function1 var2 = new <anonymous constructor>(completion);
       return var2;
    }

    public final Object invoke(Object var1) {
       return ((<undefinedtype>)this.create((Continuation)var1)).invokeSuspend(Unit.INSTANCE);
    }
 });
```

`suspend lambda` 实际会被编译成 `SuspendLambda` 的子类。`suspendLambda` 的继承关系如下图：

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/continuation_suspendlambda.jpg)

通过反编译的代码可以发现我们在协程体内编写的代码最终是在 `invokeSuspend` 函数内执行的。而在 `BaseContinuationImpl` 内实现了 `Continuation` 协程接口的 `resumeWidth` 函数，并在其内调用了 `invokeSuspend` 函数。

`suspend` 关键字的介绍先到这里，接下来我们看协程是如何创建并运行的。

### 协程是如何被创建的
> 文件地址 `kotlin.coroutines.Continuation.kt`。

`Continuation.kt` 文件基本属于协程的基础核心了，搞懂了它也就相当于搞懂了协程的基础原理。

- 协程接口的定义；
- 唤醒或启动协程的函数；
- 四种创建协程的函数；
- 帮助获取协程内的协程实例对象的函数。

首先是协程的接口声明，非常简单：

```kotlin
/**
 * 协程接口，T 表示在最后一个挂起点恢复时的返回值类型
 */
public interface Continuation<in T> {
    /**
     * 协程上下文
     */
    public val context: CoroutineContext

    /**
     * 这个函数的功能有很多，它可以启动协程，也可以恢复挂点，还可以作为最后一次挂起点恢复时输出协程的结果
     */
    public fun resumeWith(result: Result<T>)
}
```

协程接口声明之后 `Continuation.kt` 文件提供了两个调用 `resumeWith` 函数的函数：

```kotlin
public inline fun <T> Continuation<T>.resume(value: T): Unit =
    resumeWith(Result.success(value))

public inline fun <T> Continuation<T>.resumeWithException(exception: Throwable): Unit =
    resumeWith(Result.failure(exception))
```

这两个函数除了传参一成功一失败，它们的功能是一模一样的，都是直接调用了 `resumeWith` 函数。相当于是 `resumeWith` 函数的封装。

再然后就是四种创建协程的方式了：

```kotlin
public fun <T> (suspend () -> T).createCoroutine(
    completion: Continuation<T>
): Continuation<Unit> =
    SafeContinuation(createCoroutineUnintercepted(completion).intercepted(), COROUTINE_SUSPENDED)

public fun <R, T> (suspend R.() -> T).createCoroutine(
    receiver: R,
    completion: Continuation<T>
): Continuation<Unit> =
    SafeContinuation(createCoroutineUnintercepted(receiver, completion).intercepted(), COROUTINE_SUSPENDED)

public fun <T> (suspend () -> T).startCoroutine(
    completion: Continuation<T>
) {
    createCoroutineUnintercepted(completion).intercepted().resume(Unit)
}

public fun <R, T> (suspend R.() -> T).startCoroutine(
    receiver: R,
    completion: Continuation<T>
) {
    createCoroutineUnintercepted(receiver, completion).intercepted().resume(Unit)
}
```

这四种方式可以说是相似度超高，`createCoroutine` 和 `startCoroutine` 最大的区别在于，通过 `createCoroutine` 创建的协程需要掉用 `resume` 函数启动，而 `startCoroutine` 函数内部已经默认调用了 `resume` 函数。那我们先用第一种方式创建一个协程：

```kotlin
// 创建协程 
val continuation = suspend {
    println("In Coroutine")
}.createCoroutine(object : Continuation<Unit> {
    override fun resumeWith(result: Result<Unit>) {
        println(result)
    }

    override val context = EmptyCoroutineContext
})

// 启动协程
continuation.resume(Unit)
```

调用 `createCoroutine` 函数创建协程时传入了 `Continuation` 协程的匿名类对象，诶？好像有点不对，为什么创建协程的时候要传一个协程实例进去，直接用不就成了。想知道为什么的话，那就需要看看 `createCoroutine` 到底做了什么操作了。

```kotlin
SafeContinuation(createCoroutineUnintercepted(completion).intercepted(), COROUTINE_SUSPENDED)
```

首先调用的是 `createCoroutineUnintercepted` 函数，它的源码可以在 `kotlin.coroutines.intrinsics.IntrinsicsJvm.kt` 内找到：

```kotlin
public actual fun <T> (suspend () -> T).createCoroutineUnintercepted(
    completion: Continuation<T>
): Continuation<Unit> {
    val probeCompletion = probeCoroutineCreated(completion)
    return if (this is BaseContinuationImpl)
        create(probeCompletion)
    else
        createCoroutineFromSuspendFunction(probeCompletion) {
            (this as Function1<Continuation<T>, Any?>).invoke(it)
        }
}
```

> `probeCoroutineCreated` 函数内直接将参数返回了，并且通过断点的方式，它的返回值和 `completion` 传参是一样的，所以这里先忽略它。 

通过断点会发现 `(this is BaseContinuationImpl)` 判断的返回值是 `true` 这也就间接证明了上文中 `suspend lambda` 和 `BaseContinuationImpl` 的继承关系。最后返回的是 `create(Continuation)` 函数的返回值，这里可以发现作为参数传入的 `Continuation` 变量被 `suspend lambda` 包裹了一层，然后返回，相当于 `suspend lambda` 成为了 `Continuation` 的代理。

到这里 `createCoroutineUnintercepted(completion)` 的含义就搞明白了：

> 将`object : Continuation<Unit> {}` 创建的协程实例传入 `suspend lambda`，由其代理协程执行操作。

紧接着又调用了 `intercepted` 函数，`intercepted` 函数声明也在 `IntrinsicsJvm.kt` 文件内：

```kotlin
public actual fun <T> Continuation<T>.intercepted(): Continuation<T> = (this as? ContinuationImpl)?.intercepted() ?: this
```

接着看 `ContinuationImpl` 的 `intercepted` 函数：

```kotlin
public fun intercepted(): Continuation<Any?> =
    intercepted
        ?: (context[ContinuationInterceptor]?.interceptContinuation(this) ?: this)
            .also { intercepted = it }
```

其中 `context[ContinuationInterceptor]?.interceptContinuation(this)` 这句代码涉及到协程拦截器的概念，下文会详细分析。这里可以先简单介绍一下，协程拦截器和协程其实也是代理的关系。所以 `intercepted()` 可以理解为如果协程上下文中添加了协程拦截器，那么就返回协程拦截器，不然就返回 `suspend lambda` 实例本身，而它们都实现了 `Continuation` 接口。

先做一个小结，通过上文的介绍基本就清楚了，`createCoroutine、startCoroutine` 函数其实不是用来创建协程的，协程实例就是它们的传参，它们是为协程添加代理的。

```
createCoroutineUnintercepted(completion).intercepted()
```

通过上面的代码，为协程添加了代理，分别是 `suspend lambda` 和协程拦截器。这时候通过协程实例调用 `resumeWith` 函数时会先执行两层代理内实现的 `resumeWith` 函数逻辑，最终才会执行到协程的 `resumeWith` 函数输出最终结果。

在 `createCoroutine` 函数内，在添加两层代理之后又添加了一层代理，`SafeContinuation`。`SafeContinuation` 内部使用协程的三种状态，并配合 `CAS` 操作，保证当前返回的 `SafeContinuation` 实例对象仅能调用一次 `resumeWith` 函数，多次调用会报错。

- `UNDECIDED`：初始状态
- `COROUTINE_SUSPENDED`：挂起状态
- `RESUMED`：恢复状态

### 协程挂起和恢复
那为什么协程要这么做，很麻烦不是？要弄清楚这个问题先来看 `BaseContinuationImpl` 的 `resumeWith` 函数实现吧。

```kotlin
public final override fun resumeWith(result: Result<Any?>) {
    var current = this
    var param = result
    while (true) {
        probeCoroutineResumed(current)
        with(current) {
            val completion = completion!!
            val outcome: Result<Any?> =
                try {
                    val outcome = invokeSuspend(param)
                    if (outcome === COROUTINE_SUSPENDED) return
                    Result.success(outcome)
                } catch (exception: Throwable) {
                    Result.failure(exception)
                }
            releaseIntercepted() // this state machine instance is terminating
            if (completion is BaseContinuationImpl) {
                current = completion
                param = outcome
            } else {
                // top-level completion reached -- invoke and return
                completion.resumeWith(outcome)
                return
            }
        }
    }
}
```

当调用 `resume(Unit)` 启动协程时，由于代理的存在会调用到 `BaseContinuationImpl` 的 `resumeWith()` 函数，函数内会执行 `invokeSuspend()` 函数，也就说我们所说的协程体。

查看如下代码的 `invokeSuspend` 函数：

```kotlin
suspend {5}

// 反编译后的 invokeSuspend 函数

public final Object invokeSuspend(@NotNull Object $result) {
   Object var2 = IntrinsicsKt.getCOROUTINE_SUSPENDED();
   switch(this.label) {
   case 0:
      ResultKt.throwOnFailure($result);
      return Boxing.boxInt(5);
   default:
      throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
   }
}
```

可以看到这里直接返回了最终的结果 `5`，接着在 `ContinuationImpl.resumeWith` 函数内最终调用

```kotlin
completion.resumeWith(outcome)
```

输出协程的最终结果。

这是协程执行同步代码的过程，可以看到在整个过程中，`ContinuationImpl` 好像并没有起到什么作用，那接着来看在协程体内执行异步代码：

```kotlin
suspend {
    suspendFunc()
}
            
suspend fun suspendFunc() = suspendCoroutine<Int> { continuation ->
    thread {
        Thread.sleep(1000)
        continuation.resume(5)
    }
}
```
```java
// 反编译后
public final Object invokeSuspend(@NotNull Object $result) {
   Object var2 = IntrinsicsKt.getCOROUTINE_SUSPENDED();
   Object var10000;
   switch(this.label) {
   case 0:
      ResultKt.throwOnFailure($result);
      this.label = 1;
      var10000 = DeepKotlin3Kt.suspendFunc(this);
      if (var10000 == var2) {
         return var2;
      }
      break;
   case 1:
      ResultKt.throwOnFailure($result);
      var10000 = $result;
      break;
   default:
      throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
   }

   return var10000;
}

public static final Object suspendFunc(@NotNull Continuation $completion) {
  boolean var1 = false;
  boolean var2 = false;
  boolean var3 = false;
  SafeContinuation var4 = new SafeContinuation(IntrinsicsKt.intercepted($completion));
  Continuation continuation = (Continuation)var4;
  int var6 = false;
  ThreadsKt.thread$default(false, false, (ClassLoader)null, (String)null, 0, (Function0)(new DeepKotlin3Kt$suspendFunc02$2$1(continuation)), 31, (Object)null);
  Object var10000 = var4.getOrThrow();
  if (var10000 == IntrinsicsKt.getCOROUTINE_SUSPENDED()) {
     DebugProbesKt.probeCoroutineSuspended($completion);
  }

  return var10000;
}
```

`resume` 函数启动协程，`invokeSuspend` 函数第一次执行时 `this.label == 0` 执行 `case 0` 代码，`this.label` 变量赋值为 `1`, 然后判断如果 `if (var10000 == var2)` 为 `true` 那么 `invokeSuspend` 函数返回 `var2`，也就是 `COROUTINE_SUSPENDED` 标识，在 `resumeWith` 函数内，判断如果 `invokeSuspend` 函数的返回值为 `COROUTINE_SUSPENDED` 则 `reture`。这也就是协程的挂起过程。

当线程执行结束，调用 `resume` 函数恢复协程时再次执行到 `invokeSuspend` 函数，这时 `this.label == 1`，执行 `case 1` 代码，直接返回结果 `5`。那在 `resumeWith` 函数内，这时就不会执行 `return` 了，最终会调用协程的 `resumeWith` 函数输出最终的结果，这也就是协程的恢复过程。

通过了解协程运行流程可以发现 `ContinuationImpl` 其实是协程挂起和恢复逻辑的真正执行者。也正是因为协程挂起和恢复逻辑的存在，所以我们可以像编写同步代码一样调用异步代码：

```kotlin
suspend {
    println("Coroutine start")

    println("Coroutine: ${System.currentTimeMillis()}")
    val resultFun = suspendThreadFun()
    println("Coroutine: suspendThreadFun-$resultFun-${System.currentTimeMillis()}")

    val result = suspendNoThreadFun()
    println("Coroutine: suspendNoThreadFun-$result-${System.currentTimeMillis()}")
}.startCoroutine(object : Continuation<Unit> {
    override val context = EmptyCoroutineContext

    override fun resumeWith(result: Result<Unit>) {
        println("Coroutine End: $result")
    }
})

suspend fun suspendThreadFun() = suspendCoroutine<Int> { continuation ->
    thread {
        Thread.sleep(1000)
        continuation.resumeWith(Result.success(5))
    }
}

suspend fun suspendNoThreadFun() = suspendCoroutine<Int> { continuation ->
    continuation.resume(5)
}
```
```
//输出：
Coroutine start
Coroutine: 1627014868152
Coroutine: suspendThreadFun-5-1627014869182
Coroutine: suspendNoThreadFun-5-1627014869186
Coroutine End: Success(kotlin.Unit)
```

### 创建协程作用域
在通过 `createCoroutine` 创建协程时，你会发现还可为它传递 `receiver` 参数，这个参数的作用是用于扩展协程体，一般称其为 `协程作用域`。

```kotlin
public fun <R, T> (suspend R.() -> T).createCoroutine(
    receiver: R,
    completion: Continuation<T>
): Continuation<Unit> =
    SafeContinuation(createCoroutineUnintercepted(receiver, completion).intercepted(), COROUTINE_SUSPENDED)
```

可以看到 `suspend lambda` 表达式也出现了变化。我们知道 `() -> T` 是 `Function0` 的 `lambda` 表达式，`R.() -> T` 相当于 `R` 类的 `() -> T` 扩展。如果了解扩展函数的话就知道扩展函数会将所扩展的类作为其参数，那么 `R.() -> T` 也就是 `Function1` 的 `lambda` 表达式了。

> 当然由于 `suspend` 关键字的作用，又增加了 `Continuation` 参数，所以最终看到的就是 `Function1` 和 `Function2`。

因为扩展函数的作用，所以可以在协程体内通过 `this` (可隐藏)调用 `receiver` 的函数或者属性。示例如下：

```kotlin
launchCoroutine(ProducerScope<Int>()) {
    produce(1000)
}

fun <R, T> launchCoroutine(receiver: R, block: suspend R.() -> T) {
    block.startCoroutine(receiver, object : Continuation<T> {
        override val context = EmptyCoroutineContext

        override fun resumeWith(result: Result<T>) {
            println("Coroutine End: $result")
        }
    })
}

class ProducerScope<T> {
    fun produce(value: T) {
        println(value)
    }
}
```

### GlobalScope.launch 源码分析
了解上文创建协程的逻辑之后再来分析 `GlobalScope.launch` 就非常简单了。`GlobalScope.launch` 最终会执行到 `CoroutineStart.invoke` 函数：

`AbstractCoroutine.kt`
```kotlin
public fun <R> start(start: CoroutineStart, receiver: R, block: suspend R.() -> T) {
    initParentJob()
    start(block, receiver, this)
}
```

`CoroutineStart.kt`
```kotlin
public operator fun <R, T> invoke(block: suspend R.() -> T, receiver: R, completion: Continuation<T>): Unit =
    when (this) {
        DEFAULT -> block.startCoroutineCancellable(receiver, completion)
        ATOMIC -> block.startCoroutine(receiver, completion)
        UNDISPATCHED -> block.startCoroutineUndispatched(receiver, completion)
        LAZY -> Unit // will start lazily
    }
```

代码基本跟上文分析的一致。

### 自定义协程上下文
协程上下文在协程中的作用非常大，有它在相当于协程有了装备卡槽一样。你可以将你想添加的上下文对象合并到 `CoroutineContext` 参数上，然后在其他地方使用。

`CoroutineContext` 的数据结构有如下特点：

- 可以通过 `[]` 以类似 `List` 的方式访问任何一个协程上下文对象，`[]` 内是目标协程上下文。
- 协程上下文可以通过 `+` 的方式依次累加，当然 `+=` 也是可用的。

我们来自定义一个协程上下文给协程添加一个名字：

```kotlin
public data class CoroutineName(val name: String) : AbstractCoroutineContextElement(CoroutineName) {
    public companion object Key : CoroutineContext.Key<CoroutineName>
    
    override fun toString(): String = "CoroutineName($name)"
}
```

应用到示例中：

```kotlin
var coroutineContext: CoroutineContext = EmptyCoroutineContext
coroutineContext += CoroutineName("c0-01")
suspend {
    println("Run Coroutine")
}.startCoroutine(object : Continuation<Unit> {
    override fun resumeWith(result: Result<Unit>) {
        println("${context[CoroutineName]?.name}")
    }

    override val context = coroutineContext
})

//输出：
Run Coroutine
c0-01
```

> 其实协程已经为我们提供了 `CoroutineName` 实现。

### 自定义协程拦截器
通过实现拦截器接口 `ContinuationInterceptor` 来定义拦截器，因为拦截器也是协程上下文的一类实现，所以使用拦截器时将其添加到对应的协程上下文中即可。

声明一个日志拦截器：
```kotlin
class LogInterceptor : ContinuationInterceptor {
    override val key = ContinuationInterceptor

    override fun <T> interceptContinuation(continuation: Continuation<T>) = LogContinuation(continuation)
}

class LogContinuation<T>(private val continuation: Continuation<T>) : Continuation<T> by continuation {

    override fun resumeWith(result: Result<T>) {
        println("before resumeWith: $result")
        continuation.resumeWith(result)
        println("after resumeWith")
    }
}
```

拦截器的关键拦截函数是 `interceptContinuation`，可以根据需要返回一个新的 `Continuation` 实例。

在协程生命周期内每次恢复调用都会触发拦截器。恢复调用有如下两种情况：

- 协程启动时调用一次，通过恢复调用来开始执行协程体从开始到下一次挂起之间的逻辑。
- 挂起点处如果异步挂起，则在恢复时再调用一次。

由此可知，恢复调用的次数为 `n+1` 次，其中 `n` 是协程体内真正挂起执行异步逻辑的挂起点的个数。

改写上面的例子：
```kotlin
// 异步挂起函数
suspend fun suspendFunc02() = suspendCoroutine<Int> { continuation ->
    thread {
        continuation.resumeWith(Result.success(5))
    }
}

// 开启协程 - 未添加日志拦截器
suspend {
    suspendFunc02()
    suspendFunc02()
}.startCoroutine(object : Continuation<Int> {
    override val context: CoroutineContext = EmptyCoroutineContext

    override fun resumeWith(result: Result<Int>) {
        ...
        result.onSuccess {
            println("Coroutine End: ${context[CoroutineName]?.name}, $result")
        }
    }
})
```
```
// 输出如下
Coroutine End: Success(5)
```
```kotlin
// 开启协程 - 添加日志拦截器
suspend {
    suspendFunc02()
    suspendFunc02()
}.startCoroutine(object : Continuation<Int> {
    override val context: CoroutineContext = LogInterceptor()

    override fun resumeWith(result: Result<Int>) {
        ...
        result.onSuccess {
            println("Coroutine End: ${context[CoroutineName]?.name}, $result")
        }
    }
})
```
```
// 输出如下：
before resumeWith: Success(kotlin.Unit)
after resumeWith
before resumeWith: Success(5)
after resumeWith
before resumeWith: Success(5)
after resumeWith
```
