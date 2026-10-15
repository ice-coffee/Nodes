```

```
[toc]

### 参考链接
[Android中Activity四种启动模式和taskAffinity属性详解](http://blog.csdn.net/zhangjg_blog/article/details/10923643)

### Activity的生命周期图示

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_basic_activity.png)

#### Activity生命周期中的四种状态
1. 在屏幕的前台（Activity活动栈栈顶），叫做活动状态或者运行状态（active or running）

2. 如果一个Activity失去焦点，但是依然可见（一个新的非全屏的Activity 或者一个透明的Activity 被放置在栈顶），叫做暂停状态（Paused）。一个暂停状态的Activity依然保持活力（保持所有的状态，成员信息，和窗口管理器保持连接），但是在系统内存极端低下的时候将被杀掉。

3. 如果一个Activity被另外的Activity完全覆盖掉，叫做停止状态（Stopped）。它依然保持所有状态和成员信息，但是它不再可见，所以它的窗口被隐藏，当系统内存需要被用在其他地方的时候，Stopped的Activity将被杀掉。

4. 如果一个Activity是Paused或者Stopped状态，系统可以将该Activity从内存中删除，Android系统采用两种方式进行删除，要么要求该Activity结束，要么直接杀掉它的进程。当该Activity再次显示给用户时，它必须重新开始和重置前面的状态。

#### Activity切换时的方法调用顺序
> Activity1 --> startActivity() --> Activity2 --> startActivity() --> Activity1

```
onCreate::main
onStart::main
onResume::main

onPause::main
onCreate::other
onStart::other
onResume::other
onStop::main

onPause::other
onCreate::main
onStart::main
onResume::main
onStop::other
```

> Activity1 --> startActivity() --> Activity2 --> back --> Activity1

```
onCreate::main
onStart::main
onResume::main

onPause::main
onCreate::other
onStart::other
onResume::other
onStop::main

onPause::other
onRestart::main
onStart::main
onResume::main
onStop::other
onDestroy::other
```

### 使用intent传递对象
Android中Intent传递类对象提供了两种方式
- 实现Serializable接口传递对象
- 实现Parcelable接口传递对象。

Intent中传递这2种对象的方法：
```
Bundle.putSerializable(Key,Object);  //实现Serializable接口的对象

Bundle.putParcelable(Key, Object); //实现Parcelable接口的对象
```
[Serializable与Parcelable的区别](https://juejin.im/post/5a24fd8151882531ea651c37)
区别
- Serializable（Java自带）\ Parcelable（Android 专用）
- 两者最大的区别在于存储媒介的不同，Serializable 使用 I/O 读写存储在硬盘上，而 Parcelable 是直接 在内存中读写。很明显，内存的读写速度通常大于 IO 读写，所以在 Android 中传递数据优先选择 Parcelable。

选择
- Parcelable的性能比Serializable好，在内存开销方面较小，所以在内存间数据传输时推荐使用Parcelable，如activity间传输数据，而Serializable可将数据持久化方便保存，所以在需要保存或网络传输数据时选择Serializable，因为android不同版本Parcelable可能不同，所以不推荐使用Parcelable进行数据持久化

### screenOrientation属性
#### screenOrientation属性介绍
- "unspecified":默认值 由系统来判断显示方向.判定的策略是和设备相关的，所以不同的设备会有不同的显示方向. 
- "landscape":横屏显示（宽比高要长） 
- "portrait":竖屏显示(高比宽要长) 
- "user":用户当前首选的方向 
- "behind":和该Activity下面的那个Activity的方向一致(在Activity活动栈中的) 
- "sensor":有物理的感应器来决定。如果用户旋转设备这屏幕会横竖屏切换。 
- "nosensor":忽略物理感应器，这样就不会随着用户旋转设备而更改了（"unspecified"设置除外）。

#### 属性设置
1. 配置文件中
```
android:screenOrientation="portrait",  为竖屏显示。
android:screenOrientation="landscape"，为横屏显示。
```
2. 代码中

```
setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE)
```

#### 横竖屏对应不同的布局文件
如果要让软件在横竖屏之间切换，由于横竖屏的高宽会发生转换，有可能会要求不同的布局。可以通过以下方法来切换布局：

1. 在res目录下建立layout-land和layout-port目录,相应的layout文件不变，比如main.xml。layout-land是横屏的layout,layout-port是竖屏的layout，其他的不用管，模拟器会自动寻找。
2. 通过 this.getResources().getConfiguration().orientation来判断当前是横屏还是竖屏然后来加载相应的 xml布局文件。因为当屏幕变为横屏的时候,系统会重新呼叫当前Activity的onCreate方法,你可以把以下方法放在你的onCreate中来检查当前的方向,然后可以让你的setContentView来载入不同的layout xml.

### `configChanges` 属性
当你的Activity正显示在屏幕上时, 如果这时候手机的一些配置(比如: 横竖屏切换, 键盘的可用性等)发生了改变, 那么系统就会调用`onConfigurationChanged`方法. 注意, 只有当你在配置文件中选定`configChanges`属性时才会被调用, 不然就会通过正常的生命周期重启Activity.

> 当设备版本 `> 13` 那么在设置 `orientation` 时也要声明 `screenSize`。

```
android:configChanges="orientation|screenSize"
```

#### `configChanges` 属性对 `Activity` 生命周期的影响

未设置configChanges：

切换成横屏时的方法调用
```
onPause
onStop
onSaveInstanceState
onDestory
onCreate
onStart
onRestoreInstanceState
onResume
```
切换成竖屏时的方法调用
```
onPause
onStop
onSaveInstanceState
onDestory
onCreate
onStart
onRestoreInstanceState
onResume
```

设置 `configChanges`：

切换成横屏时的方法调用
```
onConfigurationChanged
```
切换成竖屏时的方法调用
```
onConfigurationChanged
```

> 注意：
> 1. 有的文章称在切换到竖屏时，声明周期会调用两次。我测试了 `10、8、6` 的虚拟机上测试都仅执行一次。
> 2. `Android 8.0` 和 `Android 10`  `onSaveInstanceState` 调用时机上有区别，`8` 在 `onPause` 后调用而 `10` 在 `onStop` 后调用。

```
onPause
onSaveInstanceState
onStop
onDestory
onCreate
onStart
onRestoreInstanceState
onResume
```

#### configChanges属性介绍
- "mcc" ：国际移动用户识别码所属国家代号改变了-----  sim被侦测到了，去更新mcc，mcc是移动用户所属国家代号 
- "mnc"： 国际移动用户识别码的移动网号码改变了------ sim被侦测到了，去更新mnc，MNC是移动网号码，最多由两位数字组成，用于识别移动用户所归属的移动通信网 
- "locale"： 地址改变了-----用户选择了一个新的语言会显示出来 
- "touchscreen"： 触摸屏是改变了------通常是不会发生的 
- "keyboard" ：键盘发生了改变----例如用户用了外部的键盘 
- "keyboardHidden"： 键盘的可用性发生了改变 
- "navigation"： 导航发生了变化-----通常也不会发生 
- "screenLayout"： 屏幕的显示发生了变化------不同的显示被激活 
- "fontScale"： 字体比例发生了变化----选择了不同的全局字体 
- "uiMode"： 用户的模式发生了变化 
- "orientation"： 屏幕方向改变了 
- "screenSize"： 屏幕大小改变了 
- "smallestScreenSize"： 屏幕的物理大小改变了，如：连接到一个外部的屏幕上

### overridePendingTransition设置页面切换动画的注意事项
> overridePendingTransition方法需要在startAtivity方法或者是finish方法调用之后立即执行

```
startIntent();
overridePendingTransition(R.anim.alpha_in, 0);
```

```
startActivity()
    @Override
    public void finish() {
        super.finish();
        overridePendingTransition(0, R.anim.alpha_out);
    }
```

### Intent中的四个重要属性
[Intent中的四个重要属性——Action、Data、Category、Extras](http://blog.csdn.net/weihan1314/article/details/7973511)

### 扩展
#### Android下Context、Activity、Application之间有什么区别
  首先Activity和Application都是Context的子类。Context从字面上理解就是上下文的意思，在实际应用中它也确实是起到了管理上下文环境中各个参数W和变量的总用，方便我们可以简单的访问到各种资源。虽然Activity和Application都是Context的子类，但是他们维护的生命周期不一样。前者维护一个Acitivity的生命周期，所以其对应的Context也只能访问该activity内的各种资源。后者则是维护一个Application的证明周期。
  
> 还有就是，在使用context的时候，小心内存泄露，防止内存泄露，注意一下几个方面：

1. 不要让生命周期长的对象引用activity context，即保证引用activity的对象要与activity本身生命周期是一样的

2. 对于生命周期长的对象，可以使用application context

3. 避免非静态的内部类，尽量使用静态类，避免生命周期问题，注意内部类对外部对象引用导致的生命周期变化
