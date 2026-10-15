[toc]

### 概述
封装描述媒体数据格式（包括音频或视频）以及可选功能元数据的信息。

音视频共同键：
名称 | 描述
- --|---
KEY_MIME | 媒体格式类型
KEY_MAX_INPUT_SIZE | 可选，输入数据缓冲区的最大大小
KEY_BIT_RATE | 仅限编码器，所需的比特率，单位为比特/秒
KEY_DURATION | 时长

视频键：
名称 | 描述
- --|---
KEY_WIDTH | 宽	 
KEY_HEIGHT | 高	 
KEY_COLOR_FORMAT | 视频数据格式
KEY_FRAME_RATE | 帧率
KEY_I_FRAME_INTERVAL | 仅限编码器，关键帧之间的时间间隔。添加了浮动支持Build.VERSION_CODES.N_MR1

音频键： 
名称 | 描述
- --|---
KEY_CHANNEL_COUNT | 声道数
KEY_SAMPLE_RATE | 采样率
KEY_AAC_PROFILE | 只有编码器，可选，如果内容是AAC音频，指定所需的配置文件。

### Api 说明
`MediaFormat` 中除了媒体格式的的 `get/set` 函数之外，还有如下函数：

* `createVideoFormat(String mime, int width, int height)`：创建视频格式对象。
* `createAudioFormat(String mime, int sampleRate, int channelCount)`：创建音频格式对象。

通常情况我们会使用 `MediaExtractor.getTrackFormat(int index)` 来获取音视频的格式对象。

### KEY_MIME
![46edfd5e4b8584a7f4e2f0958434b3e7.png](<../../attachment/2E2E021A-06E5-4D0B-B042-C83C54BEDB99.png>)

![7599305e7039d44f57019d04fb6e98d4.png](<../../attachment/A2FA9FA6-1782-48C2-ABC3-3BC464509E7C.png>)

**`视频编解码格式及对应媒体格式：`**

| 编解码格式 | MIME 类型 | 容器格式 | 用途 | 
| --- | --- | --- | --- |
| H.264 (AVC) | video/avc | .mp4, .mkv, .avi | 流媒体、视频录制、视频会议 |
| H.265 (HEVC) | video/hevc | .mp4, .mkv  4K、8K | 视频流媒体和存储 |
| VP8 | video/x-vnd.on2.vp8 | .webm | WebRTC，HTML5 视频 |
| VP9 | video/x-vnd.on2.vp9 | .webm | 高分辨率视频流媒体，YouTube 视频 |
| MPEG-4 | video/mp4v-es | .mp4, .3gp | 移动设备的视频录制和播放 |

**`音频编解码格式及对应媒体格式：`**

| 编解码格式 | MIME 类型 | 容器格式 | 用途 |
| --- | --- | --- | --- |
| AAC | audio/mp4, audio/aac | .mp4, .m4a, .3gp | 流媒体、广播、音频文件 | 
| MP3 | audio/mpeg | .mp3    音频文件，流媒体 | 
| AMR | audio/3gpp, audio/amr | .amr, .3gp | 语音通话，录音 | 
| Opus | audio/opus | .opus | VoIP，WebRTC，音频流媒体 | 
| FLAC | audio/flac | .flac | 无损音频存储 | 
| Vorbis | audio/vorbis | .ogg | 开源音频文件，流媒体 | 

在用于视频处理和编辑的场景时通常还需要原始音视频数据，可以使用如下格式：
```java
public static final String MIMETYPE_VIDEO_RAW = "video/raw";
public static final String MIMETYPE_AUDIO_RAW = "audio/raw";
```

### KEY_COLOR_FORMAT
**解码**：在解码过程中表示输入数据个颜色格式。解码器将会根据指定的颜色格式来解析输入数据。

**编码**：在编码过程中表示输出数据的颜色格式。编码器将会根据指定的颜色格式来生成输出数据。

设置颜色格式时可以通过 `MediaCodeInfo.CodecCapabilities` 查询是否支持。

```java
public void supportColorFormat(MediaFormat mediaFormat, MediaCodec codec) {
    String mime = mediaFormat.getString(MediaFormat.KEY_MIME);
    MediaCodecInfo.CodecCapabilities caps = codec.getCodecInfo().getCapabilitiesForType(mime);
    for (int c : caps.colorFormats) {
        // 支持的颜色格式
    }
}
```

常见颜色格式有 `YUV`、`RGB`，在 `MediaFormat` 中定义了多种格式，下面是一些比较重要且常用的：

* `COLOR_FormatYUV420Flexible`：它是一种灵活的 `YUV420` 格式，它代表 COLOR_FormatYUV411Planar、COLOR_FormatYUV411PackedPlanar、COLOR_FormatYUV420Planar、COLOR_FormatYUV420PackedPlanar,COLOR_FormatYUV420SemiPlanar、COLOR_FormatYUV420PackedSemiPlanar 的一种。
* `COLOR_FormatSurface`：这个颜色格式使用 `Surface` 作为输入/输出，它通常用于硬件加速编码器或渲染器。在这种情况下，输入数据不是通过内存缓冲区传递，而是通过图形处理单元（GPU）直接传递给编码器或渲染器。这个格式在一些高级应用中得到了广泛支持。
* `COLOR_FormatRGBFlexible`：这个颜色格式使用RGB颜色空间，并且同样支持灵活的采样方式。这个格式通常用于一些专业应用，例如图像处理和视频游戏等。

一般认为（**不准**） `Android` 中对应的 `YUV` 格式如下：
* `COLOR_FormatYUV420Planar`（19)：`YV21` 格式
* `COLOR_FormatYUV420PackedPlanar`（20)：`YV12` 格式
* `COLOR_FormatYUV420SemiPlanar`(21)：`NV12` 格式
* `COLOR_FormatYUV420PackedSemiPlanar`(39)：`NV21` 格式

视频格式选择：
* `COLOR_FormatSurface` 适用于需要直接从 `Surface` 获取或输出图像数据的场景，主要用于高效的视频编码和解码。
* `COLOR_FormatYUV420Flexible` 适用于需要手动处理 YUV 数据的场景，提供灵活的访问和处理能力，适合自定义视频处理和特效应用。

> 注意：当使用编码器使用 `MediaCodec.createInputSurface()` 创建的 `Surface` 作为数据源时使用 `COLOR_FormatSurface` 格式。在测试项目 `VideoProcessor` 中编码器使用 `COLOR_FormatYUV420Flexible` 报错。

### 参考
[MediaFormat api详解](https://blog.csdn.net/xgxmwang/article/details/80882016)
[常见YUV格式和Android中的COLOR_FormatYUV420对应关系](https://blog.csdn.net/qq_34557284/article/details/90902363)
[Android_Media：支持的媒体格式](https://developer.android.com/media/platform/supported-formats?hl=zh-cn)
