### MeasureSpec简介
[原文链接](http://blog.csdn.net/zjl5211314/article/details/6952698)


onMeasure方法在控件的父元素正要放置它的子控件时调用。它会问一个问题，“你想要用多大地方啊？”，然后传入两个参数——widthMeasureSpec和heightMeasureSpec。它们指明控件可获得的空间以及关于这个空间描述的元数据。比返回一个结果要好的方法是你传递View的高度和宽度到setMeasuredDimension方法里。

接下来的代码片段给出了如何重写onMeasure。注意，调用的本地空方法是来计算高度和宽度的。它们会译解widthHeightSpec和heightMeasureSpec值，并计算出合适的高度和宽度值。

	

```
@Override
protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
{
	intmeasuredHeight=measureHeight(heightMeasureSpec);
	intmeasuredWidth=measureWidth(widthMeasureSpec);
	setMeasuredDimension(measuredHeight,measuredWidth);
}
　　
private int measureHeight(intmeasureSpec)
{
	//高度测量窗口的回归.
}
　　
private int measureWidth(intmeasureSpec)
{
	//还测量窗口的宽度.
}
```

边界参数——widthMeasureSpec和heightMeasureSpec，效率的原因以整数的方式传入。在它们使用之前，首先要做的是使用MeasureSpec类的静态方法getMode和getSize来译解，如下面的片段代码所示： 

```
intspecMode=MeasureSpec.getMode(measureSpec);
intspecSize=MeasureSpec.getSize(measureSpec); 
```

接下来的框架代码给出了处理View测量的典型实现： 

```
@Override
protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) 
{
     int width  = measureDimension(dp2px(DEFAULT_SIZE), widthMeasureSpec);
     int height = measureDimension(dp2px(DEFAULT_SIZE), heightMeasureSpec);
     setMeasuredDimension(width, height);
}

private int measureDimension(int defaultSize,int measureSpec)
{
     int result = defaultSize;
     int specMode = MeasureSpec.getMode(measureSpec);
     int specSize = MeasureSpec.getSize(measureSpec);
     if (specMode == MeasureSpec.EXACTLY) 
     {
         result = specSize;
     } else if (specMode == MeasureSpec.AT_MOST) 
     {
         result = Math.min(defaultSize, specSize);
     } else 
     {
         result = defaultSize;
     }
     return result;
}

private int dp2px(int dpValue) 
{
    return (int) getContext().getResources().getDisplayMetrics().density * dpValue;
}
```
