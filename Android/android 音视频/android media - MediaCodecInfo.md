提供有关设备上可用的给定媒体编解码器的信息。您可以通过查询MediaCodecList迭代所有可用的编解码器。例如，这里是如何找到一个编码器，支持给定的MIME类型:

```
private static MediaCodecInfo selectCodec(String mimeType) {
     int numCodecs = MediaCodecList.getCodecCount();
     for (int i = 0; i < numCodecs; i++) {
         MediaCodecInfo codecInfo = MediaCodecList.getCodecInfoAt(i);

         if (!codecInfo.isEncoder()) {
             continue;
         }

         String[] types = codecInfo.getSupportedTypes();
         for (int j = 0; j < types.length; j++) {
             if (types[j].equalsIgnoreCase(mimeType)) {
                 return codecInfo;
             }
         }
     }
     return null;
 }
```

#### AudioCapabilities
> 支持查询编解码器的音频功能的类。

#### CodecCapabilities
封装给定编解码器组件的功能。例如，它支持什么配置文件/级别组合，它能够提供哪些颜色空间的解码数据，以及一些特定于编码类型的功能标志。

您可以通过MediaCodecInfo#getCapabilitiesForType获得给定MediaCodecInfo对象的实例，传递MIME类型。

```
MediaCodecInfo.CodecCapabilities capabilities = mediaCodecInfo.getCapabilitiesForType(type);

MediaCodecInfo.VideoCapabilities videoCapabilities = capabilities.getVideoCapabilities();
```

#### CodecProfileLevel
> 封装可用于编解码器组件的配置文件。

==用法不明==

#### EncoderCapabilities
> A class that supports querying the encoding capabilities of a codec.

==用法不明==

#### VideoCapabilities
> 支持查询编解码器的视频功能的类。
