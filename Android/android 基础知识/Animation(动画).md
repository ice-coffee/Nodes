## Animation(动画)
[toc]
### 1. 在 Canvas 上显示动画
> 由于动画相关的API有限,Android特提供了Canvas类满足直接向屏幕上绘图的需求;

示例代码如下:

MainActivity.java
```
public class MainActivity extends Activity 
{
	private DrawView mDrawView;
	
	@Override
	public void onCreate(Bundle savedInstanceState) 
	{
		super.onCreate(savedInstanceState);
		/*获取屏幕的宽和高*/
		Display display = getWindowManager().getDefaultDisplay();
		mDrawView = new DrawView(this);
		mDrawView.height = display.getHeight();
		mDrawView.width = display.getWidth();
		/* DrawView占据所有可用空间*/
		setContentView(mDrawView);
	}
}
```

> 通过 WindowManager 获取屏幕的宽和高，这些值用于限制 DrawView 的绘图范围。然后，将 DrawView 设置为Activity 的内容视图，表示 DrawView 会占据界面的所有可用空间

DrawView.java

```
public class DrawView extends View 
{
	private Rectangle mRectangle;
	public int width;
	public int height;
	public DrawView(Context context) 
	{
		super(context);
		/* 创建方块对象 */
		mRectangle = new Rectangle(context, this);
		mRectangle.setARGB(255, 255, 0, 0);
		mRectangle.setSpeedX(3);
		mRectangle.setSpeedY(3);
	}
	@Override
	protected void onDraw(Canvas canvas) 
	{
		/* 变换方块位置 */
		mRectangle.move();
		/* 将方块绘制到Canvas上 */
		mRectangle.onDraw(canvas);
		
		/* 重绘 */
		invalidate();
	}
}
```

> 首先，创建一个 Rectangle 实例，代表一个方块。Rectangle 类内部实现了将自身绘制到 Canvas 上的逻辑，并且已经包含了正确变换其位置的代码逻辑。当调用 onDraw() 方法时，方块的位置就会改变，然后绘制到 Canvas 上。invalidate() 方法本身就是一个小技巧，这个方法强制重绘视图。把这个方法放在 onDraw() 的目的是为了在 View 绘制完自身后，可以立即重新调用 onDraw() 方法。换句话说，通过循环调用Rectangle 的 move() 和 onDraw() 方法实现一个动画效果
