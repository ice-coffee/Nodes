## 关于XML文件的使用

[toc]

### 1. 在使用XML文件制作选择器时

[原文链接](http://blog.csdn.net/u010885095/article/details/44346595)
```
<?xml version="1.0" encoding="utf-8"?>  
<selector xmlns:android="http://schemas.android.com/apk/res/android" >  
    <!-- 默认情况,item必须放在最后 -->  
      
    <!-- 非触摸模式下获得焦点并单击时的背景图片 -->  
    <item   
        android:state_focused="true"  
        android:state_pressed="true"  
        android:drawable="@drawable/ic_launcher"  
        />  
    <!-- 触摸模式下单击时的背景图片-->  
    <item   
        android:state_focused="false"  
        android:state_pressed="true"  
        android:drawable="@drawable/ic_launcher"  
        />  
    <!--选中时的图片背景-->  
    <item   
        android:state_selected="true"  
        android:drawable="@drawable/ic_launcher"  
        />  
    <!--获得焦点时的图片背景-->  
    <item   
        android:state_focused="true"  
        android:drawable="@drawable/ic_launcher"  
        />  
    <item   
        android:drawable="@drawable/button_bg_default"  
        />  
</selector>  
```
注意：

1. 代表默认情况的item必须放在最后不然会出现以下问题:

> This item is unreachable because a previous item (item #1) is a more general match than this one   
> 如果这样放置，会出现按钮一直是默认状态，而无法获得焦点的情况
