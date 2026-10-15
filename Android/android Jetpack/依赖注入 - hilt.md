[toc]

### 参考资料
[Jetpack 新成员 Hilt 实践（一）启程过坑记](https://juejin.cn/post/6844904198803292173)

[全方面分析 Hilt 和 Koin 性能](https://juejin.cn/post/6846687596370722823)

[Jetpack新成员，一篇文章带你玩转Hilt和依赖注入](https://juejin.cn/post/6902009428633698312#heading-10)

### 什么是依赖注入
首先来看下面的示例代码：

```kotlin
class Car {

    private val engine = Engine()

    fun start() {
        engine.start()
    }
}

fun main(args: Array) {
    val car = Car()
    car.start()
}
```

可以看到 `Car` 类自己创建了 `Engine` 对象实例来执行 `start` 操作。如果我们想得到一辆普通汽车和一辆电动汽车就得创建两个类。

普通汽车：
```kotlin
class GasCar {

    private val engine = GasEngine()

    fun start() {
        engine.start()
    }
}
```

电动汽车：
```kotlin
class ElectricCar {

    private val engine = ElectricEngine()

    fun start() {
        engine.start()
    }
}
```

可以看到这两个类中仅仅是构造的 `Engine` 实现不同而已，但是我们却创建了两个不同的类，也就是这两个类的耦合太重了。我们来优化一下：

```kotlin
class Car(private val engine: Engine) {
    fun start() {
        engine.start()
    }
}

fun main(args: Array) {
    val eEngine = ElectricEngine()
    val eCar = Car(eEngine)
    eCar.start()
    
    val gEngine = GasEngine()
    val gCar = Car(gEngine)
    gCar.start()
}
```

优化完成之后 `Engine` 通过参数形式给 `Car` 提供对象，这样仅需要一个 `Car` 类就可以得到各种各样的汽车了，就达到了解耦的目的。这种以参数形式提供调用类所需对象的方式就是依赖注入。

依赖注入就是给予调用方所需要的事物。其中 `依赖` 是指可被方法调用的事物。在依赖注入形式下，调用方不再直接获取依赖，而是通过 `注入` 的方式传递给调用方。在 `注入` 之后，调用方才会调用该 `依赖`。传递依赖给调用方，而不是让调用方直接获得依赖，是依赖注入的核心。

### 为什么使用依赖注入
总结来说依赖注入的最大作用是 `解耦`。通过了解依赖注入的概念，我们知道通过依赖注入可以让调用方不必直接生产依赖方，双方 `分离解耦`。并且由于依赖方对象实例的创建由依赖注入框架完成所以 `减少了大量样板代码`，`代码更易理解`。通过依赖注入控制注入的数据可以让 `测试更加方便`。当调用方生命周期结束时依赖注入框架还可以 `自动释放相应的对象以防止内存占用`。

`Dagger`、`Hilt`、`Koin` 都是依赖注入框架。其中 `Hilt` 是对 `Dagger` 的简易封装使框架更易使用。`Koin` 是针对于 `Kotlin` 开发者提供的轻量级依赖注入框架。对于 `Hilt` 和 `Koin` 之间的对比大家可以看下面这篇文章：

[全方面分析 Hilt 和 Koin 性能](https://juejin.cn/post/6846687596370722823)

下面我们先来介绍 `Hilt` 是如何使用的。

### 添加依赖项
在项目根 `build.gradle` 文件中添加插件：
```gradle
buildscript {
    ...
    dependencies {
        ...
        classpath 'com.google.dagger:hilt-android-gradle-plugin:2.28-alpha'
    }
}
```

在 `app` 以及其他使用 `Hilt` 模块下的 `build.gradle` 文件中添加如下代码：
```gradle
...
apply plugin: 'kotlin-kapt'
apply plugin: 'dagger.hilt.android.plugin'

android {
    ...
}

dependencies {
    implementation "com.google.dagger:hilt-android:2.28-alpha"
    kapt "com.google.dagger:hilt-android-compiler:2.28-alpha"
}
```

如果你使用的是 `Java` 开发项目，可以不引入 `kotlin-kapt` 插件，并且 `kapt` 关键字替换成 `annotationProcessor`。

最后，由于 `Hilt` 使用 `Java8` 功能，所以需要在 `app/build.gradle` 文件中添加如下代码启用 `Java 8` 功能：

```
android {
  ...
  compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
  }
}
```

### 各注解用法讲解

#### @HiltAndroidApp
要使用 `Hilt` 必须创建 `Application` 类并添加 `@HiltAndroidApp` 注解。然后将 `Application` 注册到 `AndroidManifest.xml` 文件中。

```kotlin
@HiltAndroidApp
class SampleApplication : Application()
```

```xml
<application
    android:name=".SampleApplication" >

</application>
```

#### @AndroidEntryPoint
`Hilt` 目前支持注入的 `Android` 类共有如下 6 种：

- `Application`（通过使用 `@HiltAndroidApp`）
- `Activity`
- `Fragment`
- `View`
- `Service`
- `BroadcastReceiver`

除 `Application` 需要 `@HiltAndroidApp` 修饰外，其他需要依赖注入的类都需要添加 `@AndroidEntryPoint` 注解。

```kotlin
@AndroidEntryPoint
class MainHiltActivity: AppCompatActivity() {
}
```

> 注意：
> - `Hilt` 仅支持扩展 `ComponentActivity` 的 `Activity`，如 `AppCompatActivity`。
> - `Hilt` 仅支持扩展 `androidx.Fragment` 的 `Fragment`。
> - `Hilt` 不支持保留的 `Fragment`。

#### @Inject
接下来就可以通过 `@Inject` 来执行注入了：

```kotlin
@AndroidEntryPoint
class MainHiltActivity: AppCompatActivity() {

    @Inject
    lateinit var capBean: CapBean
}
```

> 注意：由 `Hilt` 注入的字段不能为私有字段。

到这里还并不能完成 `capBean` 字段的注入，这时 `Hilt` 并不知道如何创建实例对象。需要在构造函数上添加 `@Inject` 注解。这时 `Hilt` 就知道如何创建需要注入的实例对象了。

```kotlin
class CapBean @Inject constructor()
```

同理如果需要注入对象的构造函数中带有参数那么也需要对所需参数的构造函数添加 `@Inject` 注解。

```kotlin
class CapBean @Inject constructor(val waterBean: WaterBean)

class WaterBean @Inject constructor()
```

#### @Module
有些情况无法通过在构造函数中添加 `@Inject` 注解的方式来告知 `Hilt` 如何提供该类或接口的实例，比如：

- 接口。
- 来自外部库的类。

怎么处理呢？

##### @Binds
注入接口实例，需要通过 `@Module + @Binds` 注解的方式。

首先定义一个接口：

```kotlin
interface Water {
    fun drink()
}
```

然后定义接口的实现类：

```kotlin
class Milk @Inject constructor() : Water {
    override fun drink() {
        Log.e("water", "drink milk")
    }
}
```

然后定义一个抽象类添加 `@Module` 注解：

```kotlin
@Module
@InstallIn(ApplicationComponent::class)
abstract class WaterModule {
}
```

> 注意：`@Module` 必须和 `@InstallIn` 共用，以告知 `Hilt` 每个模块的作用域。

在抽象类中创建一个带 `@Binds` 注解的抽象函数：

```kotlin
@Module
@InstallIn(ApplicationComponent::class)
abstract class WaterModule {

    @Binds
    abstract fun bindsWater(milk: Milk): Water
}
```

带有 `@Binds` 注解的函数会向 `Hilt` 提供以下信息：

- 函数返回类型会告知 `Hilt` 函数提供哪个接口的实例。
- 函数参数会告知 `Hilt` 要提供哪种实现。

到这里 `Hilt` 就知道如何将接口的具体实现注入了。

```kotlin
@AndroidEntryPoint
class MainHiltActivity: AppCompatActivity() {

    @Inject
    lateinit var water: Water
}
```

##### @Provides
如果某个类不归你所有，也无法通过构造函数注入。可以通过 `@Module + @Provides` 注解告诉 `Hilt` 如何提供此类型的实例。

首先定义一个 `@Module` 注解修饰的普通类，这里是普通类而不是抽象类，因为我们要提供类实例的具体实现方式。以 `OkHttpClient` 为例：

```kotlin
@Module
@InstallIn(ActivityComponent::class)
class NetworkModule {
}
```

创建函数添加 `@Provides` 注解，函数体提供 `OkHttpClient` 对象实例的具体创建：

```kotlin
@Module
@InstallIn(ActivityComponent::class)
class NetworkModule {

    @Provides
    fun provideOkHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .connectTimeout(20, TimeUnit.SECONDS)
            .readTimeout(20, TimeUnit.SECONDS)
            .writeTimeout(20, TimeUnit.SECONDS)
            .build()
    }
}
```

带有 `@Provides` 注解的函数会向 `Hilt` 提供以下信息：

- 函数返回类型会告知 `Hilt` 函数提供哪个类型的实例。
- 函数参数会告知 `Hilt` 相应类型的依赖项。
- 函数主体会告知 `Hilt` 如何提供相应类型的实例。每当需要提供该类型的实例时，`Hilt` 都会执行函数主体。

这时就可以通过 `Hilt` 注入了：

```kotlin
@AndroidEntryPoint
class MainActivity : AppCompatActivity() {

    @Inject
    lateinit var okHttpClient: OkHttpClient
    ...
}
```

#### @Qualifier
在上面我们通过 `@Binds` 提供了 `Water` 接口的 `Milk` 实现，并成功注入到了类中。那如果在调用类中不仅需要 `Milk` 实现还需要另一个 `Water` 接口的实现 `Juice`。要怎么处理呢？

首先添加 `Juice` 实现：

```kotlin
class Juice @Inject constructor() : Water {
    override fun drink() {
        Log.e("water", "drink juice")
    }
}
```

依然要添加到 `@Module` 模块中：

```kotlin
@Module
@InstallIn(ActivityComponent::class)
abstract class WaterModule {

    @Binds
    abstract fun bindsMilk(milk: Milk): Water

    @Binds
    abstract fun bindsJuice(juice: Juice): Water
}
```

到这里直接注入调用类中还不可以：

```kotlin
@AndroidEntryPoint
class MainHiltActivity: AppCompatActivity() {
    @Inject
    lateinit var juice: Water

    @Inject
    lateinit var milk: Water
}
```

`Hilt` 没有办法区分两个 `Water` 实例的不同的，这时需要 `@Qualifier` 来定义注解区分相同类型的不同实例了。

```kotlin
@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class MilkWater

@Qualifier
@Retention(AnnotationRetention.BINARY)
annotation class MilkWater
```

然后将定义的两个注解添加到 `WaterModule` 的函数中，以告诉 `Hilt` 如何提供同一实例的不同实例：

```kotlin
@Module
@InstallIn(ActivityComponent::class)
abstract class WaterModule {

    @MilkWater
    @Binds
    abstract fun bindsMilk(milk: Milk): Water

    @JuiceWater
    @Binds
    abstract fun bindsJuice(juice: Juice): Water
}
```

在调用类中也需要添加我们刚才定义的注解来区分两个实例的不同：

```kotlin
@AndroidEntryPoint
class MainHiltActivity: AppCompatActivity() {

    @JuiceWater
    @Inject
    lateinit var juice: Water

    @MilkWater
    @Inject
    lateinit var milk: Water
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_hilt)
        juice.drink()
        milk.drink()
    }
}
```

输出如下：

```
E/water: drink juice
E/water: drink milk
```

#### @ApplicationContext、@ActivityContext
`Hilt` 提供了一些预定义的限定符。

- `@ApplicationContext`：提供 `Application` 的 `Context`。
- `@ActivityContext`：提供 `Activity` 的 `Context`。

#### Hilt 组件
`Hilt` 组件的作用是将 `Hilt` 提供的实例注入到相应的 `Android` 类。`Hilt` 组件使用如下：

```kotlin
@Module
@InstallIn(ActivityComponent::class)
object MainModule {

    @Provides
    fun provideCoffeeBean(): CoffeeBean {
        return CoffeeBean()
    }
}
```

由于 `@InstallIn` 注解中设置的组件为 `ActivityComponent`，表示 `Hilt` 将通过 `MainModule` 为 `Activity` 提供的实例。

##### @Installin
`@Installin` 注解如下：
```java
@Retention(CLASS)
@Target({ElementType.TYPE})
@GeneratesRootInput
public @interface InstallIn {
  Class<?>[] value();
}
```

`@Installin` 包含一个字段，字段可用值为 `Hilt` 提供的组件，这些组件代表要注入的目标 `Android` 类。如下表：

| Hilt 组件 | 注入器面向的对象 |
| --- | --- |
| ApplicationComponent | Application |
| ActivityRetainedComponent | ViewModel |
| ActivityComponent | Activity |
| FragmentComponent | Fragment |
| ViewComponent | View |
| ViewWithFragmentComponent | 带有 @WithFragmentBindings 注释的 View |
| ServiceComponent | Service |

##### 组件生命周期
`Hilt` 会按照相应 `Android` 类的生命周期自动创建和销毁生成的组件类的实例。

> 注意：`ActivityRetainedComponent` 在配置更改后仍然存在，因此它在第一次调用 `Activity#onCreate()` 时创建，在最后一次调用 `Activity#onDestroy()` 时销毁。

##### 组件作用域
> 注意：修改作用域字段需要删除 `build/generated/source/kapt` 下文件重新运行。

默认情况下，`Hilt` 中所有的实例都未设置限定作用域。也就是说，每次注入依赖时 `Hilt` 都会提供新的实例。如下：

```kotlin
class UserBean @Inject constructor()
```

```kotlin
@AndroidEntryPoint
class MainHiltActivity: AppCompatActivity() {

    @Inject
    lateinit var firstUserBean: UserBean
    @Inject
    lateinit var secondUserBean: UserBean

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_hilt)

        Log.e("hilt", firstUserBean.toString())
        Log.e("hilt", secondUserBean.toString())
    }
}
```

输出如下：
```
E/hilt: com.sample.hilt.UserBean@b01decb
E/hilt: com.sample.hilt.UserBean@dafe6a8
```

通过设置作用域注解，可以在相应 `Android` 类中共享同一实例。如下：
```kotlin
// 设置 UserBean 的作用域范围为 `Activity` 类
@ActivityScoped
class UserBean @Inject constructor()
```

输出如下：
```
E/hilt: com.sample.hilt.UserBean@b01decb
E/hilt: com.sample.hilt.UserBean@b01decb
```

> `@ActivityScoped`：上面的例子如果在另一个 `Activity` 页面中注入的实例对象就是另外新建的对象了。

> 注意：当 `Activity` 配置发生变化时，注入的对象会重建。可以通过配置 `android:configChanges` 防止。

`Hilt` 提供的作用域注解和对应 `Android` 类间关系如下：

| Android 类 | 生成的组件 | 作用域 |
| --- | --- | --- |
| Application | ApplicationComponent | @Singleton |
| View Model | ActivityRetainedComponent | @ActivityRetainedScope |
| Activity | ActivityComponent | @ActivityScoped |
| Fragment | FragmentComponent | @FragmentScoped |
| View | ViewComponent | @ViewScoped |
| 带有 @WithFragmentBindings 注释的 View | ViewWithFragmentComponent | @ViewScoped |
| Service | ServiceComponent | @ServiceScoped |

##### 组件层次结构
`@Module` 模块 某组件层次中提供的实例可作为其下任何子组件中的依赖项。如下：

```kotlin
class WaterBean

class CapBean (val waterBean: WaterBean)
```

```kotlin
@Module
@InstallIn(ActivityComponent::class)
object HiltActivityModule {

    @Provides
    fun provideWaterBean(): WaterBean {
        return WaterBean()
    }
}
```

```kotlin
@Module
@InstallIn(FragmentComponent::class)
object HiltFragmentModule {

    @Provides
    fun provideCapBean(waterBean: WaterBean): CapBean {
        return CapBean(waterBean)
    }
}
```

`Hilt` 中组件层次关系如下：
![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/hilt-hierarchy.jpg?versionId=CAEQFxiBgIDf5afdyBciIDBjM2U3NjYyY2M5NzQ4YzFiYzUxYThmOTQ1Y2Y3MmNk)

##### 组件默认绑定
每个 `Hilt` 组件都会默认绑定一组 `Android` 类。比如 `Activity` 组件会注入所有 `Activity` 类，每个 `Activity` 类都有 `Activity` 组件的不同实例。


#### 在 Hilt 不支持的类中注入依赖项
`Hilt` 所支持的 `Android` 类中并没有 `ContentProvider`。这是主要是因为 `ContentProvider` 的生命周期比较特殊，它在 `Application` 的 `onCreate()` 方法之前就能得到执行，而 `Hilt` 的工作原理是从 `Application` 的 `onCreate()` 方法中开始的，也就是说在这个方法执行之前，`Hilt` 的所有功能都还无法正常工作。

如果希望在 `ContentProvider` 中使用 `Hilt` 来获取某些依赖项，那需要在 `ContentProvider` 中为需要要依赖注入的类型定义一个带有 `@EntryPoint` 注解的接口，并通过 `@InstallIn` 注解声明其作用范围，如下：

```kotlin
class MyContentProvider : ContentProvider() {

    @EntryPoint
    @InstallIn(ApplicationComponent::class)
    interface ExampleContentProviderEntryPoint {
      fun getWaterBean(): WaterBean
    }
    ...
}
```

在接口中定义了获取实例的函数。

如果想要获取提供的实例，需要通过 `EntryPointAccessors` 获取，如下：

```kotlin
class MyContentProvider : ContentProvider() {

    ...
    override fun query(...): Cursor {
        context?.let {
            val entryPoint = EntryPointAccessors.fromApplication(it.applicationContext, MyEntryPoint::class.java)
            val waterBean = entryPoint.getWaterBean()
        }
        ...
    }
}
```

### 填坑记录

#### kotlin.UninitializedPropertyAccessException: lateinit property outSideBean has not been initialized

删除 `app` 模块下 `build/generated/source/kapt` 下的文件重新运行。

#### Hilt 使用编译速度提升
[哔哩哔哩在Hilt组件化的使用 | 技术探索](https://juejin.cn/post/6978407567047262222)
猜测大致意思是如果 `com.android.application` 中有一定代码量的话，而且使用了 `kotlin`，由于 `kapt` 代码生成机制，需要先将 `kotlin` 代码转换成 `java` 代码，之后才能生成 `ast` 语法树，才能生成 `hilt` 代码，所以这样耗时比较长。作者定义了一个空 `module` 来添加 `HiltApplication` 注解，以达到节省编译时间的目的。
