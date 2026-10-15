### 参考
[自定义控件三部曲之绘图篇](https://blog.csdn.net/harvic880925/article/details/51317746)

自定义圆角ImageView的几种方式:
- BitmapShader
- Xfermode
- RoundedBitmapDrawable

### 1. BitmapShader - 推荐使用
通过Paint.setShader()设置相应的Bitmap为Paint(画笔)的纹理，通过Canvas.drawCircle()和Canvas.drawRoundRect()绘制圆形和圆角图片。
简易代码如下：
```
//初始化画笔
Paint mPaint = new Paint();
//设置画笔纹理
Bitmap mBitmap = BitmapFactory.decodeResource(context.getResources(), R.mipmap.timg);
mBitmapShader = new BitmapShader(mBitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP);
mPaint.setShader(mBitmapShader);

@Override
protected void onDraw(Canvas canvas) {
    super.onDraw(canvas);
    //绘制圆角矩形
    RectF rect = new RectF(100, 100, 500, 500);
    canvas.drawRoundRect(rect, 100, 100, mPaint);
}
```

### 2. Xfermode
通过Xfermode设置图像混合模式。
简易代码如下：
```
@Override
protected void onDraw(Canvas canvas) {
    // 使用图形混合模式来显示指定区域的图片
    canvas.saveLayer(srcRectF, null, Canvas.ALL_SAVE_FLAG);
    super.onDraw(canvas);
    path.addRoundRect(srcRectF, srcRadii, Path.Direction.CCW);

    paint.setAntiAlias(true);
    paint.setStyle(Paint.Style.FILL);
    paint.setXfermode(xfermode);
    canvas.drawPath(path, paint);
    paint.setXfermode(null);

    // 恢复画布
    canvas.restore();
}
```
缺点：
因为需要绘制到新的图层所以增加了资源消耗。

### 3. RoundedBitmapDrawable 
RoundedBitmapDrawable是Android 提供的API，内部原理其实和第一种方式一样通过设置Paint的纹理来实现的。
简易代码如下：

```
Bitmap bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.photo);
RoundedBitmapDrawable roundedBitmapDrawable = RoundedBitmapDrawableFactory.create(getResources(), bitmap);
roundedBitmapDrawable.setCornerRadius(100);
iv.setImageDrawable(roundedBitmapDrawable );
```

重要方法如下：
- setCircular(boolean circular) ： 把图片的形状设为圆形。
- setCornerRadius(float cornerRadius) ： 设置图片的圆角半径。
- setAlpha：透明度
- setAntiAlias：抗锯齿
- setDither：防抖动

缺点：
测试发现源图片如果非正方形使用setCircular()设为圆形时源图片会变形。

### 引申

#### 1. 为什么使用Xfermode方式绘制圆角图片时需要创建新的图层？
[自定义控件三部曲之绘图篇](https://blog.csdn.net/harvic880925/article/details/51317746)

解决这个问题需要了解Xfermode绘图的过程以及saveLayer()的绘图过程。
