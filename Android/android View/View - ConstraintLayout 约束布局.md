[toc]
## 说明
约束布局（ConstraintLayout）提供如下功能：

* `Relative positioning`：相对定位
* `Margins`：边距
* `Centering positioning and bias`：居中定位和偏移
* `Circular positioning`：角度定位
* `Visibility behavior`：可见性
* `Dimension constraints`：尺寸限制
* `Chains`：链表
* `Virtual` Helpers objects：辅助工具
* `Optimizer`：优化器

转自：
[ConstraintLayout 使用介绍](https://zhuanlan.zhihu.com/p/86848687)

## 使用
### 相对定位
相对定位及相对于另一个 `View` 在布局中的位置，类似于 `RelativeLayout`。

![07ee3430178f1d7652c467dca8f1fa5a.jpeg](<../../attachment/1690002463100.jpg>)@w=300

用于控制相对定位的参数列表如下：

* layout_constraintLeft_toLeftOf
* layout_constraintLeft_toRightOf
* layout_constraintRight_toLeftOf
* layout_constraintRight_toRightOf
* layout_constraintTop_toTopOf
* layout_constraintTop_toBottomOf
* layout_constraintBottom_toTopOf
* layout_constraintBottom_toBottomOf
* layout_constraintStart_toEndOf
* layout_constraintStart_toStartOf
* layout_constraintEnd_toStartOf
* layout_constraintEnd_toEndOf
* layout_constraintBaseline_toBaselineOf

其中 `layout_constraintBaseline_toBaselineOf` 表示文本基线对齐，由于不同国家的习惯更推荐使用 `start` 和 `end` 而不是 `left` 和 `right`。

### 边距

`ConstraintLayout` 支持除普通的 `margin` 属性外还支持 `goneMargin`：

* layout_goneMarginStart
* layout_goneMarginEnd
* layout_goneMarginLeft
* layout_goneMarginTop
* layout_goneMarginRight
* layout_goneMarginBottom
* layout_goneMarginBaseline

`goneMargin` 只有在约束控件不可见时生效：

```xml
<TextView
    android:id="@+id/tv_01" .../>

<TextView
    android:id="@+id/tv_02" ...
    app:layout_constraintLeft_toRightOf="@id/tv_01"
    app:layout_goneMarginLeft="20dp" />
```
`tv_01` 可见时布局效果如下：
![566c1c55759f35e85dca40f05daeb0b2.jpeg](<../../attachment/1690003285902.jpg>)@w=300
`tv_01` 不可见时布局效果如下：
![bbedb96af7a442a5ee7ef52e6e11c4ea.jpeg](<../../attachment/1690003299320.jpg>)@w=300

### 居中定位和偏移
`ConstraintLayout` 中没有专门用于居中定位的参数，但可以通过其它参数实现，例如横向居中：

```xml
<Button android:id="@+id/buttonA" ... 
    app:layout_constraintLeft_toLeftOf="parent"
    app:layout_constraintRight_toRightOf="parent"/>
```

垂直居中：
```xml
<Button android:id="@+id/buttonA" ... 
    app:layout_constraintTop_toTopOf="parent"
    app:layout_constraintBottom_toBottomOf="parent"/>  
```

有时候我们或许不仅仅需要设置居中，而是按照比例的靠左或靠右，`ConstraintLayout` 提供了两个用于设置偏移的参数：

* layout_constraintHorizontal_bias：水平偏移
* layout_constraintVertical_bias：垂直偏移

我们设置下面的按钮左侧有 30% 的偏移而不是默认的 50%：

```xml
<Button android:id="@+id/button" ...
    app:layout_constraintHorizontal_bias="0.3"
    app:layout_constraintLeft_toLeftOf="parent"
    app:layout_constraintRight_toRightOf="parent/>
```

![688bc9ac741aed1645d7e58fd5b2b20f.jpeg](<../../attachment/1690004132961.jpg>)@w=300

### 角度定位
角度定位类似相对定位，其思想是，通过对控件设置圆心、角度、半径来表达控件的位置，如果我们知道一个控件的位置，那么距离这个控件 100dp，角度为 150° 方向的位置肯定也是确定的了。

![8f9d6cc50e3f8a0dc28338c6055044f5.jpeg](<../../attachment/1690004383605.jpg>)@w=300

用于角度定位的参数有如下三个：

* layout_constraintCircle : 圆心的控件 ID
* layout_constraintCircleRadius : 半径，也就是该控件距离圆心控件的位置
* layout_constraintCircleAngle : 角度

```xml
<Button android:id="@+id/buttonA" ... />
<Button android:id="@+id/buttonB" ...
  app:layout_constraintCircle="@+id/buttonA"
  app:layout_constraintCircleRadius="100dp"
  app:layout_constraintCircleAngle="45" />
```

### 更适用于 `ConstraintLayout` 的尺寸限制
`ConstraintLayout` 提供了一些更适应自身的尺寸限制，例如：

* match_parent：MATCH_CONSTRAINT
* min/maxWidth：layout_constraintWidth_min

它们的效果是相同的，只是更适应于 `ConstraintLayout` 自身的特性。

#### match_parent
`ConstraintLayout` 不推荐使用 `match_parent`，建议使用 `0dp（MATCH_CONSTRAINT）` + 上下/左右约束为父布局的方式替代。 

![ee486f9302b101d96277f4d23a7a14e9.jpeg](<../../attachment/1690005250433.jpg>)@w=300

代码示例：
```xml
<TextView
    android:id="@+id/tv_01"
    android:layout_width="0dp"
    android:layout_height="wrap_content"
    android:layout_marginStart="10dp"
    app:layout_constraintTop_toTopOf="parent"
    app:layout_constraintRight_toRightOf="parent"
    app:layout_constraintLeft_toLeftOf="parent" />
```

#### min/maxWidth

* layout_constraintWidth_min
* layout_constraintHeight_min
* layout_constraintWidth_max
* layout_constraintHeight_max

#### 百分比

* 使用 `MATCH_CONSTRAINT`.
* 设置 app:layout_constraintWidth/height_default="percent".
* 设置 app:layout_constraintWidth/height_percent 属性，取值 `0 ~ 1`.

#### 宽高比
当宽高至少有一个设置为 `0dp` 时即可设置宽高比。设置宽高比为 `1:1`：

```xml
<Button 
    android:layout_width="wrap_content"
    android:layout_height="0dp"
    app:layout_constraintDimensionRatio="1:1" />
```

该参数还支持在前缀添加 `W` 或者 `H` 来描述宽高限制：

* `"H,1:2"`：高:宽=1:2
* `"W,1:2"`：宽:高=1:2

#### layout_constrainedWidth/Height：强制布局约束
在 `ConstraintLayout 1.1` 以上，对于 `wrap_content` 会超过约束限制（常见于 `TextView`），谷歌又新增了如下属性：

* app:layout_constrainedWidth=”true|false”
* app:layout_constrainedHeight=”true|false”

设置为 `true` 可以限制内容不超过约束。

例如，需求希望布局内有两个文本控件：textA、textB。控件宽高自适应textB位于textA右侧，且textB右边界不超过父布局。根据需求编写如下：

```xml
<TextView
    android:id="@+id/textA"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="文本A："
    android:background="#ffb300"
    />

<TextView
    android:id="@+id/textB"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="文本B这是一段内容，在标题的下方并且开始位置是从标题的右侧开始并且需要保证右侧跟parent的右侧约束。"
    android:background="#b7ff00"
    app:layout_constraintTop_toBottomOf="@id/textA"
    app:layout_constraintLeft_toRightOf="@id/textA"
    app:layout_constraintRight_toRightOf="parent"
    />
```

![5b7737065852ce03ad7874314ee59b15.png](<../../attachment/E23C2B94-460C-43E4-972B-7AF51371D075.png>)

效果和想象中不一致，添加 `layout_constrainedWidth` 效果如下：

```xml
<TextView
    android:id="@+id/textA"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="文本A："
    android:background="#ffb300"
    />

<TextView
    android:id="@+id/textB"
    ......
    app:layout_constraintTop_toBottomOf="@id/textA"
    app:layout_constraintLeft_toRightOf="@id/textA"
    app:layout_constraintRight_toRightOf="parent"
    app:layout_constrainedWidth="true"
    />
```

![4e0ab7646917f268f2c7a2e4c070729d.png](<../../attachment/D6EDE501-67AF-470A-9C1A-ED2FB27E7B07.png>)

> 观察总结：未设置 `layout_constrainedWidth` 时，`textB` 宽度和父布局宽度一致。

### 链表定位
链表定位将一组在同一条轴线上的控件描述为一组控件，并且对这些控件使用统一的约束。：
> 我们不需要显示的将一组控件设置为链，一组控件如果通过双向连接连接在一起，则将它们视为一条链。（下图是横向的，竖向的同理）：

![fdaf7a915dd52eddbdc842de13697c0b.jpeg](<../../attachment/1690004480175.jpg>)@w=300

代码如下：
```xml
<TextView
    android:id="@+id/tv_01" ...
    app:layout_constraintTop_toTopOf="parent"
    app:layout_constraintLeft_toLeftOf="parent"
    app:layout_constraintRight_toLeftOf="@id/tv_02" />
<TextView
    android:id="@+id/tv_02" ...
    app:layout_constraintBaseline_toBaselineOf="@id/tv_01"
    app:layout_constraintLeft_toRightOf="@id/tv_01"
    app:layout_constraintRight_toLeftOf="@id/tv_03" />
<TextView
    android:id="@+id/tv_03" ...
    app:layout_constraintBaseline_toBaselineOf="@id/tv_02"
    app:layout_constraintLeft_toRightOf="@id/tv_02"
    app:layout_constraintRight_toRightOf="parent" />
```

上面的三个控件互相约束依赖，形成一个链。链表的第一个控件可称为链表的头（head）：

![abb0762a90fa0a48273f91b419ec59c9.jpeg](<../../attachment/1690015975545.jpg>)@w=400

我们可以在链表头中使用 `layout_constraintHorizontal_chainStyle` 或者 `layout_constraintVertical_chainStyle` 对改变链表的样式。其支持如下四种风格：

* `spread`（默认）：展开元素，元素将均匀的分配到链中。
* `spread_inside`：类似 `spread`，但两边的元素会贴着父布局。
* `packed`：元素会居中在一起，中间没有空隙。
* `weighted chain`：权重链表，在 `spread` 模式下，如果某些控件设置为 `MATCH_CONSTRAINT`，则可以通过 `layout_constraintHorizontal_weight` 和 `layout_constraintVertical_weight` 设置控件权重。

![210c7a2da22f5eafc391d334f37af5e9.jpeg](<../../attachment/E4F6A9BE-D07A-492B-B40F-14A8E4A32F37.jpg>)

至于最后一种，当设置为 `packed` 风格时，可以通过设置 `bias` 来更改控件的偏移位置。

### 辅助工具

#### Space
`Space` 是一个不可见的空间视图且不会触发任何点击事件，用于在布局中添加空间或间距。

```xml
<Space
    android:layout_width="10dp"
    android:layout_height="10dp" />
```

常见用途：

* 创建固定间距：Space 可用于在视图之间创建固定的间距，而不必使用多余的视图或分隔线。
* 对齐和布局调整：在复杂的布局中，有时需要在视图之间添加间距以调整它们的对齐和布局。
* 替代 padding：有时 Space 可以用于代替 padding，以便更好地控制视图之间的间距。

#### Guideline
`Guideline` 是辅助线，用于辅助我们完成控件的摆放，但跟其他控件不同的是，`Guideline` 不会显示在页面上。

在使用时需要先指定 Guideline 的方向，使用 `orientation` 来设置：

* `vertical`：垂直辅助线。
* `horizontal`：水平辅助线。

Guideline 支持如下几个参数：

* `layout_constraintGuide_begin`：距离父布局左边（或顶部）的距离
* `layout_constraintGuide_end`：右边距离父布局（或底部）的距离
* `layout_constraintGuide_percent`：右边距离父布局（或底部）的百分比

```xml
<androidx.constraintlayout.widget.Guideline
    android:id="@+id/guideline"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    app:layout_constraintGuide_percent="0.5" />

<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="TextView"
    app:layout_constraintTop_toTopOf="parent"
    app:layout_constraintStart_toStartOf="@id/guideline"/>
```

![d87e057869d735746437725c14afdd7d.png](<../../attachment/5CE77497-2A9F-4DF2-A9FA-3C3383BDBCBD.png>)@w=300

#### Barrier
`Barrier` 用于确定一组控件的最小边界。

```xml
<android.support.constraint.Barrier
    android:id="@+id/barrier"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    app:barrierDirection="end"
    app:constraint_referenced_ids="button1,button2" />
```

![460c906f39b32a3e0924b248c98c2f0b.png](<../../attachment/445AE0B0-E44D-46DF-8419-F7DF27B7732B.png>)@w=400

#### Group
`group` 用来将几个控件归为一组，便于统一控制显示状态。

```xml
<androidx.constraintlayout.widget.Group
    android:id="@+id/group"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:visibility="visible"
    app:constraint_referenced_ids="button4,button9" />
```

`constraint_referenced_ids` 中引用的 id 将会被归为一组，对 `group` 的可见性设置将会影响到改组控件。

#### Placeholder
`Placeholder` 用于在运行时动态替换为其他视图，从而实现布局的变化和交互效果。

### 优化器
大多为实验性

## 应用
### 在 Constraintlayout 中实现 View 压盖
使用 `Space` 增加偏移量，间接实现 `负margin`
```xml
<View
    android:id="@+id/view_1"
    android:layout_width="100dp"
    android:layout_height="100dp"
    android:background="@android:color/holo_red_light"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toTopOf="parent" />

<Space
    android:id="@+id/space"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:layout_marginBottom="50dp"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintBottom_toBottomOf="@id/view_1"/>

<View
    android:id="@+id/view_2"
    android:layout_width="100dp"
    android:layout_height="100dp"
    android:background="@android:color/holo_blue_light"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toBottomOf="@id/space" />
```

![316fa7c594021c06d4b288bac462973c.png](<../../attachment/AC528444-9C9C-49BF-AABC-55D0B0339EF5.png>)@w=100
