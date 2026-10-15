[BroadcastReceiver 、ContentProvider 知识点总结](https://juejin.cn/post/6844903989901967368#heading-36)：很详细

[toc]

### 广播的类型

1.  标准广播
2.  有序广播

| 区别 |  |  |  |
| --- | --- | --- | --- |
| 标准广播 | 异步 | 无序 | 无法截断 |
| 有序广播 | 同步 | 有序 | 可截断 |

### 广播接收器的注册方式

#### 在代码中注册 (又称动态注册)
1.  定义内部类,继承BroadcastReceiver,并重写onReceiver();当接收到广播时onReceiver()方法会被调用.

2.  创建过滤器(IntentFilter)实例,并调用addAction(String actionName)方法设置action属性;actionName可以是任意字符串.

3.  调用Context.registerReceiver(BroadcastReceiver receiver, IntentFilter intentFilter);

#### 在AndroidManifest.xml文件中注册 (又称静态注册)
1.  定义内部类,继承BroadcastReceiver,并重写onReceiver();当接收到广播时onReceiver()方法会被调用.

2.  在AndroidManifest.xml文件中注册广播和拦截器

```
<receiver android:name=".BootCompleteReceiver" >    
    <intent-filter>        
        <action android:name="android.intent.action.BOOT_COMPLETED" />    
    </intent-filter>
</receiver>
```

> 两种注册方式的优点和缺点:动态注册的广播接收器可以自由地控制注册与注销，在灵活性方面有很大的优势，但是它也存在着一个缺点，即必须要在程序启动之后才能接收到广播，因为注册的逻辑是写在onCreate()方法中的。而静态注册的方式可以让程序在未启动的情况下就能接收到广播。

### 有序广播

1. 发送有序广播
```
sendOrderedBroadcast(Intent intent, String receiverPermission);
```
	
2. 修改广播内容
对发送来的广播Intent进行修改是利用`setResultExtras(bundle);`函数来实现的。相应的`getResultExtras(true).getString(key);`用来接收广播内容

2. 设定广播接收器的先后顺序
在广播注册的时候设定过滤器的`android:priority`属性设置广播接收器的优先级,优先级比较高的广播接收器可以先收到广播

3. 广播截断
在onReceiver()方法中调用`abortBroadcast();`方法可以终止广播传递
	
``` java
Intent intent = new Intent("com.github.test.broadcast");
intent.putExtra("msg", "MainActivity");
sendOrderedBroadcast(intent, null);
```

``` java
public class FirstBroadCastReceiver extends BroadcastReceiver
{
    private static final String TAG = "MyReceiver";
    @Override
    public void onReceive(Context context, Intent intent)
    {

        //先获得传过来的MSG
        String msg = intent.getStringExtra("msg");
        Log.i(TAG, "FirstRecever："+msg);

        //更改广播数据
        Bundle bundle = new Bundle();
        bundle.putString("msg", msg + "@FirstReceiver");
        setResultExtras(bundle);
    }
}
```

``` java
public class TwoBroadCastReceiver extends BroadcastReceiver
{
    private static final String TAG = "MyReceiver";

    @Override
    public void onReceive(Context context, Intent intent)
    {
        //先获得广播过来的MSG
        String broadcast_msg = intent.getStringExtra("msg");
        Log.i(TAG, "SecondRecever--broadcast_msg：" + broadcast_msg);

        //接收通过setResultExtras传过来的msg
        String msg = getResultExtras(true).getString("msg");
        Log.i(TAG, "SecondReceiver: " + msg);

        //修改setResultExtras传来的结果
        Bundle bundle = new Bundle();
        bundle.putString("msg", msg + "@SecondReceiver");
        setResultExtras(bundle);
    }
}
```

``` java
public class ThreeBroadCastReceiver extends BroadcastReceiver
{
    private static final String TAG = "MyReceiver";

    @Override
    public void onReceive(Context context, Intent intent)
    {
        String msg = getResultExtras(true).getString("msg");
        Log.i(TAG, "ThreeBroadCastReceiver: " + msg);
    }
}
```
打印日志:
``` groovy
I/MyReceiver: FirstRecever：MainActivity
I/MyReceiver: SecondRecever--broadcast_msg：MainActivity
I/MyReceiver: SecondReceiver: MainActivity@FirstReceiver
I/MyReceiver: ThreeBroadCastReceiver: MainActivity@FirstReceiver@SecondReceiver
```

### 发送本地广播 (LocalBroadcastManager)

1. 什么是本地广播
之前发送的都是属于系统全局广播，即发出的广播可以被其他任何应用程序接收到；这样广播中的数据有可能被其他程序截获。为了能够解决广播的安全性问题 `Android` 引用了一套本地广播机制。
本地广播和标准广播的区别就是本地广播的操作都是调用 `LocalBroadcastManager` 中的方法，而标准广播是调用的 `Context` 中的方法。

2. 注册本地广播

```
//获取LocalBroadcastManager实例
LocalBroadcastManager localBroadcastManager = LocalBroadcastManager.getInstance(this);

// 广播过滤器
IntentFilter intentFilter = new IntentFilter();
intentFilter.addAction("com.example.broadcasttest.LOCAL_BROADCAST");

// 广播接收者
LocalReceiver localReceiver = new LocalReceiver();

// 注册本地广播监听器 localBroadcastManager.registerReceiver(localReceiver, intentFilter);
```

3. 发送本地广播

```
// 发送本地广播 
localBroadcastManager.sendBroadcast(intent);
```

```
// 发送广播 立即执行
localBroadcastManager.sendBroadcastSync(intent);
```

4. 销毁本地广播

```
// 本地广播销毁localBroadcastManager.unregisterReceiver(localReceiver);
```

> 注意：广播注册后记得调用`Context.unregisterReceiver(BroadcastReceiver receiver)`取消广播。

### Android8.0无法接收隐式广播消息

#### 版本区别
对于targetSdkVersion 在26或者以上的App，在Manifest里面注册的Receiver已经受到限制，而用Java代码动态注册的Receiver则不受影响。

targetSdkVersion 在 25或以下的App，其Receiver不受影响，即使在Android8.0以上的机器上运行。

#### 有哪些影响
首先要了解一个概念。官方文档里提到implicit broadcast，可译为隐式广播，指那些没有指定接收App(即包名)的广播。 
- 系统发送的广播毫无疑问都是隐式广播，因此基本上都会受到影响，除了部分受豁免广播之外 
- App发送的自定义隐式广播，都会受到影响

#### 为何限制隐式广播
总所周知，在Manifest里面注册的系统广播接收器会被缓存在系统中，即使当App关闭之后，如果有相应的广播发出，应用程序仍然会被唤醒。比如如果有20个App在Manifest里面注册了ACTION_BOOT_COMPLETED的广播接收器监听设备启动，那么当设备启动时，就会有20个应用程序被唤醒并作出相应的动作。而动态注册的广播则跟随组件的生命周期而消存。因此在Manifest里面注册广播接收器的App越多，设备的性能就越容易受到影响，限制隐式广播主要是为了优化系统性能。

#### 如何应对这一限制
分析了受限制的原因之后，就知道该如何应对这一影响了。 
- 优先使用动态注册Receiver的方式，能动态注册绝不使用Manifest注册

如果一定要Manifest注册，那么当发送广播的时候，指定广播接收者的包名，即发送显式广播

```
Intent intent = new Intent("com.xiaoqiang.try.something.receiver");
intent.putExtra("receive","test broadcast");
intent.setPackage(getPackageName());
//intent.setComponent(...)
sendBroadcast(intent);
```

如果要接收系统广播，而对应的广播在Android8.0中无法被接收，那么只能暂时把App的targetSdkVersion改为25或以下。
