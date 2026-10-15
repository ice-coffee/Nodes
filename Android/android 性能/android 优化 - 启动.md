[toc]

### 三方平台初始化

> 解决方案: 通过在子线程中对三方平台进行初始化, 这里用IntentService处理, 记得在注册服务哦.

``` java
public class InitializeService extends IntentService
{

    private static final String ACTION_INIT_WHEN_APP_CREATE = "cc.sc.engineer.service.action.INIT";

    public InitializeService()
    {
        super("InitializeService");
    }

    public static void start(Context context)
    {
        Intent intent = new Intent(context, InitializeService.class);
        intent.setAction(ACTION_INIT_WHEN_APP_CREATE);
        context.startService(intent);
    }

    @Override
    protected void onHandleIntent(@Nullable Intent intent)
    {
        if (null != intent)
        {
            final String action = intent.getAction();
            if (ACTION_INIT_WHEN_APP_CREATE.equals(action))
            {
                performInit();
            }
        }
    }

    private void performInit()
    {
        //初始化三方平台
    }
}
MyApplication 
public class MyApplication extends Application 
{
    @Override
    public void onCreate() 
    {
        super.onCreate();
        InitializeService.start(this);
    }
}
```

### 冷启动白屏

解决方案: 
* 设置背景透明
* Material Design

这里介绍第一种方式

``` java
Style.xml
<style name="SplashTheme" parent="AppTheme">
    <item name="android:windowIsTranslucent">true</item>
    <item name="windowNoTitle">true</item>
</style>
```

在AndroidManifest.xml文件中添加
``` java
<activity
    android:name=".moudle.welcome.view.SplashActivity"
    android:screenOrientation="portrait"
    android:theme="@style/SplashTheme">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
```

#### 原理
`Android` 启动时会先显示一个 `StartingWindow`。
可以通过设置 `windowDisablePreview = true` 取消显示。
