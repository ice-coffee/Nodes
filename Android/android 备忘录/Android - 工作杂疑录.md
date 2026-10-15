https://blog.csdn.net/fly7632785/article/details/107105909

[sheets-bottom](https://material.io/components/sheets-bottom)

[TabLayout - 更多操作](https://juejin.cn/post/6844903479052337166)

ViewCompat 是什么 做什么用的

能固定 Window 的背景色吗

### style
项目中用以下设置了 AppCompatDialog 的背景。那它的作用是什么呢？
```
<item name="android:backgroundDimEnabled">true</item>
<item name="android:backgroundDimAmount">0.3</item>
```

### 在viewpager的adapter里面有一个方法可以获取到当前的view
如下：

```
private View mCurrentView;
                                         
@Override
public void setPrimaryItem(ViewGroup container, int position, Object object) {
    mCurrentView = (View)object;
}
                                         
public View getPrimaryItem() {
    return mCurrentView;
}
```

### Fragment 
[Android Fragment切换动画的2种实现方式](https://blog.csdn.net/qq402164452/article/details/73611233)
[Fragment 进入和退出动画](https://www.jianshu.com/p/b0fcc2681cf9)
fragment 模拟 activity 切换动画
目前方案有二:
1. 重写 onCreateAnimation()
2. 使用 Fragmentmanager.setCustomAnimations()


### 手机拍摄横屏视频后， 通过 MediaMetadataRetriever 获取的orientation 为 0

### new Handler(Looper.getMainLooper()) 和普通方式有区别吗

### BottomSheetDialogFragment 嵌套 RecyclerView 无法正常滑动 
https://github.com/scwang90/SmartRefreshLayout/issues/994

实现一个网易云音乐的 BottomSheetDialog
https://juejin.im/entry/6844903589349949454

### Android唯一标识符

### SP 替代方案

### 2. ImmersionBar 与 fitsSystemWindows 冲突解决

原因：

### 8. 后台进程保活
[link](https://github.com/ShihooWang/DaemonLibrary)

### 11. 手势 GestureDetector 、 GestureDetectorCompat

### 12.https://juejin.im/post/5cc8118de51d456e853f81c4

### 13.ViewConfiguration

### 14. Glide4.7加载图片RoundedCorners跟CenterCrop冲突问题解决
[link](https://blog.csdn.net/qq_19269585/article/details/80968147)

### 15. [依赖库版本不一致导致的问题的解决思路](https://blog.csdn.net/submit66/article/details/79600558)

### 16. 内存
[分析并优化 Android 应用内存占用](https://juejin.im/post/5c2841cde51d45673971d03f)

### 17. Android 10 适配
- 文件访问
- 定位


### 18. 
- getBaseContext   getApplicationContext 区别
- [Android 清空activity栈的方法
](https://www.jianshu.com/p/292c88386f9c)
- RecyclerView - ItemTouchHelper
- RecyclerView 滑动菜单
- 

### 20 . ./gradlew app:dependenciesf

### 21. RecyclerView 在onBindView 中为什么获取不到子View 的宽高

### 22. StaticLayout 

### 23. View.post();
[link](https://www.cnblogs.com/plokmju/p/7481727.html)

### 24. Fragment 没有diapatchtouchevent 等事件拦截函数

### 25.自定义behavior

### 26.Dialog FragmentDialog 的区别
@android:style/Theme.Dialog
Theme.AppCompat.Dialog.Alert

Dialog 遮罩Activity时onResume不响应

### 27. CardView

### 28. lottieanimationview

### 29.悟空打包

### 30.onTouchEvent 点击事件

### 31.new Handler(Looper.myLooper()) 不提示wain

### canvas：在canvas上各个位置绘制各种图形，image\text等

### android 浮动按钮

### 滑动 顶部布局缩放 AppBarLayout 或其他方式

### EditText 所在的布局浮动在软键盘之上，软键盘监听

### ScrollView 嵌套 RecyclerView 是否会影响RecyclerView的复用；
```
override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        return ItemViewHolder(View.inflate(mContext, R.layout.view_item, null))
    }
```
为什么最后一个参数要为null

### 在Fragment中使用getResources报错 

```
not attached to a context.
```

### Canvas.drawbitmap

```
public void drawBitmap(@NonNull Bitmap bitmap, float left, float top, @Nullable Paint paint) 

public void drawBitmap(@NonNull Bitmap bitmap, @Nullable Rect src, @NonNull RectF dst,
            @Nullable Paint paint)
public void drawBitmap(@NonNull Bitmap bitmap, @Nullable Rect src, @NonNull Rect dst,
            @Nullable Paint paint) {
```

### 代码绘制Shape

### ColorStateLit - context.getResources().getColorStateList()

### getColor theme

### assets、raw 文件夹的区别，存放媒体文件

### ConstraintLayout、Motionlayout

### dialog not attached to window manager
![dialog_not_attached.jpg](http://note.youdao.com/yws/res/7246/WEBRESOURCEf6cd00e8881d36ba3d7f4f003028c4dc)

### you cannot start a load for a destroyed activity
![1598594980922.jpg](http://note.youdao.com/yws/res/7251/WEBRESOURCEabb7f14d1b4c9ba96305cd74e3e8a4d2)

### gradle - flavorDimensions

### glide - override

### CharSequence

### WindowManager 等各种Manager

### stateListAnimator

### fragment xml android:onClick 无效
[link](https://blog.csdn.net/Zafir6453/article/details/51383915)

### ObjectAnimator 的动画 - radius

### [Android权限详解](https://juejin.im/post/6844903663769485326)

### D8、R8

### AppCompatDialog \ DialogFragment

### ANR
[卡顿、ANR、死锁，线上如何监控？](https://juejin.cn/post/6973564044351373326)
[今日头条 ANR 优化实践系列 - 监控工具与分析思路](https://mp.weixin.qq.com/s?__biz=MzI1MzYzMjE0MQ==&mid=2247488182&idx=1&sn=6337f1b51d487057b162064c3e24c439&chksm=e9d0d954dea75042193ed09f30eb8ba0acd93870227c5d33b33361b739a03562afb685df9215&scene=178&cur_album_id=1780091311874686979#rd)

### ViewBinding 为什么在 Fragment 中需要手动释放对象，Activity 是如何释放 ViewBinding 对象的。

### Resource IDs will be non-final in Android Gradle Plugin version 5.0, avoid using them in switch case statements

### startActivityForResult Deprecated registerForActivityResult

### Map 的子类：HashTable、HashMap、TreeMap、ConcurrentHashMap 的区别

[《我们一起进大厂》系列-ConcurrentHashMap & Hashtable](https://juejin.cn/post/6844904023003250701)

[HashMap和HashTable到底哪不同？](https://www.cnblogs.com/xinzhao/p/5644175.html)


|  | HashTable | HashMap | ConcurrentHashMap |
| --- | --- | --- | --- |
| 继承 | Dictionary | AbstractMap |  |
| 知否支持 null | 会抛出异常 | 支持 |  |
|  |  |  |  |
|  |  |  |  |


### setDataSource failed: status = 0xFFFFFFEA
/**
             * TODO-MZP 有可能会报错 java.lang.RuntimeException: setDataSource failed: status = 0xFFFFFFEA
             * 报错原因: 空文件
             */
             
             
### 一次 Native 崩溃的分析、解决过程
[记录一次 SEGV_MAPERR 问题的分析、解决过程](https://wufengxue.github.io/2020/06/22/wechat-voice-codec-SEGV_MAPERR.html)

### HashCode 对象大小对哈希值计算速度的影响、hashCode() 优化
