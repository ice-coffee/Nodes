[toc]
### kotlin 委托
委托/代理模式：
- 代理协议
- 代理角色
- 被代理被代理角色

类委托、属性委托、自定义属性委托。

常用属性委托：

- `lazy`：延迟属性；
- `Delegates.notNull()`：不能为空；
- `Delegates.observable()`：可观察属性；
- `Delegates.vetoable()`：可观察属性，可拒绝修改属性；

自定义属性委托：

- `var` 属性自定义委托：继承 `ReadWriteProperty` 接口，并实现 `getValue()、setValue()` 方法；
- `val` 属性自定义委托：实现 `ReadOnlyProperty` 接口，并实现 `getValue` 方法。

Android + kotlin 委托应用

- `Fragment/Activity` 传参；
- `ViewBinding`。

### let、run、with、apply、also

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

### kotlin 函数

#### 扩展函数
定义：不改变原有类的情况下，扩展新的功能。
本质：扩展函数的本质就是一个普通的函数，它不会对原有类做任何修改，不一样的地方在于它默认以类对象作为函数的参数。

#### 高阶函数
定义：`高阶函数`：可以将函数用作参数或返回值的函数。
本质：高阶函数其实编译为 `java` 代码就是具有 `Function` 参数类型或返回值为 `Function` 类型的函数。
`kotlin` 准备了两种方式可以获得 `Function` 对象：

- `lambda` 表达式；
- 匿名函数；

优点：简化调用；
缺点：当大量调用高阶函数时会产生大量 `Function` 类对象，影响程序性能。

#### 内联函数
定义：使用 `inline` 修饰的函数。可以消除在使用高阶函数所带来的资源消耗。
内联函数使得 `lambda` 表达式的函数体被添加到了表达式被调用的地方，从而避免了创建 `Function` 对象。

> 注意：内联虽然会提升性能，但同时也会导致生成的代码增加，所以应避免内联过大的函数。

`lambda` 表达式中不能直接使用 `return` 而应该是用 `return@标签` 的形式。在内联函数中通过 `noinline` 和 `crossinline` 来限制在传参 `lambda` 中直接使用 `return`。

`noinline vs crossinline`

- `noinline`：取消内联。`lambda` 传参会转为 `Function` 对象。
- `crossinline`：正常内联。

在内联函数中还可以使用 `reified` 简化访问类型参数。

```
private inline fun <reified T: Activity> inlined() {
    body()
    Log.e("inline", "${T::class.java.name}")
}
```

### kotlin 泛型协变、逆变
定义：
> 逆变与协变用来描述类型转换后的继承关系，其定义：如果 `A、B` 表示类型，`f(⋅)` 表示类型转换，`≦` 表示继承关系（比如，`A≦B` 表示 `A` 是由 `B` 派生出来的子类）：
> 当 `A ≦ B` 时,如果有 `f(A) ≦ f(B)` ,那么 `f` 是协变的；
> 当 `A ≦ B` 时,如果有 `f(B) ≦ f(A)` ,那么 `f` 是逆变的；
> 如果上面两种关系都不成立，即 `(A)` 与 `f(B)` 相互之间没有继承关系，则叫做不变的。

注意：
> 不管是泛型通配符还是声明处形变，都既可以修饰集合也可以修饰类。

`kotlin vs java`
![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/kotlin_in_or_out.jpg)

### kotlin 协程
#### 协程的原理
协程通过挂起和恢复操作执行
