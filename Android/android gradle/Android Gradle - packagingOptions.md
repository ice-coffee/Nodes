
[TOC]

`packagingOptions` 常见的设置项有`exclude`、`pickFirst`、`doNotStrip`、`merge`。

### exclude
过滤掉某些文件或者目录不添加到APK中，作用于APK，不能过滤aar和jar中的内容。

比如：
```gradle
packagingOptions {
    exclude 'META-INF/**'
    exclude 'lib/arm64-v8a/libmediaplayer.so'
}
```

### pickFirst
匹配到多个相同文件，只提取第一个。只作用于APK，不能过滤aar和jar中的文件。

比如：
```gradle
packagingOptions {
    pickFirst "lib/armeabi-v7a/libaaa.so"
    pickFirst "lib/armeabi-v7a/libbbb.so" 
}
```

### doNotStrip
可以设置某些动态库不被优化压缩。

比如：
```gradle
packagingOptions{
    doNotStrip "*/armeabi/*.so"
    doNotStrip "*/armeabi-v7a/*.so"
}
```

### merge
将匹配的文件都添加到APK中，和pickFirst有些相反，会合并所有文件。

比如：
```gradle
packagingOptions {
    merge '**/LICENSE.txt'
    merge '**/NOTICE.txt'
}
```

### 参考
[link](https://blog.csdn.net/liuzehn/article/details/103587571)
