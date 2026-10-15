## ImageView

@(android 控件药店)

[TOC]

### 1. anroid:src 和 android:background 的区别
- background会根据ImageView组件给定的长宽进行拉伸，bg属性设置的是背景，使用setBackgroundResource(R.drawable.****)动态加载图片;
- 而src就存放的是原图的大小，不会进行拉伸，src属性设置的是图片内容（前景），使用setImageResource(R.drawable.****)动态加载图片;
> 两者可同时使用可以同时使用

### 2. android:scaleType
> scaleType只对src起作用

参数值说明:
- CENTER /center 在视图中心显示图片，并且不缩放图片
- CENTER_CROP / centerCrop 按比例缩放图片，使得图片长 (宽)的大于等于视图的相应维度
- CENTER_INSIDE / centerInside 按比例缩放图片，使得图片长 (宽)的小于等于视图的相应维度
- FIT_CENTER / fitCenter 按比例缩放图片到视图的最小边，居中显示
- FIT_END / fitEnd 按比例缩放图片到视图的最小边，显示在视图的下部分位置
- FIT_START / fitStart 把图片按比例扩大/缩小到视图的最小边，显示在视图的上部分位置
- FIT_XY / fitXY 把图片不按比例缩放到视图的大小显示
- MATRIX / matrix 用矩阵来绘制

> 在有些banner图左右有缝隙的情况下课试用 `android:scaleType = "fitXY"`查看效果;

### 3. Bitmap.Config
> 图片压缩质量参数

Andorid图片压缩分两方面, 一是尺寸大小, 二是其色彩.

#### 3.1 是什么
打开Android.graphics.Bitmap类里有一个内部类Bitmap.Config类，在Bitmap类里createBitmap(intwidth, int height, Bitmap.Config config)方法里会用到，打开个这个类一看

枚举变量

```
public static final Bitmap.Config ALPHA_8
public static final Bitmap.Config ARGB_4444
public static final Bitmap.Config ARGB_8888
public static final Bitmap.Config RGB_565
```

其实这都是色彩的存储方法：我们知道ARGB指的是一种色彩模式，里面A代表Alpha，R表示red，G表示green，B表示blue，其实所有的可见色都是右红绿蓝组成的，所以红绿蓝又称为三原色，每个原色都存储着所表示颜色的信息值

ALPHA_8就是Alpha由8位组成
ARGB_4444就是由4个4位组成即16位，
ARGB_8888就是由4个8位组成即32位，
RGB_565就是R为5位，G为6位，B为5位共16位

由此可见：
ALPHA_8 代表8位Alpha位图
ARGB_4444 代表16位ARGB位图
ARGB_8888 代表32位ARGB位图
RGB_565 代表8位RGB位图

位图位数越高代表其可以存储的颜色信息越多，当然图像也就越逼真。
#### 3.2 举个例子:
一幅大小为width*height色彩格式为ARGB_8888的图片，假设大小是640*480的（以像素为单位），全部数据都存放在一个 int ARGB[] 的数组中，则数组的大小就是640*480.

   一个 int 有4个 byte 依次存放着每个像素的A,R,G,B的值。

   这里只有一点需要注意：A值代表透明度，当 A == 0xff 时不透明，当 A == 0x00 时完全透明。

#### 3.3 用法
在压缩之前将option的值设置一下：

```
options.inPreferredConfig = Bitmap.Config.RGB_565;
```

### 4 圆形ImageView
#### 4.1 操作图片
##### 4.1.1 实现方式
> 把图片裁剪成圆角图片
> 优点：节约内存

```
public Bitmap getRoundRectBitmap(Bitmap bitmap, int radius) 
{
    Paint paint = new Paint();
    paint.setAntiAlias(true);
    paint.setFilterBitmap(true);
    
    int bmWidth = bitmap.getWidth();
    int bmHeight = bitmap.getHeight();
    final RectF rectF = new RectF(0, 0, width, height);
    
    Canvas canvas = new Canvas(bitmap);
    
    paint.setXfermode(null);
    canvas.drawRoundRect(rectF, radius, radius, paint);
    paint.setXfermode(new PorterDuffXfermode(Mode.SRC_IN));
    canvas.drawBitmap(bitmap, rect, rectF, paint);
    
    return bitmap;
}
```

##### 4.1.2 原理
> Clip + Region : 通过裁剪画布区域实现指定形状的图形
![enter image description here](http://gavinliu.cn/images/2016.04.12%20-%20Android-%E5%AE%9E%E7%8E%B0%E5%9B%BE%E7%89%87%E5%9C%86%E8%A7%92%E6%98%BE%E7%A4%BA%E7%9A%84%E5%87%A0%E7%A7%8D%E6%96%B9%E5%BC%8F1.jpg)

- Region.Op.UNION：显示两层。
- Region.Op.XOR：去交集，显示两层。
- Region.Op.DIFFERENCE：去交集，显示下层。
- Region.Op.INTERSECT：取交集，显示上层。

#### 4.2 操作控件
##### 4.2.1 实现方式
> 控件绘制的时候，控制显示区域
> 优点：方便省事，适合各种图片框架

```
@Override
protected void onDraw(Canvas canvas) 
{
    int saveCount = canvas.getSaveCount();
    canvas.save();
    super.onDraw(canvas);
    
    mPaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.DST_IN));
    canvas.drawRoundRect(rectF, radius, radius, mPaint);
    
    canvas.restoreToCount(saveCount);
}
```

##### 4.2.2 实现原理
> Xfermodes : 使用Xfermode 两图相交方式
![enter image description here](http://gavinliu.cn/images/2016.04.12%20-%20Android-%E5%AE%9E%E7%8E%B0%E5%9B%BE%E7%89%87%E5%9C%86%E8%A7%92%E6%98%BE%E7%A4%BA%E7%9A%84%E5%87%A0%E7%A7%8D%E6%96%B9%E5%BC%8F2.jpg)

PorterDuff.Mode.SRC_IN：取交集，显示上层。
PorterDuff.Mode.DST_IN：取交集，显示下层。

#### 4.3 使用BitmapShader着色器
##### 4.3.1 实现方式
> 本质上这中方法其实是画圆，但是渲染采用了我们的图片
> 优点: 内存消耗最少. 还可实现镜面效果

```
int radius = src.getWidth() / 2;
BitmapShader bitmapShader = new BitmapShader(src, Shader.TileMode.REPEAT,
                Shader.TileMode.REPEAT);
Bitmap dest = Bitmap.createBitmap(src.getWidth(), src.getHeight(), Bitmap.Config.ARGB_8888);
Canvas c = new Canvas(dest);
Paint paint = new Paint();
paint.setAntiAlias(true);
paint.setShader(bitmapShader);
c.drawCircle(radius,radius, radius, paint);
```

##### 4.3.2 实现原理
> 本质上这中方法其实是画圆，但是渲染采用了我们的图片

#### 参考
- [Android - 实现图片圆角显示的几种方式](http://gavinliu.cn/2016/04/12/Android-%E5%AE%9E%E7%8E%B0%E5%9B%BE%E7%89%87%E5%9C%86%E8%A7%92%E6%98%BE%E7%A4%BA%E7%9A%84%E5%87%A0%E7%A7%8D%E6%96%B9%E5%BC%8F/)
- [在android中画圆形图片的几种办法](http://blog.csdn.net/mummyding/article/details/47347331)
