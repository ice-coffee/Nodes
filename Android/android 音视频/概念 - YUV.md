### 转自
[音视频基础知识---像素格式YUV](https://blog.csdn.net/adolph_lu/article/details/89917763)

### 待参考
[YUV和RGB格式分析](https://silencewt.github.io/2015/04/29/YUV%E5%92%8CRGB%E6%A0%BC%E5%BC%8F%E5%88%86%E6%9E%90/)

### YUV
YUV格式，与我们熟知的RGB类似，YUV也是一种颜色编码方法，主要用于电视系统以及模拟视频领域，它将亮度信息（Y）与色彩信息（UV）分离，没有UV信息一样可以显示完整的图像，只不过是黑白的。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_yuv.jpg)

### YUV概述
YUV，是一种颜色编码方法。常使用在各个影像处理组件中。 YUV在对照片或影片编码时，考虑到人类的感知能力，允许降低色度的带宽。

YUV，分为三个分量：

- Y表示明亮度（Luminance或Luma），也就是灰度值；
- U(Cb)表示色度（Chrominance）
- V(Cr)表示浓度（Chroma）

通常UV一起描述影像色彩和饱和度，用于指定像素的颜色。

对于 YUV 图像来说，并不是每个像素点都需要包含了 Y、U、V 三个分量，根据不同的采样格式，可以每个 Y 分量都对应自己的 UV 分量，也可以几个 Y 分量共用 UV 分量。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_yuv_p.jpg)

### YUV采样格式

下图中，实心圆表示 Y，空心圆表示 UV。

#### YUV444 采样

`YUV444` 意味着每4个像素里的数据有4个Y、4个U、4个V ，Y、U、V 三个分量的采样比例相同。因此在生成的图像里，每个像素的三个分量信息完整，都是 8 bit，也就是一个字节。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_yuv_444.jpg)

```
图像像素数据: Y0U0V0 Y1U1V1 Y2U2V2 Y3U3V3 
采样的码流: Y0 U0 V0 Y1 U1 V1 Y2 U2 V2 Y3 U3 V3 
Y分量的大小： w*h 
U分量的大小： w*h 
V分量的大小： w*h
```
    
通过YUV444采样的图像大小和RGB颜色模型的图像大小是一样的。

一张 1280 * 720 大小的图片，在 YUV 4:4:4 采样时的大小为：

```
(1280*720*8 + 1280*720*8 + 1280*720*8)/8/1024/1024 = 2.64 MB
```
    
#### YUV422 采样

`YUV422` 意味着每4个像素里面有4个Y、2个U、2个V，每采样一个像素点，都会采样其 Y 分量，而 U、V 分量就会间隔一个采集一个，Y 分量和 UV 分量按照 2 : 1 的比例采样。如果水平方向有8个像素点，那么就采样8 个 Y 分量，4 个 UV 分量。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_yuv_422.jpg)

```
图像像素数据: Y0U0V0 Y1U1V1 Y2U2V2 Y3U3V3 
采样的码流: Y0 U0 Y1 V1 Y2 U2 Y3 V3
Y分量的大小： w*h 
U分量的大小： w*h/2 
V分量的大小： w*h/2
```
    
一张 1280 * 720 大小的图片，在 YUV 4:2:2 采样时的大小为：

```
(1280*720*8 + (1280*720)/2*8 + (1280*720)/2*8)/8/1024/1024 = 1.76 MB
```
通过与YUV444采样进行比较可以算出，YUV 422 采样的图像比YUV444采样图像节省了三分之一的存储空间，在传输时占用的带宽也会减少。

#### YUV420 采样

`YUV420`，并不是指只采样 U 分量而不采样 V 分量。而是指，其中，每采样一个像素点，都会采样其 Y 分量，而 U、V 分量就会间隔一行按照 2 : 1 进行采样。比如，第一行扫描时，YU 按照 2 : 1 的方式采样，那么第二行扫描时，YV 分量按照 2:1 的方式采样。对于每个色度分量来说，它的水平方向和竖直方向的采样和 Y 分量相比都是 2:1 。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_yuv_420.jpg)

```
图像像素数据： [Y0 U0 V0]、[Y1 U1 V1]、 [Y2 U2 V2]、 [Y3 U3 V3] 
             [Y5 U5 V5]、[Y6 U6 V6]、 [Y7 U7 V7] 、[Y8 U8 V8]
采样的码流： Y0 U0 Y1 Y2 U2 Y3 
           Y5 V5 Y6 Y7 V7 Y8 
为什么叫4：2：0，意思是每4个像素中有4个Y，2个U，0个V，而下一行的四个像素中有4个Y，0个U，2个V
Y分量的大小： w*h 
U分量的大小： w*h/4 
V分量的大小： w*h/4
```
    
一张 1280 * 720 大小的图片，在 YUV 4:2:0 采样时的大小为：

```
(1280*720*8 + (1280*720)/4*8 + (1280*720)/4*8)/8/1024/1024 = 1.32 MB
```
可以看到 YUV 420 采样的图像比 RGB 模型图像节省了一半的存储空间，因此它也是比较主流的采样方式。

### YUV存储格式
YUV存储格式有两大类：planar 和 packed

- `planar`：平面格式，先连续存储所有像素点的Y，紧接着存储所有像素点的U，然后是所有像素点的V；将几个分量分开存，比如YUV420中，data[0]专门存Y，data[1]专门存U，data[2]专门存V。
- `packed`：打包格式，每个像素点的Y,U,V是连续交错存储的，所有数据都存在data[0]中。

根据采样方式和存储格式的不同，就有了多种 YUV 格式。这些格式主要是基于 YUV 4:2:2 和 YUV 4:2:0 采样。

#### 常见的基于 YUV 4:2:2 采样的格式

* YUYV
* UYUV
* YUV422P

**`YUYV`**：

YUYV 格式是采用打包格式进行存储的，指每个像素点都采用 Y 分量，但是每隔一个像素采样它的 UV 分量，排列顺序如下：

```
Y0 UO Y1 V0 Y2 U1 Y3 V1
```
    
Y0 和 Y1 公用 U0 V0 分量，Y2 和 Y3 公用 U1 V1 分量

**`UYVY`**：

UYVY 格式是采用打包格式进行存储，它的顺序和 YUYV 相反，先采用 U 分量再采样 Y 分量，排列顺序如下：

```
U0 Y0 V0 Y1 U1 Y2 V1 Y3
```
    
**`YUV422P`**：

YUV 422P 格式，又叫做 I422，采用的是平面格式进行存储，先存储所有的 Y 分量，再存储所有的 U 分量，再存储所有的 V 分量。

```
Y0 Y1 Y2 Y3 U0 U1 V0 V1
```
    
#### 常见的基于 YUV 4:2:0 采样的格式

header 1 |YUV420采样 | YUV420采样
- --|---|---
YUV420P | YV12 | YU12
YUV420SP（semi-Planar二维平面） | NV12 | NV21

YUV 420P 和 YUV 420SP 都是基于 Planar 平面模式 进行存储的，先存储所有的 Y 分量后， YUV420P 类型就会先存储所有的 U 分量或者 V 分量，而 YUV420SP 则是按照 UV 或者 VU 的交替顺序进行存储了，具体查看看下图：

**`YUV420P`**：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_yuv_420p.jpg)

**`YUV420SP`**：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_yuv_420sp.jpg)

**`YV12`**：

YV12，采用的是平面格式进行存储，先存 Y 分量，再存 V 分量，最后U分量

```
Y0 Y1 Y2 Y3 Y4 Y5 Y6 Y7 
V0 
U0
```
    
**`YU12`**：

YU12，采用的是平面格式进行存储，先存 Y 分量，再存 U分量，最后V分量

```
Y0 Y1 Y2 Y3 Y4 Y5 Y6 Y7 
U0 
V0
```
    
**`NV12 (ios常用)`**：

NV12，采用的是平面格式进行存储，再 UV 进行交替存储

```
Y0 Y1 Y2 Y3 Y4 Y5 Y6 Y7 
U0 V0
```
    
**`NV21(android常用)`**：

NV21，采用的是平面格式进行存储，再 VU 进行交替存储

```
Y0 Y1 Y2 Y3 Y4 Y5 Y6 Y7 
V0 U0
```
 
### YUV 和 RGB转换
