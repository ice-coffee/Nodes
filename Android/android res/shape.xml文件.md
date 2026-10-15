## shape.xml文件

```
<?xml version="1.0" encoding="utf-8"?>  
<shape  
    xmlns:android="http://schemas.android.com/apk/res/android"  
    android:shape=["rectangle" | "oval" | "line" | "ring"]   
    android:innerRadius="integer"  
    android:innerRadiusRatio="integer"  
    android:thickness="integer"  
    android:thicknessRatio="integer"  
    android:useLevel="boolean"  
    >  
    <corners  
        android:radius="integer"  
        android:topLeftRadius="integer"  
        android:topRightRadius="integer"  
        android:bottomLeftRadius="integer"  
        android:bottomRightRadius="integer" />  
    <gradient  
        android:angle="integer"  
        android:centerX="float"  
        android:centerY="float"  
        android:centerColor="integer"  
        android:endColor="color"  
        android:gradientRadius="integer"  
        android:startColor="color"  
        android:type=["linear" | "radial" | "sweep"]  
        android:useLevel=["true" | "false"] />  
    <padding  
        android:left="integer"  
        android:top="integer"  
        android:right="integer"  
        android:bottom="integer" />  
    <size  
        android:width="integer"  
        android:height="integer" />  
    <solid  
        android:color="color" />  
    <stroke  
        android:width="integer"  
        android:color="color"  
        android:dashWidth="integer"  
        android:dashGap="integer" />  
</shape>  
```

### shape节点
> 该节点有7个属性, 其中后5个是当`android:shape="ring"`时才有效的.

#### 1. shape属性
- line : 直线
- oval : 椭圆
- rectangle : 矩形
- ring : 圆环

#### 2. innerRadius属性
> 指定圆环内圆的半径
#### 3. innerRadiusRatio属性
> 该值是以比例的形式来指定内圆半径。内圆半径等于该shape的宽除以该值。或者说该值的倒数代表了内圆半径占整个shape宽的比例。默认值是9。当该值等于2的时候，内圆就将占满整个shape，从而我们将看不到圆环。
#### 4. thickness属性
> 指定圆环的宽窄，也就是内圆与外圆的距离。
#### 5. thicknessRatio属性
> 以比例的形式来指定圆环的宽窄。其算法与innerRadiusRatio相同。
#### 6. useLevel属性
> 值为true意味着这是一个levelListDrawable（关于levelListDrawable又是另一个话题了）。当我们要画一个圆环是，应当而且必须将该值设为false，否则会看不到画面。

### corners节点
> 只用于矩形`android:shape="rectangle"`，用于设置矩形的4个角的圆角半径，生成圆角矩形。

- android:radius——同时设置矩形4个角的圆角半径，如上图就是值为10dp的效果。
- android:topLeftRadius——左上角圆角半径
- android:topRightRadius——右上角圆角半径
- android:bottomLeftRadius——左下角圆角半径
- android:bottomRightRadius——右下角圆角半径

> 注意: 这四个单独的设置的值会覆盖android:radius设置的值。

### padding节点
> 内边距设置显示于该shape之上的内容与该shape的边界的距离。

### size节点
> `shape`属性的值不同时, size节点代表的含义不同

- rectangle ，设置矩形的宽高；
- oval ，设置椭圆外切矩形的宽高，当宽与高相等时，为正圆，否则为椭圆；
- line ，宽代表了直线的长度，高没有效果
- ring ，宽会影响内圆半径和圆环的宽窄，高没有效果。

> 注意: 当我们将一个shape drawable作为一个View组件的背景或是内容时，通常这个drawable都会被缩放。所以实际显示的时候可能与这里的size设置不相符。

### solid节点
> solid有“实心的，纯质的”的意思，比如solid gold意为“纯金”，solid color意味“纯色”。

这里这个节点只有一个属性——android:color，用这种颜色来填充该shape内部，如果不设置该shape的边框，就能得到一张纯色的drawable。

> 注意: 用于直线时无效。

### stroke节点
#### 1. width属性
> 边框线条的宽度，特别地，用于直线时设置直线的粗细。
#### 2. color属性
> 设置线条的颜色
#### 3. dashWidth属性
> 设置虚线效果里实点的长度
#### 4. dashGap属性
> 设置虚线效果里空白点的长度

### gradient节点
#### 1. startColor属性
> 渐变的起始颜色

#### 2. endColor属性
> 渐变的结束颜色

#### 3. type属性
> 设置渐变的类型

- linear(线性渐变)
- radial(径向渐变)
- sweep(扫描渐变)

> 注意: 使用radial渐变时还必须设置android:gradientRadius属性，即设置渐变区域（一个圆）的半径。
>
#### 4. angle属性
> 指定线性渐变的角度,  只用于线性渐变。 默认值是0，从左向右渐变。该属性的值必须是45的倍数，否则运行时error。这也意味着其实线性渐变只有8个方向：从左向右、左下到右上、从下向上、右下到左上、从右向左、右上到左下、从上向下、左上到右下。

#### 5. centerX属性
#### 6. centerY属性
> 用于径向渐变和扫描渐变，使用相对比例坐标设置渐变的中心点位置。取值范围为0到1。

#### 7. centerColor属性
> 设置渐变的中间颜色，即先由startColor渐变到centerColor，再由centerColor渐变到endColor。

> 注意: 
> - startColor或endColor二者如果都没有，则看不到渐变效果；如果只有其一，那么默认另一个就是白色。
> - 如果同时有<solid>节点填充，则写在后面的会覆盖写在前面的，让写在前面的设置无效。


### 参考
- [Shape Drawable的学习](http://blog.csdn.net/pingchuanyang/article/details/9230349)
