> Android坐标系其实就是一个三维坐标，Z轴向上，X轴向右，Y轴向下。

### 转载及参考
[Android应用坐标系统全面详解](http://blog.csdn.net/yanbober/article/details/50419117)
[Android中滑屏初探 ---- scrollTo 以及 scrollBy方法使用说明](http://blog.csdn.net/qinjuning/article/details/7247126)

### Android 屏幕区域划分

常用区域的一些坐标或者度量方式:

```
//获取屏幕区域的宽高等尺寸获取
DisplayMetrics metrics = new DisplayMetrics();
getWindowManager().getDefaultDisplay().getMetrics(metrics);
int widthPixels = metrics.widthPixels;
int heightPixels = metrics.heightPixels;
```

```
//应用程序App区域宽高等尺寸获取
Rect rect = new Rect();
getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);
```

```
//获取状态栏高度
Rect rect= new Rect();
getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);
int statusBarHeight = rectangle.top;
```

```
//View布局区域宽高等尺寸获取
Rect rect = new Rect();  
getWindow().findViewById(Window.ID_ANDROID_CONTENT).getDrawingRect(rect);  
```

### Android View绝对相对坐标系
> 注意: 如下方法只有在`layout()`之后才有效

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603271054608.jpg)

这张图看着更清晰一点

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/1603271121681.jpg)

#### View的静态坐标方法
- getLeft()	：返回View自身左边到父布局左边的距离
- getTop()	：返回View自身顶边到父布局顶边的距离
- getRight()：返回View自身右边到父布局左边的距离
- getBottom()：返回View自身底边到父布局顶边的距离
- getTranslationX()	View左上角相对父View的X轴偏移量
- getTranslationY()	View左上角相对父View的Y轴偏移量
- getX()	：返回值为getLeft()+getTranslationX()，当setTranslationX()时getLeft()不变，getX()变。
- getY()	：返回值为getTop()+getTranslationY()，当setTranslationY()时getTop()不变，getY()变。

#### MotionEvent坐标方法	解释
- getX()	：	当前触摸事件距离当前View左边的距离
- getY()	：	当前触摸事件距离当前View顶边的距离
- getRawX()	：当前触摸事件距离整个屏幕左边的距离
- getRawY()	：当前触摸事件距离整个屏幕顶边的距离
- getPivotX() ：view旋转和缩放的时候的中心点
- getPivotY() ：view旋转和缩放的时候的中心点

#### View宽高方法
- getWidth()：layout后有效，返回值是mRight-mLeft，一般会参考measure的宽度（measure可能没用），但不是必须的。
- getHeight()：layout后有效，返回值是mBottom-mTop，一般会参考measure的高度（measure可能没用），但不是必须的。
- getMeasuredWidth()：返回measure过程得到的mMeasuredWidth值，供layout参考，或许没用。
- getMeasuredHeight()：	返回measure过程得到的mMeasuredHeight值，供layout参考，或许没用。

#### 获取View在屏幕中的位置

| View的方法|     上图View1结果 |   上图View2结果   |   结论描述   |
| :-------- | --------:| :------: | :------ |
| getLocalVisibleRect()|   (0, 0 - 410, 100)|  (0, 0 - 410, 470)|  获取View自身可见的坐标区域，坐标以自己的左上角为原点(0,0)，另一点为可见区域右下角相对自己(0,0)点的坐标，其实View2当前height为550，可见height为470。|
| getGlobalVisibleRect()|   (30, 100 - 440, 200)|  (30, 250 - 440, 720)|  获取View在屏幕绝对坐标系中的可视区域，坐标以屏幕左上角为原点(0,0)，另一个点为可见区域右下角相对屏幕原点(0,0)点的坐标。  |
| getLocationOnScreen()|   (30, 100)|  (30, 250)|  坐标是相对整个屏幕而言，Y坐标为View左上角到屏幕顶部的距离。|
| getLocationInWindow()|   (30, 100)|  (30, 250)  |  如果为普通Activity则Y坐标为View左上角到屏幕顶部（此时Window与屏幕一样大）；如果为对话框式的Activity则Y坐标为当前Dialog模式Activity的标题栏顶部到View左上角的距离。|

### Android View动画相关坐标系

### Android View滑动相关坐标系
> - 特别注意：View的scrollTo()和scrollBy()是用于滑动View中的内容，而不是改变View的位置；改变View在屏幕中的位置可以使用offsetLeftAndRight()和offsetTopAndBottom()方法，他会导致getLeft()等值改变。
> - scrollTo()和scrollBy()方法特别注意：如果你给一个ViewGroup调用scrollTo()方法滚动的是ViewGroup里面的内容，如果想滚动一个ViewGroup则再给他嵌套一个外层，滚动外层即可。

- offsetLeftAndRight(int offset)：水平方向挪动View，offset为正则x轴正向移动，移动的是整个View，getLeft()会变的，自定义View很有用。
- offsetTopAndBottom(int offset)：垂直方向挪动View，offset为正则y轴正向移动，移动的是整个View，getTop()会变的，自定义View很有用。
- scrollTo(int x, int y)：将View中内容（不是整个View）滑动到相应的位置，参考坐标原点为ParentView左上角，`x，y为正则向xy轴反方向移动`，反之同理。
- scrollBy(int x, int y)：在scrollTo()的基础上（当前位置）续滑动xy。
- setScrollX(int value)：实质为scrollTo()，只是只改变Y轴滑动。
- setScrollY(int value)：实质为scrollTo()，只是只改变X轴滑动。
- getScrollX()/getScrollY()：获取当前滑动位置偏移量。
