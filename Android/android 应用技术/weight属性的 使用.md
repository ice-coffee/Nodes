## weight属性的 使用
在布局中实现居中显示是一个很常见的需求,一般我可以使用我们gravity或者centerInParent属性进行实现
但是如果需要居中显示的布局根据不同手机屏幕的大小能保持占据屏幕的一般那该怎么办呢?

大家都知道在LinearLayout布局中的控件都可以使用weight属性来设置控件占据父布局的比例,但是你真的知道怎么使用它吗?

其实在LinearLayout布局中android:weightSum 属性和android:layout_width 属性是配套使用的,示例如下:

```
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
	android:layout_width="fill_parent"
	android:layout_height="fill_parent"
	android:background="#FFFFFF"
	android:gravity="center"
	android:orientation="horizontal"
	android:weightSum="1">

	<Button
		android:layout_width="0dp"
		android:layout_height="wrap_content"
		android:layout_weight="0.5"
		android:text="Click me"/>
</LinearLayout>
```

> 在示例代码中, 指定LinearLayout 的 android:weightSum 属性值 为1, 表示其内部所有子视图的 weight 比例总和是 1。LinearLayout只 有 唯 一 一 个 子 视 图：Button 控 件. 指 定 Button 的android:layout_width 属性值为 0dp，因此需要根据 android:weight-Sum 属性决定 Button 的 width。指定 Button 的 android:layout_weight 属性值为 0.5，最终 Button 将占据 50% 的可用空间
