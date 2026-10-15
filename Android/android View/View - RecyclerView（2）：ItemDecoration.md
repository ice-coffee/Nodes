[toc]
### ItemDecoration
> An ItemDecoration allows the application to add a special drawing and layout offset to specific item views from the adapter's data set. This can be useful for drawing dividers between items, highlights, visual grouping boundaries and more.

`ItemDecoration` 用于对 `ItemView` 添加装饰绘制和布局偏移量。常用于绘制布局 `ItemView` 分割线、高亮显示、视觉分组边界等。

> All ItemDecorations are drawn in the order they were added, before the item views (in onDraw() and after the items (in onDrawOver(Canvas, RecyclerView, RecyclerView.State).

可以为 `RecyclerViewe` 添加多个 `ItemDecoration`，绘制时`ItemDecoration` 将会按添加的顺序绘制，添加的装饰将绘制于 `ItemView` 绘制之前（在 `onDraw()` 中添加的装饰）或之后（在 `onDrawOver()` 中添加的装饰）。这里之前和之后指代的不是时间上的前后而是图层的前后。

#### ItemDecoration接口

`ItemDecoration接口` 如下：
``` java
public abstract static class ItemDecoration {
    /**
     * 在提供给RecyclerView的画布上绘制任何适当的装饰。
     * 通过此方法绘制的任何内容都将在绘制 item view 之前绘制，因此将出现在 item view 之下。
     *
     * @param c 画布
     * @param parent RecyclerView 将绘制 ItemDecoration 的目标 RecyclerView
     * @param state RecyclerView 状态
     */
    public void onDraw(Canvas c,RecyclerView parent, State state) {}

    /**
     * 和 onDraw 方法作用类似, 不同的是它是绘制在 item view 图层之上。
     */
    public void onDrawOver(Canvas c, RecyclerView parent, State state) {}

    /**
     * 提供指定 item view 布局偏移量。
     * outRect 的四个字段指定了四个方向上偏移量的像素数，类似于 paddinng 或 margin。默认为0。
     *
     * 可以调用 RecyclerView.getChildAdapterPosition(View) 来获得 item view 的适配器位置。
     *
     * @param outRect 用于接收偏移量.
     * @param view    目标子 view
     * @param parent  目标 RecyclerView
     * @param state   RecyclerView 的状态.
     */
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, State state) {}
}
```

`onDraw()` 和 `onDrawOver` 没什么好说的了，可以重写方法在 `Item View` 图层的下方或上方绘制任何你想绘制的图案。下面主要介绍一下 `getItemOffSet()`。

先绘制一个不添加任何 `ItemDecoration` 的 `RecyclerView`：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/recycler_no_item_offset.jpg)

设置 `outRect` 看下效果：
``` java
override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
    super.getItemOffsets(outRect, view, parent, state)
    outRect.set(10, 10, 10, 10)
}
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/recycler_add_item_offset.jpg)

这就是 `outRect` 的能力。

#### DividerItemDecoration
`Android` 官方提供了 `DividerItemDecoration` 用于 `LinearLayoutMnager` 布局中分割线的绘制，可改变分割线的高度和颜色等属性。下面来看下它是如何实现的：
``` java
public class DividerItemDecoration extends ItemDecoration {
    public static final int HORIZONTAL = 0;
    public static final int VERTICAL = 1;
    //绘制器
    private Drawable mDivider;
    //方向
    private int mOrientation;
    //要绘制的范围
    private final Rect mBounds = new Rect();

    ...
}
```
可以看到 `DividerItemDecoration` 实现 `ItemDecoration` 接口，如果我们自定义 `ItemDecoration` 的话也必须实现它。`DividerItemDecoration` 有三个重要的变量：

* `mDivider`：分割线将由它来绘制
* `mOrientation`：代表布局方向，也说明仅支持 `LinearLayoutManager` 布局
* `mBounds`：代表分割线绘制区域

看下 `getItemOffsets` 方法中的具体实现：
``` java
public void getItemOffsets(Rect outRect, View view, RecyclerView parent, State state) {
    if (this.mDivider == null) {
        outRect.set(0, 0, 0, 0);
    } else {
        if (this.mOrientation == 1) {
            outRect.set(0, 0, 0, this.mDivider.getIntrinsicHeight());
        } else {
            outRect.set(0, 0, this.mDivider.getIntrinsicWidth(), 0);
        }
    }
}
```
可以看到 `mDivider` 不为空是绘制分割线的前提条件。分割线的高度由 `mDivider` 提供。

`DividerItemDecoration` 中绘制分割线的操作在 `onDraw` 中实现：
``` java
@Override
public void onDraw(Canvas c, RecyclerView parent, RecyclerView.State state) {
    if (parent.getLayoutManager() == null || mDivider == null) {
        return;
    }
    if (mOrientation == VERTICAL) {
        drawVertical(c, parent);
    } else {
        drawHorizontal(c, parent);
    }
}

private void drawVertical(Canvas canvas, RecyclerView parent) {
    canvas.save();
    final int left;
    final int right;
    //noinspection AndroidLintNewApi - NewApi lint fails to handle overrides.
    if (parent.getClipToPadding()) {
        left = parent.getPaddingLeft();
        right = parent.getWidth() - parent.getPaddingRight();
        canvas.clipRect(left, parent.getPaddingTop(), right,
                parent.getHeight() - parent.getPaddingBottom());
    } else {
        left = 0;
        right = parent.getWidth();
    }

    final int childCount = parent.getChildCount();
    for (int i = 0; i < childCount; i++) {
        final View child = parent.getChildAt(i);
        parent.getDecoratedBoundsWithMargins(child, mBounds);
        final int bottom = mBounds.bottom + Math.round(child.getTranslationY());
        final int top = bottom - mDivider.getIntrinsicHeight();
        mDivider.setBounds(left, top, right, bottom);
        mDivider.draw(canvas);
    }
    canvas.restore();
}
```
以上源码理解起来不难，循环 `RecyclerView` 中每个子 `View` 获取其绘制范围保存在 `mBounds` 中，接着计算分割线绘制的范围，由 `mDivider` 进行绘制。

具体实现如下：
``` java
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">

    <size android:height="2dp" />
    <solid android:color="@color/colorPrimary" />

</shape>

val itemDecoration = DividerItemDecoration(this, DividerItemDecoration.VERTICAL)
itemDecoration.setDrawable(ContextCompat.getDrawable(this, R.drawable.shape_item_decor)!!)
recyclerView.addItemDecoration(itemDecoration)
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/recyclerview_divider_item.jpg)

这里我们知道 `DividerItemDecoration` 是不支持 `GridLayoutManager` 的，那来写一个吧
``` java
override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
    super.getItemOffsets(outRect, view, parent, state)
    //item view 总数
    val itemCount = parent.adapter?.itemCount ?: 0
    //当前 item view 的 adapter 位置
    val position = parent.getChildAdapterPosition(view)
    val layoutManager = parent.layoutManager
    if (layoutManager is GridLayoutManager) {
        //GridLayoutManager 列数
        val spanCount = layoutManager.spanCount
        //当前列
        val column = position % spanCount
        //是否需要包含边界
        if (includeEdge) {
            outRect.left = spacing - column * spacing / spanCount
            outRect.right = (column + 1) * spacing / spanCount
            if (position < spanCount) {
                outRect.top = spacing
            }
            outRect.bottom = spacing
        } else {
            outRect.left = column * spacing / spanCount
            outRect.right = spacing - (column + 1) * spacing / spanCount
            outRect.top = 0
            //最后一行判断
            if (position + spanCount < itemCount) {
                outRect.bottom = spacing
            }
        }
    }
}
```

#### LayoutItemDecoration
理解起来还是挺容易的。下面是一个公共方法，大家随意取用。在实际开发中需要定制分割线样式的要求不是很多，所以这里就先不加入分割线样式的设置了。

``` java
class LayoutItemDecoration : RecyclerView.ItemDecoration {

    /**
     * 水平方向间隔
     */
    var horizontalSpacing: Int

    /**
     * 垂直方向间隔
     */
    var verticalSpacing: Int

    /**
     * 是否设置边缘间距
     */
    var includeEdge: Boolean

    constructor(spacing: Int, includeEdge: Boolean) {
        this.horizontalSpacing = spacing
        this.verticalSpacing = spacing
        this.includeEdge = includeEdge
    }

    constructor(horizontalSpacing: Int, verticalSpacing: Int, includeEdge: Boolean) {
        this.horizontalSpacing = horizontalSpacing
        this.verticalSpacing = verticalSpacing
        this.includeEdge = includeEdge
    }

    /**
     * position 和对应 view 所在列的对应关系
     */
    private var positionToColumn: MutableMap<Int, Int>? = null
    /**
     * 下标对应列, 值对应某列当前最远的距离
     */
    private var endLineToColum: IntArray? = null

    override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
        super.getItemOffsets(outRect, view, parent, state)
        //item view 总数
        val itemCount = parent.adapter?.itemCount ?: 0
        //当前 item view 的 adapter 位置
        val position = parent.getChildAdapterPosition(view)
        when (val layoutManager = parent.layoutManager) {
            is GridLayoutManager -> {
                setGridItemDecoration(layoutManager, outRect, layoutManager.spanCount, position, itemCount)
            }
            is StaggeredGridLayoutManager -> {
                setStaggeredGridItemDecoration(layoutManager, outRect, layoutManager.spanCount, position, itemCount)
            }
            is LinearLayoutManager -> {
                setLinearItemDecoration(outRect, layoutManager.orientation, position, itemCount)
            }
            else -> {
                outRect.set(horizontalSpacing, verticalSpacing, horizontalSpacing, verticalSpacing)
            }
        }
    }

    /**
     * 设置线性布局分割线
     */
    private fun setLinearItemDecoration(outRect: Rect, orientation: Int, position: Int, itemCount: Int) {
        val horizontalRect = if (includeEdge) horizontalSpacing else 0
        val verticalRect = if (includeEdge) verticalSpacing else 0
        if (orientation == LinearLayoutManager.HORIZONTAL) {
            when (position) {
                0 -> outRect.set(horizontalRect, verticalRect, horizontalSpacing, verticalRect)
                itemCount - 1 -> outRect.set(0, verticalRect, horizontalRect, verticalRect)
                else -> outRect.set(0, verticalRect, horizontalSpacing, verticalRect)
            }
        } else {
            when (position) {
                0 -> outRect.set(horizontalRect, verticalRect, horizontalRect, verticalSpacing)
                itemCount - 1 -> outRect.set(horizontalRect, 0, horizontalRect, verticalRect)
                else -> outRect.set(horizontalRect, 0, horizontalRect, verticalSpacing)
            }
        }
    }

    /**
     * 设置网格布局分割线
     */
    private fun setGridItemDecoration(layoutManager: GridLayoutManager, outRect: Rect, spanCount: Int, position: Int, itemCount: Int) {
        //当前列
        val column = position % spanCount
        calculateGridOutRectByColum(outRect, spanCount, itemCount, position, layoutManager.orientation, column)
    }

    /**
     * 设置瀑布流布局分割线
     */
    private fun setStaggeredGridItemDecoration(layoutManager: StaggeredGridLayoutManager, outRect: Rect, spanCount: Int, position: Int, itemCount: Int) {
        if (null == positionToColumn) {
            positionToColumn = HashMap()
        }
        if (null == endLineToColum) {
            endLineToColum = IntArray(spanCount)
        }

        //当前 view 应处的列
        var column = 0
        if (positionToColumn!!.containsKey(position)) {
            column = positionToColumn!![position]!!
        } else {
            if (position > 0) {
                val lastViewPosition = position - 1
                val lastView = layoutManager.findViewByPosition(lastViewPosition)
                if (null != lastView) {
                    val lastViewColumn = positionToColumn!![lastViewPosition]!!
                    if (layoutManager.orientation == StaggeredGridLayoutManager.VERTICAL) {
                        endLineToColum!![lastViewColumn] = endLineToColum!![lastViewColumn] + lastView.height
                    } else {
                        endLineToColum!![lastViewColumn] = endLineToColum!![lastViewColumn] + lastView.width
                    }
                }
            }
            //首行判断
            if (position < spanCount) {
                column = position
            } else {
                var minLine = Int.MAX_VALUE
                for (i in spanCount - 1 downTo 0) {
                    if (endLineToColum!![i] <= minLine) {
                        minLine = endLineToColum!![i]
                        column = i
                    }
                }
            }
            positionToColumn!![position] = column
        }

        calculateGridOutRectByColum(outRect, spanCount, itemCount, position, layoutManager.orientation, column)
    }

    /**
     * 计算间隔
     */
    private fun calculateGridOutRectByColum(outRect: Rect, spanCount: Int, itemCount: Int, position: Int, orientation: Int, column: Int) {
        //是否需要包含边界
        if (includeEdge) {
            if (orientation == StaggeredGridLayoutManager.VERTICAL) {
                outRect.left = horizontalSpacing - column * horizontalSpacing / spanCount
                outRect.right = (column + 1) * horizontalSpacing / spanCount
                //第一行判断
                if (position < spanCount) {
                    outRect.top = verticalSpacing
                }
                outRect.bottom = verticalSpacing
            } else {
                outRect.top = verticalSpacing - column * verticalSpacing / spanCount
                outRect.bottom = (column + 1) * verticalSpacing / spanCount
                //第一行判断
                if (position < spanCount) {
                    outRect.left = horizontalSpacing
                }
                outRect.right = horizontalSpacing
            }
        } else {
            if (orientation == StaggeredGridLayoutManager.VERTICAL) {
                outRect.left = column * horizontalSpacing / spanCount
                outRect.right = horizontalSpacing - (column + 1) * horizontalSpacing / spanCount
                outRect.top = 0
                //最后一行判断
                if (position + spanCount < itemCount) {
                    outRect.bottom = verticalSpacing
                }
            } else {
                outRect.top = column * verticalSpacing / spanCount
                outRect.bottom = verticalSpacing - (column + 1) * verticalSpacing / spanCount
                outRect.left = 0
                //最后一行判断
                if (position + spanCount < itemCount) {
                    outRect.right = horizontalSpacing
                }
            }
        }
    }
}
```

#### StaggeredGridLayoutManager
这里重点再说明一下我对 `StaggeredGridLayoutManager` 添加 `ItemDecoration` 的思路。

`StaggeredGridLayoutManager` 和 `GridLayoutManager` 设置 `ItemDeration` 最重要的点都在于计算当前 `ItemView` 应被添加到的列 `column`。
`GridLayoutManager` 计算 `colum` 很简单，因为它的布局是有序的（`RTL \ LTR` 依次添加）：

``` java
val column = position % spanCount
```

而 `StaggeredGridLayoutManager` 会将 `ItemView` 添加到当前最短的一列。看下 `RecyclerView` 源码。直接定位到 `fill()` 方法（`Android` 提供的 `LayoutManager` 子 `View` 的布局逻辑都在 `fill()` 方法中）。

``` java
private int fill(RecyclerView.Recycler recycler, LayoutState layoutState,
        RecyclerView.State state) {
    。。。
    while (layoutState.hasMore(state)
            && (mLayoutState.mInfinite || !mRemainingSpans.isEmpty())) {
        View view = layoutState.next(recycler);
        LayoutParams lp = ((LayoutParams) view.getLayoutParams());
        final int position = lp.getViewLayoutPosition();
        final int spanIndex = mLazySpanLookup.getSpan(position);
        Span currentSpan;
        final boolean assignSpan = spanIndex == LayoutParams.INVALID_SPAN_ID;
        if (assignSpan) {
            currentSpan = lp.mFullSpan ? mSpans[0] : getNextSpan(layoutState);
            mLazySpanLookup.setSpan(position, currentSpan);
            if (DEBUG) {
                Log.d(TAG, "assigned " + currentSpan.mIndex + " for " + position);
            }
        } else {
            if (DEBUG) {
                Log.d(TAG, "using " + spanIndex + " for pos " + position);
            }
            currentSpan = mSpans[spanIndex];
        }
    }
    。。。
}
```

可以看到 `fill()` 方法中通过 `while` 循环添加 `ItemView` 到 `RecyclerView` 中，`currentSpan` 即代表从 `layoutState.next(recycler)` 中获取的 `View` 应被添加到那列中。接下来查看 `getNextSpan()` 它是获取 `currentSpan` 的重要方法。

``` java
    private Span getNextSpan(LayoutState layoutState) {
        final boolean preferLastSpan = preferLastSpan(layoutState.mLayoutDirection);
        final int startIndex, endIndex, diff;
        if (preferLastSpan) {
            startIndex = mSpanCount - 1;
            endIndex = -1;
            diff = -1;
        } else {
            startIndex = 0;
            endIndex = mSpanCount;
            diff = 1;
        }
        if (layoutState.mLayoutDirection == LAYOUT_END) {
            Span min = null;
            int minLine = Integer.MAX_VALUE;
            final int defaultLine = mPrimaryOrientation.getStartAfterPadding();
            for (int i = startIndex; i != endIndex; i += diff) {
                final Span other = mSpans[i];
                int otherLine = other.getEndLine(defaultLine);
                if (otherLine < minLine) {
                    min = other;
                    minLine = otherLine;
                }
            }
            return min;
        } else {
            Span max = null;
            int maxLine = Integer.MIN_VALUE;
            final int defaultLine = mPrimaryOrientation.getEndAfterPadding();
            for (int i = startIndex; i != endIndex; i += diff) {
                final Span other = mSpans[i];
                int otherLine = other.getStartLine(defaultLine);
                if (otherLine > maxLine) {
                    max = other;
                    maxLine = otherLine;
                }
            }
            return max;
        }
    }
```

可以看到 `getNextSpan()` 方法中的逻辑是通过遍历所有列找到当前长度最短（长度代表所添加子元素的长度总和，具体是高还是宽的总和看布局方向）的一列并返回。然后就是根绝所获取的 `Span` 执行

* 添加：`addView()` 
* 测量：`measureChildWithDecorationsAndMargin()` 
* 布局：`layoutDecoratedWithMargins()`

等一系列操作。

可以看到 `StaggeredGridLayoutManager` 会将 `ItemView` 添加到最短列中，那么如何确定当前 `ItemView` 应被添加到那列呢。我是参考 `getNextSpan()` 的逻辑，通过记录每列当前的长度来确定 `colum` 的值的。具体实现逻辑可以看上面的代码 `^_^`。
