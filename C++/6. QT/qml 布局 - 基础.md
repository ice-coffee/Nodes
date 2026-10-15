[toc]

## 常见元素

### 属性
#### 通用属性

* `id`：标识符。

几何：

* `x,y`：坐标，定义了元素左上角的位置。
* `width,height`：长和宽，可设置值有：
    1. 不设置 - 宽度自适应；
    2. 具体值；
    3. `parent.width/parent.height` - 填充父布局。
* `implicitWidth,implicitHeight`：默认宽高。
* `z`：堆叠次序，定义元素之间的重叠顺序。

布局：
`anchors`：锚定属性组，包括

* `left` - 左，`right` - 右，`top` - 上，`bottom` - 下。
* `verticalCenter，horizontalCenter`：水平与垂直居中。
* `margins`：`leftMargin`、`rightMargin`、`topMargin`、`bottomMargin`，需配合相应 `anchors.left` 使用。
* `padding`：`qml` 当前没有 `padding` 属性，可以使用 `margins` 模拟效果。
* `fill`：填充父布局。

使用时以目标组件为参照物，例如：

```qml
// Text 位于父布局底部水平居中
Rectangle {
    width: 500; height: 200
    color: "lightgray"

    Text {
        id: helloText
        text: "Hello world!"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        font.pointSize: 24; font.bold: true
    }
}
```

按键：

* `key`：按键。
* `keyNavigation`：按键定位。
* `focus`：焦点。

动画：

* `scale`：缩放。
* `rotate`：旋转。
* `transform`：通用的x,y,z属性列表转换。
* `transformOrigin`：旋转基点设置。

可视化：

* `opacity`：不透明度。
* `visible`：是否可见。
* `clip`：裁剪，用来限制元素边界的绘制。
* `smooth`：平滑，用来提高渲染质量。

状态：
states（状态列表属性）提供了元素当前所支持的状态列表，当前属性的改变也可以使用transitions（转变）属性列表来定义状态转变动画。

`childrenRect`：
`Item`类型的属性，它提供了以下属性用于描述包围子项的矩形：

* x: 矩形的左上角的 x 坐标相对于其父项的左上角。
* y: 矩形的左上角的 y 坐标相对于其父项的左上角。
* width: 矩形的宽度。
* height: 矩形的高度

`parent`：
通过 `parent` 可以访问父布局属性，例如 `parent.width、parent.height` 等。

#### 自定义属性

property type name: value

### 容器

#### Window

`Window`
`ApplicationWindow`

#### Item
基本元素对象，通常被用来作为其它元素的容器使用，类似HTML语言中的div元素（div element）。

#### Rectangle
矩形框，是基本元素对象的一个扩展。

属性：
`color`：填充颜色。可使用 `RGB` 字符串，或色值名称。
`border`：边界（属性组）。它包含一组属性 border.color（边界颜色），border.width（边界宽度）。
`radius`：圆角半径。

### 控件

#### Text
文本组件。

属性：
`text`：内容。
`font`：字体（属性组），font.family（字体），font.pixelSize（大小）。
`style`：文字边框效果（属性组）。

#### Image
图像组件

属性：
`source`：资源文件路径。可以是本地地址，也可以是网络地址。
`fillMode`：资源文件模式，可用于调整图像模式。

### 定位元素

`Row`：行

* spacing：设置元素间隔

`Column`：列

* spacing：设置元素间隔

`Grid`：格

* rows：行数
* columns：列数
* rowSpacing：行间隔
* columnSpacing：列间隔

`Flow`：流

* flow：布局方式

```qml
flow:Flow.LeftToRight //默认从左到右排列
flow:Flow.TopToBottom //从上到下排列
```

## 阴影 DropShadow
加载组件：
```qml
import QtGraphicalEffects 1.0
```

使用 1：在Item中，DropShadow和源组件并列，通过source和anchors与源组件关联。
```qml
import QtQuick 2.12
import QtGraphicalEffects 1.12

Item {
  width: 300
  height: 300

  Rectangle {
      anchors.fill: parent
  }

  Image {
      id: butterfly
      source: "images/butterfly.png"
      sourceSize: Qt.size(parent.width, parent.height)
      smooth: true
      visible: false
  }

  DropShadow {
      anchors.fill: butterfly
      horizontalOffset: 3
      verticalOffset: 3
      radius: 8.0
      samples: 17
      color: "#80000000"
      source: butterfly
  }
}
```

使用 2：在Rectangle中，DropShadow作为layer.effect的属性值，直接与Rectangle关联。
```qml
 Rectangle {
     id:showWin
     visible: true
     width:100
     height: 100
     x: (parent.width - width)/2
     y: (parent.height - height)/2
     color: color_SSMAN_GRAY
     radius: 10
     layer.enabled: true  // 设置layer为enable
     layer.effect: DropShadow {
         transparentBorder: true
         color: "black"
         samples:100
   	 }
 }
```

参数介绍：

* cached：是否需要缓存，默认为false，如果设置为True，则占用内存
* color：阴影对应的颜色，默认为black
* horizontalOffset：阴影在水平方向的偏移，-10代表往左边偏移10像素，10代表往右偏移10像素
* verticalOffset：竖直阴影的偏移
* radius：阴影边缘模糊的半径，默认为0
* samples：此属性定义在执行边缘软化模糊计算时，每个像素采集的采样数。值越大，质量越好，但渲染速度越慢。
* source：源组件
* spread：阴影边缘的扩散，值越大，扩散越大
* transparentBorder：边缘是否透明处理


## 动画


## 附
[qml教程](https://cwc1987.gitbooks.io/qmlbook-in-chinese/content/quick_starter/qmlqml_syntax.html)
[QML DropShadow介绍](https://blog.csdn.net/PRML_MAN/article/details/113561736)
