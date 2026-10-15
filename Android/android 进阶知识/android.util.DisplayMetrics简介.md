### android.util.DisplayMetrics简介
[toc]

[原文链接](http://blog.csdn.net/zhangqijie001/article/details/5894872)

> - Android 可设置为随着窗口大小调整缩放比例，但即便如此，手机程序设计人员还是必须知道手机屏幕的边界，以避免缩放造成的布局变形问题。
> - 手机的分辨率信息是手机的一项重要信息，很好的是，Android 已经提供DisplayMetircs 类可以很方便的获取分辨率。

下面简要介绍 DisplayMetics 类：Andorid.util 包下的DisplayMetrics 类提供了一种关于显示的通用信息，如显示大小，分辨率和字体。

#### 1. 获取DisplayMetrics信息

```
DisplayMetrics metrics = new DisplayMetrics();
getWindowManager().getDefaultDisplay().getMetrics(metrics);
```

#### 2. 常用属性
- density为显示的逻辑分辨率（文档中说了很多，看得不是很明白）;
- width及height就为屏幕分辨率（为绝对宽度与高度）;
- scaleDensity与density功能一致(文字缩放比例);
- xdpi及ydpi为准确物理像素.
