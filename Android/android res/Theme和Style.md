## Theme和Style

@(android res)

### 1. Theme
> 针对窗体级别, 可以改变窗体样式

Themes are Android's mechanism for applying a consistent style to an app or activity. The style specifies the visual properties of the elements that make up your user interface, such as color, height, padding and font size. To promote greater cohesion between all apps on the platform, Android provides three system themes that you can choose from when building apps for Ice Cream Sandwich:
主题是Android的机制被应用一个相同风格的应用程序或Activity中。样式指定了视觉属性的元素装饰你的用户界面,如颜色、高度、填充和字体大小。促进更大的凝聚力在所有平台的应用程序,Android提供了三个系统的主题,您可以选择在构建应用程序选择不同的主题:
- Holo Light
- Holo Dark
- Holo Light with dark action bars

#### 1.1 使用
Android系统的themes.xml和style.xml(位于/base/core/res/res/values/)包含了很多系统定义好的style，建议在里面挑个合适的，然后再继承修改。以下属性是在Themes中比较常见的，源自Android系统本身的themes.xml：

```
<style
   name="simple_dialog" parent="@android:style/Theme.Dialog">
       <item name="android:windowFrame">@null</item><!-- Dialog的WindowFrame框为无 -->
       <item name="android:windowNoTitle">true</item>
       <item name="android:windowIsFloating">true</item><!-- 是否悬浮在activity上 -->
       <item name="android:windowIsTranslucent">true</item><!-- 是否半透明 -->
       <item name="android:backgroundDimEnabled">false</item><!-- 背景是否模糊 -->
   </style>
```

#### 1.2 常用属性

- `android:windowFrame`：提供要在视图中所有元素`之上`显示的内容，可以是图片和颜色。
- `android:windowBackground`：提供要在试图中所有元素`之下`显示的内容，可以是图片和颜色。
- `android:windowNoTitle`：设置窗体无标题。
- `android:windowIsFloating`：设置窗口属性的宽高自适应还是其他。
- `android:windowIsTranslucent`：是否半透明 。
- `android:backgroundDimEnabled`：背景是否模糊 是否允许对话框的背景变暗，true：允许。
- `android:windowContentOverlay`：
- `android:windowFullScreen`：是否占用整个显示控件，包括状态栏部分。

### 2. Style
> 是针对窗体元素级别的，改变指定控件或者Layout的样式

A style is a collection of properties that specify the look and format for a View or window. A style can specify properties such as height, padding, font color, font size, background color, and much more. A style is defined in an XML resource that is separate from the XML that specifies the layout.
风格是一个集合的属性用于指定具有一定外观和格式的视图或窗口。一个风格可以指定属性如高度、填充、字体颜色、字体大小、背景色等等。一个样式定义在XML资源,独立于XML指定布局。

Styles in Android share a similar philosophy to cascading stylesheets in web design—they allow you to separate the design from the content.
风格在安卓中的份额就如同级联样式表在web设计中的设计，允许你将内容分割开来设计

#### 2.1 使用

正常的TextView控件书写方式
```
<TextView
    android:layout_width="fill_parent"
    android:layout_height="wrap_content"
    android:textColor="#00FF00"
    android:typeface="monospace"
    android:text="@string/hello" />

```
定义TextView风格
```
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="CodeFont" parent="@android:style/TextAppearance.Medium">
        <item name="android:layout_width">fill_parent</item>
        <item name="android:layout_height">wrap_content</item>
        <item name="android:textColor">#00FF00</item>
        <item name="android:typeface">monospace</item>
    </style>
</resources>

<TextView
    style="@style/CodeFont"
    android:text="@string/hello" />
```

### dialog
