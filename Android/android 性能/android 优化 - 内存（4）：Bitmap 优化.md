[Bitmap优化详谈](https://juejin.cn/post/6844903725081821198)

[android如何释放图片缓存](https://blog.csdn.net/lizhenmingdirk/article/details/46378905)

[初识Android Bitmap压缩原理](https://blog.csdn.net/TO_BE_RM/article/details/79859540)

### `Bitmap` 格式

* Bitmap.Config.RGB_565：两个字节
* Bitmap.Config.ARGB_4444：两个字节
* Bitmap.Config.ARGB_8888：四个字节

### 加载大小合适的图片

### 质量压缩
质量压缩的原理损失颜色精度，对于一个使用确定格式(ALPHA_8, RGB565，ARGB8888)的Bitmap，并不会减少其内存占用，因为内存占用=1/2/4 * 宽 * 高；但是保存成文件大小是会减小的，原因是需要表示的颜色少了。

颜色精度损失举例：0xFFFFFF→RGB每个单色低四位归零0xF0F0F0。假设一个图片对于颜色精度要求不高，只保存R G B各个通道的的高4位，那么颜色信息就能节省一半的空间占用。

### 采样率压缩
通过设置：

```
BitmapFactory.Options options =  new  BitmapFactory.Options(); 
options.inJustDecodeBounds =  true ;
```

通过 `BitmapFactory.decodeResource或者decodeFile` 解码图片时，将会返回空的 `Bitmap` 对象，这样可以避免 `Bitmap` 的内存分配， 但是它可以返回 `Bitmap` 的宽度、高度以及 `MimeType`。

然后根据宽高计算合适的缩放比例，再根据 `options` 解码图片，注意 `inJustDecodeBounds` 用完一定要恢复为 `false`：

```
options.inSampleSize = calculateInSampleSize(options, maxWidth, maxHeight);
options.inJustDecodeBounds = false;
Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length, options);
Log.i("yc压缩图片","压缩后大小"+bitmap.getByteCount());
return bitmap;
```

### 释放

### `Bitmap` 复用
