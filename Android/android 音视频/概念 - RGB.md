### 转自
[音视频基础知识---像素格式RGB](https://blog.csdn.net/adolph_lu/article/details/89706136)

### RGB概述
RGB是red,green, blue的简写，也就是红绿蓝三种颜色。他们是三原色，通过不同的比例相加，以产生多种多样的色光。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_rgb.jpg)

### RGB格式
一般来说，RGB在计算机中的表示主要分为两大类，一种是索引形式，一种是像素形式：

#### 索引格式：

- 索引格式是计算机早期的一种格式，它的优点比较节省空间，缺点是表现的色彩有限，目前格式基本被抛弃了，不再被使用，这里只做简单介绍。
- 索引格式中的bit存储的并非是实际的R,G, B值，而是对应点的像素在调色板中的索引。
- 调色板，可以简单理解为通过编号映射到颜色的一张二维表。如01索引，表示红色。采用索引格式的RGB，红色的像素对应存储的值便是索引01。就像指针一样，存储的是值的地址，而不是真正的值。

##### RGB1
每个像素用1个bit表示，可表示的颜色范围为双色，即黑和白。1个bit只能表示0，1两种值。需要调色板，不过调色板只包含两种颜色。

##### RGB4
每个像素用4个bit表示，4个bit所能够表示的索引范围是0-15，共16个。也就是可以表示16种颜色。即调色板中包含16中颜色。

##### RGB8
每个像素用8个bit表示。8个bit所能够表示的索引范围是0-255，共256个。也就是可以表示256中颜色。即调色板中包含256中颜色。

#### 像素格式：

RGB像素格式中的bit存储的是每一个像素点的R,G,B值

##### RGB565

一个像素用16个bit = 2个字节表示 ，R=5 G=6 B=5

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_rgb_565.jpg)

    R = color & 0xF800; //获取高字节的5个bit
 
    G = color & 0x07E0; //获取中间6个bit 
 
    B = color & 0x001F; //获取低字节5个bit
 

##### RGB555

一个像素用16个bit = 2个字节，但是最高位不用，R=5 G=5 B=5

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_rgb_555.jpg)

    R = color & 0x7C00; //获取高字节的5个bit 
 
    G = color & 0x03E0; //获取中间5个bit 
 
    B = color & 0x001F; //获取低字节5个bit
 

##### RGB24

一个像素用24个bit = 3个字节来表示，R=8 G=8 B=8

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_rgb_24.jpg)
 
    R = color & 0x0000FF00; 
 
    G = color & 0x00FF0000; 
 
    B = color & 0xFF000000;
 

##### RGB32

一个像素用32个bit = 4个字节 来表示，R=8 G=8 B=8，存储顺序为B, G, R,最后8个字节保留。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/android_media_rgb_32.jpg)

    R = color & 0x0000FF00; 
 
    G = color & 0x00FF0000; 
 
    B = color & 0xFF000000; 
 
    A = color & 0x000000FF;

#### Android平台下的几个常用RGB格式
Bitmap.Config.ALPHA_8

每个像素用8比特位表示，占1个字节，只有透明度，没有颜色。

Bitmap.Config.RGB_565

每个像素用16比特位表示，占2个字节，RGB分量分别使用5位、6位、5位，见上图。

Bitmap.Config.ARGB_4444

每个像素用16比特位表示，占2个字节，由4个4位组成，ARGB分量都是4位。

Bitmap.Config.ARGB_8888

每个像素用32比特位表示，占4个字节，由4个8位组成，ARGB分量都是8位。

> 注意：java默认使用大端字节序，c/c++默认使用小端字节序，android平台下Bitmap.config.ARGB_8888的Bitmap默认是大端字节序，当需要把这个图片内存数据给小端语言使用的时候，就需要把大端字节序转换为小端字节序。例如：java层的ARGB_565传递给jni层使用时，需要把java层的ARGB_565的内存数据转换为BGRA565。
