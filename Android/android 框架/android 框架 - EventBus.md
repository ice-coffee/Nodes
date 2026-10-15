[toc]
### 关联地址
[Android消息总线的演进之路：用LiveDataBus替代RxBus、EventBus](https://tech.meituan.com/2018/07/26/android-livedatabus.html)

[观察者模式 vs 发布订阅模式](https://zhuanlan.zhihu.com/p/51357583)

[秒懂设计模式之建造者模式](https://zhuanlan.zhihu.com/p/58093669)

[Android 面试题：EventBus 发送的消息，如何做到线程切换？](https://juejin.cn/post/6844903944561377293)

### 设计模式
`EventBus` 我们知道是基于 `发布-订阅` 模式实现的消息管理组件库。在维基百科中对于发布订阅模式的描述如下：

    在软件架构中，发布-订阅是一种消息范式，消息的发送者（称为发布者）不会将消息直接发送给特定的接收者（称为订阅者）。而是将发布的消息分为不同的类别，无需了解哪些订阅者（如果有的话）可能存在。同样的，订阅者可以表达对一个或多个类别的兴趣，只接收感兴趣的消息，无需了解哪些发布者（如果有的话）存在。

    发布/订阅是消息队列范式的兄弟，通常是更大的面向消息中间件系统的一部分。大多数消息系统在API中同时支持消息队列模型和发布/订阅模型，例如Java消息服务（JMS）。

一般认为发布订阅模式是观察者模式的变种。他们之间的区别我们来简单对比一下。

![image](https://img2018.cnblogs.com/blog/849589/201904/849589-20190424122505055-2083728728.png)

可以看到，观察者模式主要有两个角色：观察者和被观察者。而发布订阅模式有三个角色：订阅者、发布者和调度中心。因为调度中心的存在，订阅者和发布者之间是松耦合的，就像维基百科中的描述他们无需了解彼此是否存在。

除了发布订阅模式之外 `EventBus` 里还能看到作者使用了建造者模式（配置对象属性）和单例模式（获取对象实例）。关于这两个模式的详细用法和注意事项，大家可以自行搜索。

### 优化点
`EventBus` 中切换线程通知订阅者接收消息事件时做了一些小优化非常值得我们学习。

首先作者在切换线程通知订阅者时（1）都通过 `对象池` 和 `消息队列` 的方式优化内存。

在 `HandlerPoster` 中，（2）通过发送空 `Message` 也节省了内存。并且在 `handleMessage` 中使用循环调用处理消息（3），一次 `sendMessage()` 可以执行多个消息。并且由于是在主线程中执行在 (4) 中为避免长期占用主线程间隔一段时间重新 `sendMessage()`。
![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/eventbus_handlerposter.jpg)

在 `BackgroundPoster` 中 `EventBus` 使用线程池启动线程（2）,在 `run()` 方法中也通过循环调用在一个线程中重复处理事件，避免反复使用线程。
![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/eventbus_backgroundposter.jpg)

### 注解预处理

首先需要在 `build.gradle` 文件中配置：

`Kotlin`：
```
dependencies {
    implementation 'org.greenrobot:eventbus:3.2.0'
    kapt 'org.greenrobot:eventbus-annotation-processor:3.2.0'
}

kapt {
    arguments {
        arg('eventBusIndex', '包名.MyEventBusIndex')
    }
}
```

`Java`：
```
defaultConfig {
    javaCompileOptions {
        annotationProcessorOptions {
            arguments = [ eventBusIndex : '包名.MyEventBusIndex' ]
        }
    }
}

dependencies {
    implementation 'org.greenrobot:eventbus:3.2.0'
    annotationprocessor 'org.greenrobot:eventbus-annotation-processor:3.2.0'
}
```

重新编译之后会在 `build` 文件夹下生成 `MyEventBusIndex` 文件，文件名可以自己定义。


```
EventBus.builder().addIndex(MyEventBusIndex()).installDefaultEventBus()
```

### 优缺点
`EventBus` 的优缺点都很突出。优点是限制少可随意使用，缺点是限制太少使用太随意。
因为 `EventBus` 会导致开发者在架构设计上 `不思进取`，随着项目变复杂，结构越来越混乱，代码可读性变差，数据流的变化难以追踪。
所以，规模越大的项目 `EvenBus` 的负面效果越明显，因此很多大厂都禁止 `EventBus` 的使用。所以这道题千万不要把 `EventBus` 作为首选答案，比较得体的回答是：

`EventBus` 具备通信能力，但是缺点很突出，大量使用 `EventBus` 会造成项目难以维护、问题难以定位，所以我不建议在项目中使用 `EventBus` 进行通信。

### 替代方案

`RxJava`、`LiveDataBus`

推荐使用 `LiveDataBus`，利用 `LiveDataBus`，不仅可以实现消息总线功能，而且对于订阅者，他们不需要关心何时取消订阅，极大减少了因为忘记取消订阅造成的内存泄漏风险。
