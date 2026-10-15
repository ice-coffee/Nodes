[toc]

### 关联地址
[深入理解控件（ViewRoot）系统](https://wizardforcel.gitbooks.io/deepin-android-vol3/content/6.html)

[ Android LayoutInflater原理分析，带你一步步深入了解View(一)](http://blog.csdn.net/guolin_blog/article/details/12921889)

[你真的了解Android ViewGroup的draw和onDraw的调用时机吗](https://www.zybuluo.com/ltlovezh/note/903385)

[自定义控件其实很简单1/6](http://blog.csdn.net/aigestudio/article/details/41316141)

* 为什么只能在主线程修改UI
* 为什么 performTraversals() 中先预测量控件树尺寸再测量 Window 尺寸，再根据 window 尺寸决定最终控件树尺寸。
* Display 是什么

WMS
* mWindowSession：用于在ViewRootImpl中和WMS进行通信
* mWindow：接收来自WMS的回调
* mWindowAttributes：窗口对应的 LayoutParams
* mDisplay：提供显示器大小和密度信息

输入事件
* mFallbackEventHandler
* mInputChannel
* mInputEventReceiver

控件树相关
* mView：控件树根
* mAttachInfo：存储控件树中的信息
* mSurface：屏幕缓冲区句柄

线程安全
* mHandler：保证主线程操作
* mChoreographer：mChoreographer处理消息时具有VSYNC特性，因此它主要用于处理与重绘相关的操作
* mThread：创建 ViewRootImpl的线程，在ViewRootImpl处理来自控件树的请求时（如请求重新布局，请求重绘，改变焦点等），会检查发起请求的thread与这个mThread是否相同。

窗口布局相关
* mWinFrame：描述了当前窗口的位置和尺寸，由 WindowManager ，会被多个线程访问
* mPendingContentInsets：窗口内容区域
* mPendingVisibleInsets：窗口可见区域


### LayoutInflater
> 用于解析layout文件。

#### 获取实例

```java
LayoutInflater layoutInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);  
```
还有一个更简单的方式

```java
LayoutInflater layoutInflater = LayoutInflater.from(context);  
```
其实只是把第一种方式包装了一下，并没有什么区别。

#### 使用

```java
/**
 * @param resource      要加载的资源文件ID
 * @param root          可作为生成视图的父视图
 * @param attachToRoot  是否将root做为生成的视图的父视图
 */
inflate(int resource, ViewGroup root, boolean attachToRoot);  
```
`inflate()` 方法有几种重载方法，可以视情况使用。

这里比较难以理解的是第三个参数，先看下面的源码（精简版）：

```java
public View inflate(XmlPullParser parser, @Nullable ViewGroup root, boolean attachToRoot) {
    synchronized (mConstructorArgs) {
        // Temp is the root view that was found in the xml
        final View temp = createViewFromTag(root, name, inflaterContext, attrs);

        ViewGroup.LayoutParams params = null;

        if (root != null) {
            // Create layout params that match root, if supplied
            params = root.generateLayoutParams(attrs);
            if (!attachToRoot) {
                // Set the layout params for temp if we are not
                // attaching. (If we are, we use addView, below)
                temp.setLayoutParams(params);
            }
        }

        // We are supposed to attach all the views we found (int temp)
        // to root. Do that now.
        if (root != null && attachToRoot) {
            root.addView(temp, params);
        }

        // Decide whether to return the root that was passed in or the
        // top view found in xml.
        if (root == null || !attachToRoot) {
            result = temp;
        }

        return result;
    }
}
```
当 `root != null` 时，`attachToRoot` 为 `true` 或 `false` 唯一的区别就是 `是否直接添加到root父View中`，可以想到这会影响比如 `Fragment`、`RecyclerView` 的使用。拿 `Fragment` 来说，当将一个 `Fragment` 添加到 `Activity` 时会检查对应的 `View` 是否有父级，这样我们就知道在解析 `Fragment` 布局时`attachToRoot` 参数只能传 `false` 的原因了，`RecyclerView` 也一样。

总结如下：
* `root == null`：`attachToRoot` 将失去作用，返回一个 `LayoutParam = null` 的 `View`，并且不会添加到 `Root View` 中。
* `root != null，attachToRoot == true`：返回一个 `LayoutParam != null` 的 `View`，并且会添加到 `Root View` 中。
* `root != null，attachToRoot == false`：返回一个 `LayoutParam != null` 的 `View`，并且不会添加到 `Root View` 中。

那当 `root == null` 时，得到的就是一个没有添加 `LayoutParams` 的 `View`，当调用 `addView()` 时会赋予 `View` 一个默认的 `LayoutParams`，如下：

`ViewGroup`：
```java
public void addView(View child, int index) {
    LayoutParams params = child.getLayoutParams();
    if (params == null) {
        params = generateDefaultLayoutParams();
    }
    addView(child, index, params);
}
```

`LinearLayout`：
```java
protected LayoutParams generateDefaultLayoutParams() {
    if (mOrientation == HORIZONTAL) {
        return new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
    } else if (mOrientation == VERTICAL) {
        return new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
    }
    return null;
}
```

`RelativeLayout`：
```java
protected ViewGroup.LayoutParams generateDefaultLayoutParams() {
    return new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
}
```

但这只会影响到 `layout_width、layout_height` 属性，其他属性不受影响。

### LayoutParams


### onMeasure()
> onMeasure()方法顾名思义就是用于测量视图的大小的。
> View的measure()方法接收两个参数，widthMeasureSpec和heightMeasureSpec，这两个值分别用于确定视图的宽度和高度的规格和大小。

MeasureSpec的值由specSize和specMode共同组成的，其中specSize记录的是大小，specMode记录的是规格。specMode一共有三种类型，如下所示：
1. EXACTLY
表示父视图希望子视图的大小应该是精确尺寸，当我们将控件的`layout_width`或`layout_height`指定为具体数值时如`andorid:layout_width="50dip"`，或者为MATCH_PARENT是，都是控件大小已经确定的情况，都是精确尺寸。

2. AT_MOST
表示最大尺寸，当控件的`layout_width`或`layout_height`指定为`wrap_content`时，控件大小一般随着控件的子空间或内容进行变化，此时控件尺寸只要不超过父控件允许的最大尺寸即可。因此，此时的mode是AT_MOST，size给出了父控件允许的最大尺寸。

3. UNSPECIFIED
父容器不限定大小，子View想多大就多大。这种情况比较少见，不太会用到。

### onLayout()
> View的layout()方法来给视图进行布局的，也就是确定视图的位置

`View中的onLayout()方法就是一个空方法`，因为onLayout()过程是为了确定视图在布局中所在的位置，而这个操作应该是由布局来完成的，即父视图决定子视图的显示位置。`ViewGroup中的onLayout()方法是一个抽象方法`，这就意味着所有ViewGroup的子类都必须重写这个方法.

```java
@(android View)Override  
protected abstract void onLayout(boolean changed, int l, int t, int r, int b);  
```

onLayout接受的四个int形参数分别代表子视图距离父布局的margin值.

### onDraw()
> 在View的draw()方法中执行具体的绘制工作

```java
@Override  
protected void onDraw(Canvas canvas)
```

绘制流程如下 :
1. 这一步的作用是对视图的背景进行绘制
2. !!!
3. 对视图的内容进行绘制
4. 当前视图的所有子视图进行绘制
5. !!!
6. 对视图的滚动条进行绘制

### 扩展

#### getWidth 和 getMeasure 的区别
[Android开发之getMeasuredWidth和getWidth区别从源码分析](http://blog.csdn.net/dmk877/article/details/49734869/)
- getMeasuredWidth方法获得的值是setMeasuredDimension方法设置的值，它的值在measure方法运行后就会确定。
- getWidth方法获得是layout方法中传递的四个参数中的mRight-mLeft，它的值是在layout方法运行后确定的。
- 一般情况下在onLayout方法中使用getMeasuredWidth方法，而在除onLayout方法之外的地方用getWidth方法。

#### resolveSize() / resolveSizeAndState()

```java
public static int resolveSize(int size, int measureSpec) {
     int result = size;
     int specMode = MeasureSpec.getMode(measureSpec);
     int specSize =  MeasureSpec.getSize(measureSpec);
     switch (specMode) {
     case MeasureSpec.UNSPECIFIED:
         result = size;
         break;
     case MeasureSpec.AT_MOST:
         result = Math.min(size, specSize);
         break;
     case MeasureSpec.EXACTLY:
         result = specSize;
         break;
     }
     return result;
 }
```

#### 当自定义View 继承ViewGroup时, onDraw() 不被调用。
ViewGroup默认情况下，出于性能考虑，会被设置成WILL_NOT_DROW，这样，ondraw就不会被执行了。
如果我们想重写一个viewgroup的ondraw方法，有两种方法：

1. 构造函数中，给viewgroup设置一个颜色。

2. 构造函数中，调用setWillNotDraw（false），去掉其WILL_NOT_DRAW flag。

在viewgroup初始化的时候，它调用了一个私有方法：initViewGroup，它里面会有一句setFlags（WILLL_NOT_DRAW,DRAW_MASK）;相当于调用了setWillNotDraw（true），所以说，对于ViewGroup，他就认为是透明的了，如果我们想要重写onDraw，就要调用setWillNotDraw（false）。

#### TypedArray.recycle()
[TypedArray 为什么需要调用recycle()](http://blog.csdn.net/Monicabg/article/details/45014327)
> 回收 TypedArray,用于后续调用时可复用之。当调用该方法后，不能再操作该变量。

#### requestLayout、invalidate与postInvalidate
[Android View 深度分析requestLayout、invalidate与postInvalidate](http://blog.csdn.net/a553181867/article/details/51583060)

> 一般来说，如果View确定自身不再适合当前区域，比如说它的LayoutParams发生了改变，需要父布局对其进行重新测量、布局、绘制这三个流程，往往使用requestLayout。而invalidate则是刷新当前View，使当前View进行重绘，不会进行测量、布局流程，因此如果View只需要重绘而不需要测量，布局的时候，使用invalidate方法往往比requestLayout方法更高效。最后，感谢你们的阅读，希望这篇文章给你们带来帮助。
