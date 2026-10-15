### Scheme协议详细介绍

@(android 基础知识)

[关于Scheme应用案例](https://github.com/yangchong211/YCAudioPlayer)
可以参考该demo中的AppTool工具app，用aidl通信，还支持scheme协议跳转，挺好玩的！

#### 1.URL Scheme使用场景介绍
URL Scheme使用场景，目前1，2，5使用场景很广，有没有一种熟悉的感觉？

1. 通过小程序，利用Scheme协议打开原生app

2. H5页面点击锚点，根据锚点具体跳转路径APP端跳转具体的页面

3. APP端收到服务器端下发的PUSH通知栏消息，根据消息的点击跳转路径跳转相关页面

4. APP根据URL跳转到另外一个APP指定页面

5. 通过短信息中的url打开原生app

#### 2.URL Scheme基础介绍
2. 1 什么是URL Scheme？
android中的scheme是一种页面内跳转协议，是一种非常好的实现机制，通过定义自己的scheme协议，可以非常方便跳转app中的各个页面

2. 2 URL Scheme协议格式

```
String urlStr="http://www.ycbjie.cn:80/yc?id=hello&name=cg";
//url =            protocol + authority(host + port) + path + query
//协议protocol=    http
//域名authority=   www.ycbjie.cn:80
//页面path=          /yc
//参数query=       id=hello&name=cg
//authority =      host + port
//主机host=        www.ycbjie.cn
//端口port=        80
```

2. 3 Scheme链接格式样式
样式：

```
[scheme]://[host]/[path]?[query]
```

#### 3.URL Scheme如何使用
3. 1 设置Scheme
在AndroidManifest.xml中对标签增加设置Scheme

```
<activity
    android:name=".ui.main.ui.activity.SchemeFirstActivity"
    android:screenOrientation="portrait">
    <!--Android 接收外部跳转过滤器-->
    <!--要想在别的App上能成功调起App，必须添加intent过滤器-->
    <intent-filter>
        <!-- 协议部分配置 ,注意需要跟web配置相同-->
        <!--协议部分，随便设置 yc://ycbjie:8888/from?type=yangchong  -->
        <data android:scheme="yc"
            android:host="ycbjie"
            android:path="/from"
            android:port="8888"/>

        <!--下面这几行也必须得设置-->
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <action android:name="android.intent.action.VIEW" />
    </intent-filter>
</activity>
```

3. 2 获取Scheme跳转的参数，并添加跳转方式

```
public class SchemeFirstActivity extends AppCompatActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Uri uri = getIntent().getData();
        if (uri != null) {
            //获取指定参数值
            String type = uri.getQueryParameter("type");
            Log.e( "UrlUtils","main: " + type);

            if(type.equals("yangchong")){
                ActivityUtils.startActivity(GuideActivity.class);
            }else if(type.equals("main")){
                ActivityUtils.startActivity(MainActivity.class);
            }
        }
        finish();
    }
}
```

3. 3 调用方式
3. 3.1 原生调用

```
Intent intent = new Intent(Intent.ACTION_VIEW,Uri.parse("yc://ycbjie:8888/from?type=yangchong"));
startActivity(intent);
```

3. 3.2 网页调用

```
<a href="yc://ycbjie:8888/from?type=yangchong">打开叮咚app</a>
```

3. 4 如何判断一个Scheme是否有效

```
PackageManager packageManager = getPackageManager();
Intent intent = new Intent(Intent.ACTION_VIEW,
        Uri.parse("yc://ycbjie:8888/from?type=yangchong"));
List<ResolveInfo> activities = packageManager.queryIntentActivities(intent, 0);
boolean isValid = !activities.isEmpty();
if (isValid) {
    startActivity(intent);
}
```

3. 5 Scheme在短信息中注意要点
设置android:scheme=”http”或者android:scheme=”https”后，点击短信息或者h5页面，发现没有跳到指定的页面，反而打开的是网页链接。
