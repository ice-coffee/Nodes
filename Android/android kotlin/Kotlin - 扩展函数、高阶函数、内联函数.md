[toc]

### 关键词
- `扩展函数`
- `内联函数`
- `泛型协变、逆变`

在上篇文章 [偷师 - Kotlin 委托](https://juejin.cn/post/6974663675957379086) 里提到了 `ViewBindingDelegate` 库，通过 `kotlin` 委托的方式简化了在 `Android` 项目中 `ViewBinding` 使用。本来是不想再写 `ViewBindingDelegate` 分析的，但是项目中用到的 `kotlin` 知识点确实也有些是需要重点记录一下的。

直接来看 `vbpd-full/../ActivityViewBindings.kt` 文件中的 `viewBinding` 方法：

```kotlin
...
@JvmName("inflateViewBindingActivity")
public inline fun <reified T : ViewBinding> ComponentActivity.viewBinding(
    createMethod: CreateMethod = CreateMethod.BIND
) = viewBinding(T::class.java, createMethod)

...
```

可以看到这是一个扩展函数。第一个知识点来了！

### 扩展函数
扩展函数定义：`不改变原有类的情况下，扩展新的功能`。

首先确定一点扩展函数针对的是类，为类提供新的功能。那是怎么实现的呢，看下面的示例：

我定义了一个 `String` 的扩展函数用以输出它的长度：

```kotlin
private fun String.printLength() {
}
```

转换成 `java` 代码看下

```java
private final void printLength(String $this$printLength) {
}
```

这样就很好的理解扩展函数的本质了：`扩展函数的本质就是一个普通的函数，它不会对原有类做任何修改，不一样的地方在于它默认以类对象作为函数的参数`。

在扩展函数内部你可以通过 `this` 关键字访问传过来的在点符号前的对象，也就是上面示例中的 `$this$printLength` 参数。而 `this` 也可以省略。

```kotlin
private fun String.printLength() {
    Log.e("length", "$length")
}
```

转换为 `java` 代码如下：

```java
private final void printLength(String $this$printLength) {
  Log.e("length", String.valueOf($this$printLength.length()));
}
```

```java
val name = "张三"
name.printLength()

// 输出
2
```

这也就是为什么在 `ViewBindingDelegate` 项目中会突然出现 `activity` 变量的原因：

```kotlin
@JvmName("viewBindingActivity")
public fun <T : ViewBinding> ComponentActivity.viewBinding(
    viewBindingClass: Class<T>,
    rootViewProvider: (ComponentActivity) -> View
): ViewBindingProperty<ComponentActivity, T> {
    return viewBinding { activity -> ViewBindingCache.getBind(viewBindingClass).bind(rootViewProvider(activity)) }
}
```

#### 总结
扩展函数和普通函数的区别：

- **形式上**：扩展函数比普通函数多了被扩展的类型作为前缀 `被扩展类型.函数名()`
- **用法上**：扩展函数以被扩展的目标类作为首参类型，此参数不可见，但可通过 `this`(可省略) 关键字访问被扩展的目标类对象。

### 内联函数
还是上面的代码：

```kotlin
@JvmName("inflateViewBindingActivity")
public inline fun <reified T : ViewBinding> ComponentActivity.viewBinding(
    createMethod: CreateMethod = CreateMethod.BIND
) = viewBinding(T::class.java, createMethod)
```

发现两个不太认识的关键字：`inline`、`reified`。在介绍它们之前应该先理解两个概念：

- `高阶函数`：可以将函数用作参数或返回值的函数。
- `内联函数`：使用 `inline` 修饰的函数。可以消除使用高阶函数时所带来的资源消耗。

#### 高阶函数
先看一个正常的函数，两数相加：

```kotlin
private fun addTwoNumbers(firstNumber: Int, secondNumber: Int): Int {
    return firstNumber + secondNumber
}
```

很简单，没有什么好说的。但是发现一个问题，如果计算两数相减、相乘、相除就需要再定义三个函数，但是并不想这么做，怎么办呢。这种情况下高阶函数就可以派上用场了，新函数如下：

```kotlin
private fun calculateTwoNumber(
    firstNumber: Int,
    secondNumber: Int,
    calculate: (Int, Int) -> Int
): Int {
    return calculate(firstNumber, secondNumber)
}
```

函数 `calculateTwoNumber` 接受一个函数参数 `calculate`，`calculate` 函数接受两个 `Int` 型参数并返回 `Int` 型结果。`calculateTwoNumber` 就是一个高阶函数。

转成 `java` 来看下：

```java
private final int calculateTwoNumber(int firstNumber, int secondNumber, Function2 calculate) {
  return ((Number)calculate.invoke(firstNumber, secondNumber)).intValue();
}
```

发现 `calculate` 的参数类型是 `Function2`，既然有了 `Function2` 那是不是还有 `Function4、5、6、7、8、9` 呢。这个可以有，事实上有 `Function0~22` 共 `23` 个接口类型。

```kotlin
public interface Function<out R>

public interface Function0<out R> : Function<R> {
    public operator fun invoke(): R
}

public interface Function1<in P1, out R> : Function<R> {
    public operator fun invoke(p1: P1): R
}

/** 接收两个参数的 Function */
public interface Function2<in P1, in P2, out R> : Function<R> {
    /** 执行 invoke 函数 通过参数 P1、P2 得到并返回结果 R */
    public operator fun invoke(p1: P1, p2: P2): R
}

...

public interface Function10<in P1, in P2, in P3, in P4, in P5, in P6, in P7, in P8, in P9, in P10, out R> : Function<R> {
    public operator fun invoke(p1: P1, p2: P2, p3: P3, p4: P4, p5: P5, p6: P6, p7: P7, p8: P8, p9: P9, p10: P10): R
}

...
```

它们的区别就是传参数量的区别。

那现在现在清楚了所谓的高阶函数其实编译成 `java` 就是 `具有 Function 参数类型或返回值为 Function 类型的函数`。

`kotlin` 准备了两种方式可以获得 `Function` 对象：

- `lambda` 表达式
- 匿名函数

**`lambd 表达式：`**

`lambda` 表达式语法如下：

> {参数声明 -> 函数体}

使用 `lambda` 注意以下几点：

1. 参数声明类型可选，也就是说可以不标注参数类型。
```kotlin
{a: Int, b: Int -> a + b}
等价于
{a, b -> a + b}
```

2. 如果高阶函数的最后一个参数是函数，那么作为相应参数传入的 `lambda` 表达式可以放在圆括号之外。
```kotlin
calculateTwoNumber(1, 2, {a: Int, b: Int -> a + b})
等价于
calculateTwoNumber(1, 2) { a: Int, b: Int -> a + b }
```

3. 如果该 `lambda` 表达式是调用时唯一的参数，那么圆括号可以完全省略。
```kotlin
run { println("...") }
```

4. 当 `lambda` 表达式只有一个参数时可以不用声明唯一的参数并忽略 `->`。注意此时仅可使用默认变量名 `it`。
```kotlin
val ints = listOf<Int>()
ints.filter { it > 0 }
```
 
5. `lambda` 表达式默认返回最后一个表达式的值，也可以通过 `return` 显示指定返回值。
```kotlin
ints.filter {
    val shouldFilter = it > 0 
    shouldFilter
}

// 或
ints.filter {
    val shouldFilter = it > 0 
    return@filter shouldFilter
}
```

6. `lambda` 表达式中不可直接使用 `return`，要退出 `lambda` 需要用到标签。但是如果传给的函数是内联（内联函数在下文讲解）的，可以直接使用 `return`。
```kotlin
fun ordinaryFunction(block: () -> Unit) {
    println("hi!")
}
fun foo() {
    ordinaryFunction {
        return // 错误：不能使 `foo` 在此处返回
        return@ordinaryFunction // 正确
    }
}
fun main() {
    foo()
}
```

`lambda` 表达式语法缺少指定函数的返回类型的能力。在大多数情况下返回类型可以自动推断出来。但是如果确实需要显式指定，那就需要用到 `匿名函数` 了。

**`匿名函数：`**

匿名函数和常规函数的区别在于匿名函数没有函数名。其他和常规函数一模一样。

```kotlin
fun(x: Int, y: Int): Int {
    return x + y
}

// 也可以写成
fun(x: Int, y: Int): Int = x + y
```

如果函数返回类型可以推导出来那么返回类型也可以省略。

示例：
```kotlin
val list = listOf(0, 1, 2, 3)
val newList = list.filter(fun(it) = it > 0)
println(newList)

// 输出
[1, 2, 3]
```

> `注意`：当匿名函数作为参数传递时，需将其放在括号内。 允许将函数留在圆括号外的简写语法仅适用于 `lambda` 表达式。

#### 高阶函数优化 - 内联函数

现在已经清楚了高阶函数的定义，那我们来用高阶函数来计算 `0~10` 的和：

```kotlin
var result = 0
for (i in 0..10) {
    result = calculateTwoNumber(result, i) { a: Int, b: Int -> a + b }
}
Log.e("highfun", "$result") // 55
```

完美！结果明显是正确的。那再看一下编译后的代码：

```java
int result = 0;
int i = 0;

for(byte var4 = 10; i <= var4; ++i) {
 result = this.calculateTwoNumber(result, i, (Function2)null.INSTANCE);
}

Log.e("highfun", String.valueOf(result));
```

可以发现每次循环都会创建 `Function` 实例，这样在大量循环情况下会产生大量对象，影响内存，这明显得优化。优化方式有两种：

优化一：将 `lambda` 放到循环外定义。

```kotlin
val addCalculate = { a: Int, b: Int -> a + b }
var result = 0
for (i in 0..10) {
    result = calculateTwoNumber(result, i, addCalculate)
}
```

优化二：使用 `inline` 修饰高阶函数为内联函数。
```kotlin
private inline fun calculateTwoNumber(
    firstNumber: Int,
    secondNumber: Int,
    calculate: (Int, Int) -> Int
): Int {
    return calculate(firstNumber, secondNumber)
}
```

使用 `inline` 修饰高阶函数后查看编码之后的代码：

```java
for(byte var4 = 10; i <= var4; ++i) {
 int $i$f$calculateTwoNumber = false;
 int var9 = false;
 result += i;
}
```

可以发现 `lambda` 表达式的函数体被添加到了表达式被调用的地方，从而避免了创建 `Function` 对象。

> 注意：`内联虽然会提升性能，但同时也会导致生成的代码增加，所以应避免内联过大的函数`。

#### noinline、crossinline

在上文中提到过传递给 `inline` 内联函数的 `lambda` 表达式中可以使用 `return` 返回。那我们来看下面的例子：

```kotlin
private fun callFunction() {
    inlined {
        Log.e("inline", "2")
        return
    }
}

private inline fun inlined(body: () -> Unit) {
    Log.e("inline", "1")
    body()
    Log.e("inline", "3")
}

输出 ------
E/inline: 1
E/inline: 2
```

可以看到代码中有三条日志打印信息，但是输出中只打印了两条。这里 `lambda` 表达式中的 `return` 语句在输出最后一条日志信息时直接结束了整个内联函数。所以使用 `lambda` 表达式给 `inline` 内联函数传参时应该避免直接使用 `return`，而改用 `return@标签` 的方式。修改下代码：

```kotlin
private fun callFunction() {
    inlined {
        Log.e("inline", "2")
        return@inlined
    }
}

输出 ------
E/inline: 1
E/inline: 2
E/inline: 3
```

`kotlin` 中也提供了两个修饰符来帮助限制在 `inline` 函数传参为 `lambda` 时，在 `lambda` 中直接使用 `return`（编译不通过）：

- `noinline`
- `crossinline`

**`noinline：`**

如果希望只内联一部分传给内联函数的 `lambda` 表达式参数，那么可以用 `noinline` 修饰符标记不希望内联的函数参数：

```kotlin
inline fun foo(inlined: () -> Unit, noinline notInlined: () -> Unit) { …… }
```

可以内联的 `lambda` 表达式只能在内联函数内部调用或者作为可内联的参数传递，但是 `noinline` 的可以以任何我们喜欢的方式操作：`赋值给变量`、`传递给其他高阶函数` 等等。

而且使用 `noinline` 修饰的函数参数，在为其传递 `lambda` 表达式时不能直接使用 `return` 不然会报错，需要使用 `return@标签`。修改上面的示例：

```kotlin
private inline fun inlined(noinline body: () -> Unit) {
    Log.e("inline", "1")
    body()
    Log.e("inline", "3")
}

输出 ------
E/inline: 1
E/inline: 2
E/inline: 3
```

但是使用 `noinline` 也会出现一个问题，我们看一下编译后的 `java` 代码：

``` java
private final void callFunction() {
  Function0 body$iv = (Function0)null.INSTANCE;
  int $i$f$inlined = false;
  Log.e("inline", "1");
  body$iv.invoke();
  Log.e("inline", "3");
}
```

看起来跟没有使用 `inline` 修饰的高阶函数调用是一模一样的。而且你会看到警告信息：
`Expected performance impact from inlining is insignificant. Inlining works best for functions with parameters of functional types`。
意思就是如果一个内联函数没有可内联的函数参数并且没有具体化的类型参数，那么这样的函数很可能并无益处（如果你确认需要内联，则可以用 `@Suppress("NOTHING_TO_INLINE")` 注解关掉该警告）。

那有没有即可以函数内联还可以保证 `lanmbda` 传参里没有直接使用 `return` 呢。

**`crossinline：`**
`crossinline` 和 `noinline` 都可以限制 `lambda` 传参不可直接使用 `return`，区别在于 `crossinline` 修饰的函数参数仍然是内联的。修改上面的示例：

```kotlin
private inline fun inlined(crossinline body: () -> Unit) {
    Log.e("inline", "1")
    body()
    Log.e("inline", "3")
}
```

查看编译后的 `java` 代码：

``` java
private final void callFunction() {
  int $i$f$inlined = false;
  Log.e("inline", "1");
  int var3 = false;
  Log.e("inline", "2");
  Log.e("inline", "3");
}
```

#### 具体化的参数类型
`inline` 内联函数还提供了另一个有意思的能力：`reified`。

`reified` 主要简化了访问类型参数的能力，顾名思义类型参数就是函数参数是 `class` 对象，看如下代码：

```kotlin
private inline fun <T: Activity> inlined(clazz: Class<T>) {
    body()
    Log.e("inline", "${clazz.name}")
}

调用：
inlined(MainActivity::class.java)
```

其实没什么问题，就是看起来不是很优雅（装X），那怎么办呢。使用 `reified` 改造一下：

```kotlin
private inline fun <reified T: Activity> inlined() {
    body()
    Log.e("inline", "${T::class.java.name}")
}

调用：
inlined<MainActivity>()
```

查看编译后的 `java` 代码其实没什么差别，就是简便轻巧！

#### 总结
本节主要介绍了 `kotlin` 中的高阶函数和内联函数。高阶函数可以将函数用作参数或返回值，但是使用高阶函数会有一定的性能损耗，可以使用 `inline` 修饰为内联函数以避免性能损耗，并且为了避免代码量会增加，所以应避免内联过大的函数。另外使用 `noinline`、`crossinline` 修饰符可以限制 `lambda` 传参中直接使用 `return` 关键字以避免影响函数正常执行。内联函数还提供了 `reified` 简化在函数中使用类型参数。
