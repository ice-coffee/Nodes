[toc]

### 关键字

- `synchorinzed`
- `CAS`
- `委托/代理模式`

### 委托
要理解 `kotlin-委托` 的作用和用法首先要理解什么是委托。初看委托二字如果不太理解的话不妨转换成代理二字。委托模式和代理模式是一种设计模式的两种称呼而已。

#### 委托/代理模式
[设计模式 - 代理模式](https://app.yinxiang.com/shard/s58/nl/10744683/dd9c6fb0-a188-4778-8edc-f19fa39d1c7f/)

#### 类委托
对代理模式有了一些了解之后我们再来看 `kotlin-类委托` 是如何实现的：

``` kotlin
interface Base {
    fun print()
}

class BaseImpl(val x: Int) : Base {
    override fun print() { print(x) }
}

class Derived(b: Base) : Base by b

fun main() {
    val b = BaseImpl(10)
    Derived(b).print()
}
```

这是[Kotlin 语言中文站](https://www.kotlincn.net/docs/reference/delegation.html)的示例，转成 `Java` 代码如下：

``` java

public interface Base {
   void print();
}

// BaseImpl.java
public final class BaseImpl implements Base {
   private final int x;

   public void print() {
      int var1 = this.x;
      boolean var2 = false;
      System.out.print(var1);
   }

   public final int getX() {
      return this.x;
   }

   public BaseImpl(int x) {
      this.x = x;
   }
}

// Derived.java
public final class Derived implements Base {
   // $FF: synthetic field
   private final Base $$delegate_0;

   public Derived(@NotNull Base b) {
      Intrinsics.checkNotNullParameter(b, "b");
      super();
      this.$$delegate_0 = b;
   }

   public void print() {
      this.$$delegate_0.print();
   }
}

// DelegateTestKt.java
public final class DelegateTestKt {
   public static final void main() {
      BaseImpl b = new BaseImpl(10);
      (new Derived((Base)b)).print();
   }

   // $FF: synthetic method
   public static void main(String[] var0) {
      main();
   }
}
```

可以看到在 `Derived` 中已经实现了 `Base` 接口的抽象方法，而且方法的实际调用者是构造对象时传入的 `Base` 实例对象，也就是 `BaseImpl` 的实例对象。

对比上文介绍的代理模式：

- `Base`：代理协议
- `BaseImpl`：代理角色
- `Derived`：被代理角色

这样看的话，d上文类委托示例的结果包括重写方法实现和成员变量产生的结果的原因也就清晰明了了。

#### 属性委托
`kotlin` 标准库中提供的属性委托有：

- `lazy`：延迟属性；
- `Delegates.notNull()`：不能为空；
- `Delegates.observable()`：可观察属性；
- `Delegates.vetoable()`：可观察属性，可拒绝修改属性；

`lazy` 延迟属性后面再来分析，先来看 `Delegates` 的几个方法。

在 `Delegate.kt` 文件中定义了提供的标准属性委托方法，代码量很少就不贴代码了。可以看到三种委托方法都返回 `ReadWriteProperty` 接口的实例对象，它们的顶层接口是 `ReadOnlyProperty` 接口。名字就很体现它们各自的功用了：

- `ReadOnlyProperty`：仅用于可读属性，`val`；
- `ReadWriteProperty`：用于可读-写属性，`var`。

在属性委托的实现里，对应代理模式的角色如下：

- 协议：`ReadOnlyProperty` 和 `ReadWriteProperty`；
- 代理者：`Delegate`；
- 被代理者：实际使用属性。

`Delegates.notNull()` 比较简单，拿它来分析下属性委托是如何实现的。

``` kotlin
private class NotNullVar<T : Any>() : ReadWriteProperty<Any?, T> {
    private var value: T? = null

    public override fun getValue(thisRef: Any?, property: KProperty<*>): T {
        return value ?: throw IllegalStateException("Property ${property.name} should be initialized before get.")
    }

    public override fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        this.value = value
    }
}
```

``` kotlin
class DelegateTest {
    private val name: String by Delegates.notNull()
}
```
`kotlin` 转 `Java`
``` java
public final class DelegateTest {
   // $FF: synthetic field
   static final KProperty[] $$delegatedProperties = new KProperty[]{(KProperty)Reflection.property1(new PropertyReference1Impl(DelegateTest.class, "name", "getName()Ljava/lang/String;", 0))};
   private final ReadWriteProperty name$delegate;

   private final String getName() {
      return (String)this.name$delegate.getValue(this, $$delegatedProperties[0]);
   }

   public DelegateTest() {
      this.name$delegate = Delegates.INSTANCE.notNull();
   }
}
```

可以看到 `name` 属性委托给了 `NotNullVar` 的 `value` 属性。当访问 `name` 属性时，其实访问的是 `NotNullVar` 的 `value` 属性。

### Lazy
`lazy` 放到这里来分析是因为它虽然也是将属性委托给了其他类的属性，但它并没有继承 `ReadWriteProperty` 或 `ReadOnlyProperty` 接口并不是标准的属性委托。

`lazy` 源码如下：

``` kotlin
public actual fun <T> lazy(initializer: () -> T): Lazy<T> = SynchronizedLazyImpl(initializer)

public actual fun <T> lazy(mode: LazyThreadSafetyMode, initializer: () -> T): Lazy<T> =
    when (mode) {
        LazyThreadSafetyMode.SYNCHRONIZED -> SynchronizedLazyImpl(initializer)
        LazyThreadSafetyMode.PUBLICATION -> SafePublicationLazyImpl(initializer)
        LazyThreadSafetyMode.NONE -> UnsafeLazyImpl(initializer)
    }
```

`lazy` 函数接收两个参数：

- `LazyThreadSafetyMode`：线程安全模式；
- `initializer`：初始化函数。

`LazyThreadSafetyMode`：不同模式的作用如下：

- `SYNCHRONIZED`：通过 `Volatile + synchorinzed` 锁的方式保证在多线程情况下初始化函数仅调用一次，变量仅赋值一次；
- `PUBLICATION`：通过 `Volatile + CAS` 的方式保证在多线程情况下变量仅赋值一次；
- `NONE`：线程不安全。

`lazy` 函数返回 `Lazy` 接口实例。

> 注意：除非你能保证 `lazy` 实例的永远不会在多个线程初始化，否则不应该使用 `NONE` 模式。

`lazy` 函数会根据所选模式的不同返回不同的实例对象：`SynchronizedLazyImpl`、`SafePublicationLazyImpl`、`UnsafeLazyImpl`。这三者之间最大的的区别在于 `getter()` 函数的实现，但不管如何最终都是各自类中的 `value` 属性代理 `lazy` 函数所修饰的属性。

`synchorinzed`、`CAS` 都是多线程中实现锁的常用烦恼干是，关于他们的介绍可以看我之前的文章：

- [从 EventBus 看透 synchronized](https://juejin.cn/post/6969096460285509640)
- [CAS 居然可以代替 synchorinzed](https://juejin.cn/post/6972827113090973704)

### 自定义委托
根据 `Delegates` 和 `lazy` 的介绍，我们发现属性委托的实现其实是对于属性 `getValue、setValue` 两个运算符的重写。`var` 属性的委托实现需要实现 `getValue、setValue` 运算符，`val` 运算符的委托只需要实现 `getValue` 运算符。

参照 `ReadWriteProperty`，我们来实现自己的属性委托：

```kotlin
public interface ReadWriteProperty<in T, V> : ReadOnlyProperty<T, V> {
    
    public override operator fun getValue(thisRef: T, property: KProperty<*>): V

    public operator fun setValue(thisRef: T, property: KProperty<*>, value: V)
}
```

定义 `CustomDelegate` 类，重写 `getValue、setValue` 运算符：

```kotlin
class CustomDelegate<T, V> {
    private var value: T? = null

    operator fun getValue(thisRef: V, property: KProperty<*>): T {
        return value ?: throw IllegalStateException("Property ${property.name} should be initialized before get.")
    }

    operator fun setValue(thisRef: V, property: KProperty<*>, value: T) {
        this.value = value
    }
}
```

当然通过 `ReadWriteProperty、ReadOnlyProperty` 接口实现委托更加简单。

- `var` 属性自定义委托：继承 `ReadWriteProperty` 接口，并实现 `getValue()、setValue()` 方法；
- `val` 属性自定义委托：实现 `ReadOnlyProperty` 接口，并实现 `getValue` 方法。

``` java
public override operator fun getValue(thisRef: T, property: KProperty<*>): V

public operator fun setValue(thisRef: T, property: KProperty<*>, value: V)
```

参数说明：

- `thisRef` —— 必须与属性所有者类型相同或者是其超类型，通俗说就是属性所在类的类型或其父类型；
- `property` —— 表示委托属性的元信息，通过 `KProperty` 可以在运行时检查和操作属性。

```kotlin
println("delegate - thisRef: ${thisRef.toString()}")
println("delegate - property: name:${property.name}, returnType:${property.returnType}")

// 输出如下：
delegate - thisRef: com.study.myapplication.KotlinTest@5010be6
delegate - property: name:name, returnType:kotlin.String
```

### 应用
在项目中可以应用 `kotlin 委托` 可以辅助简写如下功能：

- `Fragment / Activity` 传参
- `ViewBinding`

本节所写的两个示例是摘自

[Kotlin | 委托机制 & 原理 & 应用](https://juejin.cn/post/6958346113552220173#heading-14) -- 彭丑丑
[View Binding 与Kotlin委托属性的巧妙结合，告别垃圾代码！](https://juejin.cn/post/6844904157808164878) -- Kirill Rozov 著，依然范特稀西 译

#### kotlin 委托 + Fragment / Activity 传参
示例来源：
[彭丑丑 - Kotlin | 委托机制 & 原理 & 应用](https://juejin.cn/post/6958346113552220173#heading-14)
项目地址：
[Github - DemoHall](https://github.com/pengxurui/DemoHall)

属性委托前：

``` kotlin
class OrderDetailFragment : Fragment(R.layout.fragment_order_detail) {

    private var orderId: Int? = null
    private var orderType: Int? = null

    companion object {

        const val EXTRA_ORDER_ID = "orderId"
        const val EXTRA_ORDER_TYPE = "orderType";

        fun newInstance(orderId: Int, orderType: Int?) = OrderDetailFragment().apply {
            Bundle().apply {
                putInt(EXTRA_ORDER_ID, orderId)
                if (null != orderType) {
                    putInt(EXTRA_ORDER_TYPE, orderType)
                }
            }.also {
                arguments = it
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        arguments?.let {
            orderId = it.getInt(EXTRA_ORDER_ID, 10000)
            orderType = it.getInt(EXTRA_ORDER_TYPE, 2)
        }
    }
}
```

定义 `ArgumentDelegate.kt`

``` kotlin
fun <T> fragmentArgument() = FragmentArgumentProperty<T>()

class FragmentArgumentProperty<T> : ReadWriteProperty<Fragment, T> {

    override fun getValue(thisRef: Fragment, property: KProperty<*>): T {
        return thisRef.arguments?.getValue(property.name) as? T
            ?: throw IllegalStateException("Property ${property.name} could not be read")
    }

    override fun setValue(thisRef: Fragment, property: KProperty<*>, value: T) {
        val arguments = thisRef.arguments ?: Bundle().also { thisRef.arguments = it }
        if (arguments.containsKey(property.name)) {
            // The Value is not expected to be modified
            return
        }
        arguments[property.name] = value
    }
}
```

使用属性委托后：

``` kotlin
class OrderDetailFragment : Fragment(R.layout.fragment_order_detail) {

    private lateinit var tvDisplay: TextView

    private var orderId: Int by fragmentArgument()
    private var orderType: Int? by fragmentArgumentNullable(2)

    companion object {
        fun newInstance(orderId: Int, orderType: Int?) = OrderDetailFragment().apply {
            this.orderId = orderId
            this.orderType = orderType
        }
    }

    override fun onViewCreated(root: View, savedInstanceState: Bundle?) {
        // Try to modify (UnExcepted)
        this.orderType = 3
        // Display Value
        tvDisplay = root.findViewById(R.id.tv_display)
        tvDisplay.text = "orderId = $orderId, orderType = $orderType"
    }
}
```

#### kotlin 委托 + ViewBinding
示例来源：
[ViewBindingPropertyDelegate](https://github.com/kirich1409/ViewBindingPropertyDelegate)

属性委托前：

``` kotlin
class ProfileActivity : AppCompatActivity(R.layout.activity_profile) {

    private var binding: ActivityProfileBinding? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityProfileBinding.inflate(layoutInflater)
        binding!!.profileFragmentContainer
    }
}
```

属性委托后：

``` kotlin
class ProfileActivity : AppCompatActivity(R.layout.activity_profile) {

    private val viewBinding: ActivityProfileBinding by viewBinding()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        with(viewBinding) {
            profileFragmentContainer
        }
    }
}
```

使用过后代码非常的简洁而且也不需要再用 `!!` 或者定义一个新的变量，有兴趣的同学可以去看下源码。
