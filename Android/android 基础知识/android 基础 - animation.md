[toc]

> android动画分为三大类: 补间动画  、帧动画 、属性动画

### 补间动画
> 补间动画分为四大类: AlphaAnimation、ScaleAnimation、TranslateAnimation、RotateAnimation

#### 1. AlphaAnimation(透明度渐变动画) 

    <?xml version="1.0" encoding="utf-8"?>
	<set xmlns:android="http://schemas.android.com/apk/res/android" >
	<alpha
		android:fromAlpha="0.1"
		android:toAlpha="1.0"
		android:duration="3000"
	/> 
	<!-- 透明度控制动画效果 alpha
        浮点型值：
            fromAlpha 属性为动画起始时透明度
            toAlpha   属性为动画结束时透明度
            说明: 
                0. 0表示完全透明
                1. 0表示完全不透明
            以上值取0.0-1.0之间的float数据类型的数字，也可取百分数表示
        
        长整型值：
            duration  属性为动画持续时间
            说明:     
                时间以毫秒为单位
	- ->
	</set>

#### 2. ScaleAnimation(渐变尺寸伸缩动画 ) 

    <?xml version="1.0" encoding="utf-8"?>
	<set xmlns:android="http://schemas.android.com/apk/res/android">
	   <scale  
          android:interpolator=
                     "@android:anim/accelerate_decelerate_interpolator"
          android:fromXScale="0.0"
          android:toXScale="1.4"
          android:fromYScale="0.0"
          android:toYScale="1.4"
          android:pivotX="50%"
          android:pivotY="50%"
          android:fillAfter="false"
          android:duration="700" />
	</set>
	<!-- 尺寸伸缩动画效果 scale
        属性：interpolator 指定一个动画的插入器
        在我试验过程中，使用android.res.anim中的资源时候发现
        有三种动画插入器:
            accelerate_decelerate_interpolator  加速-减速 动画插入器
            accelerate_interpolator        加速-动画插入器
            decelerate_interpolator        减速- 动画插入器
        其他的属于特定的动画效果
      浮点型值：
         
            fromXScale 属性为动画起始时 X坐标上的伸缩尺寸    
            toXScale   属性为动画结束时 X坐标上的伸缩尺寸     
        
            fromYScale 属性为动画起始时Y坐标上的伸缩尺寸    
            toYScale   属性为动画结束时Y坐标上的伸缩尺寸    
        
            说明:
                 以上四种属性值    
    
                    0. 0表示收缩到没有 
                    1. 0表示正常无伸缩     
                    值小于1.0表示收缩  
                    值大于1.0表示放大
        
            pivotX     属性为动画相对于物件的X坐标的开始位置
            pivotY     属性为动画相对于物件的Y坐标的开始位置
        
            说明:
                    以上两个属性值 从0%-100%中取值
                    50%为物件的X或Y方向坐标上的中点位置
        
        长整型值：
            duration  属性为动画持续时间
            说明:   时间以毫秒为单位

        布尔型值:
            fillAfter 属性 当设置为true ，该动画转化在动画结束后被应用
	- ->

#### 3. TranslateAnimation(位移动画) 

    <?xml version="1.0" encoding="utf-8"?>
	<set xmlns:android="http://schemas.android.com/apk/res/android">
	<translate
		android:fromXDelta="30"
		android:toXDelta="-80"
		android:fromYDelta="30"
		android:toYDelta="300"
		android:duration="2000"
	/>
	<!-- translate 位置转移动画效果
        整型值:
            fromXDelta 属性为动画起始时 X坐标上的位置    
            toXDelta   属性为动画结束时 X坐标上的位置
            fromYDelta 属性为动画起始时 Y坐标上的位置
            toYDelta   属性为动画结束时 Y坐标上的位置
            注意:
                     没有指定fromXType toXType fromYType toYType 时候，
                     默认是以自己为相对参照物             
        长整型值：
            duration  属性为动画持续时间
            说明:   时间以毫秒为单位
	- ->
	</set>

#### 4. RotateAnimation(旋转动画)

    <?xml version="1.0" encoding="utf-8"?>
	<set xmlns:android="http://schemas.android.com/apk/res/android">
	<rotate 
        android:interpolator="@android:anim/accelerate_decelerate_interpolator"
        android:fromDegrees="0" 
        android:toDegrees="360"
        android:repeatMode="restart"
        android:repeatCount="-1"         
        android:pivotX="50%" 
        android:pivotY="50%"     
        android:duration="3000" />  
	<!-- rotate 旋转动画效果
       属性：interpolator 指定一个动画的插入器
             在我试验过程中，使用android.res.anim中的资源时候发现
             有三种动画插入器:
                accelerate_decelerate_interpolator   加速-减速 动画插入器
                accelerate_interpolator               加速-动画插入器
                decelerate_interpolator               减速- 动画插入器
             其他的属于特定的动画效果
                           
       浮点数型值:
            fromDegrees 属性为动画起始时物件的角度    
            toDegrees   属性为动画结束时物件旋转的角度 可以大于360度   

        
            说明:
                     当角度为负数——表示逆时针旋转
                     当角度为正数——表示顺时针旋转              
                     (负数from——to正数:顺时针旋转)   
                     (负数from——to负数:逆时针旋转) 
                     (正数from——to正数:顺时针旋转) 
                     (正数from——to负数:逆时针旋转)       

            pivotX     属性为动画相对于物件的X坐标的开始位置
            pivotY     属性为动画相对于物件的Y坐标的开始位置
                
            说明:        以上两个属性值 从0%-100%中取值
                         50%为物件的X或Y方向坐标上的中点位置

        长整型值：
            duration  属性为动画持续时间
            说明:       时间以毫秒为单位
	- ->
	</set>

#### 5. 使用XML中的动画效果

	使用AnimationUtils类的静态方法loadAnimation()来加载XML中的动画XML文件
    AnimationUtils.loadAnimation(context, R.anim.splash);
    使用View类的方法startAnimation(Animation animation)来开始一个动画

#### 6. 在Java代码中 定义动画
	
	//透明度渐变动画
    AlphaAnimation(float fromAlpha, float toAlpha)
    AlphaAnimation anim = new AlphaAnimation(0.1f, 1.0f);

	//尺寸渐变动画
    ScaleAnimation(float fromX, float toX, float fromY, float toY,
	    int pivotXType, float pivotXValue, int pivotYType, float pivotYValue) 
    ScaleAnimation anim = new ScaleAnimation(0.0f, 1.4f, 0.0f, 1.4f,
	    Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);

	//位移动画
    TranslateAnimation(float fromXDelta, float toXDelta,
	    float fromYDelta, float toYDelta) 
	TranslateAnimation anim = new TranslateAnimation(0.0f, 0.4f, 0.0f, 0.4f);

	//旋转动画
    RotateAnimation(float fromDegrees, float toDegrees, 
	    int pivotXType, float pivotXValue, int pivotYType, float pivotYValue)
	myAnimation_Rotate=new RotateAnimation(0.0f, +350.0f,
	    Animation.RELATIVE_TO_SELF,0.5f,Animation.RELATIVE_TO_SELF, 0.5f);

	//设置时间持续时间为 3000毫秒
    anim.setDuration(3000);
    更多的函数去查看文档
    
> 以上构造函数的输入参数值的名称与上方xml中属性介绍基本一致,这里不再赘述, 这里介绍一下pivotXType、pivotYType：他们类似于android:pivotX、android:pivotY是动画相对于物体位置类型，确定x ,y轴上选择中心。

    pivotXType=Animation.ABSOLUTE，则此参数为旋转中心在屏幕上X轴的值；  
	pivotXType=Animation.RELATIVE_TO_PARENT，则参数pivotXValue为旋转中心在父控件水平位置百分比，如0.5表示在父控件水平方向中间位置  
	pivotXType=Animation.RELATIVE_TO_SELF，则参数pivotXValue为旋转中心在控件自身水平位置百分比，如果X和Y的Value都设置为0.5，则该控件以自身中心旋转。  
	

### 属性动画
[郭霖的博客](http://blog.csdn.net/guolin_blog?viewmode=contents)
> Android 3.0版本引入
#### 简介
正由于补间动画的局限性才有了属性动画的引入, 那么补间动画都有哪些局限性呢:
1. 只能对View对象进行操作；
2. 只有移动、缩放、旋转、淡入淡出四种动画操作；
3. 只能改变View的显示效果，不能改变View的属性。

属性动画是通过对目标对象进行赋值并改变其属性来实现的.

#### ValueAnimator
ValueAnimator的内部使用一种时间循环的机制来计算值与值之间的动画过渡，我们只需要将初始值和结束值提供给ValueAnimator，并且告诉它动画所需运行的时长，那么ValueAnimator就会自动帮我们完成从初始值平滑地过渡到结束值这样的效果。除此之外，ValueAnimator还负责管理动画的播放次数、播放模式、以及对动画设置监听器等。

```
ValueAnimator animator = ValueAnimator.ofInt(1, 4,5,8);
animator.setDuration(300);
animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener()
{
    @Override
    public void onAnimationUpdate(ValueAnimator animation)
    {
        int currentValue = (int)animation.getAnimatedValue();
        Log.e(TAG, "current value is " + currentValue);
    }
});

animator.start();
```

#### ObjectAnimator
> ObjectAnimator可以直接对任意对象的任意属性值进行动画操作, 比如View的alpha属性.

1. ofFloat方法
> ofFloat(Object target, String propertyName, float... values)
- @param target : 运行动画的对象
- @param propertyName : 属性名
- @param values : 动画运行的值的集合

这个方法的意思就是不断修改 target 对象的 propertyName 属性值, 从 value0 到 valuex;

propertyName 属性的值是`任意`的, 它代表可以通过相应的get和set方法来修改 propertyName属性的值; 
比如View中的setAlpha(float value) 和 getAlpha()方法.

2. 可操作的View属性大致有: 
- alpha: 渐变
- rotation: 旋转
- translationX/Y/Z: 位移
- scaleX/Y:缩放

比如X轴位移动画

```
float curTranslationX = view.getTranslationX();

ObjectAnimator animator = ObjectAnimator.ofFloat(view, "translationX", curTranslationX, -500f, curTranslationX);
animator.setDuration(2000);
animator.start();
```

#### AnimatorSet
AnimatorSet这个类是实现组合动画功能的主要方法，这个类提供了一个`play()`方法，如果我们向这个方法中传入一个Animator对象(ValueAnimator或ObjectAnimator)将会返回一个AnimatorSet.Builder的实例，AnimatorSet.Builder中包括以下四个方法：
-  after(Animator anim)   将现有动画插入到传入的动画之后执行
-  after(long delay)   将现有动画延迟指定毫秒后执行
-  before(Animator anim)   将现有动画插入到传入的动画之前执行
-  with(Animator anim)   将现有动画和传入的动画同时执行

```
ObjectAnimator moveIn = ObjectAnimator.ofFloat(view, "translationX", 0f, -500f, 0f);
ObjectAnimator rotate = ObjectAnimator.ofFloat(view, "rotation", 0f, 360f);
ObjectAnimator fadeInOut = ObjectAnimator.ofFloat(view, "alpha", 1f, 0f, 1f);
AnimatorSet animSet = new AnimatorSet();
animSet.play(rotate).with(fadeInOut).after(moveIn);
animSet.setDuration(5000);
animSet.start();
```

#### 动画监听器
对于ValueAnimator, ObjectAnimator和AnimatorSet都可以使用addListener()监听动画的各种事件.

```
anim.addListener(new AnimatorListener() {  
    @Override  
    public void onAnimationStart(Animator animation) {  
    }  
  
    @Override  
    public void onAnimationRepeat(Animator animation) {  
    }  
  
    @Override  
    public void onAnimationEnd(Animator animation) {  
    }  
  
    @Override  
    public void onAnimationCancel(Animator animation) {  
    }  
});  
```
实现动画监听还有一种简单方式, 使用Androd 提供的 AnimatorListenerAdapter 适配器类.

```
anim.addListener(new AnimatorListenerAdapter()
        {
            @Override
            public void onAnimationStart(Animator animation)
            {
                super.onAnimationStart(animation);
            }
        });
```

#### 使用xml编写动画
如果想要使用XML来编写动画，首先要在res目录下面新建一个`animator`文件夹，所有属性动画的XML文件都应该存放在这个文件夹当中属性动画的xml文件一共可以使用如下三个标签:
- <animator>  对应代码中的ValueAnimator
- <objectAnimator>  对应代码中的ObjectAnimator
- <set>  对应代码中的AnimatorSet

那么比如说我们想要实现一个从0到100平滑过渡的动画，在XML当中就可以这样写：

```
<animator xmlns:android="http://schemas.android.com/apk/res/android"  
    android:valueFrom="0"  
    android:valueTo="100"  
    android:valueType="intType"/>  
```

而如果我们想将一个视图的alpha属性从1变成0，就可以这样写：

```
<objectAnimator xmlns:android="http://schemas.android.com/apk/res/android"  
    android:valueFrom="1"  
    android:valueTo="0"  
    android:valueType="floatType"  
    android:propertyName="alpha"/>  
```

另外，我们也可以使用XML来完成复杂的组合动画操作，比如将一个视图先移出屏幕再移入屏幕，然后开始旋转360度，旋转的同时进行淡入淡出操作，就可以这样写：

```
<set xmlns:android="http://schemas.android.com/apk/res/android"
    android:ordering="sequentially">

    <objectAnimator
        android:propertyName="translationX"
        android:valueFrom="0"
        android:valueTo="500"
        android:valueType="floatType"
        android:duration="1000">
    </objectAnimator>

    <objectAnimator
        android:propertyName="translationX"
        android:valueFrom="500"
        android:valueTo="0"
        android:valueType="floatType"
        android:duration="1000">
    </objectAnimator>

    <set android:ordering="together">
        <objectAnimator
            android:propertyName="rotation"
            android:valueFrom="0"
            android:valueTo="360"
            android:valueType="floatType"
            android:duration="2000">
        </objectAnimator>

        <set android:ordering="sequentially">
            <objectAnimator
                android:propertyName="alpha"
                android:valueFrom="1"
                android:valueTo="0"
                android:valueType="floatType"
                android:duration="1000">
            </objectAnimator>

            <objectAnimator
                android:propertyName="alpha"
                android:valueFrom="0"
                android:valueTo="1"
                android:valueType="floatType"
                android:duration="1000">
            </objectAnimator>
        </set>
    </set>
</set>
```
<set>标签有一个`ordering`属性, 它有两个值
- sequentially : 依次播放
- together : 同时播放

如何在代码中把文件加载进来并将动画启动呢？只需调用如下代码即可：

```
Animator animator = AnimatorInflater.loadAnimator(context, R.animator.anim_file);  
animator.setTarget(view);  
animator.start();  
```

调用AnimatorInflater的loadAnimator来将XML动画文件加载进来，然后再调用setTarget()方法将这个动画设置到某一个对象上面，最后再调用start()方法启动动画就可以了，就是这么简单。

#### TypeEvaluator
> 告诉系统动画是如何从一个值过渡到另一个值的

ValueAnimator.ofFloat()方法就是实现了初始值与结束值之间的平滑过度，它其实就是系统内置了一个FloatEvaluator，它通过计算告知动画系统如何从初始值过度到结束值，我们来看一下FloatEvaluator的代码实现：

```
public class FloatEvaluator implements TypeEvaluator {  
    public Object evaluate(float fraction, Object startValue, Object endValue) {  
        float startFloat = ((Number) startValue).floatValue();  
        return startFloat + fraction * (((Number) endValue).floatValue() - startFloat);  
    }  
}  
```

可以看到，FloatEvaluator`实现了TypeEvaluator接口`，然后`重写evaluate()方法`。evaluate()方法当中传入了三个参数，第一个参数fraction非常重要，这个参数用于表示动画的完成度的，我们应该根据它来计算当前动画的值应该是多少，第二第三个参数分别表示动画的初始值和结束值。那么上述代码的逻辑就比较清晰了，`用结束值减去初始值，算出它们之间的差值，然后乘以fraction这个系数，再加上初始值，那么就得到当前动画的值了`。

#### ValueAnimator使用Evaluator制定控件轨迹
> 以我的感觉来说, 自定义Evaluator在ValueAnimator中的作用就是制定控件的运动轨迹, 比如自定义位移控件

首先定义个 Point 类用来记控件坐标的位置

```
public class Point 
{  
	private float x;  
    private float y;  
  
    public Point(float x, float y) 
    {  
        this.x = x;  
        this.y = y;  
    }
  
    public float getX() 
    {  
        return x;  
    }
  
    public float getY() 
    {  
        return y;  
    }
}
```

自定义Evaluator计算当前Point的位置, 并构成一个新的Point返回

```
public class PointEvaluator implements TypeEvaluator
{  
    @Override  
    public Object evaluate(float fraction, Object startValue, Object endValue) 
    {  
        Point startPoint = (Point) startValue;  
        Point endPoint = (Point) endValue;  
        float x = startPoint.getX() + fraction * (endPoint.getX() - startPoint.getX());  
        float y = startPoint.getY() + fraction * (endPoint.getY() - startPoint.getY());  
        Point point = new Point(x, y);  
        return point;  
    } 
} 
```

自定义一个控件 MyAnimView,

```
public class MyAnimView extends View 
{  
    public static final float RADIUS = 50f;  
    private Point currentPoint;  
    private Paint mPaint;  
  
    public MyAnimView(Context context, AttributeSet attrs) 
    {  
        super(context, attrs);  
        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);  
        mPaint.setColor(Color.BLUE);  
    }  
  
    @Override  
    protected void onDraw(Canvas canvas) 
    {  
        if (currentPoint == null) 
        {  
            currentPoint = new Point(RADIUS, RADIUS);  
            drawCircle(canvas);  
            startAnimation();  
        } 
        else 
        {  
            drawCircle(canvas);  
        }  
    }  
  
    private void drawCircle(Canvas canvas) 
    {  
        float x = currentPoint.getX();  
        float y = currentPoint.getY();  
        canvas.drawCircle(x, y, RADIUS, mPaint);  
    }  
  
    private void startAnimation() 
    {  
        Point startPoint = new Point(RADIUS, RADIUS);  
        Point endPoint = new Point(getWidth() - RADIUS, getHeight() - RADIUS);  
        ValueAnimator anim = ValueAnimator.ofObject(new PointEvaluator(), startPoint, endPoint);  
        anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {  
            @Override  
            public void onAnimationUpdate(ValueAnimator animation) {  
                currentPoint = (Point) animation.getAnimatedValue();  
                invalidate();  
            }  
        });  
        anim.setDuration(5000);  
        anim.start();  
    } 
}  
```

#### ObjectAnimator使用Evaluator制定控件属性改变
> 以我的感觉来说, 自定义Evaluator在ObjectAnimator中的作用就是改变控件某个属性的值, 比如改变控件颜色.

在MyAnimView中定义 `color` 属性

```
public class MyAnimView extends View 
{  
    ...  
  
    private String color;  
  
    public String getColor() 
    {  
        return color;  
    }  
  
	/**
     * 通过改变画笔颜色立即刷新视图,到达动态修改控件颜色的目的
     * @param color
     */
    public void setColor(String color) 
    {  
        this.color = color;  
        mPaint.setColor(Color.parseColor(color));  
        invalidate();  
    }  
  
    ...  
} 
```

创建ColorEvaluator并实现TypeEvaluator接口，代码如下所示：
> 这段代码中色值计算的逻辑不是很懂啊......

```
public class ColorEvaluator implements TypeEvaluator 
{  
    private int mCurrentRed = -1;  
    private int mCurrentGreen = -1;  
    private int mCurrentBlue = -1;  
  
    @Override  
    public Object evaluate(float fraction, Object startValue, Object endValue) 
    {  
        String startColor = (String) startValue;  
        String endColor = (String) endValue;  
        int startRed = Integer.parseInt(startColor.substring(1, 3), 16);  
        int startGreen = Integer.parseInt(startColor.substring(3, 5), 16);  
        int startBlue = Integer.parseInt(startColor.substring(5, 7), 16);  
        int endRed = Integer.parseInt(endColor.substring(1, 3), 16);  
        int endGreen = Integer.parseInt(endColor.substring(3, 5), 16);  
        int endBlue = Integer.parseInt(endColor.substring(5, 7), 16);  
        // 初始化颜色的值  
        if (mCurrentRed == -1) {  
            mCurrentRed = startRed;  
        }  
        if (mCurrentGreen == -1) {  
            mCurrentGreen = startGreen;  
        }  
        if (mCurrentBlue == -1) {  
            mCurrentBlue = startBlue;  
        }  
        // 计算初始颜色和结束颜色之间的差值  
        int redDiff = Math.abs(startRed - endRed);  
        int greenDiff = Math.abs(startGreen - endGreen);  
        int blueDiff = Math.abs(startBlue - endBlue);  
        int colorDiff = redDiff + greenDiff + blueDiff;  
        if (mCurrentRed != endRed) {  
            mCurrentRed = getCurrentColor(startRed, endRed, colorDiff, 0,  
                    fraction);  
        } else if (mCurrentGreen != endGreen) {  
            mCurrentGreen = getCurrentColor(startGreen, endGreen, colorDiff,  
                    redDiff, fraction);  
        } else if (mCurrentBlue != endBlue) {  
            mCurrentBlue = getCurrentColor(startBlue, endBlue, colorDiff,  
                    redDiff + greenDiff, fraction);  
        }  
        // 将计算出的当前颜色的值组装返回  
        String currentColor = "#" + getHexString(mCurrentRed)  
                + getHexString(mCurrentGreen) + getHexString(mCurrentBlue);  
        return currentColor;  
    }  
  
    /** 
     * 根据fraction值来计算当前的颜色。 
     */  
    private int getCurrentColor(int startColor, int endColor, int colorDiff,  
            int offset, float fraction) {  
        int currentColor;  
        if (startColor > endColor) {  
            currentColor = (int) (startColor - (fraction * colorDiff - offset));  
            if (currentColor < endColor) {  
                currentColor = endColor;  
            }  
        } else {  
            currentColor = (int) (startColor + (fraction * colorDiff - offset));  
            if (currentColor > endColor) {  
                currentColor = endColor;  
            }  
        }  
        return currentColor;  
    }  
      
    /** 
     * 将10进制颜色值转换成16进制。 
     */  
    private String getHexString(int value) 
    {  
        String hexString = Integer.toHexString(value);  
        if (hexString.length() == 1) {  
            hexString = "0" + hexString;  
        }  
        return hexString;  
    }  
}  
```

使用组合动画, 修改MyAnimView中的代码，如下所示：

```
public class MyAnimView extends View 
{  
    ...  
  
    private void startAnimation() 
    {  
        Point startPoint = new Point(RADIUS, RADIUS);  
        Point endPoint = new Point(getWidth() - RADIUS, getHeight() - RADIUS);  
        ValueAnimator anim = ValueAnimator.ofObject(new PointEvaluator(), startPoint, endPoint);  
        anim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {  
            @Override  
            public void onAnimationUpdate(ValueAnimator animation) {  
                currentPoint = (Point) animation.getAnimatedValue();  
                invalidate();  
            }  
        });  
        
        ObjectAnimator anim2 = ObjectAnimator.ofObject(this, "color", new ColorEvaluator(),   
                "#0000FF", "#FF0000");  
                
        AnimatorSet animSet = new AnimatorSet();  
        animSet.play(anim).with(anim2);  
        animSet.setDuration(5000);  
        animSet.start();  
    }  
} 
```

这样就可以实现控件色值的改变了....

#### Interpolator
#### ViewPropertyAnimator
这两篇请参考郭霖大神的博客

### Animator - API

Animator.start() // start the animation from the beginning
Animator.end() // end the animation
Animator.cancel() // cancel the animation
Animator.pause() // added in API 19; pause the animation
Animator.resume() // added in API 19; resume a paused animation

```
/**
 * 结束动画。在结束动画时会动画属性值设为的结束值，然后回调 onAnimationEnd() 
 *
 * 必须在运行动画的线程上调用此方法。
 */
public void end() {
}

/**
 * 取消动画。与 end() 不同的是，cancel() 会使动画停止运行，
 * 并回调 onAnimationCancel() 和 onAnimationCancel()。
 * 必须在运行动画的线程上调用此方法。
 */
public void cancel() {
}
```

start这个方法顾名思义是用来让动画从开头开始播放的。如果动画设置了一个大于0的播放延迟（startDelay），那么调用该方法后还需要等到延迟的时间过去才回开始播放。 我们有两种停止动画的方法，你可以用end方法抑或cancel方法来停止一个播放着的动画。在两种方式中动画都会终止并且只有再次调用start方法才会重新开始播放。两者的区别则在于停止后动画所在的状态，当你使用cancel方法来停止动画后，动画只是停止了它的时间轴，动画的状态会停在一个中间态(intermediate state)。如果通过end 方法来停止一个动画，那么动画会直接快进到该动画最后一帧并且停止，所有的对象都会保持在动画最终结束后的状态。 在 Kitkat 中增加的没有怎么被大家关注到的新API则是带来了动画可以暂停和恢复的能力。在那之前，一个动画如果被取消并且停留在当前的中间态，此时你用start方法去重启动画，动画只会从一开始重新播放。现在，你则可以调用pause方法来暂停当前播放中的动画，pause也会有和cancel方法一样的功效让动画停留在中间态，但是当你使用resume 方法去恢复这个动画的时候，动画会从这个状态继续播放下去。
