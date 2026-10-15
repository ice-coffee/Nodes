### 原文
[StaticLayout和DynamicLayout](https://my.oschina.net/zzxzzg/blog/1814028)

### 前言
使用Canvas的drawText绘制文本是不会自动换行的，即使一个很长很长的字符串，drawText也只显示一行，超出部分被隐藏在屏幕之外。

那么TextView这样的控件是如何处理这个问题的呢？实际上，他会利用一个叫做Layout的辅助类。

[Layout](https://developer.android.com/reference/android/text/Layout)
    
```
“A base class that manages text layout in visual elements on the screen.”
一个用于管理 text 显示在屏幕上时视觉效果的类
```

Layout是一个虚类，不过还是提供了一个非常重要的静态方法

```
float getDesiredWidth (CharSequence source, TextPaint paint)
```

用于计算source显示需要多长的宽度。

 

### StaticLayout和DynamicLayout

该两个类都是Layout的子类，无论从构造方法和成员方法上都几乎一样，他们的区别我们在下面介绍，以StaticLayout为例，我们来了解下这个东西到底是用来干嘛的。

StaticLayout是android中处理文字换行的一个工具类，StaticLayout已经实现了文本绘制换行处理，下面是如何使用StaticLayout的例子：

```
public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(new MyView(this));
    }
    public class MyView extends View {  
        Paint mPaint; //画笔,包含了画几何图形、文本等的样式和颜色信息  
        public MyView(Context context) {  
            super(context);     
        }  
        
        public MyView(Context context, AttributeSet attrs){  
            super(context, attrs);  
        }  
        
        public void onDraw(Canvas canvas){  
            super.onDraw(canvas);  
            TextPaint tp = new TextPaint();
            tp.setColor(Color.BLUE);
            tp.setStyle(Style.FILL);
            tp.setTextSize(50);
            String message = "paint,draw paint指用颜色画,如油画颜料、水彩或者水墨画,而draw 通常指用铅笔、钢笔或者粉笔画,后者一般并不涂上颜料。两动词的相应名词分别为p";
            StaticLayout myStaticLayout = new StaticLayout(message, tp, canvas.getWidth(), Alignment.ALIGN_NORMAL, 1.0f, 0.0f, false);
            myStaticLayout.draw(canvas);
            canvas.restore();
        }  
    }  
}
```

#### 构造函数
StaticLayout(CharSequence source, int bufstart, int bufend,
           TextPaint paint, int outerwidth,
           Alignment align,
           float spacingmult, float spacingadd,
           boolean includepad,
           TextUtils.TruncateAt ellipsize, int ellipsizedWidth)

1. 需要分行的字符串

2. 需要分行的字符串从第几的位置开始

3. 需要分行的字符串到哪里结束

4. 画笔对象

5. layout的宽度，字符串超出宽度时自动换行。

6. layout的对其方式，有ALIGN_CENTER， ALIGN_NORMAL， ALIGN_OPPOSITE 三种。

7. 相对行间距，相对字体大小，1.5f表示行间距为1.5倍的字体高度。

8. 在基础行距上添加多少

实际行间距等于这两者的和。

9. 参数未知

10. 从什么位置开始省略

11. 超过多少开始省略

当然还有两个其他的构造函数，参数意义相同，可以参看[sdk](https://developer.android.com/reference/android/text/StaticLayout)

### StaticLayout和DynamicLayout区别
官方网解释的是DynamicLayout用于可变字符串，而StaticLayout用于不变的字符串。但是找了DynamicLayout也没有找到类似updateText这样的方法用来更新字符串，重新计算长度的。

于是google到这样一段解释，我觉得可以用来参考。

In order to be updated on text change, DynamicLayout expects Spannable as first parameter. In that case it creates instance of internal static class DynamicLayout.ChangeWatcher, and attaches it to the Spannable. The Spannable, in turn, needs to implement Editable in order to be updated.

Example:

```
SpannableStringBuilder base = new SpannableStringBuilder("a");
DynamicLayout dynamicLayout = new DynamicLayout(base, base, paint, width, Alignment.ALIGN_NORMAL, 1.0, 0, true);
int firstHeight = dynamicLayout.getHeight();
base.append("\nA");
int secondHeight = dynamicLayout.getHeight();
```

### 参考
[参考1](http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2014/0915/1682.html)

[参考2](https://stackoverflow.com/questions/26673029/whats-the-difference-between-staticlayout-and-dynamiclayout)
