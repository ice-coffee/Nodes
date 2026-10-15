### 参考链接
[在Android应用中使用Dagger](https://developer.android.com/training/dependency-injection/dagger-android#dagger-subcomponents)

[Dagger2 注解](https://juejin.im/post/5c7f8eb3e51d4525c54d4df1)

[自定义Scope（翻译）](https://www.cnblogs.com/tiantianbyconan/p/5095426.html)

### 疑问
1、在[GithubClient](https://github.com/frogermcs/GithubClient)中使用子组件的方式和Google官方文档中不同。

### 介绍

什么是依赖注入：
类通常需要引用其他的类才能正常运行，被引用的类成为依赖项，类可以通过三种方式获得需引用的对象：
1. 类自身构造所需的依赖项。
2. 从其他类抓取。
3. 以参数形式提供。

第三种方式就是依赖注入。

依赖注入的优势：
- 重用代码
- 易于重构
- 易于测试

Android中的依赖注入方式主要有两种：
1. 构造函数注入。
2. 字段注入（或setter注入）。某些 Android 框架类（如 Activity 和 Fragment）由系统实例化，因此无法进行构造函数注入。

自动依赖注入归为两类：
- 基于反射的解决方案，可在运行时连接依赖项。
- 静态解决方案，可生成在编译时连接依赖项的代码。

Dagger 是适用于 Java、Kotlin 和 Android 的热门依赖项注入库，由 Google 进行维护。Dagger 为您创建和管理依赖关系图，从而便于您在应用中使用 DI。它提供了完全静态和编译时依赖项，解决了基于反射的解决方案（如 Guice）的诸多开发和性能问题。

Hilt 是推荐用于在 Android 中实现依赖项注入的 Jetpack 库。Hilt 通过为项目中的每个 Android 类提供容器并自动为您管理其生命周期，定义了一种在应用中执行 DI 的标准方法。如需详细了解Hilt，请参阅[使用 Hilt 实现依赖项注入](https://developer.android.com/training/dependency-injection/hilt-android)。

### 使用

添加依赖项

```
apply plugin: 'kotlin-kapt'

dependencies {
    implementation 'com.google.dagger:dagger:2.x'
    kapt 'com.google.dagger:dagger-compiler:2.x'
}
```

创建Component（组件）

```
// Definition of the Application graph
@Component
interface ApplicationComponent { ... }
```
组件存放到应用类中使其生命周期与应用一致。

```
// appComponent lives in the Application class to share its lifecycle
class MyApplication: Application() {
    // Reference to the application graph that is used across the whole app
    val appComponent = DaggerApplicationComponent.create()
}
```
注入Activity中。

```
@Component
interface ApplicationComponent {
    // This tells Dagger that LoginActivity requests injection so the graph needs to
    // satisfy all the dependencies of the fields that LoginActivity is requesting.
    fun inject(activity: LoginActivity)
}

class LoginActivity: Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Make Dagger instantiate @Inject fields in LoginActivity
        (applicationContext as MyApplication).appComponent.inject(this)
        // Now loginViewModel is available

        super.onCreate(savedInstanceState)
    }
}
```

通过Dagger提供需要注入的字段。

```
// @Inject tells Dagger how to create instances of LoginViewModel
class LoginViewModel @Inject constructor(
    private val userRepository: UserRepository
) { ... }

class LoginActivity: Activity() {
    // You want Dagger to provide an instance of LoginViewModel from the graph
    @Inject lateinit var loginViewModel: LoginViewModel

    ...
}
```
除了 @Inject 注释之外，还有一种方法可告知 Dagger 如何提供类实例，即使用 Dagger 模块中的信息。

```
// @Module informs Dagger that this class is a Dagger Module
@Module
class NetworkModule {

    // @Provides tell Dagger how to create instances of the type that this function
    // returns (i.e. LoginRetrofitService).
    // Function parameters are the dependencies of this type.
    @Provides
    fun provideLoginRetrofitService(): LoginRetrofitService {
        // Whenever Dagger needs to provide an instance of type LoginRetrofitService,
        // this code (the one inside the @Provides method) is run.
        return Retrofit.Builder()
                .baseUrl("https://example.com")
                .build()
                .create(LoginService::class.java)
    }
}
```
为了使 Dagger 图了解此模块，您必须将其添加到 @Component 接口。
```
// The "modules" attribute in the @Component annotation tells Dagger what Modules
// to include when building the graph
@Component(modules = [NetworkModule::class])
interface ApplicationComponent {
    ...
}
```

使用@Inject 或 @Module + @Providers 都可以告诉Dagger如何提供类实例。

### 子组件（@Subcomponent）
子组件是继承并扩展父组件的对象图的组件。因此，父组件中提供的所有对象也将在子组件中提供。这样，子组件中的对象就可以依赖于父组件提供的对象。提供对父组件中对象生命周期更精细的控制。

声明子组件

```
// @Subcomponent annotation informs Dagger this interface is a Dagger Subcomponent
@Subcomponent
interface LoginComponent {

    // This tells Dagger that LoginActivity requests injection from LoginComponent
    // so that this subcomponent graph needs to satisfy all the dependencies of the
    // fields that LoginActivity is injecting
    fun inject(loginActivity: LoginActivity)
}
```
您还必须在 LoginComponent 内定义子组件 factory，以便 ApplicationComponent 知道如何创建 LoginComponent 的实例。

```
@Subcomponent
interface LoginComponent {

    // Factory that is used to create instances of this subcomponent
    @Subcomponent.Factory
    interface Factory {
        fun create(): LoginComponent
    }

    fun inject(loginActivity: LoginActivity)
}
```
如需告知 Dagger LoginComponent 是 ApplicationComponent 的子组件，您必须通过以下方式予以指明：

1. 创建新的 Dagger 模块（例如 SubcomponentsModule），并将子组件的类传递给注释的 subcomponents 属性。

```
// The "subcomponents" attribute in the @Module annotation tells Dagger what
// Subcomponents are children of the Component this module is included in.
@Module(subcomponents = LoginComponent::class)
class SubcomponentsModule {}
```
2. 将新模块（即 SubcomponentsModule）添加到 ApplicationComponent：

```
// Including SubcomponentsModule, tell ApplicationComponent that
// LoginComponent is its subcomponent.
@Singleton
@Component(modules = [NetworkModule::class, SubcomponentsModule::class])
interface ApplicationComponent {
}
```

3. 提供在接口中创建 LoginComponent 实例的 factory：

```
@Singleton
@Component(modules = [NetworkModule::class, SubcomponentsModule::class])
interface ApplicationComponent {
// This function exposes the LoginComponent Factory out of the graph so consumers
// can use it to obtain new instances of LoginComponent
fun loginComponent(): LoginComponent.Factory
}
```

### 自定义生命周期

作用域限定规则如下：
- 如果某个类型标记有作用域注释，该类型就只能由带有相同作用域注释的组件使用。
- 如果某个组件标记有作用域注释，该组件就只能提供带有该注释的类型或不带注释的类型。
- 子组件不能使用其某一父组件使用的作用域注释。

```
// Definition of a custom scope called ActivityScope
@Scope
@Retention(value = AnnotationRetention.RUNTIME)
annotation class ActivityScope

// Classes annotated with @ActivityScope are scoped to the graph and the same
// instance of that type is provided every time the type is requested.
@ActivityScope
@Subcomponent
interface LoginComponent { ... }

// A unique instance of LoginViewModel is provided in Components
// annotated with @ActivityScope
@ActivityScope
class LoginViewModel @Inject constructor(
    private val userRepository: UserRepository
) { ... }
```

### 注解

常用注解

#### @Inject

@Inject注解可修饰字段和类构造函数。告诉Dagger需要字段注入或构造函数注入。

#### @Component
@Component注解修饰接口会让 Dagger 生成一个容器，其中应包含满足其提供的类型所需的所有依赖项。这成为Dagger组件，它是连接@Inject和@Module的桥梁。

#### @Module

Modules类里面的方法专门提供依赖，所以我们定义一个类，用@Module注解，这样Dagger在构造类的实例的时候，就知道从哪里去找到需要的依赖。modules的一个重要特征是它们设计为分区并组合在一起（比如说，在我们的app中可以有多个组成在一起的modules）。

#### @Provides

在modules中，我们定义的方法是用这个注解，以此来告诉Dagger我们想要构造对象并提供这些依赖。所有的Provides方法必须属于Module。将类型添加到 Dagger 图，建议的方法是使用@Inject构造函数注入。

#### @Scope

注解作用域，通过自定义注解限定对象的作用范围，(如@PerActivity自定义注解，限定对象的存活时间和Activity一致)。

#### @Singleton

单例，使用@Singleton注解之后，对象只会被初始化一次，之后的每次都会被直接注入相同的对，@Singleton 就是一个内置的作用域。

### kotlin 上使用Dagger 遇到的坑

#### Unresolved reference

错误代码：
build.gradle:

```
apply plugin: 'kotlin-android'

dependencies {
    implementation 'com.google.dagger:dagger:2.28.3'
    annotationProcessor 'com.google.dagger:dagger-compiler:2.28.3'
}
```

error log：

```
: /Users/admin/Desktop/xxx/MyApplication.kt: (13, 28): Unresolved reference: DaggerApplicationComponent
```

解决方案：

```
apply plugin: 'kotlin-android'
apply plugin: 'kotlin-kapt'

dependencies {
    implementation 'com.google.dagger:dagger:2.28.3'
    kapt 'com.google.dagger:dagger-compiler:2.28.3'
}
```

#### Dagger does not support injection into private fields

error desc:
```
Dagger does not support injection into private fields
```

解决方案：
Kotlin 生成.java文件时属性默认为 private，给属性添加@JvmField声明转成 public就行了。

### 注意
1. 注入字段不能为私有字段。
2. 使用 Activity 时，应在调用 super.onCreate() 之前在 Activity 的 onCreate() 方法中注入 Dagger，以避免出现 Fragment 恢复问题。
3. 使用 Fragment 时，应在 Fragment 的 onAttach() 方法中注入 Dagger。在这种情况下，此操作可以在调用 super.onAttach() 之前或之后完成。

### 体验记录

1. Dagger中作用域的使用方式是通过注解Component(组件)产生作用，换句话说当注解的组件实例未销毁时组件中所引用的其他实例也不会销毁。以下文章中剖析了 @Singleton 注解的源码实现：
[[Android]使用Dagger 2依赖注入 - 自定义Scope（翻译）
](https://www.cnblogs.com/tiantianbyconan/p/5095426.html)
2. 子组件要通过父组件实例创建
3. 自定义生命周期配合@Provides注解标示所提供对象实例的生命周期与Component组件的生命周期一致
4. 关于Dagger解耦的概念的理解（有待验证）：module中通过@Provides注解提供可被其他类（Activity、Fragment、MVP等其他类）用到的实例对象，这样就不用在使用时手动注入各种实例对象了，再加上生命周期的概念控制@Provides提供实例对象的生命周期，通过以上操作以达到解耦的目的。
5. Module 和 Component 之间的关系
