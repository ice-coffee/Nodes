[toc]

### LayoutManager
起因是这样一张UI美眉给的设计图：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layoutmanager_reason.jpg)

起初是有做自定义 `View` 的想法，后来发现这个想法多多少少有点不成熟，因为没有时间目前也没有能力去完成这样一个控件。

好在后来找到了 [SpannedGridLayoutManager](https://github.com/Arasthel/SpannedGridLayoutManager) 由作者 `Arasthel` 完成的一个跨行跨列的 `GridLayoutManager` 布局。作者思路很值得借鉴。

在这段时间的开发完成之后，对 `LayoutManager` 产生了一些好奇。它是如何产生这些效果的呢？如果要实现一个类似 `LayoutManager` 需要完成什么步骤呢？

#### GridLayoutManager
因为是从这次的布局开发产生的兴趣，那么首先下手的地方就是 `GridLayoutManager` 了。查看 `GridLayoutManager` 源码可以发现你，它存在三个内部类：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layoutmanager_structure.jpg)

* LayoutParams
* SpanSizeLookup
* DefaultSpanSizeLookup

##### LayoutParams
`LayoutParams` 都很熟悉了，它提供给我们布局属性，最基本的 `width`、`height`，更详细一点的 `margin` 属性，等等。很多容器组件都有其 `LayoutParams` 的子类。那 `GridLayoutManager` 的 `LayoutParams` 中增加了两个新的变量：`mSpanIndex`、`mSpanSize`。他们是做什么的呢？来继续看。

##### SpanSizeLookup
`SpanSizeLookup` 是一个帮助类，用于提供每项 `itemview` 所占用跨度数，默认值为 `1`。
它是一个抽象类，来看下其内部都定义了那些方法：

``` java
public abstract static class SpanSizeLookup {
    /**
     * @param position item 在 adapter 中的位置
     * @return position 指代的 item 所占用的列数
     */
    public abstract int getSpanSize(int position);

    /**
     * itemview 占据跨度的下标
     */
    public int getSpanIndex(int position, int spanCount){}
}
```

`getSpanIndex()` 和 `getSpanSize()` 是比较重要的两个方法，除了这两个方法外还有一些缓存的方法，用于缓存 `position` 对应 `SpanSize` 的计算结果。

`getSpanIndex()` 和 `getSpanSize()` 的含义和作用结合 `DefaultSpanSizeLookup` 更好理解。

##### DefaultSpanSizeLookup
`DefaultSpanSizeLookup` 是 `SpanSizeLookup` 的默认实现：

``` java
public static final class DefaultSpanSizeLookup extends SpanSizeLookup {
    @Override
    public int getSpanSize(int position) {
        return 1;
    }
    
    @Override
    public int getSpanIndex(int position, int spanCount) {
        return position % spanCount;
    }
}
```

可以看到 `getSpanSize()` 返回值默认为 `1`，`getSpanIndex()` 返回值为 `当前位置 % 总列数`。如果把 `GridLayoutMananger` 看做一个个小格子，每个格子下标从 `0 至 SpanCount`，一个 `SpanCount = 4` 的布局中每个小格子的下标如下：
```
0，1，2，3
0，1，2，3
0，1，2，3
...
```
那么 `positionn = 0` 的 `itemview` 的 `spanIndex = 0`, `positionn = 2` 的 `itemview` 的 `spanIndex = 2`，`positionn = 4` 的 `itemview` 的 `spanIndex = 0`。

总结一下，在每一行中，`SpanIndex` 代表 `itemview` 占据跨度的起始下标，`spanSize` 代表 `itemview` 占据了多少跨度。如果设置 `spanSize = spanCount` ：
``` java
val gridLayoutManager = GridLayoutManager(this, 3, GridLayoutManager.VERTICAL, false)
gridLayoutManager.spanSizeLookup = object : GridLayoutManager.SpanSizeLookup() {
    override fun getSpanSize(position: Int): Int {
        return 3
    }
}
```
你会得到一个使用 `GridLayoutManager` 绘制的 `LinearLayoutManager` 布局。

##### 布局实现
了解了 `SpanSize` 和 `SpanIndex` 的含义我们可以理所应当的猜测 `GridLayoutManager`  就是通过它们来确定每个 `itemview` 在容器中的位置的。

如何验证猜测的真实性呢？当然是去三兄弟 `onMeasure()`、`onLayout()`、`onDraw()` 中找了。因为是容器组件所以对于 `子View` 的测量和布局肯定是在 `onLayoutChildren()` 里了。找到 `GridLayoutManager` 的 `onLayoutChildren()` 方法：

``` java
@Override
public void onLayoutChildren(RecyclerView.Recycler recycler, RecyclerView.State state) {
    ...
    super.onLayoutChildren(recycler, state);
    ...
}
```

其内依然使用的是其父类 `onLayoutChildren` 的实现，它的父类是谁呢： `LinearLayoutManager` 。

这里插一句，很多前辈都说过，最好带着问题去看源码，我的理解是如果只是想弄明白某个问题，那么最好的做法是快速定位到具体的代码实现中，而不是去关注太多目前不需要去理解的代码，它会分散你的精力并且影响你的思路。

回到主题，可以看到 `LinearLayoutManager.onLayoutChildren()` 中的代码茫茫多。想要找到 `子View` 是如何测量和布局的，真不知道如何下手。怎么定位对我们有用的代码呢？关键词 `子View` ，先要有 `子View` 然后才能谈到测量和布局吧，在 `RecyclerView` 里 `子View` 怎么来的？
那不就是 `onCreateViewHolder()` 嘛。

从 `onCreateViewHolder()` 一级一级向上查找，可以得到如下的执行逻辑：

```
...
-> LinearLayoutManager.onLayoutChild()
-> LinearLayoutManager.fill()
-> LinearLayoutManager.layoutChunk() / GridLayoutManager.layoutChunk()
-> LinearLayoutManager.LayoutState.next()
-> RecyclerView.Recycler.getViewForPosition()
-> RecyclerView.Recycler.tryGetViewHolderForPositionByDeadline()
-> RecyclerView.Adapter.createViewHolder()
-> onCreateViewHolder()
```

在这条线上去找可以比较轻松的定位到 `子View` 是用在 `layoutChunk()` 方法中的，基本到这里就可以确定 `itemview` 测量和布局的实现代码就是在 `layoutChunk()` 里了，名字就叫布局块嘛。

在开始 `layoutChunk()` 之前，先了解一个会对理解接下来的流程很有帮助的点，我们知道 `LinearLayoutManager` 是 `GridLayoutManager` 的父类，并且 `GridLayoutManager` 重写了 `layoutChunk()` ，这也就说明 `GridLayout` 也是按行绘制的，只是它把每行都分成了 `SpanCount` 列，然后在每个单元格都绘制一个 `itemview` 。这就是 `GridLayoutManager` 的绘制逻辑。如图：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layoutmanager_layout.jpg)

接下来看 `layoutChunk()` 中具体的实现：

``` java
@Override
void layoutChunk(RecyclerView.Recycler recycler, RecyclerView.State state,
        LayoutState layoutState, LayoutChunkResult result) {
    
    int count = 0;
    int consumedSpanCount = 0;
    int remainingSpan = mSpanCount;

    // 获取某行中可添加的所有 子View
    while (count < mSpanCount && layoutState.hasMore(state) && remainingSpan > 0) {
        int pos = layoutState.mCurrentPosition;
        final int spanSize = getSpanSize(recycler, state, pos);
        if (spanSize > mSpanCount) {
            throw new IllegalArgumentException("Item at position " + pos + " requires "
                    + spanSize + " spans but GridLayoutManager has only " + mSpanCount
                    + " spans.");
        }
        remainingSpan -= spanSize;
        if (remainingSpan < 0) {
            break; // item did not fit into this row or column
        }
        View view = layoutState.next(recycler);
        if (view == null) {
            break;
        }
        consumedSpanCount += spanSize;
        mSet[count] = view;
        count++;
    }

    if (count == 0) {
        result.mFinished = true;
        return;
    }

    //一行中所有 itemview 最大的宽度
    int maxSize = 0;
    //一行中所有 itemview 最大的高度, 一般是一格的高度
    float maxSizeInOther = 0; // use a float to get size per span

    // we should assign spans before item decor offsets are calculated
    assignSpans(recycler, state, count, layingOutInPrimaryDirection);
    //在这里对 子View 进行测量
    for (int i = 0; i < count; i++) {
        View view = mSet[i];
        if (layoutState.mScrapList == null) {
            if (layingOutInPrimaryDirection) {
                addView(view);
            } else {
                addView(view, 0);
            }
        } else {
            if (layingOutInPrimaryDirection) {
                addDisappearingView(view);
            } else {
                addDisappearingView(view, 0);
            }
        }
        // 这里是 ItemDecorations 主要计算 itemview 之间的间隔
        calculateItemDecorationsForChild(view, mDecorInsets);

		// 测量子View	
        measureChild(view, otherDirSpecMode, false);

        //获取 View 做占据布局的宽度, 包括 marigin + padding + width
        final int size = mOrientationHelper.getDecoratedMeasurement(view);
        if (size > maxSize) {
            maxSize = size;
        }
        //获取 View 做占据布局的高度, 包括 marigin + padding + width
        final LayoutParams lp = (LayoutParams) view.getLayoutParams();
        final float otherSize = 1f * mOrientationHelper.getDecoratedMeasurementInOther(view)
                / lp.mSpanSize;
        if (otherSize > maxSizeInOther) {
            maxSizeInOther = otherSize;
        }
    }

    //一个布局块消耗的最大高度
    result.mConsumed = maxSize;

    //这里对 子View 进行布局，这四个值所代表的就是 view 的布局区域
    int left = 0, right = 0, top = 0, bottom = 0;
    if (mOrientation == VERTICAL) {
        if (layoutState.mLayoutDirection == LayoutState.LAYOUT_START) {
            bottom = layoutState.mOffset;
            top = bottom - maxSize;
        } else {
            top = layoutState.mOffset;
            bottom = top + maxSize;
        }
    } else {
        if (layoutState.mLayoutDirection == LayoutState.LAYOUT_START) {
            right = layoutState.mOffset;
            left = right - maxSize;
        } else {
            left = layoutState.mOffset;
            right = left + maxSize;
        }
    }
    for (int i = 0; i < count; i++) {
        View view = mSet[i];
        LayoutParams params = (LayoutParams) view.getLayoutParams();
        if (mOrientation == VERTICAL) {
            if (isLayoutRTL()) {
                right = getPaddingLeft() + mCachedBorders[mSpanCount - params.mSpanIndex];
                left = right - mOrientationHelper.getDecoratedMeasurementInOther(view);
            } else {
                left = getPaddingLeft() + mCachedBorders[params.mSpanIndex];
                right = left + mOrientationHelper.getDecoratedMeasurementInOther(view);
            }
        } else {
            top = getPaddingTop() + mCachedBorders[params.mSpanIndex];
            bottom = top + mOrientationHelper.getDecoratedMeasurementInOther(view);
        }
        // We calculate everything with View's bounding box (which includes decor and margins)
        // To calculate correct layout position, we subtract margins.
        // 对 ziView 布局
        layoutDecoratedWithMargins(view, left, top, right, bottom);
        if (DEBUG) {
            Log.d(TAG, "laid out child at position " + getPosition(view) + ", with l:"
                    + (left + params.leftMargin) + ", t:" + (top + params.topMargin) + ", r:"
                    + (right - params.rightMargin) + ", b:" + (bottom - params.bottomMargin)
                    + ", span:" + params.mSpanIndex + ", spanSize:" + params.mSpanSize);
        }
        // Consume the available space if the view is not removed OR changed
        if (params.isItemRemoved() || params.isItemChanged()) {
            result.mIgnoreConsumed = true;
        }
        result.mFocusable |= view.hasFocusable();
    }
    Arrays.fill(mSet, null);
}
```

看过 `layoutChunk()` 方法的实现，其总共分为三步：

* 获取某行中可放置的所有 `子View`
* 测量 `子View`
* 布局 `子View`

可以看到在 `layoutChunk()` 代码的开始就执行了一个 `while` 循环用于获取当前行中可存放的所有 `子View`，用白话解释就是 ”一个 `SpanCount = 4` 的布局，一行中可存放四个 `SpanSize = 1` 的子View，或者两个 `SpanSize = 2` 的子View ....“

接下来调用 `measureChild()` 对所有 `子View` 进行宽高测量（建议看源码），主要获取了 `子View` 的布局间隔、`margin` 并通过这些值计算得到子 `View` 宽高的 `MeasureSpace` 值。

其中 `getSpaceForSpanRange()` 比较不好理解，它是用于获取在垂直方向上 `itemview` 的宽度。`getSpaceForSpanRange()` 如下：

``` java
/** 
 * @params startSpan itemview 占据单元格起始下标
 * @params spanSize itemview 占据单元格总数
 */
int getSpaceForSpanRange(int startSpan, int spanSize) {
    if (mOrientation == VERTICAL && isLayoutRTL()) {
        return mCachedBorders[mSpanCount - startSpan]
                - mCachedBorders[mSpanCount - startSpan - spanSize];
    } else {
        return mCachedBorders[startSpan + spanSize] - mCachedBorders[startSpan];
    }
}
```

方法内使用了一个名为 `mCachedBorders` 的数组，`mCachedBorders` 是一个大小为 `spanCount + 1` 的数组，数组内存储的是将 `RecyclerView` 分成 `spanCount` 列的 `spanCount + 1` 条线的 `X` 轴坐标。数组第一位的值总是 `0`。

`mCachedBorders` 的计算方法如下：

``` java
static int[] calculateItemBorders(int[] cachedBorders, int spanCount, int totalSpace) {
    if (cachedBorders == null || cachedBorders.length != spanCount + 1
            || cachedBorders[cachedBorders.length - 1] != totalSpace) {
        cachedBorders = new int[spanCount + 1];
    }
    cachedBorders[0] = 0;
    int sizePerSpan = totalSpace / spanCount;
    int sizePerSpanRemainder = totalSpace % spanCount;
    int consumedPixels = 0;
    int additionalSize = 0;
    for (int i = 1; i <= spanCount; i++) {
        int itemSize = sizePerSpan;
        additionalSize += sizePerSpanRemainder;
        if (additionalSize > 0 && (spanCount - additionalSize) < sizePerSpanRemainder) {
            itemSize += 1;
            additionalSize -= spanCount;
        }
        consumedPixels += itemSize;
        cachedBorders[i] = consumedPixels;
    }
    return cachedBorders;
}
```
举例，如果 `RecyclerView.width = 1080, SpanCount = 3`，那么经计算得到 `mCachedBorder` 的值就为 `[0, 360, 720, 1080]`。

到这里就可以确定 `RecyclerView` 是通过 `mCachedBorder` 搭配 `SpanSizeLookup` 来计算每个 `itemview` 的宽度的了。

到这里测量的过程其实就结束了，也得到了每个 `itemview` 的宽高了。

接下来就是布局阶段了，这里比较简单，就是得到，四个值 `left、top、right、bottom`，有一个比较重要的值 `layoutState.mOffset` 它是某行开始绘制的像素偏移量：

``` java
layoutState.mOffset += layoutChunkResult.mConsumed * layoutState.mLayoutDirection;
```

`layoutChunkResult.mConsumed` 是每个布局块所占用的最大高度，`layoutState.mLayoutDirection` 布局填充的方向：
 
* `LAYOUT_START`：-1 从下往上填充布局
* `LAYOUT_END`：1 从上往下填充布局

如果 `GridLayoutManager` 是垂直布局并且从上往下填充布局的话，`layoutState.mOffset` 的值就是绘制某行时其绘制起始点的 `Y` 轴坐标。

这里有一个疑问不太懂，既然在之前 `itemview` 的测量中已经获得了它的宽高，为什么确认布局位置的时候还是用的 `mCachedBorders`，不知道这是基于那些考虑。

到这里 `GridLayoutMananger` 的布局逻辑就介绍完了。我们也知道了通过 `GridLayoutManager` 来实现UI美眉的设计图也是不行的了，因为它只支持跨列而不支持跨行，万幸，有前辈做了 `SpannedGridLayoutManager` 赞美开源，赞美作者 `^_^`。

#### SpannedGridLayoutManager
在讲解 `SpannedGridLayoutManager` 的具体实现前，先说明一下它的实现逻辑，有助于理解作者的思路。

在 `LayoutManager` 中最大的难点是确定 `itemview` 的布局属性，在 `GridLayoutMananger` 中是通过：

* layoutState.mOffset：偏移量
* SpanSize：跨度大小
* SpanIndex：跨度起始下标
* mCachedBorders：边框位置
* 等等

来确定某个 `position` 所对应 `itemview` 的布局属性的。

那来看下 `SpannedGridLayoutManager` 的作者是通过什么思路来解决这个难题的呢?

比如要实现上面那张UI美眉给的设计图（以下都是按垂直方向布局）：

首先，作者定义了 `SpanSize` 类，定义 `itemview` 占据单元格的行数和列数：

```
/**
 * Helper to store width and height spans
 */
class SpanSize(val width: Int, val height: Int)
```

然后，定义了一个列表 `freeRects`，用于存储 `RecyclerView` 所占据的整个空间中所有可用矩形范围：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layoutmanager_span_0.jpg)

初始状态下 `freeRects` 中只包含一个 `Rect`，它的值为：

```
Rect(0, 0 - 3, 2147483647)
```

从 `Rect` 的值中可以发现，作者在 `Rect` 中保存的并不是具体的像素距离值，而是单元格数。如图红色框区域就是其代表可用的范围，当然它的底部范围是很大的，最多可以占据 `Int.MAX_VALUE` 个单元格，这里我觉得画上边线会更好解释一点，自己心里清楚就好了。

下面我们来放第一个 `itemview`，它的宽高都占据两个单元格：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layoutmanager_span_1.jpg)

可以看到当第一个 `itemview` 被添加到图上之后，其将可用范围分成了两个，将这两个可用范围按照一定规律进行排序。然后添加第二个 `itemview`，他的宽高只占据一个单元格，正好可以添加到黄色框的部分，添加并更新可用范围，如下：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layoutmanager_span_2.jpg)

再来添加第三个 `itemview`，宽高仍是占据一个单元格，还是添加到黄色框区域：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layoutmanager_span_3.jpg)

这时可以发现，黄色框区域完全包裹在红色框区域内，那就可以将代表黄色框的 `Rect` 去掉，只保留红色框区域了，如下：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/layoutmanager_span_4.jpg)

依次类推，通过这种方式，在不超过可用范围的情况下可以随意设置任意 `itemview` 的跨行和跨列。以上仅是作者的基本思路，具体的代码实现逻辑还是有些许的不同的，下面就来看具体是怎么做的吧。

首先看代码结构，它包含两个内部类：

* `SpanSize`：定义 `itemview` 占据单元格的行数和列数。
* `RectHelper`：其内实现的就是对可用矩形区域的查找、缓存和更新。

可以看到 `SpannedGridLayoutManager` 和 `GridLayoutManager` 不同，它集成的是 `RecyclerView.LayoutMananger`。没关系依然用上述 `GridLayoutManager` 的方法找到最接近答案的节点。

``` java
protected open fun makeView(position: Int, direction: Direction, recycler: RecyclerView.Recycler): View {
    val view = recycler.getViewForPosition(position)
    measureChild(position, view)
    layoutChild(position, view)

    return view
}
```

就很清晰，拿到 `itemview`，测量，布局。

首先来看 `measure` 过程：

``` java
protected open fun measureChild(position: Int, view: View) {

    val freeRectsHelper = this.rectsHelper

    val itemWidth = freeRectsHelper.itemSize
    val itemHeight = freeRectsHelper.itemSize

    val spanSize = spanSizeLookup?.getSpanSize(position) ?: SpanSize(1, 1)

    val usedSpan = if (orientation == Orientation.HORIZONTAL) spanSize.height else spanSize.width

    if (usedSpan > this.spans || usedSpan < 1) {
        throw InvalidSpanSizeException(errorSize = usedSpan, maxSpanSize = spans)
    }

    // This rect contains just the row and column number - i.e.: [0, 0, 1, 1]
    val rect = freeRectsHelper.findRect(position, spanSize)

    // Multiply the rect for item width and height to get positions
    val left = rect.left * itemWidth
    val right = rect.right * itemWidth
    val top = rect.top * itemHeight
    val bottom = rect.bottom * itemHeight

    val insetsRect = Rect()
    calculateItemDecorationsForChild(view, insetsRect)

    // Measure child
    val width = right - left - insetsRect.left - insetsRect.right
    val height = bottom - top - insetsRect.top - insetsRect.bottom
    val layoutParams = view.layoutParams
    layoutParams.width = width
    layoutParams.height = height
    measureChildWithMargins(view, width, height)

    // Cache rect
    childFrames[position] = Rect(left, top, right, bottom)
}
```

这部分代码就很好理解，首先得到 `position` 对应的 `SpanSize`，再根据通过 `RectHelper.findRect()` 得到适合 `itemview` 存放的矩形区域，调用 `RecyclerView.measureChildWithMargins()` 进行对 `itemview` 进行测量。可以看到在 `RectHelper.findRect()` 中 `Rect` 是存放在 `rectsCache` 数组中的。在 `onLayoutChildren()` 方法中可以找到一个 `for` 循环，它的作用就是得到 `itemCount` 个 `itemview` 的布局区域并存储在 `rectsCache` 数组中。

然后就是 `layout` 过程：

``` java
protected open fun layoutChild(position: Int, view: View) {
    val frame = childFrames[position]

    if (frame != null) {
        val scroll = this.scroll

        val startPadding = getPaddingStartForOrientation()

        if (orientation == Orientation.VERTICAL) {
            layoutDecorated(view,
                    frame.left + paddingLeft,
                    frame.top - scroll + startPadding,
                    frame.right + paddingLeft,
                    frame.bottom - scroll + startPadding)
        } else {
            layoutDecorated(view,
                    frame.left - scroll + startPadding,
                    frame.top + paddingTop,
                    frame.right - scroll + startPadding,
                    frame.bottom + paddingTop)
        }
    }

    // A new child was layouted, layout edges change
    updateEdgesWithNewChild(view)
}
```

这部分代码也很简单，但是这里面加入了 `scroll` 的处理，由于这篇文章不涉及 `scroll`，将其排除在外的话理解起来还是没有难度的。

其实整个 `SpannedGridLayoutManager` 中最重要的是对于 `itemview` 布局区域的获取，其大部分代码都存在于 `subtract()` 方法中。理解了这个方法也就理解了作者对于布局的处理。

到这里也就介绍完了，再次感叹作者的思路，赞美开源精神。读完了 `GridLayoutManager` 和 `SpannedGridLayoutManager` 的源码，发现 `RecyclerView` 对于 `itemview` 的布局就好像是在玩儿拼图游戏的感觉，从左至右，从上到下，依次排列每一个 `子View`，其实和我们在做类似拼图游戏的时候规定按从左至右，从上到下的规则排列大小不等的块的处理逻辑是不是很像。那 `GridLayoutManager` 和 `SpannedGridLayoutManager` 的作者在实现的时候是不是就是将这种我们大脑处理类似问题的逻辑给翻译成代码了呢。

#### 自定义 LayoutManager
现在来看下如果要自定一个 `LayoutManager` 的话需要做些什么，或者需要重写那些方法。

``` java
class MyLayoutManager extends RecyclerView.LayoutManager {
    //===================================
    //  * 必须重写
    //  ~ 唯一 abstract 方法
    //===================================
    /**
     * * 必须重写
     * 它是 `LayoutManager` 中唯一的 `abstract` 方法, 为子类提供 LayoutParams,
     * 可以使用 RecyclerView.LayoutParams() 对象也可以自定义的 ViewGroup.LayoutParams 对象.
     * 如果自定义话需要重写如下方法:
     * checkLayoutParams（LayoutParams）
     * generateLayoutParams（android.view.ViewGroup.LayoutParams）
     * generateLayoutParams（android.content.Context，android.util.AttributeSet）
     */
    @Override
    public RecyclerView.LayoutParams generateDefaultLayoutParams() {
        return null;
    }

    //====================================
    //  * 必须重写
    //  ~ 布局相关
    //====================================

    /**
     * * 必须重写
     * 主要实现 itemview 的 measure 和 layout 过程
     */
    @Override
    public void onLayoutChildren(RecyclerView.Recycler recycler, RecyclerView.State state) {
        super.onLayoutChildren(recycler, state);
    }

    //====================================
    //  * 必须重写
    //  ~ 滑动相关
    //====================================

    /**
     * 是否可以水平滑动
     */
    @Override
    public boolean canScrollHorizontally() {
        return super.canScrollHorizontally();
    }

    /**
     * 是否可以垂直滑动
     */
    @Override
    public boolean canScrollVertically() {
        return super.canScrollVertically();
    }

    /**
     * 控制在水平方向上的滑动距离
     */
    @Override
    public int scrollHorizontallyBy(int dx, RecyclerView.Recycler recycler, RecyclerView.State state) {
        return super.scrollHorizontallyBy(dx, recycler, state);
    }

    /**
     * 控制在垂直方向上的滑动距离
     */
    @Override
    public int scrollVerticallyBy(int dy, RecyclerView.Recycler recycler, RecyclerView.State state) {
        return super.scrollVerticallyBy(dy, recycler, state);
    }

    /**
     * 滑动到适配器指定位置
     */
    @Override
    public void scrollToPosition(int position) {
        super.scrollToPosition(position);
    }

    /**
     * 平滑滚动到适配器指定位置
     * 创建 SmoothScroller 实例并调用 startSmoothScroll()
     */
    @Override
    public void smoothScrollToPosition(RecyclerView recyclerView, RecyclerView.State state, int position) {
        super.smoothScrollToPosition(recyclerView, state, position);
    }

    //===================================
    //  ~ 状态相关
    //===================================

    @Nullable
    @Override
    public Parcelable onSaveInstanceState() {
        return super.onSaveInstanceState();
    }

    @Override
    public void onRestoreInstanceState(Parcelable state) {
        super.onRestoreInstanceState(state);
    }
}

```

如果想支持滚动条需要重写这些方法：
``` java
public int computeHorizontalScrollExtent(@NonNull State state) {
    return 0;
}

public int computeHorizontalScrollOffset(@NonNull State state) {
    return 0;
}

public int computeHorizontalScrollRange(@NonNull State state) {
    return 0;
}

public int computeVerticalScrollExtent(@NonNull State state) {
    return 0;
}

public int computeVerticalScrollOffset(@NonNull State state) {
    return 0;
}

public int computeVerticalScrollRange(@NonNull State state) {
    return 0;
}
```

最重要的其实还是 `onLayoutChildren()` 方法了，其他方法都可以对照 `LinearLayoutManager` 或者 `GridLayoutManager` 来写，或者干脆跟 `GridLayoutManager` 一样，继承于 `LinearLayoutManager` 专心于 `onLayoutChildren()` 实现想要的布局也是可以的。
