### Bitmap 内存占用计算
从资源文件夹下加载图片资源：
```
width * height * (inTargetDensity / inDensity) * 单位像素大小
```

其他途径：
```
width * height * 单位像素大小
```

### `Bitmap` 格式
不同图片格式每单位像素的大小：

* `Bitmap.Config.RGB_565`：两个字节
* `Bitmap.Config.ARGB_4444`：两个字节
* `Bitmap.Config.ARGB_8888`：四个字节

### `inBitmap`
[图片加载\<第六篇\>：图片优化之inBitmap](https://www.jianshu.com/p/45fbef7a58ba)

`inBitmap` 变量是在 `Android 3.0+` 版本加入到系统源码当中，也就意味着当你的app版本低于3.0的时候，只能使用 `bitmap.recycle()` 进行 `Bitmap` 的回收操作；在 `Android 3.0+` 以上根据系统版本的不同，使用 `inBitmap` 的规则也不相同，具体区分如下：

* `4.4` 之前：只能够重用相同大小的 `Bitmap` 内存区域。简单而言，被重用的 `Bitmap` 需要与新的 `Bitmap` 规格完全一致，否则不能重用。
* `4.4` 之后：系统不再限制旧 `Bitmap` 与新 `Bitmap` 的大小，只要保证旧 `Bitmap` 的大小是大于等于新 `Bitmap` 大小即可。

除上述规则之外，旧 `Bitmap` 必须是 `mutable` 的，这点也很好理解，如果一个 `Bitmap` 不支持修改，那么其内存自然也重用不了，代码如下：

```
BitmapFactory.Options options = new BitmapFactory.Options();
options.inMutable = true;//如果为true， 那么该bitmap缓存区可以被修改，否则不可被修改
```

### getByteCount() 和 getAllocationByteCount()的区别

[Android Bitmap 到底占了多少内存](https://www.jianshu.com/p/4a0b070d56af)

* `getByteCount()`：占用内存；
* `getAllocationByteCount()`：可用内存；

> 当 `Bitmap` 未复用时两者结果相等。
