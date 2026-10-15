## CSS display

@(CSS)

### 参考
[理解与应用css中的display属性](http://www.cnblogs.com/zhuzhenwei918/p/6058457.html)
[css Table 布局 - display:table](https://juejin.im/entry/57fb074c2e958a005590fb11)
[使用 CSS 弹性盒子](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_Flexible_Box_Layout/Using_CSS_flexible_boxes)

### 行内元素和块元素
既然要区分块级元素和行内元素，就得先说说标准文档流了。标准文档流：简称标准流，指的是在不使用其他的与排列和定位相关的css规则时，各种元素的排列规则。于是，我们将“各种元素”分为块级元素和行内元素。（注：实际上还有空元素，如`<br>`用于换行，`<hr>`为一条水平线，这里对空元素不做过多讨论）

#### 1. 块级元素特点：
- 总是以一个块的形式表现出来，占领一整行。若干同级块元素会从上之下依次排列（使用float属性除外）。
- 可以设置高度、宽度、各个方向外补丁（margin）以及各个方向的内补丁（padding）。
- 当宽度（width）缺省时，它的宽度时其容器的100%，除非我们给它设定了固定的宽度。
- 块级元素中可以容纳其他块级元素或行内元素。
- 常见的块级元素有`<p><div><h1><li>`等等。
- 块级元素的display属性值默认为block。

#### 2. 行内元素特点：
- 它不会单独占据一整行，而是只占领自身的宽度和高度所在的空间。若干同级行内元素会从左到右（即某个- - 行内元素可以和其他行内元素共处一行），从上到下依次排列。
- 行内元素不可以设置高度、宽度，其高度一般由其字体的大小来决定，其宽度由内容的长度控制。
- 行内元素只能设置左右的margin值和左右的padding值，而不能设置上下的margin值和上下的padding值。因- - 此我们可以通过设置左右的padding值来改变行内元素的宽度。
- 常见的行内元素有`<a><em><img>`等等。
- 行内元素一般不可以包含块级元素。
- 行内元素的display属性值默认为inline。

> 注意: 行内元素，默认按文字底部对齐。要改变这一默认行为可使用`vertical-align`属性

### display介绍
display属性是我们在前端开发中常常使用的一个属性，其中，最常见的有：
- none
- block
- inline
- inline-block
- inherit
- flex
- grid

#### 1. none
none这个值表示此元素将不被显示。比如，当我们在浏览网页时，如果看到了某个烦人的广告遮挡了我们的实现，更为可气的是，它还没有关闭的选项，这时（以chrome为例），我们就可以按下F12，打开开发者工具，点击element，然后使用左上角的选择工具选中想要删除的广告，可以看到element中会有高亮的一行或几行代码，右键，点击Add Attribute，然后输入：style="display:none"，这时就可以发现广告不见啦！ 当然display:none的用法绝不是专门用于这里的，它还可以用于二级下拉菜单的制作中将二级下拉菜单先设置位display:none;,当鼠标滑过一级菜单时，再显示出来（详见《如何实现导航菜单中的二级下拉菜单》）。还可以用于登陆模态框的制作等等。

#### 2. block
> 使用了display：block;之后， 此元素将显示为块级元素，此元素前后会带有换行符。

#### 3. inline
> 此元素会被显示为内联元素，元素前后没有换行符。

#### 4. inline-block
> 它是结合了inline和block的特性于一身。即设置了inline-block属性的元素既具有block元素可以设置width和height属性的特性，又保持了inline元素不换行的特性。

#### 5. inherit
> 规定从父元素继承 display 属性的值。

### display:table介绍

### display:flex介绍

### display:grid介绍
[CSS：Grid 布局](https://juejin.im/entry/5894135c8fd9c5a19507f6a1)
https://www.jianshu.com/p/d183265a8dad
https://www.jianshu.com/p/b90e4542b117

### 扩展

#### 1. 隐藏元素
- display:none：元素彻底消失，用户无法触发其点击事件（可使用js调用其点击事件）。
- visibility:hidden：无法触发其点击事件，有一种说法是display:none是元素看不见摸不着，而visibility:hidden是看不见摸得着，这种说法是不准确的，设置元素的visibility后无法触发点击事件，说明这种方法元素也是消失了，只是依然占据着页面空间。

#### 2. 制作导航栏

#### 去除inline-block元素间的空格
> 原理: 实际上，这是inline元素自身出现的问题，而inline-block结合了inline和block属性，当然也就存在这个问题了。这些空隙是空白符，在浏览器中，空白符是不会被浏览器忽略的，多个连续的空白符浏览器会自动将其合并成一个。我们编写代码时写的空格，换行都会产生空白符。所以自然而然的两个元素之间会有空白符，如果将上述例子中的a标签写成一行，空白符消失，菜单之间也就紧凑起来了。

方法1 : 使用注释符号

```
<div><span class="1">1</span></div><!--
--><div><span class="2">2</span></div><!--
 --><div><span class="3">3</span></div><!--
--><div><span class="4">4</span></div>
```

方法2 : 在父元素使用font-size
由于其本质是空白符的缘故, 所以可以再父元素使用font-size属性设置字体大小为0已到达消除空白符的效果, 但是使用这种方式必须在子元素中重新定义font-size属性不然文字将无法正常显示.

方法3:  letter-spacing / word-spacing
- letter-spacing : 字符间距
- word-spacing : 单词间距
