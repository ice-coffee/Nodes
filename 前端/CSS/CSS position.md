## CSS position

@(CSS)


### 参考
[css绝对定位、相对定位和文档流的那些事](http://www.cnblogs.com/tim-li/archive/2012/07/09/2582618.html)
[CSS绝对定位absolute详解](http://www.jianshu.com/p/a3da5e27d22b)

### 文档流
html的布局机制就是用文档流模型的，即块元素（block）独占一行，内联元素（inline）不独占一行

### 属性值

#### static
默认值, 一个 static 元素表示它不会被“positioned”，一个 position 属性被设置为其他值的元素表示它会被“positioned”。

#### fixed
一个固定定位（position属性的值为fixed）元素会相对于视窗来定位，这意味着即便页面滚动，它还是会停留在相同的位置。和 relative 一样， top 、 right 、 bottom 和 left 属性都可用。
一个固定定位元素不会保留它原本在页面应有的空隙（脱离文档流）。

令人惊讶地是移动浏览器对 fixed 的支持很差。[这里有相应的解决方案](http://bradfrost.com/blog/mobile/fixed-position/)。

#### relative
相对定位就是相对于元素本身来定位, 在一个相对定位（position属性的值为relative）的元素上设置 top 、 right 、 bottom 和 left 属性会使其偏离其正常位置。但是相对定位属性的元素并没有脱离文档流, 所以元素本身所占的位置会保留. 

![Alt text](<../../attachment/:2012070915493457.jpg>)

#### absolute
所谓绝对定位，其实也要找个东西来相对来绝对的，而这个东西就是元素的第一个有position，且positon不能为static的祖先元素. 注意绝对定位属性的元素是脱离文档流的, 所以重新定位后元素是不会占着原来的位置的. 
![Alt text](<../../attachment/:2012070916382133.jpg>)


### 应用

#### 右上角红色圈圈

![Alt text](<../../attachment/:1508248995145.jpg>)

```
<div style="margin-top: 200px;">
	<img src="img_1.jpeg">
	<span class="tipIcon2">X</span>
</div>
```

```
.tipIcon2 {
  background-color: #f00;
  color: #fff;
  border-radius:50%;
  text-align: center;
  position: absolute;
  width: 20px;
  height: 20px;
  margin:-10px 0 0 -10px;   //用margin来进行偏移
}
```
