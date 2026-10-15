### ripple
点触水波纹效果
`Android` 按钮点触时一般会有水波纹一样的效果，默认的水波纹效果通过 `android:background="?android:attr/selectableItemBackground` 设置。也可以在 `drawable` 文件中创建 `ripple` 文件自定义水波纹效果。如下：

```
<ripple xmlns:android="http://schemas.android.com/apk/res/android"
    android:color="@color/purple_600">
    <item android:id="@android:id/mask"
        android:drawable="@drawable/ic_android" />
    <item android:id="@android:id/background"
    android:drawable="@drawable/ic_android" />
</ripple>
```

创建 `ripple` 文件时 `<ripple android:color>` 是必设的，它表示水波纹颜色。

`ripple` 中可以有很多层这里列出了 `mask 蒙层` 和 `background 背景层` 两部分，在别的博文中基本能找到的就这两层了，还有别的用法欢迎交流 `^_^`。
    
`@android:id/background` 表示背景层。可以设为图片也可以设为色值。当 `ripple` 文件设为空间的 `background` 属性值时背景层就会显示出来让你用户看拿到。

`@android:id/mask` 表示蒙层，蒙层不会立即被用户看到而是在点按触发时水波纹先在 `mask` 层绘制再合并到其他层。如果不设置 `mask` 那么水波纹直接绘制在其它层。`mask` 层也可以看做是水波纹的显示范围，`mask` 可设为图片和色值，当 `mask` 设为图片时，水波纹范围在图片范围内绘制显示，设为颜色时经测试和不设置 `mask` 层效果相同。

如果 `ripple` 不设置任何层，如下：
```
<ripple android:color="#ffff0000" />
```

则 `ripple` 将绘制在视图层次结构中第一个可用的父背景之上。 在这种情况下，绘图区域可能会延伸到 `Drawable` 边界之外。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/drawable_ripple.gif)

### layer-list
