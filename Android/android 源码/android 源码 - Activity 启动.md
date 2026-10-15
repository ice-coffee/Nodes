### Activity 启动过程

[Activity启动过程全解析](https://blog.csdn.net/zhaokaiqiang1992/article/details/49428287)
[探索7.x, 全面解析Activity启动框架](https://www.jianshu.com/p/269e3dc06b09)
[Android Framework之Activity启动流程](https://pomelojiang.github.io/android_framework_start_activity_1#ActivityStarter)：源码分析

#### ActivityManagerServices
简称AMS，服务端对象，负责系统中所有Activity的生命周期
#### ActivityThread
App的真正入口。当开启App之后，会调用main()开始运行，开启消息循环队列，这就是传说中的UI线程或者叫主线程。与ActivityManagerServices配合，一起完成Activity的管理工作
#### ApplicationThread
用来实现ActivityManagerService与ActivityThread之间的交互。在ActivityManagerService需要管理相关Application中的Activity的生命周期时，通过ApplicationThread的代理对象与ActivityThread通讯。
#### ApplicationThreadProxy
是ApplicationThread在服务器端的代理，负责和客户端的ApplicationThread通讯。AMS就是通过该代理与ActivityThread进行通信的。
#### Instrumentation
每一个应用程序只有一个Instrumentation对象，每个Activity内都有一个对该对象的引用。Instrumentation可以理解为应用进程的管家，ActivityThread要创建或暂停某个Activity时，都需要通过Instrumentation来进行具体的操作。
#### ActivityStack
Activity在AMS的栈管理，用来记录已经启动的Activity的先后关系，状态信息等。通过ActivityStack决定是否需要启动新的进程。
#### ActivityRecord
ActivityStack的管理对象，每个Activity在AMS对应一个ActivityRecord，来记录Activity的状态以及其他的管理信息。其实就是服务器端的Activity对象的映像。
#### TaskRecord
AMS抽象出来的一个“任务”的概念，是记录ActivityRecord的栈，一个“Task”包含若干个ActivityRecord。AMS用TaskRecord确保Activity启动和退出的顺序。如果你清楚Activity的4种launchMode，那么对这个概念应该不陌生。

应用启动流程：
Activity 启动流程
[ActivityManagerService架构剖析开篇](https://www.jianshu.com/p/17b2844b2a27)
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/activity_launch_sx.jpg)

[3分钟看懂Activity启动流程](https://www.jianshu.com/p/9ecea420eb52)
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/activity_launch_sx_1.jpg)

[WindowManagerService Window View 关系](https://www.jianshu.com/p/52c8665f068f)

[详解Window、Activity、DecorView以及ViewRoot之间的错综关系](https://zhuanlan.zhihu.com/p/69830632)

### 布局文件解析
布局文件解析在setContent()调用，最终会调用到PhoneWindow的setContent()，通过LayoutInflater解析布局文件，或者直接添加到ContentParent中

### Activity 启动优化
[StartingWindow流程分析](https://www.jianshu.com/p/9740ab570df7)
[AndroidAPP启动速度优化；冷启动和热启动解析](https://www.jianshu.com/p/f29740834979)
[Android开发之Theme、Style探索及源码浅析](https://www.cnblogs.com/chenxibobo/p/6136681.html)

### Activity 页面刷新机制

[面试官又来了：你的app卡顿过吗？](https://juejin.im/post/5d837cd1e51d4561cb5ddf66)


看到一个报错，可以很清晰的看到应用启动和类加载的流程，看流程用报错的方式也是不错。
```
 Caused by: java.lang.ClassNotFoundException: Didn't find class "com.example.android.camera2basic.CameraTestActivity" on path: DexPathList[[zip file "/data/app/com.example.android.camera2basic-qqdJgC294vIaQ4A0nayTvQ==/base.apk", zip file "/system/framework/org.apache.http.legacy.jar"],nativeLibraryDirectories=[/data/app/com.example.android.camera2basic-qqdJgC294vIaQ4A0nayTvQ==/lib/arm64, /system/lib64, /system/product/lib64]]
        at dalvik.system.BaseDexClassLoader.findClass(BaseDexClassLoader.java:196)
        at java.lang.ClassLoader.loadClass(ClassLoader.java:379)
        at java.lang.ClassLoader.loadClass(ClassLoader.java:312)
        at android.app.AppComponentFactory.instantiateActivity(AppComponentFactory.java:95)
        at android.app.Instrumentation.newActivity(Instrumentation.java:1297)
        at android.app.ActivityThread.performLaunchActivity(ActivityThread.java:3413)
        at android.app.ActivityThread.handleLaunchActivity(ActivityThread.java:3640) 
        at android.app.servertransaction.LaunchActivityItem.execute(LaunchActivityItem.java:83) 
        at android.app.servertransaction.TransactionExecutor.executeCallbacks(TransactionExecutor.java:135) 
        at android.app.servertransaction.TransactionExecutor.execute(TransactionExecutor.java:95) 
        at android.app.ActivityThread$H.handleMessage(ActivityThread.java:2222) 
        at android.os.Handler.dispatchMessage(Handler.java:107) 
        at android.os.Looper.loop(Looper.java:230) 
        at android.app.ActivityThread.main(ActivityThread.java:7738) 
        at java.lang.reflect.Method.invoke(Native Method) 
        at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:508) 
        at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1034) 
```
