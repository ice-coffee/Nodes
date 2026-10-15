[toc]

### 推荐阅读
[Jetpack新成员，App Startup一篇就懂](https://blog.csdn.net/guolin_blog/article/details/108026357)

[我为何弃用Jetpack的App Startup?](https://segmentfault.com/a/1190000023512681)

[面试官：今日头条启动很快，你觉得可能是做了哪些优化？](https://zhuanlan.zhihu.com/p/85612027)

### App Startup 是什么
`App Startup` 提供了一种高效的在应用启动时初始化组件的方式，还可以用它来制定组件初始化的顺序。

在开始之前先来看下面的代码有没有跟你项目中的很相似。

```java
class SampleApplication : BaseApplication() {

    override fun onCreate() {
        super.onCreate()
        initAA()
        initBB()
        initCC()
        initDD()
        ...
    }
}
```

为了可以使用到 `Context`，在 `Application` 中初始化组件是我们想到的基本操作。但是在初始化大量组件时 `Application` 就势必会显得凌乱。这种情况下有些组件开发者就想到用 `ContentProvider` 来隐式进行组件的初始化操作。

这样做的好处就是既可以在 `ContentProvider` 得到初始化组件库需要的 `Context`，还避免了 `Application` 中显示初始化而造成的的代码混乱。

这本来是个很聪明的操作，但是 `ContentProvider` 作为四大组件之一，其本身就是个重量级的组件，如果每个组件库都声明了各自的 `ContentProvider` 以在应用启动时进行初始化那反而会影响到 `App` 的启动速度。

![image](https://img-blog.csdnimg.cn/20200815182404587.png)

上图来自于 `郭霖` 的博客，源地址在 [Android官方视频教程](https://www.youtube.com/watch?v=R3caBPj-6Sg) 里。这张图显示了多个 `Empty ContentProvider` 的耗时测试。

`App Startup` 解决了这个问题，它提供了一个公共的 `ContentProvider` 供大家使用，以减少 `ContentProvider` 初始化数量的方式提高应用的启动速度。

从这里可以看到 `App Startup` 其实只是一种给组件库开发者制定的一种规则。如果组件库开发者都遵守这个规则，那么 `App` 的启动速度是会有一定程度的提升。`App Startup` 库对于 `App` 开发者显然没有什么太大作用。

### 作用

- 提供统一 `ContentProvider`
- 制定组件库初始化顺序

### 用法

首先声明依赖：

```gradle
dependencies {
    implementation "androidx.startup:startup-runtime:1.0.0"
}
```

然后需要定义一个实现 `Initializer<T>` 接口的类，如下：

```kotlin
// Initializes WorkManager.
class WorkManagerInitializer : Initializer<WorkManager> {
    override fun create(context: Context): WorkManager {
        val configuration = Configuration.Builder().build()
        WorkManager.initialize(context, configuration)
        return WorkManager.getInstance(context)
    }
    override fun dependencies(): List<Class<out Initializer<*>>> {
        // No dependencies on other libraries.
        return emptyList()
    }
}
```

`Initializer<T>` 接口中声明了两个方法：

```java
public interface Initializer<T> {

    /**
     * 在这里初始化组件
     */
    @NonNull
    T create(@NonNull Context context);

    /**
     * 此方法返回 create 中初始化组件所依赖的其他 Initializer 对象的列表.
     * 可以通过此方法控制 App 启动时组件初始化的顺序
     */
    @NonNull
    List<Class<? extends Initializer<?>>> dependencies();
}
```

比如再定义一个依赖于 `WorkManagerInitializer` 的 `ExampleLoggerInitializer` 类。如下：

```kotlin
class ExampleLoggerInitializer : Initializer<ExampleLogger> {
    override fun create(context: Context): ExampleLogger {
        // WorkManager.getInstance() is non-null only after
        // WorkManager is initialized.
        return ExampleLogger(WorkManager.getInstance(context))
    }

    override fun dependencies(): List<Class<out Initializer<*>>> {
        // Defines a dependency on WorkManagerInitializer so it can be
        // initialized after WorkManager is initialized.
        return listOf(WorkManagerInitializer::class.java)
    }
}
```

最后需要在 `AndroidManifest.xml` 中配置：

```xml
<provider
    android:name="androidx.startup.InitializationProvider"
    android:authorities="${applicationId}.androidx-startup"
    android:exported="false"
    tools:node="merge">
    <!-- This entry makes ExampleLoggerInitializer discoverable. -->
    <meta-data  android:name="com.example.ExampleLoggerInitializer"
          android:value="androidx.startup" />
</provider>
```

自定义 `Initializer` 配置有两种方式：

- 添加 `meta-data` 标签
- 在其他 `Initializer` 的 `dependencies()` 中返回

到这里其实已经结束了。下面介绍一个延迟初始化的操作。

```xml
<meta-data  android:name="com.example.ExampleLoggerInitializer"
    android:value="androidx.startup"
    tools:node="remove"/>
```

在 `meta-data` 添加 `tools:node="remove"` 可以在应用启动时不自动初始化，在需要的地方进行手动初始化：

```java
AppInitializer.getInstance(context).initializeComponent(ExampleLoggerInitializer::class.java)
```

这里 `App Startup` 的用法就这些了。

### 思考
有一个问题和大家分享下：

> 同为四大组件，为什么要使用 `ContentProvider` 来作为初始化组件库的入口。
> 答：这是因为 `ContentProvider` 的生命周期比较特殊，它在 `Application` 的 `onCreate()` 方法之前就能得到执行。
