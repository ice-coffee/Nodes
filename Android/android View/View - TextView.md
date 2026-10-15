[toc]
### 关联地址
[自定义Span](https://www.jianshu.com/p/deb28c22852a)

###  Span
#### 1. SpannableString、SpannableStringBuilder与String的关系
SpannableString、SpannableStringBuilder与String一样，可以保存字符串，但SpannableString、SpannableStringBuilder可以对这些字符串添加额外的样式信息，但String则不行。

#### 2.SpannableString与SpannableStringBuilder区别
SpannableStringBuilder类似于StringBuilder，它可以通过其append()方法来拼接多个String, 而SpannableString像一个String一样，构造对象的时候传入一个String，之后再无法更改String的内容

```
//使用SpannableString，必须一次传入，构造完成  
SpannableString word = new SpannableString("欢迎光临Harvic的博客");  
  
//使用SpannableStringBuilder,可以使用append()再添加  
SpannableStringBuilder multiWord = new SpannableStringBuilder();  
multiWord.append("欢迎光临");  
multiWord.append("Harvic的");  
multiWord.append("博客");
```
#### 3. SetSpan()

1. 设置点击事件
> 使用SpanableString添加点击事件需设置`TextView.setMovementMethod(LinkMovementMethod.getInstance());`

```
SpannableString spanableInfo = new SpannableString(agree);
spanableInfo.setSpan(new ClickableSpan()
            {
                @Override
                public void onClick(View arg0)
                {
                    /**
                     * 用户阅读注册协议
                     */
                    Intent intent = new Intent(context, WebBrowserActivity.class);
                    intent.putExtra(FoContents.TITLE, context.getString(R.string.agreement_content));
                    intent.putExtra(FoContents.URL, url);
                    context.startActivity(intent);
                }

                @Override
                public void updateDrawState(TextPaint ds)
                {
                    // TODO Auto-generated method stub
                    super.updateDrawState(ds);
                    // 背景色
                    ds.setColor(Color.parseColor("#5f81f7"));
                    // 是否设置下划线
                    ds.setUnderlineText(false);
                }

            }, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
```

2. 其他的文本格式化
```
/** 
* 超链接 
*/  
private void addUrlSpan() {  
    SpannableString spanString = new SpannableString("超链接");  
    URLSpan span = new URLSpan("tel:0123456789");  
    spanString.setSpan(span, 0, 3, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);  
    tv.append(spanString);  
}  
  
  
/** 
* 文字背景颜色 
*/  
private void addBackColorSpan() {  
    SpannableString spanString = new SpannableString("颜色2");  
    BackgroundColorSpan span = new BackgroundColorSpan(Color.YELLOW);  
    spanString.setSpan(span, 0, 3, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);  
    tv.append(spanString);  
}  
  
  
/** 
* 文字颜色 
*/  
private void addForeColorSpan() {  
    SpannableString spanString = new SpannableString("颜色1");  
    ForegroundColorSpan span = new ForegroundColorSpan(Color.BLUE);  
    spanString.setSpan(span, 0, 3, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);  
    tv.append(spanString);  
}  
  
  
/** 
* 字体大小 
*/  
private void addFontSpan() {  
    SpannableString spanString = new SpannableString("36号字体");  
    AbsoluteSizeSpan span = new AbsoluteSizeSpan(36);  
    spanString.setSpan(span, 0, 5, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);  
    tv.append(spanString);  
}  
  
  
/** 
* 粗体，斜体 
*/  
private void addStyleSpan() {  
    SpannableString spanString = new SpannableString("BIBI");  
    StyleSpan span = new StyleSpan(Typeface.BOLD_ITALIC);  
    spanString.setSpan(span, 0, 2, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);  
    tv.append(spanString);  
}  
  
  
/** 
* 删除线 
*/  
private void addStrikeSpan() {  
    SpannableString spanString = new SpannableString("删除线");  
    StrikethroughSpan span = new StrikethroughSpan();  
    spanString.setSpan(span, 0, 3, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);  
    tv.append(spanString);  
}  
  
/** 
* 下划线 
*/  
private void addUnderLineSpan() {  
    SpannableString spanString = new SpannableString("下划线");  
    UnderlineSpan span = new UnderlineSpan();  
    spanString.setSpan(span, 0, 3, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);  
    tv.append(spanString);  
}  
  
/** 
* 图片 
*/  
private void addImageSpan() {  
    SpannableString spanString = new SpannableString(" ");  
    Drawable d = getResources().getDrawable(R.drawable.ic_launcher);  
    d.setBounds(0, 0, d.getIntrinsicWidth(), d.getIntrinsicHeight());  
    ImageSpan span = new ImageSpan(d, ImageSpan.ALIGN_BASELINE);  
    spanString.setSpan(span, 0, 1, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);  
    tv.append(spanString);  
}  
```

项目实例

```
public class SpannableStringUtils {

    private static SpannableStringUtils instance = new SpannableStringUtils();

    public static SpannableStringUtils getInstance() {
        return instance;
    }

    private SpannableString spanString;

    public SpannableStringUtils setString(String content) {
        spanString = new SpannableString(content);
        return instance;
    }

    public SpannableStringUtils addForeColorSpan(int start, int end, int color) {

        if (null != spanString) {
            ForegroundColorSpan span = new ForegroundColorSpan(color);
            spanString.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        }

        return instance;
    }

    public SpannableStringUtils addClickSpan(int start, int end, Object span) {

        if (null != spanString) {

            spanString.setSpan(span, start, end, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        }

        return instance;
    }

    public void loadView(TextView tv) {

        if (null != spanString) {
            tv.setText("");
            tv.append(spanString);
        }
    }
}
```

### TextView.setError (CharSequence error, Drawable icon);
设置错误提醒, android API如下:

> Sets the right-hand compound drawable of the TextView to the specified icon and sets an error message that will be displayed in a popup when the TextView has focus. 

大致意思是: 调用此方法可以为TextView在右侧设置一个错误标识, 并且可以设置一个错误信息提示当获取到焦点的时候显示出来

EditText是TextView的子类,也可以调用此方法但是我写的demo中显示有区别, TextView中总也显示不出来错误提示:

### 使用TextSwitcher给TextView添加动画
[源码下载](http://pan.baidu.com/s/1bnmJX7L)

只需要以下几个简单步骤：
1. 通 过 findViewById() 方 法 获 取 TextSwitcher 对 象 的 引 用switcher，当然也可以直接在代码中构造该对象。
2. 通过 switcher.setFactory() 方法指定 TextSwitcher 的 View-Factory。
3. 通过 switcher.setInAnimation() 方法设置换入动画效果。
4. 通过 switcher.setOutAnimation() 方法设置换出动画效果

示例代码如下所示:

```
public class TextActivity extends Activity
{
    private static final String[] TEXTS = { "First", "Second", "Third" };
    /* 即将显示的文字下标 */
    private int mTextsPosition = 0;
    private TextSwitcher mTextSwitcher;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.text_layout);

        /* TextSwitcher控件初始化 */
        mTextSwitcher = (TextSwitcher) findViewById(R.id.your_textview);

        /* 指定ViewFactory */
        mTextSwitcher.setFactory(new ViewSwitcher.ViewFactory() {
            @Override
            public View makeView() {
                TextView t = new TextView(TextActivity.this);
                t.setGravity(Gravity.CENTER);
                return t;
            }
        });

        /* 加载显示动画 */
        mTextSwitcher.setInAnimation(this, R.anim.fade_in);
        /* 加载隐藏动画 */
        mTextSwitcher.setOutAnimation(this, R.anim.fade_out);

        onSwitchText(null);
    }

    /**
     * Button 按钮
     * @param v
     */
    public void onSwitchText(View v) {
        /* 切换文字内容 */
        mTextSwitcher.setText(TEXTS[mTextsPosition]);
        setNextPosition();
    }

    /**
     * 循环获取TEXTS数组的下标
     */
    private void setNextPosition() {
        mTextsPosition = (mTextsPosition + 1) % TEXTS.length;
    }
}
```

### 设置TextView字体
[源码下载](http://pan.baidu.com/s/1qW5qzso)
1. 首先下载需要的资源文件
2. 放到assets文件下
3. TextView类有setTypeface()方法可以设置文字的字体和风格
4. 

```
mName.setTypeface(Typeface.createFromAsset(getAssets(), "fonts" + File.separator + "gile.ttf"));
```

### TextView自动换行问题
android项目中的文字排版参差不齐的情况非常严重，textview自动换行导致混乱的原因是----半角字符与全角字符混乱所致！一般情况下，我们输入的数字、字母以及英文标点都是半角，所以占位无法确定。它们与汉字的占位大大的不同，由于这个原因，导致很多文字的排版都是参差不齐的。对此找到了两种办法可以解决这个问题： 
1. 将textview中的字符全角化。即将所有的数字、字母及标点全部转为全角字符，使它们与汉字同占两个字节，这样就可以避免由于占位导致的排版混乱问题了。 半角转为全角的代码如下，只需调用即可。 

```
/*** 半角转换为全角 
 *
 * @param input    
 * @return      
 */      
public static String ToDBC(String input) 
{          
	char[] c = input.toCharArray();
	for (int i = 0; i < c.length; i++)
	{              
		if (c[i] == 12288) 
		{                 
			c[i] = (char) 32;                  
			continue;
		}
		if (c[i] > 65280 && c[i] < 65375)
		{
			c[i] = (char) (c[i] - 65248);
		}	
	}
	return new String(c);
}  
```

2. 去除特殊字符或将所有中文标号替换为英文标号。利用正则表达式将所有特殊字符过滤，或利用replaceAll（）将中文标号替换为英文标号。则转化之后，则可解决排版混乱问题。 

```
/** 
 *去除特殊字符或将所有中文标号替换为英文标号
 * @param str
 * @return
 */
public static String stringFilter(String str) 
{         
	// 替换中文标号
	str = str.replaceAll("【", "[").replaceAll("】", "]")
             .replaceAll("！", "!").replaceAll("：", ":");
	String regEx = "[『』]"; // 清除掉特殊字符         
	Pattern p = Pattern.compile(regEx);
	Matcher m = p.matcher(str);
	return m.replaceAll("").trim();
}  
```

### 动态修改string.xml中的值
有些朋友可能会动态的修改Android中strings.xml文件中的值，在这里给大家推荐一种简单的方法。
strings.xml中节点是支持占位符的，如下所示：

```
<string name="data">整数型:%1$d，浮点型：%2$.2f，字符串:%3$s</string>
```

- `%n$ms`：代表输出的是字符串，n代表是第几个参数，设置m的值可以在输出之前放置空格 
- `%n$md`：代表输出的是整数，n代表是第几个参数，设置m的值可以在输出之前放置空格，也可以设为0m,在输出之前放置m个0 
- `%n$mf`：代表输出的是浮点数，n代表是第几个参数，设置m的值可以控制小数位数，如m=2.2时，输出格式为00.00 。并遵循`四舍五入`的特性。

简写为:
- `%d`：表示整数型；
- `%f` ：表示浮点型，其中f前面的.2表示小数的位数
- `%s`：表示字符串

在程序中我们可以通过下面的代码对字符串进行格式化，也就是填充占位符中的内容：

```
String data = getResources().getString(R.string.data);
data = String.format(data, 100, 10.3, "2011-07-01");
```

### 跑马灯效果
页面中只有`单个`TextView需要实现跑马灯效果，在TextView标签中设置如下属性：

```
android:singleLine="true"
android:ellipsize="marquee"
android:marqueeRepeatLimit="-1"
android:focusable="true"
android:focusableInTouchMode="true"
```

页面中只有`多个`TextView需要实现跑马灯效果，除在TextView标签中设置以上属性外，还需在代码中做如下设置：

```
tv.setFocusable(true);
tv.setHorizontallyScrolling(true);
tv.setFocusableInTouchMode(true);
tv.setSelected(true);
```

> 注意: `singleLine`不可替换为`maxLine`

### 特殊符号转义

- `...`：`&#8230;`
- ` `：`&#160;` 
- `<`：`&lt;`

> 注意：当在 `strings.xml` 文件中使用 `Html` 代码时，开括号（`<`）使用 `&lt;` 转义字符。

### TextView no padding
在代码中设置:

```
setIncludeFontPadding(false)
```

或者在`XML`中设置:

```
android:includeFontPadding="false"
```
这个属性的默认值是true.

### TextView 设置滑动
需要两步：
一、

```
android:scrollbars="vertical"
android:fadeScrollbars="true"
```

二、

```
TextView tv = findViewById(R.id.tv);          tv.setMovementMethod(ScrollingMovementMethod.getInstance());
```

相关属性：

| 属性      |     含义 |   可用值   |
| :--------: | :--------:| :------: |
| scrollbars    |   滚动方式 | none（隐藏）、horizontal（水平）、vertical(垂直)  |
| scrollbarThumbVertical[Horizontal] | 滑动条 | Shape自定、Drawable、图片、.9.png、@color/xxx色值 （不可以直接使用#xxxxxx颜色值） |
| scrollbarTrackVertical[Horizontal] | 背景条 | 同上 |
| scrollbarStyle | 滚动条的样式和位置 | insideOverlay、insideInset、outsideOverlay、outsideInset |
| scrollbarSize | 滚动条宽度 | dp、sp |
| fadeScrollbars | 滚动后是否隐藏滚动条 |  |
| scrollbarFadeDuration | 设置滚动条淡出效果（从有到慢慢的变淡直至消失）时间，以毫秒为单位 |  |
| scrollbarDefaultDelayBeforeFade | 设置N毫秒后开始淡化，以毫秒为单位 |  |

| 属性      |     含义 | 
| :--------: | :--------:| 
| insideOverlay | 默认值，表示在padding区域内并且覆盖在view上 |
| insideInset |	表示在padding区域内并且插入在view后面 |
| outsideOverlay | 表示在padding区域外并且覆盖在view上 |
| outsideInset | 表示在padding区域外并且插入在view后面 |
