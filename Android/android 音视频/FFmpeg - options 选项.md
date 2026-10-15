### Main Option

#### -i
后跟输入文件url地址

#### -y
不需要询问直接覆盖输出文件

#### -c[:stream_specifier] codec (input/output,per-stream)
#### -codec[:stream_specifier] codec (input/output,per-stream)
为一个或多个流选择编码器(在输出文件之前使用)或解码器(在输入文件之前使用)。codec是解码器/编码器或特殊值副本(仅输出)的名称，用于指示流不需要重新编码。

#### -t
当用作输入选项(在-i之前)时，限制从输入文件读取数据的时间。

当作为输出选项使用时(在输出url之前)，在输出持续时间达到持续时间之后停止写入输出。

#### copy
"-c:v copy"告诉FFmpeg将视频的比特流复制到输出。例如，您的AVI视频有一个XviD视频位流，您可以将其复制到MP4容器中，而无需重新编码视频。这在本质上给了你同样的质量，因为在视频比特流中什么也不会改变。

"-c:a copy"复制音频流

#### preset
[FFmpeg preset comparison x264 2019; Encode speed and file size](https://write.corbpie.com/ffmpeg-preset-comparison-x264-2019-encode-speed-and-file-size/)

FFmpeg_preset是媒体编码所要经过的速度值。在较慢的频谱范围内，您会在牺牲时间的同时获得更高的质量，更快的速度获得更大的文件大小。
下图显示不同值输出文件的大小：
![image](https://cdn.write.corbpie.com/wp-content/uploads/2019/01/ffmpeg-comparison-x264-output-size-chart-700x494.png)

下图显示不同值输出文件的速度：
![image](https://cdn.write.corbpie.com/wp-content/uploads/2019/01/ffmpeg-comparison-x264-encode-time-chart-700x481.png)

### Video Options - 视频选项

#### -aspect[:stream_specifier] aspect (output,per-stream)
设置按方面指定的视频显示宽高比。

#### -vcodec
设置视频编解码器。是"-codec:v"的别名。

### Audio Options - 音频选项

#### -acodec
设置音频编解码器。是"-codec:a"的别名。
