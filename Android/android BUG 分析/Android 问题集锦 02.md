### Android 问题集锦 02
[原文链接](http://blog.csdn.net/lincyang/article/details/42673151)
@(android BUG记录)

#### 1. bug描述
> java.lang.IllegalStateException: You need to use a Theme.AppCompat theme (or descendant) with this activity.

#### 2. 原因分析
我想在Manifest中设置我的activity全屏
```
<activity  
    android:name=".MainActivity"  
    android:theme="@android:style/Theme.NoTitleBar.Fullscreen"  
    android:label="@string/app_name" >  
```

#### 3. 产生情景
错误提示中提到Theme.AppCompat theme，这是因为我们的activity一定是继承了兼容包中的类，比如继承了actionBarActivity，它来android.support.v7.app.ActionBarActivity。所以就要使用与其配合的AppCompat的theme才行。

#### 4. 解决方案
1. 根据提示来使用AppCompat的theme

```
<activity  
    android:name=".MainActivity"  
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"  
    android:label="@string/app_name" >  
```

不过我要设置全屏，但我并没有找到，所以虽然错误不见了，但并没有达到我的预期。

2. 如果不是那么强烈需要继承自ActionBarActivity，就直接继承Activity吧。问题自然搞定！
