[toc]

### 推荐阅读
[抽丝剥茧RecyclerView - ItemAnimator & Adapter](https://juejin.cn/post/6844903942938165255)
[RecyclerView 动画原理 | 换个姿势看源码（pre-layout）](https://juejin.cn/post/6890288761783975950#comment)

之前有看到同事在 `RecyclerView` 上加了动画，心想有时间就来看看 `RecyclerView` 动画是如何实现的，真是不刨不知道，一刨吓我一大跳。我们慢慢来看。文末列出了动画过程中涉及到类的一些属性可以帮助理解。

### 预布局
在开始之前先来说明一个概念 `预布局`。

#### 什么是预布局
预布局是指在正式布局 `RecyclerView` 中的 `ItemView` 前执行的一次布局过程。

#### 预布局的作用
预布局的作用是为了使 `ItemAnimator` 执行时能给用户更好的视觉体验。

#### 预布局和正式布局的区别
预布局过程和正式布局过程执行的都是一样的代码，不同的是预布局过程得到的是 `ItemAnimator` 执行前的布局，而正式布局得到的是 `ItemAnimator` 执行后的布局也就是最终用户看到的布局。

#### 什么情况下会执行预布局
当布局结束后若有新的 `ItemView` 在布局结尾显示则需要执行预布局，也就是当 `RecycleView` 中有 `ItemView` 被删除或更新时需要执行预布局。看下图更清晰。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/recycclerview_itemanimator.gif)

从上图中可以看到当不执行预布局时如果布局结尾有新的 `ItemView` 出现会执行 `DefaultItemAnimator` 的添加动画（淡入），这种看起来好像卡顿一样的显示给用户的感觉并不好。当然如果根本没有动画那预布局也就没有了意义。

### 动画执行过程解析
> `RecyclerView` 的动画过程相当复杂，涉及的类也很多，如果大量的贴代码的话可能会比较乱，在这里只放调用过程，并辅以注释，希望能有更好的阅读体验。

现在开始正式动画执行过程的解析，这里我选择了 `notifyItemRemoved()` 方法作为分析的入口。

- `RecyclerView.notifyItemRemoved()`
    - `AdapterDataObservable.notifyItemRangeRemoved()`
        - `RecyclerViewDataObserver.onItemRangeRemoved()`
            - `AdapterHelper.onItemRangeRemoved()`：保存视图发生的变化信息
            - `RecyclerViewDataObserver.triggerUpdateProcessor()`
                - `RecyclerView.requestLayout()` ：更新视图
- `onLayout()`
    - `dispatchLayoutStep1()` ：【1】
        - `#.processAdapterUpdatesAndSetAnimationFlags()`
            - `AdapterHelper.preProcess()`
                - `#.applyRemove()`
                    - `#.postponeAndUpdateViewHolders()`
                        - `#.Callback.offsetPositionsForRemovingLaidOutOrNewView()`
                        - `RecyclerView.offsetPositionRecordsForRemove()`：【2】
            - `State.mRunSimpleAnimations`、`State.mRunPredictiveAnimations`：【4】 
        - `ViewInfoStore.addToPreLayout()`：【5】
        - `LayoutManager.onLayoutChildren()`：【6】
        - `ViewInfoStore.addToAppearedInPreLayoutHolders()`：记录新出现的 `ViewHolder`
    - `dispatchLayoutStep2()`：【7】
        - `LayoutManager.onLayoutChildren()`：再次布局以确定最终出现在屏幕上的 `子View`
    - `dispatchLayoutStep3()`：【8】
        - `ViewInfoStore.addToPostLayout()`
        - `ViewInfoStore.process()`：执行动画
    - `mFirstLayoutComplete`：`Layout` 完成。

【1】：`dispatchLayoutStep1()` 的作用如下：

* 处理适配器的更新；
* 决定应该采用什么动画；
* 保存当前views的信息；
* 运行预布局并且保存预布局结束后的布局信息。

【2】`offsetPositionRecordsForRemove()`

`for` 循环遍历 `RecyclerView` 的 `子View` 更新对应 `ViewHolder` 的 `position` 属性并对于要删除的 `ViewHolder` 添加 `ViewHolder.FLAG_REMOVED` 标识。

方法末尾还会调用 `Recycler.offsetPositionRecordsForRemove()` 去做清理缓存的处理。

【4】`mRunSimpleAnimations`、`mRunPredictiveAnimations`

此处主要更新如下两个状态赋值。

- `mRunSimpleAnimations`：是否执行 `ItemAnimator`。
- `mRunPredictiveAnimations`：是否执行预布局。

``` java
mState.mRunSimpleAnimations = mFirstLayoutComplete
        && mItemAnimator != null
        && (mDataSetHasChangedAfterLayout
        || animationTypeSupported
        || mLayout.mRequestedSimpleAnimations)
        && (!mDataSetHasChangedAfterLayout
        || mAdapter.hasStableIds());
mState.mRunPredictiveAnimations = mState.mRunSimpleAnimations
        && animationTypeSupported
        && !mDataSetHasChangedAfterLayout
        && predictiveItemAnimationsEnabled();
```

此处可以看到 `mFirstLayoutComplete` 是判断是否执行预布局的充要条件，而 `mFirstLayoutComplete` 只有在第一次 `Layout` 完成之后才会赋值为 `true`，也就是说 `RecyclerView.ItemAnimator` 是不支持初始动画的 `-_-!`。

【5】`ViewInfoStore.addToPreLayout()`

`Step 0`：执行预布局前先将 `RecyclerView` 中所有可见 `ViewHolder` 的位置信息，记录于 `ViewStoreInfo.record` 中，并设置 `FLAG_PRE` 预布局标记。

【6】`Layout.onLayoutChildren()`

`Step 1`：执行预布局。
以 `LinearLayoutMananger` 为例：

- `LinearLayoutManager.onLayoutChildren`
    - `#.fill()`：填充布局
        - `#.layoutChunk()`：填充布局块，也就是 `ItemView`。

`fill()` 方法是填充 `RecyclerView` 中空白布局的方法也是预布局产生做用的位置，如下：

``` java
int fill(){
	int remainingSpace = layoutState.mAvailable + layoutState.mExtraFillSpace;
	LayoutChunkResult layoutChunkResult = mLayoutChunkResult;
	while ((layoutState.mInfinite || remainingSpace > 0) && layoutState.hasMore(state)) {

	    layoutChunk(recycler, state, layoutState, layoutChunkResult);
	    
	    layoutState.mOffset += layoutChunkResult.mConsumed * layoutState.mLayoutDirection;
	    if (!layoutChunkResult.mIgnoreConsumed || layoutState.mScrapList != null || !state.isPreLayout()) {
	        layoutState.mAvailable -= layoutChunkResult.mConsumed;
	        // we keep a separate remaining space because mAvailable is important for recycling
	        remainingSpace -= layoutChunkResult.mConsumed;
	    }
	}
}
```

`fill()` 方法中有三个重要变量：

- `remainingSpace`：是需要填充的布局范围，添加的 `ViewHolder` 至少要填充满 `remainingSpace` 所代表的区域。
- `LayoutChunkResult.mConsumed`：`mConsumed` 是每次 `layoutChunk()` 方法的输出，指代一行 `ViewHolder` 所占有的区域。如果是 `GridLayoutManager` 那么一行会有 `SpanCount` 个 `ViewHolder`。
- `layoutState.mOffset`：指已填充的区域范围。

那我们可以发现如果 `fill()` 中 `if` 代码块不执行的话 `remainingSpace` 的值是不会变的。也就是说如果 `if` 代码块不执行 `layoutChunk()` 会一直被调用，`layoutState.mOffset` 的值会一直累加，一个个 `子View` 会被添加到 `RecyclerView` 中，直至把所有 `子View` 都添加到 `RecyclerView` 中。

这里 `if` 代码块的作用就是限制 `layoutChunk()` 的调用次数，仅填充满 `remainingSpace` 区域就停止。再来看这个 `if` 代码块，它有三个判断条件，因为我们是在 `预布局阶段` 所以 `!state.isPreLayout()` 为 `false`，`layoutState.mScrapList != null` 这里不考虑，也就是说当 `layoutChunkResult.mIgnoreConsumed` 为 `true` 时，本次调用 `remainingSpace` 的值不会变，也就是说会多执行一次 `layoutChunk()`，多添加一个 `子View` 到 `RecylerView`。代码跳转一下可以看到：

``` java
void layoutChunk(RecyclerView.Recycler recycler, RecyclerView.State state,
    LayoutState layoutState, LayoutChunkResult result) {
    ...
   
    // Consume the available space if the view is not removed OR changed
    if (params.isItemRemoved() || params.isItemChanged()) {
        result.mIgnoreConsumed = true;
    }
    ...
}
```

只有在 `ItemView` 被删除或者有更新的情况下才会为 `true`，其实也就是 `ViewHolder.flag` 属性为 `FLAG_REMOVED | FLAG_UPDATE` 情况下。在【2】中已经给要删除的 `ViewHolder` 的 `flag` 属性被设为 `FLAG_REMOVED` 了。

可以看到在预布局阶段 `ViewHolder.flag == FLAG_REMOVED` 的 `ViewHolder` 被添加到 `RecyclerView` 布局中时它所占有的高度并没有被记录，也就是说在 `RecyclerView` 的空白布局被填满后 `layoutChunk()` 再次执行了一次。多加载了一个 `ViewHolder` 到 `RecyclerView` 中。

在 `预布局` 结束之后回到 `dispatchLayoutStep1()` 方法中看到又循环了一遍当前 `子View` 如果某个 `ViewHolder` 未在 【5】 的循环中添加到 `ViewInfoStore` 中时将其添加到 `ViewInfoStore` 并标记为 `FLAG_APPEAR`。这个 `ViewHolder` 是由于 `notifyItemRemoved()` 操作而新补位出现的那个 `ViewHolder`。

【7】`dispatchLayoutStep2()`

预布局结束之后，会再次执行 `LayoutManager.onLayoutChildren()` 以确定最终出现在屏幕上的布局，这个方法可能会执行多次。

【8】`dispatchLayoutStep3()`

这是 `layout` 的最后一步，保存在 `dispatchLayoutStep2()` 中最终确定的 `ViewHolder` 信息，然后触发动画，最后做清理。

`Step 3`：遍历在 `dispatchLayoutStep2()` 中最终确定要显示在屏幕上的 `ViewHolder` 的信息，通过 `ViewInfoStore.addToPostLayout()` 方法，一般是 `ItemHolderInfo`，并设置 `FLAG_PRE` 标记，将其记录于 `ViewStoreInfo` 中。

`Step 4`：调用 `ViewInfoStore.process()` 方法，根据 `Flag` 执行对应的回调，回调会调用 `ItemAnimator` 执行动画。

最后就是一些清理的操作了。

### ItemAnimator
关于动画相关的类有三个：

* `ItemAnimator`
* `SimpleItemAnimator`
* `DefaultItemAnimator`

#### ItemAnimator
> `ItemAnimator` 是抽象类，它定义了适配器数据更新时在 `ItemView` 上执行的动画。

> 注意：当每个 `animateAppearance()`、`animateChange()`、`animatePersistence()` 和 `animateDisappearance()` 调用，必须至少有一个匹配的 `dispatchAnimationFinished()` 调用。

状态标识：

| Flag | 简介 |
| --- | --- |
| `FLAG_CHANGED` | 此 `ViewHolder` 对应的 `ItemView` 将被更新 |
| `FLAG_REMOVED` | 此 `ViewHolder` 对应的 `ItemView` 将被删除 |
| `FLAG_INVALIDATED` | `Adapter#notifyDataSetChanged()` 被调用并且此 `ViewHolder` 标识的内容失效 |
| `FLAG_MOVED` | 此 `ViewHolder` 对应的 `ItemView` 的位置已被更改 |
| `FLAG_APPEARED_IN_PRE_LAYOUT` | 当 `ViewHolder` 在预布局过程中添加到视图中时被设置，其在预布局阶段中不可见，布局结束后可能可见 |

重要方法：
> 翻译我尽力了 `-_-!`

* `animateAppearance()`

``` java
/**
 * @param viewHolder 执行动画的 ViewHolder
 * @param preLayoutInfo 由 recordPreLayoutInformation() 返回. 当 
 *                      1. itemview 仅被添加到 adapter 
 *                      2. LayoutManager 不支持预测动画 
 *                      3. 无法预测此 ViewHolder 将可见 
 *                      时 preLayoutInfo 可为 null
 * @param postLayoutInfo 由 recordPreLayoutInformation() 返回. 不为空
 * @return 动画执行调用则返回 true，否则返回 false
 */
public abstract boolean animateAppearance(ViewHolder viewHolder, @Nullable ItemHolderInfo preLayoutInfo, ItemHolderInfo postLayoutInfo);
```

将 `ViewHolder` 添加到布局时，由 `RecyclerView` 调用。

动画完成后，`ItemAnimator` 必须调用 `dispatchAnimationFinished()`，如果决定不对视图进行动画处理，则立即调用 `dispatchAnimationFinished()`。

* `animateChange()`

``` java
/**
 * @param oldHolder layout 开始前的 ViewHolder, oldHolder 可能与 newHolder 不相等
 * @param newHolder layout 结束后的 ViewHolder, oldHolder 可能与 newHolder 不相等
 * @param preLayoutInfo 由 recordPreLayoutInformation() 返回. 不为空
 * @param postLayoutInfo 由 recordPreLayoutInformation() 返回. 不为空
 * @return 动画执行调用则返回 true，否则返回 false
 */
public abstract boolean animateChange(RecyclerView.ViewHolder oldHolder, RecyclerView.ViewHolder newHolder, RecyclerView.ItemAnimator.ItemHolderInfo preLayoutInfo, RecyclerView.ItemAnimator.ItemHolderInfo postLayoutInfo);
```

在 `layout` 之前或之后都存在的 `ItemView` 收到 `Adapter#notifyItemChanged()` 方法调用时，此方法被调用。`Adapter#notifyDataSetChanged()` 也可能触发此方法，但是如果调用时 `ViewType` 发生变化，则将创建新的 `ViewHolder` 并为其调用 `animateAppearance()` 方法，而旧的 `ViewHolder` 将被回收。

如果由于 `Adapter＃notifyDataSetChanged()` 调用而调用了此方法，则很有可能该项目的内容并没有真正改变，而是从适配器重新绑定。如果 `ViewItem` 在屏幕上的位置未更改，则 `DefaultItemAnimator` 将跳过对 `ItemView` 设置动画的操作，开发人员也应处理这种情况，并避免创建不必要的动画。

When an item is updated, ItemAnimator has a chance to ask RecyclerView to keep the previous presentation of the item as-is and supply a new ViewHolder for the updated presentation (see: canReuseUpdatedViewHolder(ViewHolder, List). This is useful if you don't know the contents of the Item and would like to cross-fade the old and the new one (DefaultItemAnimator uses this technique).

在使用自定义的 `ItemAnimator` 时，重用 `ViewHolder` 并手动设置内容动画更高效、优雅。

调用 `Adapter＃notifyItemChanged` 时，`ItemView` 的 `ViewType` 可能会更改。如果在调用 `canReuseUpdatedViewHolder()` 时此 `ViewHolder` 的 `Item` 的 `ViewType` 已更改或 `ItemAnimator` 返回 `false`，则 `oldHolder` 和 `newHolder` 将是代表同一 `Item` 的不同 `ViewHolder` 实例。在这种情况下，只有新的 `ViewHolder` 对 `LayoutManager` 可见，但是 `RecyclerView` 保留了旧的 `ViewHolder` 进行动画附加。

动画执行完之后，如果 `oldHolder` 和 `newHolder` 是同一实例，则仅需调用一次 `dispatchAnimationFinished()`，但是如果不是同一实例，则每个 `ViewHolder` 都需要调用一次。

* `animateDisappearance()`

``` java
/**
 * @param viewHolder
 * @param preLayoutInfo
 * @param postLayoutInfo
 * @return 动画执行调用则返回 true，否则返回 false
 */
public abstract boolean animateDisappearance(RecyclerView.ViewHolder viewHolder, RecyclerView.ItemAnimator.ItemHolderInfo preLayoutInfo, RecyclerView.ItemAnimator.ItemHolderInfo postLayoutInfo);
```
当 `ViewHolder` 从布局中消失时调用。
当此方法被调用时，虽然对应的 `View` 还未被 `RecylerView` 移除，但已被 `LayoutManager` 删除。 它可能已从 `Adapter` 中移除或由于其他因素而不可见。可以通过检查传递给 `recordPreLayoutInformation()` 的 `flag` 标志来区分这两种情况。

当在同一 `layout` 过程中同时发生 `changes` 和 `disappears` 时，具体执行那个动画回调取决于 `ItemAnimator` 和 `LayoutManager`，具体执行需查询源码。

动画完成后，`ItemAnimator` 必须调用 `dispatchAnimationFinished()`，如果决定不对视图进行动画处理，则立即调用 `dispatchAnimationFinished()`。

* `animatePersistence()`

``` java
/**
 * @param viewHolder
 * @param preLayoutInfo
 * @param postLayoutInfo
 * @return 动画执行调用则返回 true，否则返回 false
 */
public abstract boolean animatePersistence(ViewHolder viewHolder, ItemHolderInfo preLayoutInfo, ItemHolderInfo postLayoutInfo);
```
当 `Adapter#notifyItemChanged()` 或 `Adapter#notifyDataSetChanged()` 未调用且 `layout` 前后 `ViewHolder` 都存在且内容无变化时此方法被调用。

在 `SimpleItemAnimator` 中，当 `Item` 的位置发生变化时才会执行动画。

动画完成后，`ItemAnimator` 必须调用 `dispatchAnimationFinished()`，如果决定不对视图进行动画处理，则立即调用 `dispatchAnimationFinished()`。

* `canReuseUpdatedViewHolder()`

``` java
/**
 * @param viewHolder
 * @param payloads
 * @return 动画执行调用则返回 true，否则返回 false
 */
public boolean canReuseUpdatedViewHolder(ViewHolder viewHolder)
public boolean canReuseUpdatedViewHolder(ViewHolder viewHolder, List<Object> payloads)
```

当 `Item` 被更改时，`ItemAnimator` 可以决定是要重复使用同一 `ViewHolder` 执行动画还是应创建该项目的副本，并且 `ItemAnimator` 将使用两者来执行动画（例如，淡入淡出）。

请注意，仅当 `ViewHolder#ViewType` 未改变时才会调用此方法。 否则 `ItemAnimator` 将始终在 `animateChange()` 方法中同时接收两个不同的 `ViewHolder`。

如果你的应用程序使用了局部更新（payloads），则可以重写 `canReuseUpdatedViewHolder()` 来基于 ` payloads` 判断。

* `recordPreLayoutInformation()`

`recordPreLayoutInformation()` 在 `pre_layout（预布局）` 之后调用，用于保存 `ViewHolder` 的相关信息。默认返回 `ItemHolderInfo`。

* `recordPostLayoutInformation()`

`recordPostLayoutInformation()` 在 `layout` 之后调用，用于保存 `ViewHolder` 最终状态的相关信息。默认返回 `ItemHolderInfo`。

#### SimpleItemAnimator
> `SimpleItemAnimator` 继承于 `ItemAnimator`，实现了 `ItemAnimator` 提供的方法，并提供了更易理解的 `animateAdd()`、`animateRemove()`、`animateChange()`、`animateMove()` 方法。

#### DefaultItemAnimator
> `DefaultItemAnimator` 继承于 `SimpleItemAnimator`，实现了其提供的 `add、remove、change、move` 方法。

一般情况下自定义动画，实现自己的 `add、remove、change、move` 就好了。可以看到 `DefaultAnimatorAnimator` 中是通过 `ViewPropertyAnimator` 实现动画的，除 `animateMove` 是 `translate` 动画外，都是 `alpha` 动画。

#### 自定义 ItemAnimator
由于 `mFirstLayoutComplete` 的影响，首次加载 `RecyclerView` 是不会调用动画的。而一般看到在首次加载就出现的动画操作都是在 `onBindViewHolder()` 中调用执行动画的结果。

### 相关类

#### ViewHolder
> `ViewHolder` 用过 `RecyclerView` 的都知道。它包含了对应 `ItemView` 以及相关的信息，比如 `Position` 和状态信息。

| Flag | 简介 |
| --- | --- |
| `FLAG_BOUND` | 此 `ViewHolder` 与某个 `Position` 绑定 |
| `FLAG_UPDATE` | 此 `ViewHolder` 对应的数据发生变动，需重新绑定以更新数据 |
| `FLAG_INVALID` | 此 `ViewHolder` 对应的数据无效，需重新绑定新的数据 |
| `FLAG_REMOVED` | 此 `ViewHolder` 指代被移出数据集的数据，此时它仍可用于移动动画等事件 |
| `FLAG_NOT_RECYCLABLE` | 此 `ViewHolder` 不应被回收，这个标志通过 `setIsRecyclable()` 设置，目的是为了在动画期间保留视图 |
| `FLAG_RETURNED_FROM_SCRAP` | 此 `ViewHolder` 是从 `scrap` 列表中返回的，这意味着我们期待这个 `itemView` 被 `addView()` 调用。在被添加到 `RecyclerView` 布局前此 `ViewHolder` 仍存放在 `scrap` 列表中直到布局结束，如果它没有被添加到 `RecyclerView` 布局，则由 `RecyclerView` 回收 |
| `FLAG_IGNORE` | 此 `ViewHolder` 完全由 `LayoutManager` 管理。除非替换 `LayoutManager`，否则我们不会废弃、回收或删除它。它对 `LayoutManager` 仍然是完全可见的 |
| `FLAG_TMP_DETACHED` | 当此 `ViewHolder` 从父视图中分离时，设置这个标志，以便在需要删除或添加它时采取正确的操作 |
| `FLAG_ADAPTER_POSITION_UNKNOWN` | * 此 `ViewHolder` 的位置在绑定到新的位置前无法确定，其与 `FLAG_INVALID` 不同 |
| `FLAG_ADAPTER_FULLUPDATE` | 当调用 `addChangePayload(null)` 时设置 |
| `FLAG_MOVED` | * `ItemAnimator` 在改变 `ViewHolder` 位置时设置 |
| `FLAG_APPEARED_IN_PRE_LAYOUT` | * `ItemAnimator` 在预布局中出现 `ViewHolder` 时使用 |

#### ItemHolderInfo
> `ItemHolderInfo` 是 `ItemAnimator` 的内部类，用于保存 `ViewHolder` 的位置信息。如果想要自定义 `ItemAnimator` 也可以重写它，附加更多你想要的信息。

```
public int left;
public int top;
public int right;
public int bottom;
```

#### InfoRecord
> `InfoRecord` 是 `ViewInfoStore` 的内部类。它记录了 `ViewHolder` 要执行的动画，和动画执行的 `起始` 信息和 `终止` 信息。

`InfoRecord` 中主要有三个变量

```
int flags;
RecyclerView.ItemAnimator.ItemHolderInfo preInfo;
RecyclerView.ItemAnimator.ItemHolderInfo postInfo;
```

* `preInfo（ItemHolderInfo）`：动画执行前 `ViewHolder` 的位置信息
* `postInfo（ItemHolderInfo）`：动画执行后 `ViewHolder` 的位置信息
* `flag`：根据 `flag` 判断要执行那种动画

#### ViewInfoStore
> `ViewInfoStore` 中记录了所有动画相关 `ViewHolder` 对应的 `InfoRecord` 信息。

包含了一个 `ArrayMap`：
```
final SimpleArrayMap<RecyclerView.ViewHolder, InfoRecord> mLayoutHolderMap = new SimpleArrayMasp<>();
```

并提供 `process()` 方法，它是开始执行动画的入口。在 `process()` 方法中遍历 `ArrayMap` 的每一项，根据 `InfoRecord#flag` 判断执行相应回调，回调中会调用 `ItemAnnimator` 相应的方法执行动画。
