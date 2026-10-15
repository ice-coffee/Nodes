[toc]

> 注意：由于 `Android - 14` 后默认开启了硬件加速效果，所以如果发现某些功能无效，可尝试关闭其硬件加速。相关硬件加速知识推荐在 Android 文档中食用。

### 关联地址
[Canvas类的最全面详解](https://blog.csdn.net/carson_ho/article/details/60598775)

《Canvas类的最全面详解》这篇博客已经很详细的讲述了如何在Canvas上绘制各种图形的方法，以下是记录比较重要或一些补充的知识点。

### Canvas 的创建 & 获取

```java
/**
 * 方法1:利用空构造方法直接创建对象
 */
Canvas canvas = new Canvas()；

/**
 * 方法2:通过传入装载画布Bitmap对象创建Canvas对象，Bitmap上存储所有绘制在Canvas的信息
 */
Canvas canvas = new Canvas(bitmap)

/**
 * 方法3:通过重写View.onDraw（）创建Canvas对象，在该方法里可以获得这个
 * view对应的Canvas对象
 */
@Override
protected void onDraw(Canvas canvas) {
    super.onDraw(canvas);
    //在这里获取Canvas对象
}

/**
 * 方法4:在SurfaceView里画图时创建Can
 * vas对象
 */
SurfaceView surfaceView = new SurfaceView(this);
// 从SurfaceView的surfaceHolder里锁定获取Canvas
SurfaceHolder surfaceHolder = surfaceView.getHolder();
//获取Canvas
Canvas c = surfaceHolder.lockCanvas();
        
// ...（进行Canvas操作）
// Canvas操作结束之后解锁并执行Canvas
surfaceHolder.unlockCanvasAndPost(c);
```
官方推荐方法4来创建并获取Canvas，原因：
- SurfaceView里有一条线程是专门用于画图，所以方法4的==画图性能最好，并适用于高质量的、刷新频率高的图形==。
- 方法3刷新频率低于方法4，但==系统花销小，节省资源==。

### 方法概览
以下绘制颜色和绘制基本图形都是 `canvas` 的基础功能，基本一看就懂，只列出来就不过多介绍了。

#### 绘制颜色
* drawColor
* drawRGB

#### 绘制基本图形
* drawPoint、drawPoinst：画点
* drawLine、drawLines：画线
* drawRect：绘制矩形
* drawRoundRect：绘制圆角矩形
* drawCircle：绘制圆形
* drawOval：绘制椭圆
* drawArc：绘制弧线

#### drawText 字符绘制

```java
/**
 * text:要绘制的字符
 * x：绘制原点x坐标
 * y：绘制原点y坐标
 * paint:用来做画的画笔
 */
public void drawText(String text, float x, float y, Paint paint)
```

注意: 绘制Text的坐标原点(X, Y)在左下角。

`自定义View - Paint` 中有更详细的介绍。

#### 绘制图片
* drawPicture：绘制矢量图
* drawBitmap：绘制位图

##### drawPicture 绘制矢量图
`Picture` 中存在一个 `PictureCanvas` 它是 `Canvas` 的子类，`Picture` 可以通过 `PictureCanvas` 记录绘制的图形，然后通过`Picture.draw(canvas)` 或 `Canvas.drawPicture(picture)` 将 `PictureCanvas` 保存的图形显示到目标 `Canvas`上。对于大多数绘制操作(例如文本、线条、矩形)，从 `Picture` 中绘制要比等效的API调用要快，因为图片在回放时不会产生任何方法调用开销。

使用如下：

```java
/**
 * 1. 创建Picture对象
 */
Picture picture = new Picture();
/**
 * 2. 开始录制, 返回新的 Canvas 画布
 */
Canvas pictureCanvas = picture.beginRecording(0, 0);
/**
 * 3. 在新的 Canvas 画布上绘制的图形会被记录, 但不会显示到屏幕上
 */
pictureCanvas.drawRect(rectF, paint);
/**
 * 4. 结束录制
 */
picture.endRecording();

/**
 * 5. 将存储在Picture的图形绘制到目标 Canvas 画布
 */
canvas.drawPicture(picture);
```

`beginRecording()` 开始录制时传入的宽高值并不会影响返回 `PictureCanvas` 的大小，`PictureCanvas` 的大小只和其上绘制的图形所占区域相关。

`Canvas.drawPicture(picture, dstRect)` 通过这种方式将 `picture` 中的内容绘制到目标 `dstRect` 中时，绘制内容会变形以适配 `dstRect` 的区域。

`Picture.draw(canvas)`，使用这种方式需保证在 `recording` 期间 `canvas` 状态的 `保存\释放` 达到平衡也就是 `save` 和 `restore` 调用的次数要一样多,不然会影响到目标 `canvas` 的状态。

> 注意：多次重复的绘制可以使用 `darwPicture` 来进行优化。可大幅度节约绘制资源。比如绘制大量重复的位图 (Bitmap)。

> 注意：在默认开启硬件加速的情况下，`drawPicture()` 最低支持的版本为 `Android 23` 。

##### drawBitmap 绘制位图

```java
// 方法1
public void drawBitmap (Bitmap bitmap, Matrix matrix, Paint paint)

// 方法2
public void drawBitmap (Bitmap bitmap, float left, float top, Paint paint)

// 方法3
public void drawBitmap (Bitmap bitmap, Rect src, Rect dst, Paint paint)

// 方法4
public void drawBitmap (Bitmap bitmap, Rect src, RectF dst, Paint paint)

```

- 方法1：根据 `Matrix` 绘制位图可对位图进行形变操作。
- 方法2：指定开始绘制位图左上角的坐标(距离坐标原点的距离)。绘制的位图不会被压缩。
```java
/**
 * @param left 距离原点 X 轴距离
 * @param top 距离原点 Y 轴距离
 */
public void drawBitmap (Bitmap bitmap, float left, float top, Paint paint)
```
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603698067027.jpg)

- 方法3：绘制位图的部分到目标区域
```java
/**
 * @param src 要绘制的位图的自身区域
 * @param dst 绘制位图的目标区域，位图会进行压缩\平移以填充区域。
 */
public void drawBitmap (Bitmap bitmap, Rect src, Rect dst, Paint paint)
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603698156820.jpg)

[Canvas类的最全面详解](https://blog.csdn.net/carson_ho/article/details/60598775)的作者在文中举了个栗子，可以通过一点点绘制位图更多的部分实现某些效果。

#### drawPath 绘制轨迹

#### Canvas 修改状态

##### translate 平移
```java
/**
 * @param dx 在 X 轴的移动距离
 * @param dy 在 Y 轴的移动距离
*/
public void translate(float dx, float dy)
```
##### rotate 旋转
```java
/**
 * @param degrees 旋转角度
 */
public void rotate(float degrees)
```
##### scale 缩放
```java
/**
 * @param sx 在 X 轴上缩放的倍数
 * @param sy 在 Y 轴上缩放的倍数
 * @param px 缩放的中心 X 轴坐标
 * @param py 缩放的中心 Y 轴坐标
 */
public final void scale(float sx, float sy, float px, float py)
```
##### skew 错切
```java
/**
 * @param sx 将画布在x方向上倾斜相应的角度，sx为倾斜角度的tan值
 * @param sy 将画布在y轴方向上倾斜相应的角度，sy为倾斜角度的tan值
 */
public void skew(float sx, float sy) {
```
> 注意：这里全是倾斜角度的 `tan` 值，比如我们打算在X轴方向上倾斜45度，tan45=1。

##### clip 剪裁
> 个人感觉剪裁并没有什么特殊的使用场景。希望有这方面经验的认知的小伙伴能交流一下`^_^`。

```java
// 裁剪路径
// 方法1
public boolean clipPath(@NonNull Path path)

// 裁剪矩形
// 方法1
public boolean clipRect(int left, int top, int right, int bottom)
// 方法2
public boolean clipRect(float left, float top, float right, float bottom)

// 裁剪区域
public boolean clipRegion(@NonNull Region region)
```

#### Canvas 状态保存、恢复
* canvas 状态：当前画布经过的一系列操作
* 状态栈：存放画布状态和图层的栈（后进先出）

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603701087557.jpg)

* canvas 画布：
> 1. 画布是由多个图层构成的；
> 2. 在画布上操作 = 在图层上操作；
> 3. 如无设置，绘制操作和画布操作是默认在默认图层上进行；
> 4. 在通常情况下，使用默认图层就可满足需求；若需要绘制复杂的内容（如地图），则需使用更多的图层；
> 5. 最终显示的结果 = 所有图层叠在一起的效果。 

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603703028826.jpg)

##### save 保存 `Canvas` 状态
```java
/**
 * 将当前 矩阵 和 clip 保存到状态栈中。
 * 随后可以正常调用 translate、scale、rotate、skew、concat或clipRect、clipPath，
 * 但是当调用 restore 时，这些调用会被遗忘，canvas 会恢复 save 之前的状态。在其上绘制的图形不会消失。
 *
 * @return 返回值可以通过 restoreToCount 指定恢复此次 save 保存的状态
 */
public int save()
```

##### restore、restoreToCount 恢复 `Canvas` 状态
```java
/**
 * 移除 `最近一次` save 调用后对 canvas 状态的操作，恢复 `最近一次` save 调用前的状态。
 * 状态栈中
 */
public void restore()
```
```java
/**
 * 移除 `某次` save 调用后对 canvas 状态的操作，恢复`某次` save 调用前的状态。参数不可为空。
 */
public void restoreToCount(int saveCount)
```

> 注意：对 `Canvas` 不管执行多少次 `save`、`restore`、`restoreToCount` 都需要保证，状态栈在最后刚刚好清空。

##### saveLayer 基于当前画布状态创建新的图层
```java
/**
 * 创建区域大小为 bounds 的新图层
 */
public int saveLayer(@Nullable RectF bounds, @Nullable Paint paint)
```
`saveLayer` 和 `save` 作用相似，有一点区别就是`saveLayer` 会为 `canvas` 创建一个新的透明图层。这个图层存在于屏幕之外，创建新图层后的绘制和画布状态操作都仅会影响新图层，只有在 `restore` 之后，才会将其绘制到上一个图层或者画布上。

> 注意：`saveLayer` 是非常耗费资源的操作，应谨慎使用。

Android 文档中对 `saveLayer` 的注释中有一句没看明白，英语好的小伙伴来帮帮忙吧 `^_^`。
```
Note: this method is very expensive, incurring more than double rendering cost for contained content. Avoid using this method when possible and instead use a hardware layer on a View to apply an xfermode, color filter, or alpha, as it will perform much better than this method.
```

#### 矩阵操作

* concat：叠加矩阵
* setMatrix：替换矩阵
