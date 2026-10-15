## View药店

@(android 控件药店)


[toc]

### 1. 如何获得View在屏幕中的位置
在android api中有这么一个方法
> public void getLocationOnScreen (int[] location)

官方给出的描述是

> Computes the coordinates of this view on the screen. The argument must be an array of two integers. After the method returns, the array contains the x and y location in that order.
> 计算这个view在屏幕上的坐标. 传递参数必须是一个包含两个int值的数组. 这个函数的返回值是x与y的值;

示例:
				

```
View view = findViewById(R.id.head_icon);
int[] locations1 = new int[2];
view.getLocationOnScreen(locations1);
int x1 = locations1[0];// 获取组件当前位置的横坐标
int y1 = locations1[1];// 获取组件当前位置的纵坐标
System.out.println("----------" + x1 + "---------" + y1);
```

### 2. 如何获得屏幕的大小
在android api13之后获取屏幕就不能使用`getHeight()/getWidth()`来获取屏幕的宽高属性了取而代之的是`getSize(Point point)`方法

示例:

```
Point point = new Point();
getWindowManager().getDefaultDisplay().getSize(point);

Toast.makeText(this, point.x + ":" + point.y, Toast.LENGTH_SHORT).show();
```
> 注意:使用getSize()方法须在AndroidManifest.xml文件中设置
```
<uses-sdk android:minSdkVersion = "13"/>
```

### 3. 如何在onCreate()中获取View的宽高
分析为什么在 Activity 的onCreate()方法中读取视图的尺寸会返回0值。
- 当onCreate()方法被调用时,会通过 LayoutInflater将XML 布局文件填充到 ContentView。填充过程只包括创建视图，却不包括设置其大小。那么，视图的大小是在何时指定的呢?Android 开发文档（见 13.2 节）的解释如下所示：“绘制布局由两个遍历过程组成：测量过程和布局过程。测量过程由measure(int, int) 方法完成，该方法从上到下遍历视图树。在递归遍历过程中，每个视图都会向下层传递尺寸和规格。当measure 方法遍历结束时，每个视图都保存了各自的尺寸信息。第二个过程由 layout(int, int, int, int) 方法完成，该方法也是由上而下遍历视图树，在遍历过程中，每个父视图通过测量过程的结果定位所有子视图的位置信息。”

> 结论如下：只有在整个布局绘制完毕后，视图才能得到自身的高和宽，这个过程发生在 onCreate() 方法之后，因此，在此之前调用 getHeight() 和 getWidth() 方法返回的结果都是 0。

解决方案:
1. 在onWindowFocusChanged方法中调用 
这个方法表示window焦点的变化，当这个方法被调用时view已经初始化完毕了，自然也就能获取到view的坐标了，缺点：但是这个方法会在焦点发生变化的时候调用，也就会存在多次调用，这点需要注意。 
2. 利用view.post(runnable) 
这样会把runnable放在一个队列中，view初始化完成的时候就会进行处理，示例代码如下：

```
protected void onCreate(Bundle savedInstanceState)
{
	super.onCreate(savedInstanceState);
	setContentView(R.layout.main);
	View view = findViewById(R.id.main_my_view);
	view.post(new Runnable() 
	{
		@Override
		public void run() 
		{
			Log.d(TAG, "view has width: "+view.getWidth() +" and height: "+view.getHeight());
		}
	});
}
```

### 4. View.post (Runnable action)
> post方法中传递的参数Runnable是运行在UI线程中的,在这个Runnable的run()方法里是可以修改UI控件的

TextView也有用来设置"`全文`"和"`收起`"

```
/**
 * 根据回答内容的行数控制是否需要"全文"按钮
 */
tv_content.post(new Runnable()
{
	@Override
	public void run() 
	{
		if (holder.tv_content.getLineCount() > 3) 
		{
			holder.tv_content.setMaxLines(3);
		} 
		else 
		{
			holder.tv_content.setMaxLines(Integer.MAX_VALUE);
		}
	}
});
```
