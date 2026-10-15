## css 居中

@(CSS)

### 参考
[css中关于居中的那点事儿](http://www.cnblogs.com/zhuzhenwei918/p/6058086.html)
[用display:table实现居中对齐](https://codepen.io/feiwen8772/pen/kkyRqZ)
[CSS布局:动态水平居中对齐](https://codepen.io/feiwen8772/pen/ALRmpj)

### 水平居中

```
*{margin:0;padding: 0;}
.parent { width: 500px; height: 500px; background: #333; }
.child { background: #ff3422; }

/*-----------------------行内元素-----------------------*/
.child { display: inline; }

/*1. 在行内元素外面的块元素的样式中添加：text-align:center;*/
/*注意：对于某个块元素的居中，不能在其父元素的样式中设置text-align:center，这是无效的。*/
.parent { text-align: center; }

/*-----------------------块元素--------------------------*/
/*.child { display: block; }*/

/*1. 左右两边的外补丁为auto*/
/*.child { height: 100px; width: 100px; margin: 0 auto; }*/

/*------------------------通用--------------------------*/
/*再动态元素上应用display:table 和 margin: auto*/
.parent { display: table; margin: auto; }
```

### 垂直居中

```
*{margin:0;padding: 0;}
.parent { width: 500px; height: 500px; background: #333; }
.child { background: #ff3422; }

/*-----------------------行内元素-----------------------*/
.child { display: inline; }

/*1. */
.child { vertical-align: middle; }

/*------------------------块元素------------------------*/
/*.child { display: block; }*/
/*.child { height: 100px; width: 100px; }*/
```

### 水平垂直居中

```
*{margin:0;padding: 0;}
.parent { width: 500px; height: 500px; background: #333; }
.child { background: #ff3422; }

/*-----------------------行内元素-----------------------*/
/*.child { display: inline; }*/

/*1. 垂直水平居中*/
/*.parent { text-align: center; }*/
/*.child { line-height: 500px; }*/

/*-----------------------块元素--------------------------*/
/*.child { display: block; }*/
/*.child { height: 100px; width: 100px; }*/

/*------------------------通用--------------------------*/
/*1. 使用css弹性盒子*/
.parent { display: flex; align-items:center;  justify-content:center; }

/*2. 使用css弹性盒子*/
/*.parent { display: flex; }*/
/*.child { margin: auto; }*/

/*3. 标签元素以表格单元格的形式呈现，类似于td标签*/
/*注意的是：table-cell会被其他一些css属性破坏，比如float和position:absolute等等。且一旦设置位table-cell，这时margin就不能用了。这种方法也可以用于块级元素的垂直居中。*/
/*.parent { display: table-cell; vertical-align: middle; text-align: center; }*/
```

### 属性介绍
#### align-items  
> 在`弹性盒模型`中定义flex子项在flex容器的当前行的`侧轴`（纵轴）方向上的对齐方式。

#### justify-content 
> 在`弹性盒模型`中定义flex子项在flex容器的当前行的`主轴`（横轴）方向上的对齐方式。

#### vertical-align
> 设置`行内元素`的`垂直`对齐方式。

#### text-align
> 设置`块级元素`内`文本`的`水平`对齐方式。
