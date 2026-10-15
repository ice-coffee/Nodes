[toc]

### 四级缓存吗？
很多文章在介绍 `RecyclerView` 缓存时都会提到 `RecyclerView 的四级缓存`，先来看这所说的是那四级呢？

- 一级缓存：`mAttachedScrap`、`mChangedScrap`
- 二级缓存：`mCachedViews`
- 三级缓存：`ViewCacheExtension` 自定义缓存
- 四级缓存：`RecycledViewPool` 缓存池

那么 `RecyclerView` 缓存真的是由四级组成的吗？慢慢来看

上面所说的四级缓存都在 `RecyclerView` 的内部类 `Recycler` 中定义。它也是实现 `RecyclerView` 缓存逻辑的主要类。

``` java
/**
 * mCachedViews 中最大缓存数
 */
mViewCacheMax = DEFAULT_CACHE_SIZE

final ArrayList<ViewHolder> mAttachedScrap = new ArrayList<>();
ArrayList<ViewHolder> mChangedScrap = null;

final ArrayList<ViewHolder> mCachedViews = new ArrayList<ViewHolder>();

/**
 * 自定义缓存实现
 */
private ViewCacheExtension mViewCacheExtension;

/**
 * 缓存池
 */
RecycledViewPool mRecyclerPool;
```

其中 `mViewCacheMax` 变量决定了 `mCachedViews` 的最大容量，其最终值是由两部分组成：

``` java
void updateViewCacheSize() {
    int extraCache = mLayout != null ? mLayout.mPrefetchMaxCountObserved : 0;
    mViewCacheMax = mRequestedCacheMax + extraCache;
}
```

`mLayout.mPrefetchMaxCountObserved` 在 `RecyclerView：预取` 篇介绍过，它代表每次预取 `ViewHolder` 的数量，可以想象到不同的 `LayoutManager` 值会不同，比如 `LinearLayout` 每次只需要预取一个 `ViewHolder`，而 `GridLayoutManager` 每次需要预取 `SpanCount` 个 `ViewHolder`。`mRequestedCacheMax` 的值可调用 `set` 方法设置。所以如果没有特殊修改的话在 `LinearLayoutManager` 中 `mViewCacheMax = 3`，在 `GridLayoutManager` 中 `mViewCacheMax = 2 + SpanCount`。

### 获取 ViewHolder 缓存
然后先来看 `RecyclerView` 是如何从缓存中取值的。`RecyclerView` 在布局时会调用如下方法获取 `View`。

``` java
public View getViewForPosition(int position) {
    return getViewForPosition(position, false);
}

View getViewForPosition(int position, boolean dryRun) {
    return tryGetViewHolderForPositionByDeadline(position, dryRun, FOREVER_NS).itemView;
}
```

在 `tryGetViewHolderForPositionByDeadline()` 方法中包含了从缓存中获取 `ViewHolder` 和创建新 `ViewHolder` 以及绑定数据的逻辑。

``` java
/**
 * @param position 获取 ViewHolder 在列表中的位置
 * @param dryRun 是否从
 * @param deadlineNs 下一帧刷新时间 用于预加载过程
 * @return
 */
RecyclerView.ViewHolder tryGetViewHolderForPositionByDeadline(int position,
                                                              boolean dryRun, long deadlineNs) {
    RecyclerView.ViewHolder holder = null;
    // 0) If there is a changed scrap, try to find from there
    // 0) 当前如果处于预布局阶段则从 mChangeScrap 中获取缓存 ViewHolder
    if (mState.isPreLayout()) {
        holder = getChangedScrapViewForPosition(position);
    }
    // 1) Find by position from scrap/hidden list/cache
    // 1) 从 mAttachedScrap 和 mCachedViews 中获取缓存 ViewHolder
    if (holder == null) {
        holder = getScrapOrHiddenOrCachedHolderForPosition(position, dryRun);
    }
    if (holder == null) {
        final int type = mAdapter.getItemViewType(offsetPosition);
        // 2) Find from scrap/cache via stable ids, if exists
        // 2) 如果开发者设置了 ItemId 则通过 ItemId 获取 ViewHolder
        if (mAdapter.hasStableIds()) {
            holder = getScrapOrCachedViewForId(mAdapter.getItemId(offsetPosition),
                    type, dryRun);
            if (holder != null) {
                // update position
                holder.mPosition = offsetPosition;
            }
        }
        //如果开发者自定义了缓存实现 mViewCacheExtension 则从其获取 ViewHolder
        if (holder == null && mViewCacheExtension != null) {
            // We are NOT sending the offsetPosition because LayoutManager does not
            // know it.
            final View view = mViewCacheExtension
                    .getViewForPositionAndType(this, position, type);
            if (view != null) {
                holder = getChildViewHolder(view);
            }
        }
        //从 RecyclerView 缓存池中获取 ViewHolder
        if (holder == null) { // fallback to pool
            holder = getRecycledViewPool().getRecycledView(type);
            if (holder != null) {
                //清理 ViewHolder 中保存的信息以重新绑定数据
                holder.resetInternal();
            }
        }
        // 如果仍然没有获取到 ViewHolder 则只能通过 createViewHolder 创建新的 ViewHolder 了
        if (holder == null) {
            long start = getNanoTime();
            if (deadlineNs != FOREVER_NS
                    && !mRecyclerPool.willCreateInTime(type, start, deadlineNs)) {
                // abort - we have a deadline we can't meet
                return null;
            }
            holder = mAdapter.createViewHolder(RecyclerView.this, type);

            long end = getNanoTime();
            mRecyclerPool.factorInCreateTime(type, end - start);
        }
    }

    // 是否需要重新绑定数据
    boolean bound = false;
    if (mState.isPreLayout() && holder.isBound()) {
        // do not update unless we absolutely have to.
        holder.mPreLayoutPosition = position;
    } else if (!holder.isBound() || holder.needsUpdate() || holder.isInvalid()) {
        final int offsetPosition = mAdapterHelper.findPositionOffset(position);
        bound = tryBindViewHolderByDeadline(holder, offsetPosition, position, deadlineNs);
    }

    return holder;
}
```

这里把方法中的代码精简了一部分，更便于理解 `RecyclerView` 是如何获取 `ViewHolder` 的。可以看到 `RecyclerView` 会依次从 `mChangedScrap、mAttachedScrap、mCachedViews、mViewCacheExtension、mRecyclerPool` 中试图获取缓存的 `ViewHolder` ，如果未取到则通过 `createViewHolder()` 新建 `ViewHolder`。然后再判断 `ViewHolder` 实例是否需要调用 `tryBindViewHolderByDeadline().bindViewHolder()` 方法绑定数据。

### 缓存 ViewHolder
介绍了 `RecyclerView` 是如何从缓存获取 `ViewHolder` 的，再来看 `ViewHolder` 是如何被缓存的，并且这么多缓存方式之间的关系是什么？我们一个个来看。

首先是 `mViewCacheExtension、mRecyclerPool`，当开发者有自定义缓存需求的可以通过 `mViewCacheExtension` 替代 `mRecyclerPool`，所以他们属于功能相同的同一级，默认情况下通过 `RecycledViewPool` 来缓存从 `mCacheViews` 中移除的 `ViewHolder`。使用 `RecycledViewPool` 中的 `ViewHolder` 时需要调用 `bindViewHolder()` 重新绑定数据。

那 `mChangedScrap、mAttachedScrap、mCachedViews` 它们之间的关系是什么呢？

首先是 `mCacheView`，其缓存 `ViewHolder` 的逻辑在 `recycleViewHolderInternal()` 方法中。在 `预取` 篇中介绍过在执行预取逻辑后获取到的 `ViewHolder` 会通过 `recycleViewHolderInternal()` 方法进行缓存。

预取逻辑的相关内容可以看这篇[RecyclerView：预取](https://juejin.cn/post/6911107137661829128)。

而 `mChangedScrap、mAttachedScrap` 仅在 `scrapView()` 方法被调用时才会缓存 `ViewHolder` 而它会在 `RecyclerView` 布局时被调用。可以通过调用 `notifyItem***()` 方法可以触发 `onLayout()` 进行断点跟踪其调用逻辑。

到这里可以知道 `RecyclerView` 缓存的两个重要方法：

- `recycleViewHolderInternal()`
- `scrapView()`

首先看 `recycleViewHolderInternal()` 方法：

``` java
void recycleViewHolderInternal(ViewHolder holder) {
    // 判断 mCacheViews 中元素是否填充满
    int cachedViewSize = mCachedViews.size();
    if (cachedViewSize >= mViewCacheMax && cachedViewSize > 0) {
    	// 若填充满则将首位元素添加入缓存池中
        recycleCachedViewAt(0);
        cachedViewSize--;
    }

    int targetCacheIndex = cachedViewSize;
    if (ALLOW_THREAD_GAP_WORK
            && cachedViewSize > 0
            && !mPrefetchRegistry.lastPrefetchIncludedPosition(holder.mPosition)) {
        // when adding the view, skip past most recently prefetched views
        int cacheIndex = cachedViewSize - 1;
        while (cacheIndex >= 0) {
            int cachedPos = mCachedViews.get(cacheIndex).mPosition;
            if (!mPrefetchRegistry.lastPrefetchIncludedPosition(cachedPos)) {
                break;
            }
            cacheIndex--;
        }
        targetCacheIndex = cacheIndex + 1;
    }
    // 将新缓存的 ViewHolder 添加到 mCacheViews
    mCachedViews.add(targetCacheIndex, holder);
    cached = true;
	}
	if (!cached) {
	    addViewHolderToRecycledViewPool(holder, true);
	    recycled = true;
	}
}
```

可以看到缓存的 `ViewHolder` 会先添加到 `mCacheViews` 集合中，`mCacheViews` 填满之后，将首位元素移出加入缓存池。

再来看 `scrapView()` 方法：

``` java
void scrapView(View view) {
    final ViewHolder holder = getChildViewHolderInt(view);
    // ViewHolder 被移除 \ 数据无效 \ 数据未更新 \ 当数据更新时是否使用同一 ViewHolder 执行动画
    if (holder.hasAnyOfTheFlags(ViewHolder.FLAG_REMOVED | ViewHolder.FLAG_INVALID)
            || !holder.isUpdated() || canReuseUpdatedViewHolder(holder)) {
        holder.setScrapContainer(this, false);
        mAttachedScrap.add(holder);
    } else {
        if (mChangedScrap == null) {
            mChangedScrap = new ArrayList<ViewHolder>();
        }
        holder.setScrapContainer(this, true);
        mChangedScrap.add(holder);
    }
}
```

两个方法的代码量都比较少，也容易理解就不过多解释了，看注释就可以。这里重点提一下我只找到了一种会执行 `mChangedScrap.add(holder)` 逻辑的方式就是调用 `notifyItemChange(int)` 方法，目标 `ViewHolder` 会被添加到 `mChangedScrap` 集合中，这样做的原因下面再讲。

那这两个方法都是如何被触发的呢？

已知的是 `预取` 是触发 `recycleViewHolderInternal()` 的方式之一。`scrapView()` 的触发是在 `Layout` 阶段，在布局前会首先会调用 `scrapView()` 把屏幕上所有可见的 `ViewHolder` 都缓存到 `mAttachedScrap / mChangedScrap` 集合中，在布局时再从缓存中获取。

在布局过程中调用 `addViewInt()` 向布局中添加 `子View` 时会判断如下：

``` java
if (holder.isScrap()) {
    holder.unScrap();
}
```

用于清理 `mAttachedScrap` 中已复用的 `ViewHolder`。对于未复用的 `ViewHolder`在布局结束时最终会执行 `recycleViewHolderInternal()` 将其添加到 `mCachedViews` 缓存中。比如由于调用 `notifyItemAdd()、notifyItemRemoved()` 而被移出屏幕的 `ViewHolder`。

``` java
// 布局结束
private void dispatchLayoutStep3() {
    ...
    // 回收未复用的 ViewHolder
    mLayout.removeAndRecycleScrapInt(mRecycler);
    ...
    // 清理 mCangedScrap 缓存集合
    if (mRecycler.mChangedScrap != null) {
    	mRecycler.mChangedScrap.clear();
    }
    ...
}

void removeAndRecycleScrapInt(Recycler recycler) {
    final int scrapCount = recycler.getScrapCount();
    for (int i = scrapCount - 1; i >= 0; i--) {
        recycler.quickRecycleScrapView(scrap);
    }
    recycler.clearScrap();
}
```

但是如果在 `recycler.quickRecycleScrapView()` 处断点，会发现代码根本走不到这里。这是因为 `RecyclerView` 中默认动画的缘故，`ItemAnimator` 中 `mAttachedScrap` 中的 `ViewHolder` 被用于执行动画了，当动画执行完毕会对此 `ViewHolder` 进行缓存或其他操作。缓存依然是通过 `unScrap()` 和 `recycleViewHolderInternal()` 方法。如下设置可以让断点处发挥作用：

``` java
recyclerView.itemAnimator = null
```

到这里 `RecyclerView` 是如何缓存 `ViewHolder` 的就清楚了，再来张图加深下印象：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/recyclerview_recycler.jpg?versionId=CAEQFxiBgICQnKGvwBciIGRhZjUyNDRjMDNhOTRiZTQ5ZjE5ZWIzOGI0MDBmOTQw)

> 图中 `onLayout` 过程的缓存逻辑设置了 `recyclerView.itemAnimator = null`

### 总结
那现在对于 `RecyclerView` 缓存就分析结束了，对于开头的问题 `RecyclerView 真的是四级缓存吗？` 的问题应该也有了答案。`RecyclerView` 是 `三级缓存` 但有 `四种缓存方式`，分如下两种情况：

- 滑动：执行 `mCachedViews + RecycledViewPool` 的二级缓存方案，以优化滑动
- 重布局： 执行 `(mAttachedScrap + mChangedScrap) + mCachedViews + RecycledViewPool` 的三级缓存方案，以优化重布局过程。

### 未解疑问
还有一个问题，为什么重布局时需要 `mChangeScrap、mAttachedScrap` 两个集合来保存数据呢，从代码里来看是因为 `mChangeScrap` 仅在预布局过程中被使用，当预布局结束，执行真正的布局时 `mAttachedScrap` 和 `mCacheViews` 中都获取不到对应的 `ViewHolder` 而只能从缓存池中获取（或调用 `createViewHolder()`）继而执行数据更新操作。但是为什么不通过 `mFlags` 字段来区分呢？不是更方便。对于这个问题欢迎同学一起讨论 `^_^`。
