### 图片框架对比
[Picasso，Glide，Fresco对比分析](https://cloud.tencent.com/developer/article/1385853)

[Kotlin 新秀 Coil、Glide 和 Picasso 大比拼](https://juejin.cn/post/6844904182781050893#heading-13)

结论：
`Picasso`：最轻量，不支持 `gif`，包体积、内存的占用都较低，适合纯图片应用。
`Glide`：在使用中内存、速度的表现都很好，而且支持图片格式丰富（JPG、PNG、GIF、WEBP）。
`Fresco`：包体积大，项目入侵性强（必须使用它提供的SimpleDraweeView来代替ImageView）。
`Coil`：目前来说性能、内存等各个方面都还没有特别的突出。`kotlin` 开发，支持 `androidx lifecycle` 可以说是特点吧。它还有很长的一段路要走

转自：
[一道面试题：Glide 做了哪些优化?](https://mp.weixin.qq.com/s/zq9qqGnvOkfsPfXJVBalGA)
[Glide 这样用，更省内存！！！](https://segmentfault.com/a/1190000011423889)

### 缓存机制

* 内存缓存
    * 活动缓存：弱引用
    * Lru 缓存：`LruCache`
* 磁盘缓存：`DiskLruCache`
* `Bitmap` 复用池

#### 内存缓存

* 活动缓存：弱引用
* LRU 缓存：`LruCache`

#### 磁盘缓存

根据缓存策略，缓存图片原图或转换后的图片资源。

* `DiskCacheStrategy.NONE`：表示不缓存任何内容。
* `DiskCacheStrategy.RESOURCE`：在资源解码后将数据写入磁盘缓存，即经过缩放等转换后的图片资源。
* `DiskCacheStrategy.DATA`：在资源解码前将原始数据写入磁盘缓存。
* `DiskCacheStrategy.ALL`：使用 `DATA` 和 `RESOURCE` 缓存远程数据，仅使用 `RESOURCE` 来缓存本地数据。
* `DiskCacheStrategy.AUTOMATIC`：它会尝试对本地和远程图片使用最佳的策略。当你加载远程数据时， `AUTOMATIC` 策略仅会存储未被你的加载过程修改过的原始数据，因为下载远程数据相比调整磁盘上已经存在的数据要昂贵得多。对于本地数据，`AUTOMATIC` 策略则会仅存储变换过的缩略图，因为即使你需要再次生成另一个尺寸或类型的图片，取回原始数据也很容易。默认使用这种缓存策略。

### 内存优化
`Glide` 内存优化针对的是 `Bitmap`，所以内存优化也就是 `Bitmap` 优化。

采样率压缩：使用 `inSampleSize` 进行采样率压缩
质量压缩：使用 `Bitmap.compress` 进行质量压缩
图片格式：
缓存池：
内存缓存：
释放内存：监听 onLowMemory()、onTrimMemory()

> 注意：在 `Glide4.0` 之前，`Glide` 默认使用 `RGB565` 格式，比较省内存但是之后，默认格式已经变成了 `ARGB_8888` 格式了。

### 圆角图片原理
