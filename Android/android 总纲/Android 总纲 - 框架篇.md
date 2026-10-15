¸[toc]

### Android EventBus
设计模式：单例模式、Builder\建造者模式、订阅发布模式。
数据结构：`ArrayList` 消息队列。
相关优化：对象池优化内存；线程池优化线程开启；`HandlerPoster` 中一次消息重复处理事件并防止长期占用主线程；`BackgroundPoster` 在一个线程中重复处理事件避免反复使用线程。

`ASYNC` 和 `BACKGROUND` 的区别：
通过分析 `AsyncPoster` 和 `BackgroundPoster` 可知 `BACKGROUND` 是在某个线程中循环处理消息队列中的事件，事件的处理时间会受到之前事件的影响。`ASYNC` 是为每个事件都开辟一个新的线程处理，线程过多会影响性能和内存甚至 OOM。

观察者模式和发布订阅模式的区别。
发布订阅模式也属于观察者模式，区别在于发布订阅模式中有三个角色：发布者、订阅者、调度者，而观察者模式中只有两个角色：观察者、被观察者。发布订阅模式优于观察者模式的地方在于发布者和订阅者之间完全不存在耦合关系，并且在调度者中可以加入线程调度，优先级控制等操作。

`EventBus` 的优缺点。
优点：完全解耦。
缺点：包体积增大、需要定义大量事件类、反射调用处理事件影响性能。并且 `EventBus` 的滥用会导致项目结构混乱，代码可读性变差，数据流的变化难以追踪。

LiveDataBus、RxBus、EventBus 对比。
- LiveDataBus 依赖于 `LiveData` 对于包大小的影响最小。
- LiveDataBus 只能在主线程中处理事件。
- LiveDataBus 杜绝了不小心产生的内存泄漏。

### Hilt VS Dagger

### LeakCanary 
通过监听Activity的onDestory，手动调用GC，然后通过ReferenceQueue+WeakReference，来判断Activity对象是否被回收，然后结合dump Heap的hpof文件，通过Haha开源库分析泄露的位置

### BlockCanary
`BlockCanary` 通过设置自定义 `Painter`，监控主线程 `dispatchMessage()` 对卡顿进行判定。

### 热修复

### JNI怎么使用

### 设计一个图片缓存加载机制

### Asynctask具体用法？
### Asynctask的Do in background方法是怎么通知UI线程刷新进度条的？
### Asynctask的Do in background方法默认是返回 true ，表示任务完成，如果想返回具体的数据呢，怎么做。如果Activity被销毁了，还会执行到postexcutd方法吗？

### MVC、MVP、MVVM
### JVM 和Dalvik虚拟机的区别
### 应用常驻后台，避免被第三方杀掉的方法，讲讲你用过的奇淫巧技？
### 数据持久化的四种方式有哪些？
### 65K限制
[原文链接](http://www.infoq.com/cn/news/2014/11/android-multidex)
> 近日，Android Developers在Google+上宣布了新的Multidex支持库，为方法总数超过65K的Android应用提供了官方支持。

如果你是一名幸运的Android应用开发者，正在开发一个前景广阔的应用，不断地加入新功能、添加新的类库，那么终有一天，你会不幸遇到这个错误：

```
Conversion to Dalvik format failed: Unable to execute dex: method ID not in [0, 0xffff]: 65536
```

这个错误是Android应用的方法总数限制造成的。Android平台的Java虚拟机Dalvik在执行DEX格式的Java应用程序时，使用原生类型short来索引DEX文件中的方法。这意味着单个DEX文件可被引用的方法总数被限制为65536。通常APK包含一个classes.dex文件，因此Android应用的方法总数不能超过这个数量，这包括Android框架、类库和你自己开发的代码。

这个问题可以通过将一个DEX文件分拆成多个DEX文件解决。Facebook介绍了为Android应用开发的Dalvik补丁；Android Developers博客介绍了通过自定义类加载过程的方法来解决此问题。但这些方法有些复杂而且并不优雅。

随着[新的MultiDex支持库发布](http://developer.android.com/tools/support-library/features.html#multidex)，Google正式为解决此问题提供官方支持。[构建超过65K方法数的应用](http://developer.android.com/tools/building/multidex.html)介绍了如何使用Gradle构建多DEX应用。

首先使用Android SDK Manager升级到最新的Android SDK Build Tools和Android Support Library R21。然后进行以下两步操作：

1. 修改Gradle配置文件，启用MultiDex并包含MultiDex支持：

```
android { 
	compileSdkVersion 21 buildToolsVersion "21.1.0"
	
	defaultConfig {
	    ...
	    minSdkVersion 14
	    targetSdkVersion 21
	    ...
	
	    // Enabling multidex support.
	    multiDexEnabled true
	}
	...
}

dependencies { compile 'com.android.support:multidex:1.0.0' } 
```

2. 让应用支持多DEX文件。在[MultiDexApplication JavaDoc](http://developer.android.com/reference/android/support/multidex/MultiDexApplication.html)中描述了三种可选方法：

- 在AndroidManifest.xml的application中声明android.support.multidex.MultiDexApplication；
- 如果你已经有自己的Application类，让其继承MultiDexApplication；
- 如果你的Application类已经继承自其它类，你不想/能修改它，那么可以重写attachBaseContext()方法：

```
	@Override 
	protected void attachBaseContext(Context base) {
	    super.attachBaseContext(base); MultiDex.install(this);
	}
```

经过以上步骤，你的应用已经可以实现多个DEX文件了。当应用构建时，构建工具会分析哪些类必须放在第一个DEX文件，哪些类可以放在附加的DEX文件中。当它创建了第一个DEX文件（classes.dex）后，如果有必要会继续创建附加的DEX文件，如classes2.dex, classes3.dex。Multidex的支持类库将被包含在应用的第一个DEX文件中，帮助实现对其它DEX文件的访问。

文中还介绍了在开发多DEX应用时，通过设置productFlavors提高开发效率以及多DEX应用的测试方法。

Android 5.0和更高版本使用名为ART的运行时，它原生支持从APK文件加载多个DEX文件。在应用安装时，它会执行预编译，扫描classes(..N).dex文件然后将其编译成单个.oat文件用于执行。[了解更多关于ART的信息](https://source.android.com/devices/tech/dalvik/art.html).

虽然Google解决了应用总方法数限制的问题，但并不意味着开发者可以任意扩大项目规模。Multidex仍有一些限制：

- DEX文件安装到设备的过程非常复杂，如果第二个DEX文件太大，可能导致应用无响应。此时应该使用ProGuard减小DEX文件的大小。
- 由于Dalvik linearAlloc的Bug，应用可能无法在Android 4.0之前的版本启动，如果你的应用要支持这些版本就要多执行测试。
- 同样因为Dalvik linearAlloc的限制，如果请求大量内存可能导致崩溃。Dalvik linearAlloc是一个固定大小的缓冲区。在应用的安装过程中，系统会运行一个名为dexopt的程序为该应用在当前机型中运行做准备。dexopt使用LinearAlloc来存储应用的方法信息。Android 2.2和2.3的缓冲区只有5MB，Android 4.x提高到了8MB或16MB。当方法数量过多导致超出缓冲区大小时，会造成dexopt崩溃。
- Multidex构建工具还不支持指定哪些类必须包含在首个DEX文件中，因此可能会导致某些类库（例如某个类库需要从原生代码访问Java代码）无法使用。
避免应用过大、方法过多仍然是Android开发者要注意的问题。Mihai Parparita的开源项目[dex-method-counts](https://github.com/mihaip/dex-method-counts)可以用于统计APK中每个包的方法数量。

通常开发者自己的代码很难达到这样的方法数量限制，但随着第三方类库的加入，方法数就会迅速膨胀。因此选择合适的类库对Android开发者来说尤为重要。

开发者应该避免使用Google Guava这样的类库，它包含了13000多个方法。尽量使用专为移动应用设计的Lite/Android版本类库，或者使用小类库替换大类库，例如用Google-gson替换Jackson JSON。而对于Google Protocol Buffers这样的数据交换格式，其标准实现会自动生成大量的方法。采用Square Wire的实现则可以很好地解决此问题。

### Dalvik虚拟机系列问题
1. 什么是Dalvik虚拟机？
Dalvik虚拟机是Android平台的核心。它可以支持.dex格式的程序的运行，.dex格式是专为Dalvik设计的一种压缩格式，可以减少整体文件尺寸，提高I/O操作的速度，适合内存和处理器速度有限的系统。

2. Dalvik虚拟机的作用是什么？
Dalvik虚拟机主要是完成对象生命周期管理，内存回收，堆栈管理，线程管理，安全和异常管理等等重要功能。

3. Dalvik虚拟机与JVM有什么区别
- Dalvik 基于寄存器，而 JVM 基于栈。基于寄存器的虚拟机对于更大的程序来说，在它们编译的时候，花费的时间更短。
- Dalvik执行.dex格式的字节码，而JVM执行.class格式的字节码。

4. 每个应用程序对应多少个Dalvik虚拟机
- 每一个Android应用在底层都会对应一个独立的Dalvik虚拟机实例，其代码在虚拟机的解释下得以执行 ，而所有的Android应用的线程都对应一个Linux线程

### Android Handler 使用以及源码分析
- handler 的组成
- MessageQueue的数据结构
- Message.obtain()

### Android SharedPreference 使用以及源码分析
- SharedPreferences初始化时需要从磁盘中加载数据到内存，这个过程是会堵塞主线程的
- get操作是从内存中取数据的，性能高
- commit操作是同步的有返回值、apply操作是异步的无返回值

### Android SQLite 使用、升级、多线程使用优化
- 继承SqLiteOpenHelper，重写onCreate、onUpgrade
- getReadableDatabase()、getWriteableDatabase()的区别
- 数据库升级

### Android Binder

### Android Lifecycle、LiveData、ViewModel

### Glide
[Android图片加载框架最全解析 - Glide](https://blog.csdn.net/guolin_blog/article/details/53759439)
1. Glide 内存缓存

Glide的内存缓存方式为lrucache + 弱引用的方式，正在使用的图片会获取它的弱引用放到map集合中

2. Glide 硬盘缓存

Glide的硬盘缓存使用DiskLrucache

3. 图片转换

实现Transformation接口，在transform函数中实现转换逻辑，如原型图片canvas.drawCircle
