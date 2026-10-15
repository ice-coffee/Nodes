## 2018年 Android 小知识

@(android 基础知识)

### 1. Serializable与Parcelable的区别
[Serializable与Parcelable的区别](https://juejin.im/post/5a24fd8151882531ea651c37)
区别
- 两者最大的区别在于存储媒介的不同，Serializable 使用 I/O 读写存储在硬盘上，而 Parcelable 是直接 在内存中读写。很明显，内存的读写速度通常大于 IO 读写，所以在 Android 中传递数据优先选择 Parcelable。

选择
- Parcelable的性能比Serializable好，在内存开销方面较小，所以在内存间数据传输时推荐使用Parcelable，如activity间传输数据，而Serializable可将数据持久化方便保存，所以在需要保存或网络传输数据时选择Serializable，因为android不同版本Parcelable可能不同，所以不推荐使用Parcelable进行数据持久化

### 2. SharedPrefrence 的 apply() 和       commit() 的区别

区别
- commit() 是直接同步地提交到硬件磁盘，因此，多个并发的采用 commit() 做提交的时候，它们会等待正在处理的 commit() 保存到磁盘后再进行操作，从而降低了效率。而 apply() 只是原子的提交到内容，后面再调用 apply() 的函数进行异步操作。
- apply() 方法不会有任何失败的提示。

选择
- 大多数情况下，我们都是在同一个进程中，这时候的 SharedPrefrence 都是单实例，一般不会出现并发冲突，如果对提交的结果不关心的话，我们非常建议用 apply() ，当然需要确保操作成功且有后续操作的话，还是需要用 commit() 的。

### 4. DiffUtil

### 5. 资源压缩`shrinkResources`

### 6. model library  引用 aar

### 7. 修改状态栏颜色和状态栏文字颜色

### 8. ViewCompat 实现向下兼容

### 9. Android 8.0 图标适配

### 10. Android 8.0 WorkManager

### 11. Android UI 适配 WKView

### 12. StateListDrawable

### 13. Canvas
Canvas.translate(float dx, float dy);
 [Android Canvas绘图详解（图文）](http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2012/1212/703.html)

### 14. optJSONObject / optJSONArray
opt 和 get 的优势在于结果为`null`会直接返回`null`而不

### 15. Fragment startActivityForActivity();

### 16. [android获取设备唯一标示](https://cloud.tencent.com/developer/article/1031880)

### 17. [RxJava2--操作符](https://blog.csdn.net/shangmingchao/article/details/73502564)

### 18. Sugar

### 19. Notification Android 8.0

### 20. Android下设置文字大小用sp还是dp
- 当修改系统字体大小时，字体大小以dp为单位时，大小不变；
- 当修改系统字体大小时，字体大小以sp为单位时，大小跟随变化；
