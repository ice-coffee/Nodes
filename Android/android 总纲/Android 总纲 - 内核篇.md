P[toc]

### Binder
[Android跨进程通信：图文详解 Binder机制 原理](https://blog.csdn.net/carson_ho/article/details/73560642)
[为什么systemServer进程与zygote进程的通信是使用socket而不是binder？](https://blog.csdn.net/anhenzhufeng/article/details/106444099)
[为什么 Android 要采用 Binder 作为 IPC 机制](https://www.zhihu.com/question/39440766)
[https://cloud.tencent.com/developer/article/1780764](Android中怎么跨进程传输大图片)
[写给 Android 应用工程师的 Binder 原理剖析](https://zhuanlan.zhihu.com/p/35519585)

`IPC` 是指进程间通信，在 `Linux` 中进程空间分为 `用户空间和内核空间`，为保证安全性进程间用户空间不可互相访问，要做到跨进程通信只能通过内核空间，内核空间是所有进程共享的。

跨进程通信的方式：

- `共享内存`：速度最快，但需要考虑并发问题。
- `Socket`：性能低，需要两次拷贝，接收数据缓存大小不确定。
- `Binder`：性能较高，仅需要一次拷贝。
- `ContentProvider`：内部使用 `Binder` 实现。

传统的 `IPC` 做法是首先在内核空间中开辟一块内核缓存区，通过系统调用 `copy_from_user` 和 `copy_to_user` 完成两次 `copy` 操作，将数据传输到目标进程。

![image](https://pic1.zhimg.com/80/v2-aab2affe42958a659ea8a517ffaff5a0_1440w.jpg)

这种传统的 IPC 通信方式有两个问题：

- 性能低下，一次数据传递需要经历 2 次数据拷贝；
- 接收数据的缓存区由数据接收进程提供，但是接收进程并不知道需要多大的空间来存放将要传递过来的数据，因此只能开辟尽可能大的内存空间或者先调用 API 接收消息头来获取消息体的大小，这两种做法不是浪费空间就是浪费时间。

`Binder` 是一种在 `Android` 中实现跨进程通信（IPC）的方式。`Binder` 是通过 `mmap：内存映射` 实现的。`mmap` 可以在内核空间中创建一个数据接收缓存区，并映射到用户空间，这样发送进程只需要通过系统将数据拷贝进内核空间，由于映射关系的存在也就相当于发送到了接收进程的用户空间。

![](https://pic4.zhimg.com/80/v2-cbd7d2befbed12d4c8896f236df96dbf_1440w.jpg)

`Binder` 跨进程通信优点：

- 传输效率高，仅需要一次拷贝；
- 节省缓存区内存。

在 `Android` 中用到的跨进程通信方式还有 `Socket`，`SystemServer` 进程和 `Zygote` 进程就是通过 `Socket` 进行通信的。不使用 `Binder` 是因为 `Zygote` 和 `ServiceManager` 都是 `Linux` 的 `init` 进程启动的，而且 `Zygote` 先启动，所以没办法将 `Zygote` 注册到 `ServiceManager` 中也就不能使用 `Binder` 了。

`Socket` 和 `Binder` 的区别：

- Socket 需两次拷贝，Binder 仅需一次；
- Android 为每个进程都分配了UID，`Binder` 通过 C/S 架构，仅暴露用户端，这样服务端可以根据用户端UID判断是否安全。而 `Socket` 等传统方式无法获取进程的 UID/PID，无法判断其安全性。

手写 `Binder` 跨进程通信，`Android AIDL` 就是通过 `Binder` 实现的。具体步骤如下：

- `init`进程：init是所有linux程序的起点，是Zygote的父进程。解析init.rc孵化出Zygote进程。
- `Zygote`进程：Zygote是所有Java进程的父进程，所有的App进程都是由Zygote进程fork生成的。
- `SystemServer`进程：System Server是Zygote孵化的第一个进程。SystemServer负责启动和管理整个Java framework，包含AMS，PMS等服务。
- `Launcher`：Zygote进程孵化的第一个App进程是Launcher。

#### 为什么systemServer进程与zygote进程的通信是使用socket而不是binder？
首先，Binder通信需要使用Binder线程池。然后，Zygote 在fork进程之前，会把多余的线程（包括Binder线程）都杀掉只保留一个线程。所以此时就无法把结果通过Binder把消息发送给system_server。fork()进程完成之后Zygote也会把其他线程重新启动，这时候即使有了Binder线程，也无法重新建立连接。由于fork进程（Zygote）出来的进程A只有一个线程，如果Zygote有多个线程，那么A会丢失其他线程。这时可能造成死锁。

### Android 系统启动流程


### Activity 启动流程
[3分钟看懂Activity启动流程](https://juejin.cn/post/6844903474606374925)
[作为Android开发者 你真的知道app从启动到主页显示的过程吗？](https://zhuanlan.zhihu.com/p/72899995)

点击图标，`Launcher` 调用 `Instrumentation` 的 `startActivity` 方法。
`Instrumentation` 通过 `IBinder` 跨进程通知 `AMS` 启动应用。
`AMS` 判断应用是否已启动。h
若应用进程已存在，则跨过创建应用进程。
若未启动则 `AMS` 通过 `Socket` 跨进程通知 `Zygote` 新建应用进程。
`Zygote fork` 进程，并反射调用 `ActivityThread` 的 `main` 方法，`App` 启动是在 `ActivityThread.main()` 中开始：

```
public static void main(String[] args){
	//初始化Looper
	Looper.prepareMainLooper(); 
	    
	//实例化ActivityThread
	ActivityThread thread = new ActivityThread();

	//这个方法最后就是为了发送出创建Application的消息
	thread.attach(false);
	   
	//主线程进入无限循环状态，等待接收消息
	Looper.loop();   
}
```

`Thread.attach(false)` 方法通过 `Binder` 跨进程通信通知 `ActivityManagerService` 调用 `ActivityThread` 中的 `bindApplication()` 发送 `BIND_APPLICATION` 消息 `ActivityThread` 中的 `Handler` 收到消息后调用 `ActivityThread.handleBindApplication()` 方法.

在 `ActivityThread.handleBindApplication()` 方法中通过 `LoadedApk.makeApplication()` 方法最终调用 `Instrumentation.newApplication()` 创建 
`Application` 结束.

```
private void handleBindApplication(AppBindData data) {
    ...
    mInstrumentation = (Instrumentation)
        cl.loadClass(data.instrumentationName.getClassName())
        .newInstance();
    //通过反射初始化一个Instrumentation仪表。后面会介绍。
    ...
    Application app = data.info.makeApplication(data.restrictedBackupMode, null);
    //通过LoadedApp命令创建Application实例
    mInitialApplication = app;
    ...
    mInstrumentation.callApplicationOnCreate(app);
    //让仪器调用Application的onCreate()方法
    ...
}
```

当 `Application` 初始化完成后，系统会根据 `Manifest` 文件中配置的启动 `Activity` 发送 `Intent` 启动对应的 `Activity`。

这时会调用 `ActivityThread` 中的 `handleLaunchActivity() --> performLaunchActivity()` 方法。

```
private void handleLaunchActivity(...) {
	performLaunchActivity(...);
}
```

```
private Activity performLaunchActivity(...) {
    ...
    activity = mInstrumentation.newActivity(
      cl, component.getClassName(), r.intent);
    //通过仪表来创建Activity
    ...
    Application app = r.packageInfo.makeApplication(false
    , mInstrumentation);
    //前面说过，是在获取Application
    ...
    activity.attach(......);
    ...
    if (r.isPersistable()) {
     mInstrumentation.callActivityOnCreate(
       activity, r.state, r.persistentState);
    } else {
     mInstrumentation.callActivityOnCreate(activity, r.state);
    }
    //根据是否可持久化选择onCreate()方法。
    ...
}
```

备注:
- `LoadedApk` 对象是 `APK` 文件在内存中的表示。`Apk` 文件的相关信息，诸如 `Apk` 文件的代码和资源，甚至代码里面的 `Activity`，`Service` 等组件的信息我们都可以通过此对象获取。
- `onSaveInstanceState` 和 `onRestoreInstanceState` 方法是一对拯救灾难的方法，它们不在“正常“的 Activity生命周期中，
只有一些突发异常情况才会触发它们，比如横竖屏切换、按 Home 键等。当 `API 21` 后增加了 `PersistableBundle` 参数，令这些方法有了系统关机重启后数据恢复的能力。

- `ActivityThread`：App的真正入口。当开启App之后，会调用main()开始运行，开启消息循环队列，这就是传说中的UI线程或者叫主线程。与ActivityManagerServices配合，一起完成Activity的管理工作
- `ApplicationThread`：用来实现ActivityManagerService与ActivityThread之间的交互。在ActivityManagerService需要管理相关Application中的Activity的生命周期时，通过ApplicationThread的代理对象与ActivityThread通讯。
- `ApplicationThreadProxy`：是ApplicationThread在服务器端的代理，负责和客户端的ApplicationThread通讯。AMS就是通过该代理与ActivityThread进行通信的。
- `Instrumentation`：每一个应用程序只有一个Instrumentation对象，每个Activity内都有一个对该对象的引用。Instrumentation可以理解为应用进程的管家，ActivityThread要创建或暂停某个Activity时，都需要通过Instrumentation来进行具体的操作。
- `ActivityRecord`：用来记录对应Activity的各种信息的，如theme，启动模式、当前是否可见等等（为了排版更简洁，上图只列出来一个icicle），它里面还有很多管理Activity状态的相关方法；
- `TaskRecord`：任务栈（内部其实是 ArrayList），它的主要职责就是管理ActivityRecord。每当Activity启动时，会先找到合适的TaskRecord（或创建新实例），然后将该Activity所对应的ActivityRecord添加到TaskRecord的mActivities中；
- `ActivityStack`：管理TaskRecord，当新TaskRecord被创建后，会被添加到它mTaskHistory里面。
- `Launcher`：是第一个启动的程序。

### ActivityManangerService 的作用

-  管理四大组件的生命周期
-  管理应用进程

### WindowManangerService 的作用


### Handler 机制
`Handler 机制` 是 `Android` 中的消息处理机制，它是 `Android` 得以运行的动力源泉。`Handler` 机制由三部分组成：

- `Handler`：消息的发送者、处理者；
- `Message`：消息体；
- `Looper`：消息体搬运工。

`postDelayed` 是如何工作的，如何保证时间的。

### Activity 启动模式
`Android` 通过 `Task` 存储 `Activity`，不同的启动模式会影响 `Activity` 在 `Task` 中的存放。

`Android` 共有四种启动模式：

- standard
- singleTop
- singleTask
- singleInstance

选择不同的启动模式在启动 `Activity` 时会为 `Intent` 添加不同的 `Flag`，如：

- singleTop：FLAG_ACTIVITY_CLEAR_TOP
- singleTask：FLAG_ACTIVITY_CLEAR_TASK

在 `Manifest` 文件中可以设置 `android:taskAffinity` 属性以影响启动结果。

### MediaCodec
`MediaCodec` 是 `Android` 提供的媒体信息编解码器，它是硬编解码器，软编解码器的代表是著名的 `FFmpeg`。`MediaCodec` 架构采用了输入、输出两个缓冲区队列，异步处理编解码数据。一边开发者获取空的可用输入缓冲区，填充需要编码或解码的数据，将其发送给编解码器，由其进行编码或解码数据并将输入缓冲区数据清空，另一边，开发者请求输出缓冲区中已解码或编码后的数据并释放输出缓冲区。可以看到一些开源项目中经常使用两个 while（1）循环来进行上述操作。



### Context
[你真的懂 Context 吗](https://cloud.tencent.com/developer/article/1628570)

### 布局是怎么加载到屏幕上的
