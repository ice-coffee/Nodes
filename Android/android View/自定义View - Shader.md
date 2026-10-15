> Shader是绘图中着色器的基础类，通过Paint.setShader()方法设置画笔着色器，之后的任何绘制操作（除了绘图位图 - drawBitmap()）都会通过着色器获取颜色。

### TileMode
> Shader.TileMode 着色器平铺模式

- CLAMP：当绘制的区域超过了原始的大小，超出的区域就会用边缘的颜色进行拉伸。
- REPEAT：重复水平或者竖直方向的图片。
- MIRROR：用图片的镜像填充。

### 实现类
- BitmapShader：位图着色器
- LinearGradient：线性渐变着色器
- RadialGradient：放射渐变着色器
- SweepGradient：扫描渐变着色器
- ComposeShader：合并两种着色器

#### 1. BitmapShader

```
/**
 * 位图着色器
 * @param bitmap    着色器使用的位图
 * @param tileX     X轴绘制位图平铺方式
 * @param tileY     Y轴绘制位图平铺方式
 */
public BitmapShader(Bitmap bitmap,  TileMode tileX, TileMode tileY)
```

#### 2. LinearGradient
常用构造函数
```
/**
 * 沿直线绘制线性渐变的着色器。
 *
 * @param x0        线性起点的X轴坐标
 * @param y0        线性起点的Y轴坐标
 * @param x1        线性终点的X轴坐标
 * @param y2        线性终点的Y轴坐标
 * @param colors    实现渐变颜色组合
 * @param positions 颜色组合中的各颜色在渐变中占据的位置，如果为空，则表示上述颜色的集合在渐变中均匀出现
 * @param tile      平铺模式
 */
public LinearGradient(float x0, float y0, float x1, float y1, int[] colors, float[] positions, TileMode tile){}
```

#### 3. RadialGradient
常用构造函数
```
/**
 * 放射渐变着色器
 *
 * @param centerX   放射中心X轴坐标
 * @param centerY   放射中心Y轴坐标
 * @param radius    放射半径，必须为正值
 * @param colors    从圆心到边缘渐变颜色组合
 * @param stops     颜色组合中的各颜色在渐变中占据的位置，如果为空，则表示上述颜色的集合在渐变中均匀出现
 * @param tileMode  平铺模式
 */
public RadialGradient(float centerX, float centerY, float radius, long[] colors, float[] stops,, TileMode tileMode) {}
```

#### 4. SweepGradient
常用构造函数

```
/**
 * 扫描渐变着色器
 *
 * @param cx        中心点X轴坐标
 * @param cy        中心点Y轴坐标
 * @param colors    渐变颜色组合， 最少两个色值
 * @param positions 颜色组合中的各颜色在渐变中占据的位置，如果为空，则表示上述颜色的集合在渐变中均匀出现
 */
public SweepGradient(float cx, float cy, @NonNull @ColorLong long[] colors,
        @Nullable float[] positions) {
    this(cx, cy, colors.clone(), positions, detectColorSpace(colors));
}
```


#### 5. ComposeShader
混合两种着色器以获得新的着色器，通过观察构造函数可以发现，混合方式有三种：
- Xfermode
- PorterDuff.Mode
- BlendMode

> ==重点记录一下 positions、stops等参数的使用==：
> - 若为空，则颜色均匀渐变
> - positions数组元素个数必须与colors数组一致
> - positions数组元素的值为[0 - 1]
> - positions中各个元素值代表对应颜色出现的位置，若positions = [0.2, 0.5, 0.7]，标识将颜色分为四个区域，其中`0%~20%`显示第一种颜色，`20%~50%`显示第一种颜色与第二种颜色渐变，`%50~70%`显示第二种与第三种颜色渐变，`70%~100%`为第三种颜色。

### 实现

[github](https://github.com/ice-coffee/ViewSample/tree/master/app/src/view_shader)

#### 1. 图片圆角
通过BitmapShader实现圆角图片，代码量较多，请参看项目代码。

#### 2. 文字颜色渐变

```
class LinearGradientView(context: Context?, attributeSet: AttributeSet?) : AppCompatTextView(context!!, attributeSet) {

    var mLinearGradient: LinearGradient? = null
    private val mMatrix = Matrix()
    private var mX = 0

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)

        mLinearGradient = LinearGradient(0f, 0f, measuredWidth.toFloat(), 0f, intArrayOf(Color.YELLOW, Color.RED, Color.GREEN), floatArrayOf(0.2f, 0.4f, 0.6f), Shader.TileMode.REPEAT)
        paint.shader = mLinearGradient

        initAnimator(w)
    }

    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)
        mMatrix.reset()
        mMatrix.preTranslate(mX.toFloat(), 0f)
        mLinearGradient!!.setLocalMatrix(mMatrix)
    }

    private fun initAnimator(width: Int) {
        val animator = ValueAnimator.ofInt(0, width * 2) //我们设置value的值为0-getMeasureWidth的3 倍
        animator.addUpdateListener { animation ->
            mX = animation.animatedValue as Int
            postInvalidate()
        }
        animator.repeatMode = ValueAnimator.RESTART //重新播放
        animator.repeatCount = ValueAnimator.INFINITE //无限循环
        animator.duration = 2000
        animator.start()
    }
}
```

#### 3. 水波纹

```
/**
 * date: 2020/9/20
 * author: ice_coffee
 * remark: TODO-MZP 本实例仅用于演示 RadialGradient 的用法, 在android material design 设计规范中按钮水波纹使用 material.ripple 实现
 */
class RadialGradientView(context: Context?, attributeSet: AttributeSet?) : BaseView(context, attributeSet) {

    private var mX = 0f
    private var mY = 0f
    private var mAnimator: ObjectAnimator? = null
    private var mCurRadius = 0f
    private val mPaint: Paint = Paint()

    companion object {
        private const val DEFAULT_RADIUS = 50
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {

        if (event.action == MotionEvent.ACTION_UP) {
            mX = event.x
            mY = event.y

            mAnimator?.isRunning ?: mAnimator?.cancel()
            mAnimator?.start()
        }
        return true
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)

        //自定义属性动画
        mAnimator = ObjectAnimator.ofInt(this, "radius", DEFAULT_RADIUS, w)
        mAnimator?.interpolator = AccelerateInterpolator()
        mAnimator?.addListener(object : AnimatorListener {
            override fun onAnimationStart(animation: Animator) {}
            override fun onAnimationEnd(animation: Animator) {
                setRadius(0)
            }

            override fun onAnimationCancel(animation: Animator) {}
            override fun onAnimationRepeat(animation: Animator) {}
        })
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        canvas.drawCircle(mX, mY, mCurRadius, mPaint)
    }

    //注意这里的方法名必须是setRadius(自定义属性动画)
    fun setRadius(radius: Int) {
        mCurRadius = radius.toFloat()
        if (mCurRadius > 0) {
            mPaint.shader = RadialGradient(mX, mY, mCurRadius, 0x00FFFFFF, -0xa70554, Shader.TileMode.CLAMP)
        }
        invalidate()
    }
}
```
