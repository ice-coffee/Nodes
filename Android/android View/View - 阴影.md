转自：
[Android开发 View的阴影详解 ](https://www.cnblogs.com/guanxinjing/p/11151036.html)

`Google` 在 `Android5.0` 版本添加这阴影效果的支持。

### 功能Api

* 设置View的Z轴高度：`android:elevation="10dp" / setElevation()`; 
* 设置View的Z轴高度：`android:translationZ="10dp" / setTranslationZ()`。
* 设置View阴影轮廓范围的模式：`android:outlineProvider="" / setOutlineProvider()`;
* 设置View的阴影颜色：`android:outlineSpotShadowColor="#03A9F4" / setOutlineSpotShadowColor()`（请注意！此条属性必需在高于Android10版本包含10的版本才有效果）。
* 设置View的阴影光环颜色，但是基本看不到，非常迷惑的属性。 `android:outlineAmbientShadowColor="#03A9F4" / setOutlineAmbientShadowColor`（请注意！此条属性必需在高于Android10版本包含10的版本才有效果）。
* 设置View自定义形状的阴影 `setOutlineProvider(new ViewOutlineProvider())`。

### 注意事项

1. 请**开启硬件加速**功能 android:hardwareAccelerated="true" ，现在的设备一般是默认开启硬件加速的。但是如果你主动设置关闭会出现没有阴影效果的问题。
2. 请检查好自己的Android版本，必需在5.0以上。设置阴影颜色效果必需需要在10.0以上。
3. **阴影是绘制于父控件上的，所以控件与父控件的边界之间需有足够空间绘制出阴影才行**。
4. 如果未设置 android:outlineProvider="bounds" ，那么控件这个属性会默认为android:outlineProvider="background"， 这个时候View必须设置背景色，且不能为透明，否则会没有阴影。
5. 不能将elevation 或者 translationZ 的值设置的比整个View还大，这样会有阴影效果。但是阴影的渐进效果会被拉的很长很长，会看不清楚阴影效果，你会错认觉得没有阴影效果。

### android:elevation 与 android:translationZ
这两个属性都是设置View的Z轴高度，他们的关系是：
> 实际ViewZ轴高度 = elevation + translationZ

google为什么要这么别扭的弄出2个一样功能的实现来配置Z轴高度呢？这就是涉及到他们2个的区别：

* `elevation` 是View的默认值Z轴高度
* `translationZ` 是View的动态Z轴高度，什么是动态高度？ 就是假设你需要实现阴影动画，改变Z轴高度，你就应该使用此条属性。

### 示例
