[toc]
### 关联地址
[CoordinatorLayout](https://developer.android.com/reference/androidx/coordinatorlayout/widget/CoordinatorLayout)

[细说 AppbarLayout,如何理解可折叠 Toolbar 的定制](https://blog.csdn.net/briblue/article/details/77075198)

[coordinatorLayout使用总结篇，看完这篇完全可以开发5.0的高级特效了](https://segmentfault.com/a/1190000015340856)

[支付宝首页滑动](https://github.com/taixiang/alihome)

[自定义behavior](https://github.com/zoonooz/simple-view-behavior)

### CoordinatorLayout + AppBarLayout + CollapsingToolbarLayout + Toolbar
在布局中经常会看到使用 `CoordinatorLayout` + `AppBarLayout` + `CollapsingToolbarLayout` + `Toolbar` 实现一些联动布局，那么这些都是什么要怎么用呢，一个一个来看。

#### 导入
`AppBarLayout` 和 `CollapsingToolbarLayout` 都是由 `Material Design` 包提供，项目使用时要先导入包：
```
implementation 'com.android.support:design:x.x.x'
```
AndroidX方式：
```
implementation 'com.google.android.material:material:1.2.1'
```

#### CoordinatorLayout
根据官方文档的描述 `CoordinatorLayout` 可以看做 `FrameLayout` 来用。主要应用如下：
* 作为顶层布局。
* 作为一个或多个子View间特定交互的容器。

`CoordinatorLayout` 实现子 `View` 间的交互通过如下三种方式：
* `anchor`
* `insetEdge`
* `Behaviors`

##### anchor
`CoordinatorLayout` 的子 `View` 可以设置 `anchor (view id)` 作为锚点，当 `anchor` 指定的 `View` 移动时，此 `View` 也会跟随移动。可作为锚点的必须是 `CoordinatorLayout` 的子孙 `View`。

示例如下：
```
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    xmlns:app="http://schemas.android.com/apk/res-auto">

    <View
        android:id="@+id/move_view"
        android:layout_gravity="center"
        android:background="@color/blue"
        android:layout_width="100dp"
        android:layout_height="100dp"/>

    <View
        android:layout_width="100dp"
        android:layout_height="100dp"
        android:background="@color/color_90b3b3b3"
        app:layout_anchor="@id/move_view"
        app:layout_anchorGravity="clip_vertical"/>

</androidx.coordinatorlayout.widget.CoordinatorLayout>
```

示例中还用到了 `layout_anchorGravity` 属性，用于设置相对于锚点的位置。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layout_anchor.gif)

##### insetEdge
`View A` 通过 `layout_insetEdge` 来设置插入 `CoordinatorLayout` 的方向，`View B` 通过设置`layout_dodgeInsetEdges` 来躲避来自相同方向的 `View A`，这样就可以避免产生重叠。

示例如下：
```
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    xmlns:app="http://schemas.android.com/apk/res-auto">

    <View
        android:id="@+id/move_view"
        android:layout_gravity="center"
        android:background="@color/blue"
        android:layout_width="100dp"
        android:layout_height="100dp"
        app:layout_insetEdge="right"/>

    <View
        android:layout_width="100dp"
        android:layout_height="100dp"
        android:layout_gravity="center_vertical"
        android:background="@color/color_90b3b3b3"
        app:layout_dodgeInsetEdges="right"/>

</androidx.coordinatorlayout.widget.CoordinatorLayout>
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layout_insetEdge.gif)

> `FloatingActionButton` 和 `Snackbar` 就和 `insetEdge` 有关。

##### Behaviors
通过为 `CoordinatorLayout` 的子 `View` 指定 `Behaviors`，可以指定子 `View` 的交互方式，也可以指定子 `View` 间彼此的交互方式。

详细 `Behaviors` 在下面👇介绍。

#### AppBarLayout
`AppBarLayout` 的本质是一个实现了 `CoordinatorLayout.AttachedBehavior` 接口的 `LinearLayout`，可以设置实现一些奇妙的滑动效果。

应用如下：
* 作为 `CoordinatorLayout` 的直接子 `View` 使用，否则它与普通的 `LinearLayout` 无异。
* `AppBarLayout` 的直接子 `View` 可以设置 `layout_scrollFlags` 属性改变其滑动行为。`Appbarlayout` 会响应外部的嵌套滑动事件，然后根据特定的规则去伸缩和滑动内部的子 `View`。
* `AppbarLayout` 的子 `View` 不仅仅可以是 `Toolbar`, 它们还可以是任何的 `View`。

`layout_scrollFlags` 属性可设置的值如下：
* `scroll`：必设
* `enterAlways`
* `enterAlwaysCollapsed`
* `exitUntilCollapsed`
* `snap`
* `snapMargins`

> 注意：其他的属性都是建立在滑动的基础之上的，所以 `scroll` 值是必需的。
> `app:layout_scrollFlags="scroll|enterAlways"`

基本使用如下：

`scroll`
当前 `View` 将和滑动事件关联。`layout_scrollFlags` 属性必须设置 `scroll` 不然设置其他值也没用

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layout_scrollFlags_scoll.gif)

`scroll|enterAlways`
当滑动组件下滑该 `View` 也会下滑。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layout_scrollFlags_enterAlways.gif)

`scroll|enterAlways|enterAlwaysCollapsed`
需和 `enterAlways` 一起使用来增强 `enterAlways` 功能，当滑动组件下滑该 `View` 将先滑动显示 `minHeight` 高度，滑动组件继续滑动到最顶端时该 `View` 才会继续下滑。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layout_scrollFlags_enterAlwaysCollapsed.gif)

`scroll|exitUntilCollapsed`
当滑动组件上滑时该 `View` 也会上滑，直到其高度缩小到 `minHeight` 后不再响应上滑事件。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layout_scrollFlags_exitUntilCollapsed.gif)

`scroll|snap`
滑动超过该 `View` 一半或者未超过一半时松手会自动滑动上滑和下滑。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layout_scrollFlags_snap.gif)

`scroll|snap|snapMargins`
需和 `snap` 一起使用来增强 `snap` 功能，当设置 `layout_marginBottom`、`layout_marginTop` 时需设置 `snapMargins`。

##### 滑动监听
AppBarLayout滑动监听器。

```
appBarLayout.addOnOffsetChangedListener((appBarLayout, verticalOffset) -> {
    //垂直方向偏移量
    int offset = Math.abs(verticalOffset);
    //最大偏移距离
    int scrollRange = appBarLayout.getTotalScrollRange();
});
```

#### CollapsingToolbarLayout
`CollapsingToolbarLayout` 是 `Toolbar` 的封装，实现了一个折叠的 `app bar`。`CollapsingToolbarLayout` 应作为 `AppBarLayout` 的子类使用，使用如下：

> 注意：`CollapsingToolbarLayout` 是为了增强 `Toolbar` ，所以 `Toolbar` 需添加到 `CollapsingToolbarLayout` 布局中以上属性才能生效。

自身可用属性：
* `app:title`：设置的 `title` 会随着滑动其大小和位置会发生变化。
* `app:contentScrim`：当 `CollapsingToolbarLayout` 折叠时会使用设置的颜色遮罩布局内的 `View`。
* `app:statusBarScrim`：当 `CollapsingToolbarLayout` 折叠时会使用设置的颜色遮罩手机的状态栏。
* `app:collapsedTitleTextAppearance`：折叠时title的样式里面可以定义字体大小颜色等。
* `app:expandedTitleTextAppearance`：展开时title的样式里面可以定义字体大小颜色等。

> 注意：`statusBarScrim` 但是仅可在 `Lollipop` 版本使用，还需设置 `android:fitSystemWindows="true"`。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/CollapsingToolbarLayout.gif)

子View可用属性
`app:layout_collapseMode`：子 `View` 的折叠模式。
* `none`：默认，无任何效果
* `Parallax`：视差滚动
* `pin`：固定 `View` 的位置，不随滑动事件变动位置。
* `app:layout_collapseParallaxMultiplier`：速度因子。取值范围 0~1，值越小对滑动约敏感，默认0.5。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layout_collapseMode.gif)

以上示例代码如下：
```
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/myList"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:layout_behavior="@string/appbar_scrolling_view_behavior"/>

    <com.google.android.material.appbar.AppBarLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:fitsSystemWindows="true">

        <com.google.android.material.appbar.CollapsingToolbarLayout
            android:layout_width="match_parent"
            android:layout_height="200dp"
            android:minHeight="?attr/actionBarSize"
            app:title="@string/app_name"
            app:contentScrim="@color/black"
            app:expandedTitleTextAppearance="@style/expanded_title_text"
            app:collapsedTitleTextAppearance="@style/collapsed_title_text"
            app:layout_scrollFlags="scroll|snap|enterAlwaysCollapsed|exitUntilCollapsed">

            <ImageView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:scaleType="centerCrop"
                android:src="@mipmap/appbar_naruto"/>

            <ImageView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:src="@mipmap/ic_launcher"
                app:layout_collapseMode="parallax" />

            <androidx.appcompat.widget.Toolbar
                android:layout_width="match_parent"
                android:layout_height="?attr/actionBarSize" />

        </com.google.android.material.appbar.CollapsingToolbarLayout>

    </com.google.android.material.appbar.AppBarLayout>

</androidx.coordinatorlayout.widget.CoordinatorLayout>
```

##### 使用注意
1. `CoordinatorLayout` 继承自 `viewgroup`,但是使用类似于 `FramLayout`，有层次结构，后面的布局会覆盖在前面的布局之上，但跟 `behavior` 属性也有很大关系的，`app:layout_behavior` 属性只有`CoordinatorLayout` 的直接子布局才能响应。

2. 如果 `Toolbar` 为 `CollapsingToolbarLayout` 子 `View` 那么 `CollapsingToolbarLayout` 折叠后高度就是 `Toolbar` 的高度，相当于 `CollapsingToolbarLayout` 设置了 `minHeight` 属性。

3. 

#### Toolbar
`Toolbar` 是在 `Android 5.0` 开始推出的一个 `Material Design` 风格的导航控件，网上资料很多这里就不再赘述了。

### 开发记录

#### CoordinatorLayout + recyclerview显示不全

临时方案：删除Toolbar。

#### 固定表头

实现固定表头，将表头布局放在 `CollapsingToolbarLayout` 之后，`AppBarLayout` 之内即可。
