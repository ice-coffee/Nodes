[TOC]

## 数据类型

### Kotlin 基本类型自动装箱

数字装箱保留了相等性, 但未保留同一性
[Kotlin 基本类型自动装箱](https://www.linuxidc.com/Linux/2017-10/147675.htm)

[Kotlin中的“数字装箱”问题·坑](https://blog.csdn.net/shenpibaipao/article/details/76855568)

在`Java`平台数字是物理存储为`JVM`的原生类型，除非我们需要一个可空的引用（如 `Int?`）或泛型。后者情况下会把数字装箱。

> 注意：数字装箱不一定保留同一性

```kotlin
val a: Int = 100
val boxedA: Int? = a
val anotherBoxedA: Int? = a

val b: Int = 10000
val boxedB: Int? = b
val anotherBoxedB: Int? = b

println(boxedA === anotherBoxedA) // true
println(boxedB === anotherBoxedB) // false
```
要理解这个例子的输出结果，首先要理解上述说明
`除非我们需要一个可空的引用（如 Int?）或泛型。 后者情况下会把数字装箱。`
也就是说在对可空数字类型或泛型赋值时会把数字装箱。

将`Kotlin`转为`Java`来看下：
```java
int a = 100;
Integer boxedA = Integer.valueOf(a);
Integer anotherBoxedA = Integer.valueOf(a);
int b = 10000;
Integer boxedB = Integer.valueOf(b);
Integer anotherBoxedB = Integer.valueOf(b);
boolean var7 = boxedA == anotherBoxedA;
System.out.println(var7);
var7 = boxedB == anotherBoxedB;
System.out.println(var7);
```

可以看到果然对数字进行了装箱操作，也就是说我们所比较的是两个对象是否是同一个对象，从结果倒推过程也就是说，`boxedA`和`anotherBoxedA`是同一个对象，`boxedB`和`anotherBoxedB`不是同一个对象，这是为什么呢？再来看下Integer.valueOf()的源码：

```java
public static Integer valueOf(int var0) {
    return var0 >= -128 && var0 <= Integer.IntegerCache.high ? Integer.IntegerCache.cache[var0 + 128] : new Integer(var0);
}
```

其中`Integer.IntegerCache.high`为127，好了真相大白：`Kotlin文档的示例代码中说的不一定保留同一性，表示的是数字范围在[-128， 127]，引用相同，其他不同。`

### **操作符**
[揭秘 Kotlin 中的 == 和 ===](https://mp.weixin.qq.com/s/Ay29MUlvMzHB9QBpRetm7A)

#### 比较操作符
**`Java：`**
`==`：
基本数据类型：值比较
引用数据类型：地址比较

`equals`：默认情况下在不重写 `equals` 方法时，等价于 `==`

> 注意：
> 1. `String` -> `equals`：地址相等 或 值相等都为 `true`。

**`Kotlin：`**
`===`：
基本数据类型：值比较
引用数据类型：地址比较

`==`、`equals`：

`Kotlin` 中的操作符 `==` 等价于 `equals` 用于比较对象的结构是否相等, 也就是对象内部变量会依次执行 `equals` 操作，都为 `true` 则为 `true`。

**`注意：`**
* `String` -> `equals`：地址相等 或 值相等都为 `true`。
* `Integer.valueOf()、Long.valueOf()`：`Kotlin` 整型赋值会先从缓存中获取`[-128,127]`，若缓存没有再创建新对象。
* 浮点型（`Float`、`Double`）：对于带符号的 `0`，`==` 和 `equals` 处理结果不一样。

整型比较：
```kotlin
val b:Int = 5
val b1:Int? = b
val b11:Int? = b
println(b1 === b11) // 注意这里打印的是 'true'

val a: Int = 10000
val a1: Int? = a
val a11: Int? = a 
println (a1 === a11 ) // 注意这里打印的是 'false'
-->
int a = 10000;
Integer a1 = Integer.valueOf(a);
Integer a11 = Integer.valueOf(a);
boolean var5 = a1 == a11;
System.out.println(var5);

val b1:Int? = 5
val b11:Int? = 5
println(b1 === b11) // 注意这里打印的是 'true'

val a1: Int? = 10000
val a11: Int? = 10000
println (a1 === a11 ) // 注意这里打印的是 'false'
--->
Integer a1 = 10000;
Integer a11 = 10000;
boolean var4 = a1 == a11;
System.out.println(var4);
// 为什么上面 Integer a1 = Integer.valueOf(a); 和 val a1: Int? = 10000 赋值的方式比较的结果一样还不清楚

val c1:Int = 10000
val c11:Int = 10000
println(c1 === c11) // 注意这里打印的是 'true'
--->
int c1 = 10000;
int c11 = 10000;
boolean var4 = true;
System.out.println(var4);
```

浮点型比较：
```kotlin
float a3 = -0.0F;
float a4 = 0.0F;
System.out.println(a3 == a4); // true

Float a3 = -0.0F;
Float a4 = 0.0F;
System.out.println(a3 == a4); // false
System.out.println(a3.equals(a4)); // false

val a3 = -0f
val a4 = 0f
println(a3 == a4)       // true
println(a3.equals(a4))  // false
println(a3 === a4)      // true
```

自定义数据类型比较：
```kotlin
val s1 = Student("aaa", 13)
val s2 = Student("aaa", 13)

println(s1 == s2)       // true
println(s1.equals(s2))   // true
println(s1 === s2)      // false

val p1 = People(Home(), "aaa", 13)
val p2 = People(Home(), "aaa", 13)

println(p1 == p2)       // false
println(p1.equals(p2))  // false
println(p1 === p2)      // false

data class Student(var name: String, var age: Int)
data class People(var home: Home, var name: String, var age: Int)
class Home
```

#### 显示转换
`Kotlin` 缺乏隐式转换,  但是算术运算会有重载做适当转换，例如：
```kotlin
val l = 1L + 3 // Long + Int => Long
```

### 空安全操作符

* 可空类型声明：`？`
* 非空断言：`!!`
* 安全调用：`?.`

安全调用在链式调用中如果任意一个属性（环节）为 `null`，这个链式调用就会返回 `null`。

```kotlin
bob?.department?.head?.name
```

* Elvis 操作符：`?:`
* 安全的类型转换：`as?`

如果对象不是目标类型，那么常规类型转换可能会导致 `ClassCastException`。 另一个选择是使用安全的类型转换，如果尝试转换不成功则返回 `null`：

```kotlin
val aInt: Int? = a as? Int
```

* 可空类型的集合：

如果你有一个可空类型元素的集合，并且想要过滤非空元素，你可以使用 `filterNotNull` 来实现：

```kotlin
val nullableList: List<Int?> = listOf(1, 2, null, 4)
val intList: List<Int> = nullableList.filterNotNull()
```

## 类
#### 抽象类和接口

[抽象类和接口](https://blog.csdn.net/io_field/article/details/52860971)

#### Parcelable

`kotlin` 提供了注解简化Parcelable的书写：

* `build.gradle` 中添加如下代码：

```gradle
plugins {
    id 'kotlin-android-extensions'
}

// 若 kotlin_version 大于 1.5.30 则不需要手动添加依赖
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-parcelize:$kotlin_version"
}
```

* 定义类实现 `Parcelable` 接口，并添加 `@Parcelize` 注解

```kotlin
@Parcelize
data class TestModel(val name: String = "张三") : Parcelable
```

#### Kotlin 之 let、apply、with、run 函数区别
它们的唯一目的是在对象的上下文中执行代码块。
这些函数基本上做了同样的事情：在一个对象上执行一个代码块。不同的是这个对象在块中如何使用，以及整个表达式的结果是什么。

| 函数 | 对象引用 | 返回值 | 是否是扩展函数 |
| --- | --- | --- | --- |
| let | it | Lambda 表达式结果 | 是 |
| run | this | Lambda 表达式结果 | 是 |
| run | - | Lambda 表达式结果 | 不是：调用无需上下文对象 | 
| with | this | Lambda 表达式结果 | 不是：把上下文对象当做参数 |
| apply | this | 上下文对象 | 是 |
| also | it | 上下文对象 | 是 |

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/kotlin_action_space.jpg)
