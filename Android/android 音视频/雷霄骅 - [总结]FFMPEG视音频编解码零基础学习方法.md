[官网](http://ffmpeg.org/)

[下载地址](http://ffmpeg.zeranoe.com/builds/)

[FFMpeg中文翻译](https://www.bookstack.cn/read/other-doc-cn-ffmpeg/README.md)

FFMpeg 可供下载的版本：
- Static：
- Shared：
- Dev：

#### Static
包含可执行文件。Static把相关的链接库编译到可执行文件中了。

- ffmpeg：用于转码的应用程序。
- ffplay：用于播放的应用程序。
- ffprobe：用于查看文件格式的应用程序。

#### Shared
和Static不同的是链接库放到了可执行之外，运行时到相应的链接库中调用功能。

#### Dev
Dev版本是用于开发的，里面包含了库文件xxx.lib以及头文件xxx.h，这个版本不包含可执行文件。

- libavdevice：读取电脑的多媒体设备的数据，或者输出数据到指定的多媒体设备上。
- libavutil是一个包含简化编程功能的库，其中包括随机数生成器，数据结构，数学代码，核心多媒体工具等更多东西。
- libavcodec是一个包含音频/视频解码器和编码器的库。
- libavformat是一个包含了多媒体格式的分离器和混流器的库。
- libavdevice是一个包含输入输出设备的库，用于捕捉和渲染很多来自常用的多媒体输入/输出软件框架的数据，包括Video4Linux，Video4Linux2，VfW和ALSA。
- libavfilter是一个包含媒体过滤器的库。AVFilter可以给视音频添加各种滤镜效果。可以给视频添加水印，给YUV数据加特效。
- libswscale是一个用于执行高度优化的图像缩放和颜色空间/像素格式转换操作的库。
- libswresample是一个用于执行高度优化的音频重采样，重新矩阵和取样格式转换操作的库。
