### Android 8.0 Only fullscreen opaque activities can request orientation

@(android BUG记录)

[原文地址](http://www.manongjc.com/article/37655.html)

前言：

> 在android 8.0上遇到Only fullscreen opaque activities can request orientation,采用优雅的方式，Hook绕过检查，无需要修改xml，或者降低目标版本。

查看android其他版本中正常运行的项目中的配置：

Activity的设置黑色背景且指定屏幕为竖屏:
在xml中，设置主题:

```
<style name="Theme.picture" parent="AppTheme">

    <item name="colorPrimaryDark">#000000</item>
</style>

<activity
        android:name=".ui.Activity.myStory.xxxxActivity"
        android:screenOrientation="portrait"
        android:theme="@style/Theme.picture" />
```

在android 8.0系统上运行报错：

```
 Caused by: java.lang.IllegalStateException: Only fullscreen opaque activities can request orientation
        at android.app.Activity.onCreate(Activity.java:1038)
        at android.support.v4.app.SupportActivity.onCreate(ComponentActivity.java:75)
        at android.support.v4.app.FragmentActivity.onCreate(FragmentActivity.java:335)
        at android.support.v7.app.AppCompatActivity.onCreate(AppCompatActivity.java:85)
```

源码追踪
1. 查看api 27 Activity的oncreate()的源码：

```
 protected void onCreate(@Nullable Bundle savedInstanceState) {
 
        if (getApplicationInfo().targetSdkVersion >= O_MR1 && mActivityInfo.isFixedOrientation()) {
            final TypedArray ta = obtainStyledAttributes(com.android.internal.R.styleable.Window);
            final boolean isTranslucentOrFloating = ActivityInfo.isTranslucentOrFloating(ta);
            ta.recycle();

            if (isTranslucentOrFloating) {
                throw new IllegalStateException(
                        "Only fullscreen opaque activities can request orientation");
            }
        }
 }
```

发现多了检查屏幕操作。当满足条件一：固定屏幕方向。且满足条件二:透明色或者悬浮，会抛出异常。

2. 查看Activity的屏幕方向

接下来看下：ActivityInfo.isFixedOrientation() 检查屏幕方向，是否需要修复

```
  /**
     * Returns true if the activity's orientation is fixed.
     * @hide
     */
    public boolean isFixedOrientation() {
        return isFixedOrientationLandscape() || isFixedOrientationPortrait()
                || screenOrientation == SCREEN_ORIENTATION_LOCKED;
    }
```

3. 查看Activity的是否透明色或者悬浮

最后,来看下ActivityInfo.isTranslucentOrFloating() 用于检查是否透明色

```
 /**
     * Determines whether the {@link Activity} is considered translucent or floating.
     * @hide
     */
    public static boolean isTranslucentOrFloating(TypedArray attributes) {
        final boolean isTranslucent =
                attributes.getBoolean(com.android.internal.R.styleable.Window_windowIsTranslucent,
                        false);
        final boolean isSwipeToDismiss = !attributes.hasValue(
                com.android.internal.R.styleable.Window_windowIsTranslucent)
                && attributes.getBoolean(
                        com.android.internal.R.styleable.Window_windowSwipeToDismiss, false);
        final boolean isFloating =
                attributes.getBoolean(com.android.internal.R.styleable.Window_windowIsFloating,
                        false);

        return isFloating || isTranslucent || isSwipeToDismiss;
    }
```

优雅的方式： Hook 反射绕过检查
思路：

判断是否透明色或者悬浮
修改activity的屏幕方向，不固定，绕过检查。

```
public class ActivityHook {
    /**
     * java.lang.IllegalStateException: Only fullscreen opaque activities can request orientation
     * <p>
     * 修复android 8.0存在的问题
     * <p>
     * 在Activity中onCreate()中super之前调用
     *
     * @param activity
     */
    public static void hookOrientation(Activity activity) {
        //目标版本8.0及其以上
        if (activity.getApplicationInfo().targetSdkVersion >= Build.VERSION_CODES.O) {
            if (isTranslucentOrFloating(activity)) {
                fixOrientation(activity);
            }
        }
    }

    /**
     * 设置屏幕不固定，绕过检查
     *
     * @param activity
     */
    private static void fixOrientation(Activity activity) {
        try {
            Class<Activity> activityClass = Activity.class;
            Field mActivityInfoField = activityClass.getDeclaredField("mActivityInfo");
            mActivityInfoField.setAccessible(true);
            ActivityInfo activityInfo = (ActivityInfo) mActivityInfoField.get(activity);
            //设置屏幕不固定
            activityInfo.screenOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 检查屏幕 横竖屏或者锁定就是固定
     *
     * @param activity
     * @return
     */
    private static boolean isTranslucentOrFloating(Activity activity) {
        boolean isTranslucentOrFloating = false;
        try {
            Class<?> styleableClass = Class.forName("com.android.internal.R$styleable");
            Field WindowField = styleableClass.getDeclaredField("Window");
            WindowField.setAccessible(true);
            int[] styleableRes = (int[]) WindowField.get(null);
            //先获取到TypedArray
            final TypedArray typedArray = activity.obtainStyledAttributes(styleableRes);
            Class<?> ActivityInfoClass = ActivityInfo.class;
            //调用检查是否屏幕旋转
            Method isTranslucentOrFloatingMethod = ActivityInfoClass.getDeclaredMethod("isTranslucentOrFloating", TypedArray.class);
            isTranslucentOrFloatingMethod.setAccessible(true);
            isTranslucentOrFloating = (boolean) isTranslucentOrFloatingMethod.invoke(null, typedArray);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return isTranslucentOrFloating;
    }
}
```

在需要的Activiy中的oncreate()中调用：

```
 @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
         
         ActivityHook.hookOrientation(this);//hook，绕过检查
         
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_xxxx);

    }
```
