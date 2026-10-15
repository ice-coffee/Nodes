音视频的编解码流程大同小异，这里以视频编解码来重点展开。

简易流程如下：
```
//MediaExtractor
//MediaExtractor - 添加数据源 - setDataSource
//MediaExtractor - 选择视频轨道 - selectTrack

//MediaCodec - extractor.getTrackFormat
//MediaCodec - 配置解码器 - configure
//MediaCodec - start

//FileChannel
while(1){
    //MediaCodec - dequeueInputBuffer
    //MediaCodec - queueInputBuffer
    //MediaCodec - getInputBuffer
    //MediaExtractor - advance - 下一帧数据

    //MediaCodec - dequeueOutputBuffer
    //MediaCodec - getOutputBuffer
    //MediaCodec - releaseOutputBuffer
}

//release   
```
下面展开讲解一下

### 解码

在开始进行视频解码和编码操作之前需要先创建MediaExtractor 和 MediaMuxer 对象，分别用于提取媒体信息和合并媒体信息

新建MediaExtractor对象。
```
MediaExtractor extractor = new MediaExtractor();
```
选择要操作的轨道，音轨或视频轨道，我们这里是解码视频所以选择视频轨道。
```
extractor.setDataSource(inputPath);
int numTracks = extractor.getTrackCount();
for (int i = 0; i < numTracks; i++) {
    MediaFormat format = extractor.getTrackFormat(i);
    String mime = format.getString(MediaFormat.KEY_MIME);
    if(mime.startsWith("video/")) {
        extractor.selectTrack(i);
    }
}
```
新建MediaMuxer对象, 指定输出格式
```
MediaMuxer mediaMuxer = new MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
```
添加具有指定格式的轨道，轨道添加需要注意添加的位置可以参考这篇文章
```
mediaMuxer.addTrack(mediaFormat);
```

然后接下来初始化解码器
```
MediaCodecList codecList = new MediaCodecList(MediaCodecList.REGULAR_CODECS);
MediaCodec mDecoder = MediaCodec.createByCodecName(codecList.findDecoderForFormat(inputFormat));
```

配置解码器
```
configure (MediaFormat format, Surface surface, MediaCrypto crypto, int flags)
configure (MediaFormat format, Surface surface, int flags, MediaDescrambler descrambler)
```
假如不涉及加密和解密，这两个方法没什么区别，其中有几个共同的参数，来看下：
- format: 可以通过extractor.getTrackFormat(i)方法获取。
- surface：配置此参数说明指定要在其上呈现此解码器输出的内容。在处理原始视频数据时推荐配置surface来处理解码数据，效率更高。
- flags：MediaCodec.CONFIGURE_FLAG_ENCODE，标识配置解码器还是编码器。

配置完成后启动解码器

```
mDecoder.start();
```

开始循环解码

```
MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();
boolean decoderDone = false;

while (!decoderDone) {
    //返回可用的输入流缓冲区的索引，如果当前没有可用的输入缓冲区，则返回-1。
    int inputBufIndex = mDecoder.dequeueInputBuffer(TIMEOUT_USEC);
    if (inputBufIndex >= 0) {
        //获取输入缓冲区ByteBuffer
        ByteBuffer inputBuf = mDecoder.getInputBuffer(inputBufIndex);
        //检索当前的数据，并从给定偏移量开始将其存储在字节缓冲区中。
        int chunkSize = mExtractor.readSampleData(inputBuf, 0);
        if (chunkSize < 0) {
            //检索不到数据表明解码完成, 输入流入队end_of_stream标识
            mDecoder.queueInputBuffer(inputBufIndex, 0, 0, 0L, MediaCodec.BUFFER_FLAG_END_OF_STREAM);
            decoderDone = true;
        } else {
            //返回当前示例的显示时间(以微秒为单位)。
            long sampleTime = mExtractor.getSampleTime();
            //输入流入队,解码器解码
            mDecoder.queueInputBuffer(inputBufIndex, 0, chunkSize, sampleTime, 0);
            
            //读取下一帧数据
            mExtractor.advance();
        }
    }
}
```
获取只读输出流索引，释放缓冲区。若解码器配置了surface,传入doRender = true则显示到surface上
```
//解码器输出可用
boolean decoderOutputAvailable = !decoderDone;
while (decoderOutputAvailable) {
    if (outputBufferIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
        break;
    } else if (outputBufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
        MediaFormat newFormat = mDecoder.getOutputFormat();
    } else if (outputBufferIndex < 0) {
        
    } else {
        boolean doRender = true;
        //解码数据可用
        if (info.flags == MediaCodec.BUFFER_FLAG_END_OF_STREAM) {
            decoderDone = true;
            mDecoder.releaseOutputBuffer(outputBufferIndex, false);
            break;
        }
        //释放ByteBuffer缓冲区, 若解码器配置了surface,传入doRender = true则显示到surface上
        mDecoder.releaseOutputBuffer(outputBufferIndex, doRender);
        if (doRender) {
            boolean errorWait = false;
            try {
                mOutputSurface.awaitNewImage();
            } catch (Exception e) {
                errorWait = true;
            }
            if (!errorWait) {
                if (videoStartTimeUs == -1) {
                    videoStartTimeUs = info.presentationTimeUs;
                }
                mOutputSurface.drawImage(false);
                long presentationTimeNs = (info.presentationTimeUs - videoStartTimeUs) * 1000;
                if (mSpeed != null) {
                    presentationTimeNs /= mSpeed;
                }
                mInputSurface.setPresentationTime(presentationTimeNs);
                mInputSurface.swapBuffers();
                break;
            }
        }
    }
}
```

### 编码

由于解码时已经创建了MediaExtractor 和 MediaMuxer 对象这里就不讲了，然后直接初始化编码器也是使用google推荐的方式。

```
MediaFormat outputFormat = MediaFormat.createVideoFormat(mimeType, mResultWidth, mResultHeight);
outputFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
outputFormat.setInteger(MediaFormat.KEY_FRAME_RATE, frameRate);
//设置关键帧间隔
outputFormat.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, mIFrameInterval);
outputFormat.setInteger(MediaFormat.KEY_BIT_RATE, mBitrate);

MediaCodec mEecoder = MediaCodec.createByCodecName(codecList.findEncoderForFormat(outputFormat));
```

配置编码器
```
mEncoder.configure(outputFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
```

> 注意：这里使用的outputFormat 要使用MediaFormat.createVideoFormat方法创建，不然会报错'java.lang.IllegalArgumentException'原因不明。

配置完成后启动编码器

```
mEncoder.start();
```

然后就是读取输出流缓冲区中的数据，将数据写入新文件

```
while (true) {
    int outputBufferIndex = mEncoder.dequeueOutputBuffer(info, TIMEOUT_USEC);
            
    if (outputBufferIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
        continue;
    } else if (outputBufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
        MediaFormat newFormat = mEncoder.getOutputFormat();
        if (videoTrackIndex == -5) {
            videoTrackIndex = mMuxer.addTrack(newFormat);
            mMuxer.start();
            mMuxerStartLatch.countDown();
        }
    } else if (outputBufferIndex < 0) {
    } else {
        //编码数据可用
        ByteBuffer outputBuffer = mEncoder.getOutputBuffer(outputBufferIndex);
        if (info.flags == MediaCodec.BUFFER_FLAG_END_OF_STREAM && info.presentationTimeUs < 0) {
            info.presentationTimeUs = 0;
        }
        if (info.flags != MediaCodec.BUFFER_FLAG_CODEC_CONFIG) {
            lastVideoFrameTimeUs = info.presentationTimeUs;
        }
        mMuxer.writeSampleData(videoTrackIndex, outputBuffer, info);
        mEncoder.releaseOutputBuffer(outputBufferIndex, false);
        if (info.flags == MediaCodec.BUFFER_FLAG_END_OF_STREAM) {
            break;
        }
    }
}
```
> 注意：很重要的一点当mCodec.dequeueOutputBuffer 返回的是MediaCodec.INFO_OUTPUT_FORMAT_CHANGED时，说明编码参数格式已经生成（比如视频的码率，帧率，SPS/PPS帧信息等），需要把这些信息写入到mp4对应媒体轨道中（这里通过 addTrack 在子类中配置音视频对应的编码格式），之后才能开始将编码完成的数据，通过MediaMuxer写入到相应媒体通道中。
