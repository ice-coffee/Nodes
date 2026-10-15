### 类介绍
MediaMetadataRetriever类提供了用于从输入媒体文件检索帧和元数据的统一接口。

### 属性介绍

- METADATA_KEY_ALBUM ：检索数据源的专辑标题信息的元数据键。
- METADATA_KEY_ALBUMARTIST： 检索与数据源相关的表演者或艺术家的信息的元数据键。
- METADATA_KEY_ARTIST：检索有关数据源的艺术家的信息的元数据键。
- METADATA_KEY_AUTHOR：检索有关数据源作者的信息的元数据键
- METADATA_KEY_BITRATE：此键检索平均比特率（以比特/秒），如果可用的话。
- METADATA_KEY_CD_TRACK_NUMBER：元数据关键字，用于检索描述原始数据记录中音频数据源的顺序的数字字符串。
- METADATA_KEY_COMPILATION：检索音乐专辑编辑状态的元数据键
- METADATA_KEY_COMPOSER：检索有关数据源的作曲家的信息的元数据键
- METADATA_KEY_DATE：检索或创建数据源时的日期的元数据键
- METADATA_KEY_DISC_NUMBER：用于检索描述音频数据源的集合的哪一部分的数字字符串的元数据键
- METADATA_KEY_DURATION：检索数据源回放持续时间的元数据键
 - METADATA_KEY_GENRE:检索数据源的内容类型或类型的元数据键
- METADATA_KEY_HAS_AUDIO:如果存在此密钥，则媒体包含音频内容
- METADATA_KEY_HAS_VIDEO:如果存在此密钥，则媒体包含视频内容
- METADATA_KEY_LOCATION:此键检索位置信息，如果可用的话。该位置应根据ISO-6709标准，在MP4/3GP框“@ XYZ”下指定。例如，经度为90度和纬度为180度的位置将被检索为“-90＋180”。
- METADATA_KEY_MIMETYPE:检索数据源MIME类型的元数据键。一些示例MIME类型包括："video/mp4", "audio/mp4", "audio/amr-wb"
- METADATA_KEY_NUM_TRACKS:元数据键，用于检索数据源（如MP4或3GPP文件）中的音轨的数目，如音频、视频、文本。
- METADATA_KEY_TITLE:检索数据源标题的元数据键
- METADATA_KEY_VIDEO_HEIGHT:如果媒体包含视频，则该键检索其高度
- METADATA_KEY_VIDEO_ROTATION:此键检索视频旋转角度的程度，如果可用的话。视频旋转角度可以是0, 90, 180度，也可以是270度
- METADATA_KEY_VIDEO_WIDTH:如果媒体包含视频，则该密钥检索其宽度
- METADATA_KEY_WRITER:检索数据源的作者（如歌词作者）信息的元数据键
- METADATA_KEY_YEAR:检索创建或修改数据源的一年的元数据密钥
- OPTION_CLOSEST:此选项与getFrameAtTime（long，int）一起使用，以检索与最接近或给定时间的数据源相关联的帧（不一定是关键帧）
- OPTION_CLOSEST_SYNC:（时间）或给定时间的数据源相关联的同步（或密钥）帧。
- OPTION_NEXT_SYNC:此选项与getFrameAtTime（long，int）一起使用，以检索与数据源相关联的同步（或密钥）帧，该数据源位于或在给定的时间之后。
- OPTION_PREVIOUS_SYNC:此选项与getFrameAtTime（long，int）一起使用，以检索与数据源相关联的同步（或密钥）帧，该数据源正好位于给定时间之前或给定时间

### 简单使用
#### 获取视频宽、高、时长、旋转角度

```
MediaMetadataRetriever retr = new MediaMetadataRetriever();
retr.setDataSource();
String height = retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT);
String width = retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH);
String rotation = retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION);
retr.release();
```
> 注意：MediaMetadataRetriever 这个类无法灵活判断在不同方向上正确的宽高,
经过测试取两边长者为宽，短者为高。所以需要在旋转角度为90、270时对宽高进行处理。

```
if (videoRotation == 90 || videoRotation == 270) {
    if (videoHeight < videoWidth) {
        videoRealH = videoWidth;
        videoRealW = videoHeight;
    }
}
```

#### 获取视频帧

retr.getFrameAtTime(position * 1000 * 1000);

> 注意：这里的时间单位是微秒。
