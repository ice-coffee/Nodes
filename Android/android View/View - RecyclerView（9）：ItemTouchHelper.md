#### ItemTouchHelper 简介
`ItemTouchHelper` 是实现 `RecyclerView` 侧滑删除和拖拽移动的工具类。我们可以通过集成 `ItemTouchHelper.Callback` 或 `ItemTouchHelper.SimpleCallback` 抽象类并实现相应方法以实现侧滑删除和拖拽移动的功能。

#### ItemTouchHelper.Callback 简介
`ItemTouchHelper.Callback` 和 `ItemTouchHelper.SimpleCallback` 都是抽象类，并且 `SimpleCallback` 继承与 `Callback`。那么就来看下 `Callback` 中有哪些常用方法并且都有什么作用。

##### isItemViewSwipeEnabled()
``` java
public boolean isItemViewSwipeEnabled() {
    return true;
}
```

`isItemViewSwipeEnabled()` 返回值决定 `ItemTouchHelper` 是否会响应用户侧滑删除手势，默认返回 `true`。

##### isLongPressDragEnabled()
``` java
public boolean isLongPressDragEnabled() {
    return true;
}
```

`isLongPressDragEnabled()` 返回值决定 `ItemTouchHelper` 是否响应用户长按拖动手势，默认返回 `true`。

##### getMovementFlags
``` java
public abstract int getMovementFlags(RecyclerView recyclerView, ViewHolder viewHolder);
```

`getMovementFlags()` 是抽象方法我们必须实现它，该方法的返回值是一个复合标识，这个标识定义了 `swip` 和 `drag` 的可滑动方向。

一般我们会通过 `makeMovementFlag(int, int)` 或 `makeFlag(int, int)` 方法生成此标识。

##### makeMovementFlag、makeFlag
``` java
/**
 * @param dragFlags 长按可拖动方向
 * @param swipeFlags 可侧滑方向
 */
public static int makeMovementFlags(int dragFlags, int swipeFlags) {
    return makeFlag();
}

public static int makeFlag(int dragFlags, int swipeFlags) {
}
```

`ItemTouchHelper` 为我们提供了如下常量：

- `ItemTouchHelper.Top`：向上
- `ItemTouchHelper.DOWN`：向下
- `ItemTouchHelper.LEFT`：向左
- `ItemTouchHelper.RIGHT`：向右
- `ItemTouchHelper.START`：水平开始方向，取决于 `RecyclerView` 的布局方向。
- `ItemTouchHelper.END`：水平结束方向，取决于 `RecyclerView` 的布局方向。

这些常量可作为 `makeMovementFlag(int, int)` 方法的参数，并且可以组合使用。比如如果 `RecylerView` 支持上下拖动替换位置和右滑删除操作，那应如下：

``` java
makeMovementFlags(ItemTouchHelper.UP | ItemTouchHelper.DOWN, ItemTouchHelper.RIGHT );
```

##### onMove
``` java
/**
 * @param viewHolder 当前拖动 Item
 * @param target 交换位置目标 Item
 */
public abstract boolean onMove(RecyclerView recyclerView, ViewHolder viewHolder, ViewHolder target);
```

当 `ItemTouchHeler` 想要 `viewHolder` 代表的项与 `targe` 参数代表的项交换位置时 `onMove()` 会被调用。如果返回 `true` 则两者交换位置，否则无法交换位置。

> 注意：在实现 `onMove` 方法时要注意如下几点：
> 1. 在拖动过程中每次两个相邻 `Item` 之间交换位置都会调用 `onMove` 方法。
> 2. 当 `onMove` 返回 `true` 时，要调用 `notifyItemMoved()` 方法交换位置，数据源也要做相应交换。

##### onSwiped
``` java
public abstract void onSwiped(ViewHolder viewHolder, int direction);
```

当用户侧滑删除某项时 `onSwiped()` 方法会被回调。

> 注意：`onSwiped()` 方法被调用时，要调用 `notifyItemRemoved()` 方法删除项，数据源也要做相应改变。

##### onChildDraw
``` java
public void onChildDraw(Canvas c, RecyclerView recyclerView, ViewHolder viewHolder, float dX, float dY, int actionState, boolean isCurrentlyActive) {}
```

`onChildDraw()` 方法会在 `RecylerView.onDraw()` 方法中被调用，也就是说当 `RecyclerView` 因为拖拽移动和侧滑时 `UI` 发生改变时，`onChildDraw()` 都会被调用。

如果需要自定义视图和用户的交互方式可以重写此方法。

##### onDrawOver 

`onDrawOver` 和 `onChildDraw` 方法作用类似, 不同的是它是绘制在 `item view` 图层之上。

##### onSelectedChanged
``` java
/**
 * @param actionState 操作状态
 */
public void onSelectedChanged(ViewHolder viewHolder, int actionState) {}
```

当 `ViewHolder` 被拖动、侧滑、释放时此方法被调用。`actionState` 可为如下值：

- `ItemTouchHelper.ACTION_STATE_IDLE`: 被释放
- `ItemTouchHelper.ACTION_STATE_SWIPE`: 被拖拽
- `ItemTouchHelper.ACTION_STATE_DRAG`: 被侧滑

##### clearView
``` java
public void clearView(RecyclerView recyclerView, ViewHolder viewHolder) {}
```

当用户和视图之间交互结束并动画完成时，此方法被调用。在此方法中可以清理在 `onSelectedChanged()、onChildDraw()` 方法中做的操作以及动画等。

#### 基本使用

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/recyclerview_itemtouchhelper.gif)

`MyItemTouchCallBack.kt`

``` java
class MyItemTouchCallBack(private val onItemTouchListener: OnItemTouchListener) : ItemTouchHelper.Callback() {

    override fun isItemViewSwipeEnabled(): Boolean {
        return true
    }

    override fun isLongPressDragEnabled(): Boolean {
        return true
    }

    override fun getMovementFlags(recyclerView: RecyclerView, viewHolder: RecyclerView.ViewHolder): Int {
        return if (recyclerView.layoutManager is LinearLayoutManager) {
            makeMovementFlags(ItemTouchHelper.UP or ItemTouchHelper.DOWN, ItemTouchHelper.RIGHT)
        } else {
            makeMovementFlags(ItemTouchHelper.UP or ItemTouchHelper.DOWN or ItemTouchHelper.LEFT or ItemTouchHelper.RIGHT, 0)
        }
    }

    override fun onSwiped(viewHolder: RecyclerView.ViewHolder, direction: Int) {
        //此处是侧滑删除的主要代码
        val position = viewHolder.adapterPosition
        onItemTouchListener.onSwiped(position)
    }

    override fun onMove(recyclerView: RecyclerView, viewHolder: RecyclerView.ViewHolder, target: RecyclerView.ViewHolder): Boolean {
        val fromPosition = viewHolder.adapterPosition
        val toPosition = target.adapterPosition
        onItemTouchListener.onMove(fromPosition, toPosition)
        return true
    }

    override fun onSelectedChanged(viewHolder: RecyclerView.ViewHolder?, actionState: Int) {
        super.onSelectedChanged(viewHolder, actionState)
        onItemTouchListener.onSelectedChanged(viewHolder, actionState)
    }

    override fun clearView(recyclerView: RecyclerView, viewHolder: RecyclerView.ViewHolder) {
        super.clearView(recyclerView, viewHolder)
        onItemTouchListener.onClear(viewHolder)
    }

    /**
     * 移动交换数据的更新监听
     */
    interface OnItemTouchListener {
        /**
         * 拖拽滑动Item时调用
         */
        fun onMove(fromPosition: Int, toPosition: Int)

        /**
         * 侧滑Item时调用
         */
        fun onSwiped(position: Int)

        /**
         * 状态改变时调用
         */
        fun onSelectedChanged(viewHolder: RecyclerView.ViewHolder?, actionState: Int)

        /**
         * ViewHolder 释放时使用
         */
        fun onClear(viewHolder: RecyclerView.ViewHolder)
    }
}
```

`ItemTouchHelperActivity.kt`

``` java
class ItemTouchHelperActivity: AppCompatActivity() {

    private lateinit var itemtouchAdapter: ItemTouchAdapter
    private val itemList = arrayListOf("星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_recyclerview_itemtouchhelper)

        itemtouchAdapter = ItemTouchAdapter(this, itemList)
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = itemtouchAdapter
        recyclerView.addItemDecoration(LayoutItemDecoration(8, true))

        val touchCallBack = MyItemTouchCallBack(onItemTouchListener)
        val itemTouchHelper = ItemTouchHelper(touchCallBack)
        itemTouchHelper.attachToRecyclerView(recyclerView)
    }

    private val onItemTouchListener = object : MyItemTouchCallBack.OnItemTouchListener {
        override fun onMove(fromPosition: Int, toPosition: Int) {
            itemtouchAdapter.notifyItemMoved(fromPosition, toPosition)
            Collections.swap(itemList, fromPosition, toPosition)
        }

        override fun onSelectedChanged(viewHolder: RecyclerView.ViewHolder?, actionState: Int) {
            if (actionState == ItemTouchHelper.ACTION_STATE_DRAG) {
                runViewAnimation(viewHolder!!.itemView, true)
            }
        }

        override fun onSwiped(position: Int) {
            itemtouchAdapter.notifyItemRemoved(position)
            itemList.removeAt(position)
        }

        override fun onClear(viewHolder: RecyclerView.ViewHolder) {
            runViewAnimation(viewHolder.itemView, false)
        }
    }

    /**
     * 动画
     */
    private fun runViewAnimation(view: View?, isSelected: Boolean) {
        if (null != view) {
            val xScaleAnimator = ObjectAnimator.ofFloat(view, "scaleX", if (isSelected) 1.04f else 1.0f)
            val yScaleAnimator = ObjectAnimator.ofFloat(view, "scaleY", if (isSelected) 1.04f else 1.0f)
            val animatorSet = AnimatorSet()
            animatorSet.duration = 200
            animatorSet.play(xScaleAnimator).with(yScaleAnimator)
            animatorSet.start()
        }
    }
}

class ItemTouchAdapter(val context: Context, private val itemList: List<String>) : RecyclerView.Adapter<ItemTouchViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemTouchViewHolder {
        return ItemTouchViewHolder(LayoutInflater.from(context).inflate(R.layout.view_item, parent, false))
    }

    override fun getItemCount(): Int {
        return itemList.size
    }

    override fun onBindViewHolder(holder: ItemTouchViewHolder, position: Int) {
        holder.tvItem.text = itemList[position]
    }
}

class ItemTouchViewHolder(view: View) : RecyclerView.ViewHolder(view) {
    val tvItem: TextView = view.findViewById(R.id.tvItem)
}
```
