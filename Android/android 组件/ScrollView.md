## ScrollView

@(android 控件药店)


### 与`weight`不兼容问题
使用`android:fillViewport="true"`就可解决您的烦恼:

```
 <ScrollView 
        android:id="@+id/scrollView1"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
         android:fillViewport="true" >
```

### ScrollView默认位置不是顶部
#### 描述
Scrollview里面嵌套了一个listview ，这是开发中最寻常的一种布局，遇到的问题是：在这个Scrollview页面默认的起始位置不是最顶部，而是listview的底部。

#### 原因：
在Activity计算窗口的高度时，是在listview没有填充数据时候就完成的，由于ScrollView嵌套listview时没有指定高度，所以ScrollView就会按照layout中定义的默认高度计算。

因为listview获取了焦点。

找一个顶部view, 让它获取焦点
```
editByCopy.isFocusable = true
editByCopy.isFocusableInTouchMode = true
editByCopy.requestFocus()
```

### 参考
[Android问题：ScrollView默认位置不是最顶部最全解决方案](https://blog.csdn.net/jiaoyaning1210/article/details/51084246)
