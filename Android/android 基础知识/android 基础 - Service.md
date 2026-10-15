[toc]

#### 如何使用服务

```
class NewService extends Service {

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
```

1. 定义一个服务类, 
2. 继承android.app.Service抽象类, 
3. 重写onBind()方法,
4. 在AndroidManifest.xml文件中注册服务;

#### Service 的生命周期

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_service.jpg)

* `onCreate`：服务创建时调用；
* `onStartCommand`：服务启动时调用；
* `onBind`：服务绑定时调用, 通过这个方法可以实现Activity与Service之间的通讯；
* `onUnBind`：服务解绑时调用；
* `onDestroy`：服务销毁时调用；

> 注意：
> 1. 如果一个 `Service` 被 `startService` 方法多次启动，那么 `onCreate` 方法只会调用一次，`onStartCommand` 将会被调用多次，并且系统只会创建 `Service` 的一个实例（因此你应该知道只需要一次 `stopService` 调用就可以终止服务）。该 `Service` 将会一直在后台运行，而不管对应程序的`Activity` 是否在运行，直到被调用 `stopService`，或自身的 `stopSelf` 方法。当然如果系统资源不足，`android` 系统也可能结束服务。
> 2. 被绑定的服务的生命周期：如果一个 `Service` 被某个 `Activity` 调用 `bindService` 方法绑定启动，不管调用 `bindService` 调用几次，`onCreate` 方法都只会调用一次，同时 `onStartCommand` 方法始终不会被调用。
> 3. 在与 `Service` 绑定的 `Activity` 销毁之前必须解绑, 不然会报错, 所以建议绑定服务使用全局的上下文变量.

`onStartCommand` 方法返回值有4种：

- `START_STICKY`
- `START_NOT_STICKY`
- `START_REDELIVER_INTENT`
- `START_STICKY_COMPATIBILITY`

以下的情况都是在服务启动后，`onStartCommand()` 返回值之后，服务被系统 `KILL` 了之后的情况描述。

`START_STICKY`：指系统会重新创建service，然后呢由于重新创建了service，那么onstartCommand方法就一定会被重新调用，如果这个时候，没有其他启动service的命令传过来，那么这个时候的Intent就是null，这里需要注意一下。

`START_STICKY_COMPATIBILITY`：这个其实是用来兼容api5 一下的，这个的作用和START_STICK一样，但是这个返回值不能保证系统一定会重新创建service

`START_REDELIVER_INTENT`：这个是指服务被重新创建后，直接将之前Intent的值传入，和上面START_STICK不同，这里的Intent不会为null。

`START_NOT_STICKY`：这个就是系统被kill了，服务不会重新启动。

#### 启动服务的两种方式

服务有两种启动方式：绑定和不绑定, 所以有以下几种启动和停止的方式
`不绑定`： 
* 启动: `startService()`
* 停止: `stopService()`

`绑定`：
* 启动: `bindService()`
* 停止: `unbindService()`

`启动后绑定`
* 启动: `startService()`
* 绑定: `bindService()`
* 解绑: `unbindService()`
* 停止: `stopService()`

> 注意: 服务启动后再绑定, 这种情况下需要先进行解绑才可停止服务

#### Service 属性

```
android:exported
```

`exported` 这个属性用于指示该服务是否能够被其他应用程序组件调用或跟它交互。如果设置为true，则能够被调用或交互，否则不能。设置为false时，只有同一个应用程序的组件或带有相同用户ID的应用程序才能启动或绑定该服务。
它的默认值依赖与该服务所包含的过滤器。没有过滤器则意味着该服务只能通过指定明确的类名来调用，这样就是说该服务只能在应用程序的内部使用（因为其他外部使用者不会知道该服务的类名），因此这种情况下，这个属性的默认值是false。另一方面，如果至少包含了一个过滤器，则意味着该服务可以给外部的其他应用提供服务，因此默认值是true。 
这个属性不是限制把服务暴露给其他应用程序的唯一方法。还可以使用权限来限制能够跟该服务交互的外部实体。
详细一点: 

1. 这样的Service其他进程是不能访问的
```
<service Android:name=".RemoteService"/>
```
2. 设置访问权限
```
<service android:name=".RemoteService"
    android:exported="true" 
    android:permission="com.stone.RemoteAccess">
    <intent-filter>
        <action android:name="com.example.ipc_b.RemoteService"/>
    </intent-filter>
</service>
```

其他进程要访问上面的service, 必须使用permission
```
<uses-permission android:name="com.stone.RemoteAccess"/>
```

3. 其他进程可以访问下面的service, 有intent-filter(包含action), exported属性就默认为true
```
<service android:name=".RemoteService">
    <intent-filter>
        <action android:name="com.example.ipc_b.RemoteService"/>
    </intent-filter>
</service>
```

#### Activity 和 Service 间通信

使用非绑定方式开启服务后,活动和服务之间就基本没有什么关系了，如果要实现活动和服务之间的通信需使用绑定方式开启服务：

1. 调用 `bindService` 绑定服务。
2. 调用 `Service` 类中的 `onBind` 方法返回自定义的 `IBinder` 对象。
3. 在 `ServiceConnection` 匿名类的 `onServiceConnected` 内获取 `onBind` 方法返回的 `IBinder` 对象。
4. 使用获取的 `IBinder` 对象调用自定义 `IBinder` 中的方法。

```
Service代码:
public class TestService extends Service
{
    private final static String TAG = "TestService";

    @Nullable
    @Override
    public IBinder onBind(Intent intent)
    {
        Log.e(TAG, "onBind");
        return new MyBind();
    }

    public class MyBind extends Binder
    {
        public void doSomething()
        {
            Log.e(TAG, "doSomething");
        }
    }
}
```

```
Activity代码:
//重点提醒, 记得解绑
bindService(serviceIntent, mServiceConnection, Context.BIND_AUTO_CREATE);

private class TestServiceConnection implements ServiceConnection
{
    @Override
    public void onServiceConnected(ComponentName name, IBinder service)
    {
        TestService.MyBind mBinder = (TestService.MyBind) service;
        mBinder.doSomething();
    }

    @Override
    public void onServiceDisconnected(ComponentName name)
    {
        Log.e(TAG, "service disconnected");
    }
}
```

#### 前台服务
由于服务的优先级较低,当内存不足时,有可能会回收掉正在后台运行的服务.如果希望服务可以一直保持运行状态,那么就可以考虑使用前台服务;如果需要在系统状态栏显示数据,那么也可以使用前台服务;前台服务和普通服务最大的区别就在于，它会一直有一个正在运行的图标在系统的状态栏显示，下拉状态栏后可以看到更加详细的信息，非常类似于通知的效果。开启前台服务就是把以下代码写到Service类的onCreate()方法中(与创建通知的代码相同)

> 注意：使用startForeground,如果id为0,那么notification将不会显示。

#### 远程服务

##### 标准远程服务
将一个普通的 `Service` 转换成 `远程Service` 其实非常简单，只需要在注册 `Service` 的时候将它的设置 `android:process` 属性就可以了。

```
<service  
    android:name="com.example.servicetest.MyService"  
    android:process=":remote" >  
</service>  
```

> 注意: remote不是关键字, 可使用其他单词替换。`value` 值以冒号开头的话，那么该进程就是私有进程，如果是以其他字符开头，那么就是公有进程？

使用场景：

- 启动新的进程，播放音乐。
- 多进程应用。

##### AIDL
[android 基础 - Service - aidl](https://app.yinxiang.com/shard/s58/nl/10744683/6f752ee4-d680-4e69-b6bc-38f9ff2701ff/)

#### IntentService（过时）

普通 `Service` 是运行在主线程中的，所以如果要处理一些耗时的逻辑，就很容易出现 `ANR`。可以使用 `IntentService` 启动一个异步的、会自动停止的服务执行耗时操作。

```
class NewIntentService extends IntentService {

    public NewIntentService(String name) {
        super(name);
    }
    
    @Override
    protected void onHandleIntent(@Nullable Intent intent) {

    }
}
```

`IntentService` 中通过 `HandlerThread` 开启了一个子线程，在 `start` 方法里直接发送消息，调用 `onHandleIntent` 函数在子线程中执行任务，`onHandleIntent` 结束后调用 `stopSelf` 方法结束 `Service`。

```
public abstract class IntentService extends Service {
    private volatile Looper mServiceLooper;
    private volatile ServiceHandler mServiceHandler;

    private final class ServiceHandler extends Handler {
        public ServiceHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            onHandleIntent((Intent)msg.obj);
            // 逻辑执行完成后结束 Service
            stopSelf(msg.arg1);
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        // 启动子线程
        HandlerThread thread = new HandlerThread("IntentService[" + mName + "]");
        thread.start();

        // 创建 Handler
        mServiceLooper = thread.getLooper();
        mServiceHandler = new ServiceHandler(mServiceLooper);
    }

    @Override
    public void onStart(@Nullable Intent intent, int startId) {
        // 发送消息
        Message msg = mServiceHandler.obtainMessage();
        msg.arg1 = startId;
        msg.obj = intent;
        mServiceHandler.sendMessage(msg);
    }

    ...
}
```

> 注意：在 `Android 8.0 (API level 26)` 或以上，系统不允许在应用在后台时创建服务。这种情况下可以通过如下方式创建服务：
> - 通过 `Context.startForegroundService()` 方式启动一个前台 `Service`。
> - `JobService`、`JobIntentService`。

#### startForegroundService
在系统创建服务后，应用有五秒的时间来调用该服务的 `startForeground` 方法以显示新服务的用户可见通知。

#### JobService
[Android秘技之JobService的使用详解](https://www.catbro.cn/detail/5c394d0584063683a872a591.html)

JobScheduler和JobService是安卓在api 21中增加的接口，用于在某些指定条件下执行后台任务。

`MyJobService.kt`
```
class MyJobService: JobService() {
    companion object {
          val MYJOBSERVICE_JOB_ID = 0 //最为该jobservice的id标识
          val MYJOBSERVICE_JOB_OVERDIDE_DEADLINE = 1000 //延迟多少秒执行
          private val TAG = "MyJobService"

      }

      override fun onStopJob(params: JobParameters?): Boolean {
          Log.i(TAG, "onStopJob start")
          return true
      }

      override fun onStartJob(params: JobParameters?): Boolean {
          Log.i(TAG, "onStartJob start")
          return true
      }
  }
```

`AndroidManifest.xml`
```
 <service android:name="MyJobService"
        android:permission="android.permission.BIND_JOB_SERVICE" >
   ...
 </service>
```

`MainActivity.kt`
```
override fun onCreate(savedInstanceState: Bundle?) {
  super.onCreate(savedInstanceState)
  setContentView(R.layout.activity_main)
  
  val myJobServiceComponentName  = ComponentName(this, MyJobService::class.java)

  val jobBuilder = JobInfo.Builder(MyJobService.MYJOBSERVICE_JOB_ID, myJobServiceComponentName)
  jobBuilder.setPeriodic(1000*60*15)
  val myJob = jobBuilder.build()

  val scheduler = this.getSystemService(JobScheduler::class.java)

  scheduler.schedule(myJob)
}
```

#### JobIntentService
1. 继承 `JobIntentService`，并重写 `onHandleWork` 方法：
```
public class MyJobIntentService extends JobIntentService {
    @Override
    protected void onHandleWork(@NonNull Intent intent) {
        Log.d("MyJobIntentService所在线程", Thread.currentThread().getId() + "");
        Log.d("MyJobIntentService服务#", "开始工作了");
    }
}
```

2. 注册：
```
<uses-permission android:name="android.permission.WAKE_LOCK" />
...
<application>
    <service
        android:name=".MyJobIntentService"
        android:exported="false"
        android:permission="android.permission.BIND_JOB_SERVICE"><!--android.permission.BIND_JOB_SERVICE这个权限一定要有，否则程序会崩溃-->
        </service>
 ...
</application>
```

3. 启动服务：
```
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
   int JOB_ID = 8;
   Intent work  = new Intent();
   work.putExtra("key","value555555");
   MyJobIntentService.enqueueWork(MainActivity.this,MyJobIntentService.class,JOB_ID, work);
}
```

`JobIntentService` 内部维护了一个 `AysncTask` 处理异步逻辑。

### 遗留
1. `JobService` 原理
