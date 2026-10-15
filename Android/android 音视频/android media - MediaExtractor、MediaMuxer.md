[Android 音视频开发(五)：使用 MediaExtractor 和 MediaMuxer API 解析和封装 mp4 文件](https://www.cnblogs.com/renhui/p/7474096.html)

一个音视频文件是由音频和视频组成的，我们可以通过MediaExtractor、MediaMuxer把音频或视频给单独抽取出来，抽取出来的音频和视频能单独播放； 

### MediaExtractor API介绍
MediaExtractor的作用是把音频和视频的数据进行分离。

主要API介绍：

- setDataSource(String path)：即可以设置本地文件又可以设置网络文件。
- getTrackCount()：得到源文件通道数。
- getTrackFormat(int index)：获取指定（index）的通道格式。
- getSampleTime()：返回当前帧的时间戳。 
- readSampleData(ByteBuffer byteBuf, int offset)：把指定通道中的数据按偏移量读取到ByteBuffer中。
- seekTo()：根据指定的模式，所有选择的轨道寻找接近要求的时间。通俗讲就是跳转。
- advance()：读取下一帧数据。
- release(): 读取结束后释放资源。

使用示例：

```
MediaExtractor extractor = new MediaExtractor();
//1.设置数据源
extractor.setDataSource(...);
//2.分离轨道
int numTracks =
extractor.getTrackCount();
for (int i = 0; i < numTracks; ++i) {
    MediaFormat format = extractor.getTrackFormat(i);
    String mime = format.getString(MediaFormat.KEY_MIME);
    if (weAreInterestedInThisTrack) {
        //3.选择轨道
        extractor.selectTrack(i);
    }
}
ByteBuffer inputBuffer = ByteBuffer.allocate(...)
//4.读取数据
while (extractor.readSampleData(inputBuffer, ...) >= 0) {
   int trackIndex = extractor.getSampleTrackIndex();
   long presentationTimeUs = extractor.getSampleTime();
   ...
   //5.下一帧
   extractor.advance();
}
//6.释放
extractor.release();
extractor = null;
```

### MediaMuxer API介绍
MediaMuxer的作用是生成音频或视频文件；还可以把音频与视频混合成一个音视频文件。缺点是，现在可以只支持一个audio track和一个video track，而唯一支持mp4出口。

相关API介绍：

- MediaMuxer(String path, int format)：path:输出文件的名称  format:输出文件的格式；当前只支持MP4格式；
- addTrack(MediaFormat format)：添加通道；我们更多的是使用MediaCodec.getOutpurForma()或Extractor.getTrackFormat(int index)来获取MediaFormat;也可以自己创建；
- start()：开始合成文件
writeSampleData(int trackIndex, ByteBuffer byteBuf, MediaCodec.BufferInfo bufferInfo)：把ByteBuffer中的数据写入到在构造器设置的文件中；
- stop()：停止合成文件
- release()：释放资源
 
使用示例：

```
MediaMuxer muxer = new MediaMuxer("temp.mp4", OutputFormat.MUXER_OUTPUT_MPEG_4);
//1.添加轨道
// More often, the MediaFormat will be retrieved from MediaCodec.getOutputFormat()
// or MediaExtractor.getTrackFormat().
MediaFormat audioFormat = new MediaFormat(...);
MediaFormat videoFormat = new MediaFormat(...);
int audioTrackIndex = muxer.addTrack(audioFormat);
int videoTrackIndex = muxer.addTrack(videoFormat);
ByteBuffer inputBuffer = ByteBuffer.allocate(bufferSize);
boolean finished = false;
BufferInfo bufferInfo = new BufferInfo();

muxer.start();
while(!finished) {
    // getInputBuffer() will fill the inputBuffer with one frame of encoded
    // sample from either MediaCodec or MediaExtractor, set isAudioSample to
    // true when the sample is audio data, set up all the fields of bufferInfo,
    // and return true if there are no more samples.
    finished = getInputBuffer(inputBuffer, isAudioSample, bufferInfo);
    if (!finished) {
        int currentTrackIndex = isAudioSample ? audioTrackIndex : videoTrackIndex;
        //2.读取数据
        muxer.writeSampleData(currentTrackIndex, inputBuffer, bufferInfo);
    }
};
//3.停止、释放
muxer.stop();
muxer.release();
```
### 注意
1. 调用addTrack()方法应在start()方法前.
2. 添加视频通道应该在编码器MediaCodec编码过程开始，dequeueOutputBuffer返回
==INFO_OUTPUT_FORMAT_CHANGED==状态时才调用(==这个不知道为什么要放到这里==)，如下所示：
```
int videoTrackIndex = -5;

int outputBufferIndex = mDecoder.dequeueOutputBuffer(info, TIMEOUT_USEC);

if (outputBufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
    MediaFormat newFormat = mEncoder.getOutputFormat();
    if (videoTrackIndex == -5) {
        videoTrackIndex = mMuxer.addTrack(newFormat);
        mMuxer.start();
    }
}
```
