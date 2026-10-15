[toc]

> 注意：由于 `Android - 14` 后默认开启了硬件加速效果，所以如果发现某些功能无效，可尝试关闭其硬件加速。相关硬件加速知识推荐在 Android 文档中食用。

### 关联地址
[Github - 示例地址](https://github.com/ice-coffee/ViewSample)
[硬件加速](https://developer.android.com/guide/topics/graphics/hardware-accel?hl=zh-cn)
[GcsSloop - 安卓自定义View进阶-画笔基础(Paint)](https://www.gcssloop.com/customview/paint-base)
> 这篇博客讲解了Paint（画笔）中基础的概念和使用，可以学到包括Cap、Joink、Style和各种PathEffect的使用。

[为什么 Android 上 Canvas 画出的图形不够平滑？](http://gold.xitu.io/entry/5739909a79df5400601cfc71)
> 这篇博客讲解了通过“先在 Bitmap 上绘制再将 Bitmap 绘制到 Canvas 上”这种方式绘制图形有锯齿的原因，可以学到如何在Bitmap中绘制平滑图形。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603614871349.jpg)

### 内部类

类型 | 简介
- --|---
Paint.Cap | 指定了描边线和路径(Path)的开始和结束显示效果。
Paint.Join | 指定线条和曲线段在描边路径上连接的处理。
Paint.Style | 指定绘制的图元是否被填充，描边或两者均有(以相同的颜色)。
Paint.FontMetrics | 描述给定字体大小文本的各种度量。
Paint.Align | 文本对齐方式。

### 常量

类型 | 简介
- --|---
Paint.ANTI_ALIAS_FLAG | 开启抗锯齿功能的标记。
Paint.DITHER_FLAG | 在绘制时启用抖动的标志。
Paint.FILTER_BITMAP_FLAG | 绘制标志，在缩放的位图上启用双线性采样。

#### Paint.Style 画笔填充方式

Style | 简介
- --|---
Paint.Style.FILL | 填充内容，也是画笔的默认模式。
Paint.Style.STROKE | 描边，只绘制图形轮廓。
Paint.Style.FILL_AND_STROKE | 描边+填充，同时绘制轮廓和填充内容。

![Image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/20201023150734.png)

#### Paint.Cap 线段开始和结束时的效果

Cap | 简介
- --|---
Paint.Cap.BUTT | 无线帽，也是默认类型。
Paint.Cap.SQUARE | 以线条宽度为大小，在开头和结尾分别添加半个正方形。
Paint.Cap.ROUND | 以线条宽度为直径，在开头和结尾分别添加一个半圆。

![Image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/20201023151115.png)

#### Paint.Join 线段链接处的显示方式

Join | 简介
- --|---
Paint.Join.MITER | 尖角 (默认模式)
Paint.Join.BEVEL | 平角
Paint.Join.ROUND | 圆角

### 常用方法

#### setAntiAlias 抗锯齿
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603681997472.jpg)

抗锯齿大家都懂的，开启后绘制的图形边缘会更加光滑。
这篇文章中讲解了一些关于 `antialias` 的原理性东西：
[为什么 Android 上 Canvas 画出的图形不够平滑？](http://gold.xitu.io/entry/5739909a79df5400601cfc71)

简单来说，绘制图形的边缘都是一种色彩的透明度渐变处理，在不设置 `setAntiAlias` 的的情况下透明度渐变会很快，打比方可能只需要三个像素块儿，而设置了 `setAntiAlias` 可能就需要六个像素块了，这样给人眼的感觉边缘会更加柔和更加光滑。

当然更高精度的处理也会消耗更多的资源`^_^`。

#### setDither 防抖动
设置 `setDither` 会影响在处理颜色的下采样时使用高于设备本身的精度。白话说就是颜色之间的过渡会更加柔和平稳。效果如下：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603683134694.jpg)

和抗锯齿大致一样的道理，更高精度的处理也会消耗更多的资源`^_^`。

#### setColor 设置画笔颜色
以下几个就不讲了吧，地球人都明白 `^_^`。

#### setStrokeWidth 设置画笔宽度

#### setFakeBoldText 设置文字粗体

#### setUnderlineText 设置下划线

#### setStrikeThruText 设置删除线

#### setPathEffect 修改 path 绘制效果
`PathEffect` 在绘制之前修改几何路径，它可以实现划线，自定义填充效果和自定义笔触效果。PathEffect 虽然名字看起来是和 Path 相关的，但实际上它的效果可以作用于 Canvas 的各种绘制，例如 drawLine， drawRect，drawPath 等。

> 注意：Android 对 setPathEffect 支持版本最低是 `28` 呦！

PathEffect | 简介
- --|---
CornerPathEffect | 圆角效果，将尖角替换为圆角。
DashPathEffect | 虚线效果，用于各种虚线效果。
PathDashPathEffect | Path 虚线效果，虚线中的间隔使用 Path 代替。
DiscretePathEffect | 让路径分段随机偏移。
SumPathEffect | 两个 PathEffect 效果组合，同时绘制两种效果。
ComposePathEffect | 两个 PathEffect 效果叠加，先使用效果1，之后使用效果2。

```
// 设置效果PathEffect
paint.setPathEffect(effect);

// 取消PathEffect
paint.setPathEffect(null);
```
##### CornerPathEffect 圆角效果
CornerPathEffect 可以将线段之间的任何锐角替换为指定半径的圆角(适用于 STROKE 或 FILL 样式)。
```
/**
 * CornerPathEffect 可以将线段之间的任何锐角替换为指定半径的圆角(适用于 STROKE 或 FILL 样式)。
 * 
 * @param radius 为圆角半径大小，半径越大，path 越平滑。
 */
public CornerPathEffect(float radius)
```
>

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603442437898.jpg)

> 这里有两点需要注意：
> 1. 使用 `CornerPathEffect`，只可以实现圆角矩形效果，即使圆角足够大也不能绘制椭圆或圆形。
> 2. CornerPathEffect `仅`可以将线段之间的锐角替换为圆角，所以如果使用 `path.lineTo()` 绘制长方形会发现起始点还是锐角。

##### DashPathEffect 虚线效果
DashPathEffect 用于实现虚线效果。

```java
/**
 * 虚线绘制，仅支持 paint's style 为 STROKE 或 FILL_AND_STROKE。
 * @param intervals 必须为偶数，控制显示和隐藏的长度。
 * @param phase 绘制虚线时的偏移量。正值：自右向左偏移，负值：自左向右偏移。
 */
public DashPathEffect(float intervals[], float phase)
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603446237199.jpg)

> 注意：intervals[] 中是允许设置多组数据的，每两个为一组，第一个表示显示长度，第二个表示隐藏长度。

##### PathDashPathEffect path虚线效果
实现Path 虚线效果。

```java
/**
 * 使用 Path 图形 绘制虚线，仅支持 paint's style 为 STROKE 或 FILL_AND_STROKE。
 * @param shape Path 图形
 * @param advance 图形占据长度
 * @param phase 相位差
 * @param style 转角样式
 */
public PathDashPathEffect(Path shape, float advance, float phase, Style style)
```
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603448258853.jpg)

`PathDashPathEffect.Style`

`PathDashPathEffect` 的最后一个参数是 `PathDashPathEffect.Style`，这个参数用于处理 `Path` 图形在转角处的样式。

| Style | 简介 |
| --- | --- |
| TRANSLATE | 在转角处对图形平移。 |
| ROTATE | 在转角处对图形旋转。 |
| MORPH | 在转角处对图形变形。 |
	
> 测试发现，不管 paint's style 设置为何值，都正常绘制。

##### ComposePathEffect 合并两种 PathEffect
`ComposePathEffect` 合并两种效果，它会先应用一种效果后，再次叠加应用另一种效果，因此交换参数最终得到的效果是不同的。

```
/**
 * 构造一个 PathEffect, 其效果是首先应用 innerpe 再应用 outerpe (如: outer(inner(path)))。
 */
ComposePathEffect(PathEffect outerpe, PathEffect innerpe);
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603449497727.jpg)

##### DiscretePathEffect 使Path产生随机偏移效果（不常用 ^_^!）
DiscretePathEffect 可以让 Path 产生随机偏移效果。

```
/**
 * segmentLength: 分段长度
 * deviation: 偏移距离
 */
public DiscretePathEffect(float segmentLength, float deviation)
```

##### SumPathEffect 使用两种效果各绘制一遍（不常用 ^_^!）
SumPathEffect 用于合并两种效果，它相当于使用两种效果各绘制一遍。

```
/**
 * 使用两种效果各绘制一遍
 */
SumPathEffect(PathEffect first, PathEffect second)
```

#### getFillPath 获取 Path 预处理后图形的边界 Path
根据原始 `Path(src)` 获取预处理后的 `Path(dst)`。
```
/**
 * 根据原始Path(src)获取预处理后的Path(dst)
 */
public void getFillPath(Path src, Path dst)

```

用白话理解 `getFilePath()` 的用法就是：
```
paint.getFillPath(arcPath, dstPath)
```
得到通过 `paint` 绘制 `arcPath` 的图形的路径，将其保存在 `dstPath` 中。
这里图形的路径可以理解为图形边线。

示例如下：
```
val arcPath = Path()

arcPath.addArc(RectF(100f, 100f, 500f, 500f), 30f, 300f)

val paint = Paint()
paint.style = Paint.Style.STROKE
paint.strokeCap = Paint.Cap.ROUND
paint.strokeWidth = 100f

canvas!!.drawPath(arcPath, paint)
```

```
canvas.translate(0f, 500f)

//获取
val dstPath = Path()
paint.getFillPath(arcPath, dstPath)

paint.style = Paint.Style.STROKE
paint.strokeWidth = 2f
paint.isAntiAlias = true
canvas.drawPath(dstPath, paint)
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603451791640.jpg)

#### getFontMetrics 获取绘制字符的各种测量值
`FontMetrics` 是用于描述给定 `textSize` 和 `typeface` 的文字的各种测量值的。也就是说影响文字测量结果的影响因素只有两个，就是 `textSize` 和 `typeface`  这哥俩。

获取 `FontMetrics`：
```
paint.fontMetrics
```

`FontMetrics` 属性：
```
top
字符最高点到baseline的最大距离

ascent
字符最高点到baseline的推荐距离

bottom
字符最低点到baseline的最大距离

descent
字符最低点到baseline的推荐距离

leading
行间距，即前一行的descent与下一行的ascent之间的距离
```
测试打印输出如下：
```
top：-209.59999
ascent：-185.59999
bottom：54.2
descent：48.8
leading：0
```

> 注意：
> * `文字坐标原点` 和其他坐标原点位于左上角不同，文字绘制的坐标原点在左下角。
> * `fontMetrics` 的测量是以坐标原点为参照，且 Y 轴向下是正方向，所以`ascent`、`top` 是负值，`bottom`、`descent` 为正值，而 `leading` 不知道为啥总是为0 `^_^!`。

关于 `fontMetrics` 如下图：
> 从上到下依次为：`top`、`ascent`、`descent`、`bottom`

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1604041212899.jpg)

#### measureText 测量传入文字的宽度

```
/**
* 测量传入文字的宽度并返回
* @param text  测量文字不可为空
*/
public float measureText(String text)
```
```
/**
* 测量传入文字的宽度并返回
*
* @param text  测量文字不可为空
* @param start 开始测量的第一个字符的下标，按下标从0计量
* @param end   结束测量的最后一个字符的下标，所代表字符不参与测量
*/
public float measureText(String text, int start, int end)
```

根据 `measureText` 测量所得文字宽度绘制文字范围：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1604041980464.jpg)

#### getTextBounds 测量包含所有字符的最小矩形
```
/**
* 测量绘制文本的最小区域，并返回。
* 在边界内(由调用者分配)包含所有字符的最小矩形，隐含的原点在(0,0)处。
*
* @param text 要测量的文字
* @param start 开始测量的第一个字符的下标
* @param end 结束测量的最后一个字符的下标，所代表字符不参与测量
* @param bounds 测量结果赋值
*/
public void getTextBounds(String text, int start, int end, Rect bounds) 
```
`measureText` 虽然可以获取绘制字符的宽度，但结果并不精确。而通过 `getTextBounds` 不但可以获得精确的字符宽度还可以获取字符高度。下面是 `measureText` 和 `getTextBounds` 的对比：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1604042032956.jpg)

可以看到 `getTextBounds` 比 `measureText` 的结果更精确。

> 注意：由于绘制文字的坐标原点在左下角，所以 `bounds.top` 属性为负值。
字符宽度 = textRect.width() = bounds.right - bounds.left
字符高度 = textRect.height() = bounds.bottom - (-bounds.top)

#### setMaskFilter 设置遮罩滤镜
通过设置 MaskFilter 可以实现边缘模糊和浮雕效果。

##### BlurMaskFilter 实现边缘模糊效果

```
/**
* 创建一个模糊遮罩滤镜
*
* @param radius 模糊滤镜的半径，必须 > 0
* @param style  模糊类型
*/
public BlurMaskFilter(float radius, Blur style)
```

`Blur.Style`
| Style | 简介 |
| --- | --- |
| NORMOL | 模糊内部和外部的原始边界 |
| SOLID | 在边界内绘制实线，在边界外模糊 |
| OUTER | 在边界内不画任何东西，模糊外面 |
| INNER | 模糊内部边界，不绘制任何外部 |

效果如下：
NORMOL：左上
SOLID：右上
OUTER：左下
INNER：右下

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603528571717.jpg)

那这种模糊效果是如何产生的呢？
可能下面这幅图可以提供一些猜测。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603528624053.jpg)

第一幅图中 radius = 10, 而第二幅图中 radius = 100，产生的效果可以发现是对边界的像素进行多次绘制以及逐步透明化的处理来达到效果的。应该是这样 `^_^`

##### EmbossMaskFilter (已弃用)

#### setColorFilter 设置颜色滤镜
```
/**
* 设置或清除色彩过滤器
*/
public ColorFilter setColorFilter(ColorFilter filter) 
```

ColorFilter 有如下子类：

* BlendModeColorFilter：混合模式过滤器
* ColorMatrixColorFilter： 色彩矩阵过滤器
* LightingColorFilter：
* PorterDuffColorFilter：混合模式过滤器

##### ColorMatrixColorFilter 色彩滤镜
```
val colorMatrix = ColorMatrix()
val colorFilter = ColorMatrixColorFilter(colorMatrix)
paint.colorFilter = colorFilter
```

通过对 `ColorMatrix` 进行操作，得到各种滤镜效果。

##### LightingColorFilter 模拟灯光效果

#### BlendModeColorFilter 混合模式过滤器

#### PorterDuffColorFilter 混合模式过滤器
