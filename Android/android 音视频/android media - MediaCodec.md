
### 推荐参考链接
[MediaCodec 文档翻译](https://juejin.im/entry/5aa234f751882555712bf210)
[卢俊 - 音频数据的编解码](https://zhuanlan.zhihu.com/p/20706983)

### MediaCodec API
在学习[MadiaCodec](https://developer.android.com/reference/android/media/MediaCodec?hl=zh-cn)时最好的方式就是阅读google官方文档，网上也有很多翻译的博客搭配看事半功倍，这里主要是想记录一下我在使用MediaCodec进行编解码时遇到的一些疑问点。

#### MediaCodec 核心原理与简易编解码流程
首先看下图：
![image](https://img-blog.csdnimg.cn/20200807164222626.jpg)

这张图展示了MediaCodec的核心架构，MediaCodec架构上采用了2个缓冲区队列，异步处理编解码数据。图中 Client 和 Codec 分别代表 用户API调用 和 编解码器。

它表示的其实是解码或编码流程的其中一个流程，不要理解成左边是解码操作右边是编码操作。其实编码和解码的核心流程是一样的，一边开发者获取空的可用输入缓冲区，填充需要编码或解码的数据，将其发送给编解码器，由其进行编码或解码数据并将输入缓冲区数据清空，另一边，开发者请求输出缓冲区中已解码或编码后的数据并释放输出缓冲区。可以看到一些开源项目中经常使用两个 while（1）循环来进行上述操作，搭配项目代码看更容易加深理解。再展开详细讲解一下：
1. 从 input 缓冲区队列申请 empty buffer [dequeueInputBuffer]
2. 把需要编解码的数据拷贝到 empty buffer，然后放入 input 缓冲区队列 [queueInputBuffer]
3. 模块从 input 缓冲区队列取一帧数据进行编解码处理
4. 编解码处理结束后，MediaCodec 将原始数据 buffer 置为 empty 后放回 input 缓冲区队列，将编解码后的数据放入到 output 缓冲区队列
5. Client 从 output 缓冲区队列申请编解码后的 buffer [dequeueOutputBuffer]
6. Client 对编解码后的 buffer 进行渲染/播放
7. 渲染/播放完成后，Client 再将该 buffer 放回 output 缓冲区队列 [releaseOutputBuffer]

以上就是MediaCodec编解码媒体数据的简易流程了。其中还涉及到另外两个重要的角色，MediaExtractor（提取器）、MediaMuxer（复用器），它们充当了解码器的数据提供者和编码器的数据消费者的角色。具体用法可以参考其他博客。

#### MediaCodec 数据处理以及处理方式
MediaCodec主要对三种数据进行处理：==压缩数据==、==原始音频数据==和==原始视频数据==。
- 压缩数据存：储媒体格式文件中
- 原始音视频数据：将媒体格式文件中的压缩数据进行解压缩也就是解码处理后就得到了原始音视频数据。

MediaCodec 和三种数据的关系如下图：
![image](https://img-blog.csdnimg.cn/20200807165440892.jpg)

MediaCode处理数据有两种方式：==ByteBuffer(字节缓冲区)==、==Surface==，这两种方式都是作为传输数据的载体。在处理原始视频数据时推荐使用Surface，这样效率更高，效果更好，因为surface使用的更底层的视频数据，不会映射或者复制到ByteBuffer缓冲区。在使用surface作为输入源时，开发者不能访问到到原始视频数据，但是可以使用ImageReader来获取到原始未加密的视频数据。

关于如何使用Surface其中有两个关键方法：
- MediaCodec.configure：配置参数surface。
- MediaCodec.releaseOutputBuffer：指定参数render = true将缓冲区数据输出到surface中。

还有一点需要注意的是使用Surface需要配置颜色格式：

```java
MediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
```

官方文档中指出编解码器支持三种颜色格式，其中两种都可与Surface一起使用，但是我测试只有上面一种格式可用。

具体项目中使用Surface处理数据更加复杂，结合项目更易加深理解。

#### 编解码器创建方式
编解码器的创建方式有如下三种种：
- MediaCodec createDecoderByType (String mime)
- MediaCodec createEncoderByType (String mime)
- MediaCodec createByCodecName (String name)

google推荐使用第三种种方式，这种方式能用于注入特征，并且可以确保生成的编解码器可以处理给定的格式，具体代码如下：

```java
MediaCodecList codecList = new MediaCodecList(MediaCodecList.REGULAR_CODECS);
MediaCodec mDecoder = MediaCodec.createByCodecName(codecList.findDecoderForFormat(mediaFormat));
```
> 注意：虽然google推荐使用第三种方式，但是在处理4K视频时在某些手机中可能会 空指针 报错。

```java
//小米8 4K视频
{color-format=2130708361, i-frame-interval=1, mime=video/avc, width=2160, frame-rate=20, height=3840} - null

{color-format=2130708361, i-frame-interval=1, mime=video/avc, width=1080, frame-rate=20, height=1920} - OMX.qcom.video.encoder.avc
```
可以看到编解码器的选择和视频宽高也有关。

> 注意：在 Android 5.0以上使用时需调用
format.setString(MediaFormat.KEY_FRAME_RATE, null)清除格式中任何现有的帧速率设置。

但是这种方式有个问题就是无法确定MediaCodec是通过哪种方式编解码的。虽然我们可以通过MediaCodecList获得所有编解码器的名字来创建指定编解码器，但是也要通过MediaCodecInfo.CodecCapabilities.isFormatSupported()方法判断是否支持才行，这存一个==疑点==。

注入特征可以理解为是否支持某种功能或行为，可选如下：
- FEATURE_AdaptivePlayback：编解码器支持无缝分辨率变化。
- FEATURE_SecurePlayback：是否支持安全解密
- FEATURE_TunneledPlayback：支持隧道播放
- FEATURE_DynamicTimestamp：不懂
- FEATURE_FrameParsing：不懂
- FEATURE_MultipleFrames：不懂
- FEATURE_PartialFrame：支持部分帧排队
- FEATURE_IntraRefresh：支持内部刷新

以FEATURE_SecurePlayback为例，代码如下：

```java
//判断是否支持此特性
MediaCodecInfo.CodecCapabilities.isFeatureSupported(MediaCodecInfo.CodecCapabilities.FEATURE_SecurePlayback)
//打开或关闭此特性
MediaFormat.setFeatureEnabled(String feature, boolean enabled)
```
#### 加密编解码器
关于使用加密编解码器还有更多的知识点待开发。
这里找到一篇很好的博客：
[Android视频开发进阶(part6-安卓的DRM,视频版权保护)](https://www.jianshu.com/p/5a0fb2dedabf)
#### 特殊前缀设置信息
在google官方文档中有这么一句话，翻译过来是这么说的

> 在使用AAC audio， MPEG4, H.264， H.265 video格式的数据作为输入源解码的时候，需要指定一个特殊的前缀设置信息。

举两个需要设置特殊前缀信息的栗子：

```java
MediaFormat encodeFormat = MediaFormat.createAudioFormat(audioMimeType, sampleRate, channelCount);//参数对应-> mime type、采样率、声道数
encodeFormat.setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC);

//设置前缀信息
encodeFormat.setByteBuffer("csd-0", csd);
```

```java
//编码器那边会先发sps和pps来，头一帧就由sps和pps组成
byte[] spspps=mServer.readFrame();
if(spspps==null){
    return false;
}
//找到sps与pps的分隔处
int pos=0;
if(!((pos+3<spspps.length)&&(spspps[pos]==0&&spspps[pos+1]==0&&spspps[pos+2]==0&&spspps[pos+3]==1))){
    return false;
}else {
    //00 00 00 01开始标志后的一位
    pos=4;
}
while((pos+3<spspps.length)&&!(spspps[pos]==0&&spspps[pos+1]==0&&spspps[pos+2]==0&&spspps[pos+3]==1)){
    pos++;
}
if(pos+3>=spspps.length){
    return false;
}
mSps=Arrays.copyOfRange(spspps,0,pos);
mPps=Arrays.copyOfRange(spspps,pos,spspps.length);
MediaFormat format = MediaFormat.createVideoFormat(videoMimeType, mWidth, mHeight);
format.setByteBuffer("csd-0", ByteBuffer.wrap(mSps));
format.setByteBuffer("csd-1", ByteBuffer.wrap(mPps));
```

通过createAudioFormat方法新创建的MediaFormat需要设置前缀信息，而通过如下方式创建的MediaFormat不需要

```java
MediaExtractor extractor = new MediaExtractor();
extractor.setDataSource(path);
MediaForamt mediaFormat = extractor.getTrackFormat(mVideoIndex);
```

这里猜测是通过getTrackFormat()创建的MediaFormat对象自带前缀信息。
