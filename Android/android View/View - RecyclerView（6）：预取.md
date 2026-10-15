[toc]

### 关联地址
[RecyclerView（一）：预取机制](https://blog.csdn.net/tangedegushi/article/details/88790754)

### RecyclerView 预取机制

#### 什么是预取
`预取` 就是把将要显示的 `ViewHolder` 预先放置到缓存中，以优化 `RecyclerView` 滑动流畅度。`预取` 功能是在 ` Android Version 21` 之后加入的。

#### 源码分析
`GapWorker` 是 `RecyclerView` 实现预取主要涉及到的类，`GapWorker` 初始化的位置在 `RecyclerView.onAttachedToWindow()` 中：

``` java
private static final boolean ALLOW_THREAD_GAP_WORK = Build.VERSION.SDK_INT >= 21;
@Override
protected void onAttachedToWindow() {
    super.onAttachedToWindow();
    //对当前版本进行判断，
    if (ALLOW_THREAD_GAP_WORK) {
        // Register with gap worker
        //这里利用的是 ThreadLocal 的特性，这也说明主线程中就一个 GapWorker 实例对象 
        mGapWorker = GapWorker.sGapWorker.get();
        if (mGapWorker == null) {
            mGapWorker = new GapWorker();

            // break 60 fps assumption if data from display appears valid
            // NOTE: we only do this query once, statically, because it's very expensive (> 1ms)
            Display display = ViewCompat.getDisplay(this);
            float refreshRate = 60.0f;
            if (!isInEditMode() && display != null) {
                float displayRefreshRate = display.getRefreshRate();
                if (displayRefreshRate >= 30.0f) {
                    refreshRate = displayRefreshRate;
                }
            }
            //计算绘制一帧所需时间，单位是纳秒 (ns)，1秒 = 10亿纳秒
            mGapWorker.mFrameIntervalNs = (long) (1000000000 / refreshRate);
            GapWorker.sGapWorker.set(mGapWorker);
        }
        //将 RecyclerView 添加到 mRecyclerView 集合中
        mGapWorker.add(this);
    }
}
```

在 `onAttachedToWindow()` 方法中初始化了 `GapWorker` 对象时也赋值给 `mFrameIntervalNs` 变量。`mFrameIntervalNs` 的作用是防止预取消耗的时间过长反而影响性能。它会在之后被用到。

那 `GapWorker` 是如何发挥作用的呢，通过搜索可以看到 `GapWorker` 在 `RecyclerView` 中，被调用的方法除 `add()、remove()` 外还有一个就是 `postFromTraversal()` 方法。可以看到它调用的位置都与滑动相关。在 `onTouchEvent` 的 `MOVE` 事件中可以看到有如下代码：

``` java
@Override
public boolean onTouchEvent(MotionEvent e) {
    
    switch (action) {
        case MotionEvent.ACTION_MOVE: {               
            int dx = mLastTouchX - x;
            int dy = mLastTouchY - y;

            if (mScrollState == SCROLL_STATE_DRAGGING) {

                if (scrollByInternal(
                        canScrollHorizontally ? dx : 0,
                        canScrollVertically ? dy : 0,
                        vtev)) {
                    getParent().requestDisallowInterceptTouchEvent(true);
                }
                if (mGapWorker != null && (dx != 0 || dy != 0)) {
                    mGapWorker.postFromTraversal(this, dx, dy);
                }
            }
        } break;

    return true;
}
```

当 `RecyclerView` 发生滑动事件时会执行 `scrollByInternal()` 和 `postFromTraversal()` 方法，在 `scrollByInternal()` 中调用 `invalidate()` 方法触发控件树刷新，而 `postFromTraversal()` 调用了 `View.post(Runnable)` 方法，了解控件树刷新机制的同学应该清楚这样就会在下一次控件树刷新时执行 `Runnable` 参数的 `Run()` 方法了。

``` java
void postFromTraversal(RecyclerView recyclerView, int prefetchDx, int prefetchDy) {
    //为true
    if (recyclerView.isAttachedToWindow()) {
    //mRecyclerViews中包含的是已经绑定到Window上的所有RecyclerView，不止是当前处在前台的activity
    //可以这么理解，只要activity中含有RecyclerView，并且没有被销毁，那么这个RecyclerView就会被添加到mRecyclerViews中
        if (RecyclerView.DEBUG && !mRecyclerViews.contains(recyclerView)) {
            throw new IllegalStateException("attempting to post unregistered view!");
        }
        if (mPostTimeNs == 0) {
            mPostTimeNs = recyclerView.getNanoTime();
            //预取的逻辑是通过这里处理的，GapWorker实现了Runnable接口
            recyclerView.post(this);
        }
    }
    //这里只是将这两值传递进去，就是赋值而已
    recyclerView.mPrefetchRegistry.setPrefetchVector(prefetchDx, prefetchDy);
}
```

`GapWorker` 本身就实现了 `Runnable` 接口，下面就来看 `run()` 方法中做了什么操作：

``` java
@Override
public void run() {
    try {
        TraceCompat.beginSection(RecyclerView.TRACE_PREFETCH_TAG);

        if (mRecyclerViews.isEmpty()) {
            // abort - no work to do
            return;
        }

        // Query most recent vsync so we can predict next one. Note that drawing time not yet
        // valid in animation/input callbacks, so query it here to be safe.
        final int size = mRecyclerViews.size();
        long latestFrameVsyncMs = 0;
        //遍历所有保存的 RecyclerView，查找处于可见状态的view并获取最近上一帧开始的时间
        for (int i = 0; i < size; i++) {
            RecyclerView view = mRecyclerViews.get(i);
            if (view.getWindowVisibility() == View.VISIBLE) {
                latestFrameVsyncMs = Math.max(view.getDrawingTime(), latestFrameVsyncMs);
            }
        }

        if (latestFrameVsyncMs == 0) {
            // abort - either no views visible, or couldn't get last vsync for estimating next
            return;
        }
        //计算下一帧到来的时间，在这个时间内没有预取到那么就会预取失败，预取的本意就是为了滑动更流畅，如果预取在
        //下一帧到来时还没取到，还去取的话那么就会影响到绘制，得不偿失，
        long nextFrameNs = TimeUnit.MILLISECONDS.toNanos(latestFrameVsyncMs) + mFrameIntervalNs;
        //看名字就知道这里是去预取了
        prefetch(nextFrameNs);

        // TODO: consider rescheduling self, if there's more work to do
    } finally {
        mPostTimeNs = 0;
        TraceCompat.endSection();
    }
}

void prefetch(long deadlineNs) {
    buildTaskList();
    flushTasksWithDeadline(deadlineNs);
}
```

在 `run()` 方法中通过计算获得了要刷新下一帧的时间，根据此时间防止在 `CreateViewHolder` 和 `BindViewHolder` 时耗时过多。一旦预取超时则预取失败。

至此准备工作都做好了，接下来执行 `perfetch()` 中预取的具体逻辑，它调用了`buildTaskList()`，`flushTasksWithDeadline(long)` 这两个方法。先来看 `buildTaskList()`：

``` java
private void buildTaskList() {
    // Update PrefetchRegistry in each view
    final int viewCount = mRecyclerViews.size();
    int totalTaskCount = 0;
    //计算有多少个可见的RecyclerView
    for (int i = 0; i < viewCount; i++) {
        RecyclerView view = mRecyclerViews.get(i);
        if (view.getWindowVisibility() == View.VISIBLE) {
        //计算需要预取条目的位置，最终会调用到 addPosition() 方法，将位置信息和偏移量保存到mPrefetchArray数组中
            view.mPrefetchRegistry.collectPrefetchPositionsFromView(view, false);
            totalTaskCount += view.mPrefetchRegistry.mCount;
        }
    }

    // Populate task list from prefetch data...
    mTasks.ensureCapacity(totalTaskCount);
    int totalTaskIndex = 0;
    for (int i = 0; i < viewCount; i++) {
        RecyclerView view = mRecyclerViews.get(i);
        if (view.getWindowVisibility() != View.VISIBLE) {
            // Invisible view, don't bother prefetching
            continue;
        }

        LayoutPrefetchRegistryImpl prefetchRegistry = view.mPrefetchRegistry;
        final int viewVelocity = Math.abs(prefetchRegistry.mPrefetchDx)
                + Math.abs(prefetchRegistry.mPrefetchDy);
         //创建预取条目的task
        //mCount 是当前 ViewHolder 需要预取的个数，这里*2是因为 mPrefetchArray 数组不仅保存了位置，还保存了到预取 ViewHolder 到窗口的距离
        for (int j = 0; j < prefetchRegistry.mCount * 2; j += 2) {
            final Task task;
            if (totalTaskIndex >= mTasks.size()) {
                task = new Task();
                mTasks.add(task);
            } else {
                task = mTasks.get(totalTaskIndex);
            }
            //预取 ViewHolder 和窗口的距离
            final int distanceToItem = prefetchRegistry.mPrefetchArray[j + 1];
            //表示这个预取的 ViewHolder 在下一帧是否会显示，当滑动距离大于等于 distanceToItem 说明本次滑动后此 ViewHolder 将出现在屏幕上
            task.immediate = distanceToItem <= viewVelocity;
            //滑动的距离
            task.viewVelocity = viewVelocity;
            //...
            task.distanceToItem = distanceToItem;
            //预取item的RecyclerView
            task.view = view;
            //预取item所处的位置（position）
            task.position = prefetchRegistry.mPrefetchArray[j];
            //预取的总个数
            totalTaskIndex++;
        }
    }

    // ... and priority sort
    //对需要预取的 task 按照优先级进行排序，immediate = true的将会排在前面，这是因为immediate =true的将会在下一帧显示
    Collections.sort(mTasks, sTaskComparator);
}
```

`buildTaskList()` 方法的主要作用是填充预取任务 `Task` 集合。可以看到方法内有嵌套 `for` 循环，代表集合的填充数量由两方面决定：

- 当前处于可见状态的 `RecyclerView` 数量。
- `RecyclerView.LayoutManager.LayoutPrefetchRegistry` 接口的实现定义 `RecyclerView` 每次预取 `ViewHolder` 的数量。

虽然看起来我们可以自己实现 `LayoutPrefetchRegistry` 接口来决定每次预取数量，但如果没有自定义 `LayoutManager` 的需求不要去自定义 `LayoutPrefetchRegistry`，`RecyclerView.tryGetViewHolderForPositionByDeadline()` 方法中对于获取数量有限制，超前获取将会报错。所以最好还是用 `GapWorker` 中提供的默认 `LayoutPrefetchRegistry` 实现比较方便。

``` java
static class LayoutPrefetchRegistryImpl
        implements RecyclerView.LayoutManager.LayoutPrefetchRegistry {

    // 预取 ViewHolder 信息
    int[] mPrefetchArray;

    // 预取 ViewHolder 数
    int mCount;

    /**
     * 收集预取项
     * @ param view RecyclerView
     * @ nested 是否是嵌套 RecyclerView
     */
    void collectPrefetchPositionsFromView(RecyclerView view, boolean nested) {
        mCount = 0;
        if (mPrefetchArray != null) {
            Arrays.fill(mPrefetchArray, -1);
        }

        // 调用 LayoutManager 中的预取和嵌套预取的实现来收集预取项信息
        final RecyclerView.LayoutManager layout = view.mLayout;
        if (view.mAdapter != null
                && layout != null
                && layout.isItemPrefetchEnabled()) {
            if (nested) {
                // nested prefetch, only if no adapter updates pending. Note: we don't query
                // view.hasPendingAdapterUpdates(), as first layout may not have occurred
                if (!view.mAdapterHelper.hasPendingUpdates()) {
                    layout.collectInitialPrefetchPositions(view.mAdapter.getItemCount(), this);
                }
            } else {
                // momentum based prefetch, only if we trust current child/adapter state
                if (!view.hasPendingAdapterUpdates()) {
                    layout.collectAdjacentPrefetchPositions(mPrefetchDx, mPrefetchDy,
                            view.mState, this);
                }
            }

            // 更新 RecyclerView 中 mCacheViews 缓存集合的大小
            if (mCount > layout.mPrefetchMaxCountObserved) {
                layout.mPrefetchMaxCountObserved = mCount;
                layout.mPrefetchMaxObservedInInitialPrefetch = nested;
                view.mRecycler.updateViewCacheSize();
            }
        }
    }

    /**
     * 收集预取项信息，其中每两个元素代表一个 ViewHolder 的信息，第一位代表 ViewHolder 在 RecyclerView 中的位置，第二位代表其到窗口的距离
     * @ param view RecyclerView
     * @ nested 是否是嵌套 RecyclerView
     */
    @Override
    public void addPosition(int layoutPosition, int pixelDistance) {
    	...
        // add position
        mPrefetchArray[storagePosition] = layoutPosition;
        mPrefetchArray[storagePosition + 1] = pixelDistance;

        mCount++;
    }
}
```

通过 `buildTaskList()` 方法之后我们就得到了需要预取的 `Task` 任务集合了，那 `Task` 到底是什么呢？每一个 `Task` 都代表一个预取任务，其内保存了预取任务执行所需的各种信息。

``` java
static class Task {
    //表示这个预取 ViewHolder 在下一帧是否会显示，通常为false，表示在下一帧不显示，为true就说明在下一帧是会显示的
    public boolean immediate;
    //滑动的距离
    public int viewVelocity;
    //预取 ViewHolder 和窗口的距离
    public int distanceToItem;
    //对应的 RecyclerView
    public RecyclerView view;
    //预取 ViewHolder 所处的位置
    public int position;
}
```

那下面来看 `flushTasksWithDeadline(long)` 方法：

``` java
private void flushTasksWithDeadline(long deadlineNs) {
    //所有的task，预取出相应的view，然后清空task
    for (int i = 0; i < mTasks.size(); i++) {
        final Task task = mTasks.get(i);
        if (task.view == null) {
            break; // done with populated tasks
        }
        //这里就是去取task
        flushTaskWithDeadline(task, deadlineNs);
        task.clear();
    }
}
```

遍历任务列表，交给 `flushTaskWithDeadline(Task, long)` 去执行预取，执行结束后清理 `Task`：

``` java
/**
 * @param task 预取任务
 * @param deadlineNs 下一帧刷新的时间
 */
private void flushTaskWithDeadline(Task task, long deadlineNs) {
    long taskDeadlineNs = task.immediate ? RecyclerView.FOREVER_NS : deadlineNs;
    RecyclerView.ViewHolder holder = prefetchPositionWithDeadline(task.view,
            task.position, taskDeadlineNs);
    if (holder != null
            && holder.mNestedRecyclerView != null
            && holder.isBound()
            && !holder.isInvalid()) {
        prefetchInnerRecyclerViewWithDeadline(holder.mNestedRecyclerView.get(), deadlineNs);
    }
}
```

看名字就知道 `prefetchPositionWithDeadline()` 是去预取的，然后返回的就是 `ViewHolder`，`ViewHolder != null` 就说明预取成功了。下面还一个判断执行，这个判断的作用是预取的这个 `view` 是否是 `RecyclerView`，如果是就会执行嵌套预取逻辑。来看 `prefetchPositionWithDeadline()` 方法：

``` java
private RecyclerView.ViewHolder prefetchPositionWithDeadline(RecyclerView view,
        int position, long deadlineNs) {
    if (isPrefetchPositionAttached(view, position)) {
        // don't attempt to prefetch attached views
        return null;
    }
	//这里先拿到 RecyclerView 的缓存对象
    RecyclerView.Recycler recycler = view.mRecycler;
    RecyclerView.ViewHolder holder;
    try {
        view.onEnterLayoutOrScroll();
        //这里就是去缓存中获取或是新创建一个，这里先不讲，之后分析 RecyclerView 缓存实现的时候会说到
        holder = recycler.tryGetViewHolderForPositionByDeadline(
                position, false, deadlineNs);

        if (holder != null) {
            if (holder.isBound() && !holder.isInvalid()) {
                // Only give the view a chance to go into the cache if binding succeeded
                // Note that we must use public method, since item may need cleanup
                //一般会执行到这里，这里是将获取的 ViewHolder 添加到 mCachedViews 缓存中
                recycler.recycleView(holder.itemView);
            } else {
                // Didn't bind, so we can't cache the view, but it will stay in the pool until
                // next prefetch/traversal. If a View fails to bind, it means we didn't have
                // enough time prior to the deadline (and won't for other instances of this
                // type, during this GapWorker prefetch pass).
                //将holder添加到第四级缓存mRecyclerPool中
                recycler.addViewHolderToRecycledViewPool(holder, false);
            }
        }
    } finally {
        view.onExitLayoutOrScroll(false);
    }
    return holder;
}
```

看到通过 `tryGetViewHolderForPositionByDeadline()` 方法最后获取到了目标 `ViewHolder`，并将其存放到缓存中。这个方法会在 `RecyclerView` 缓存中具体说明，大致的流程是，首先在各个缓存集合中寻找目标 `ViewHolder`，若未找到则调用 `Adapter.createViewHolder()` 方法新建 `ViewHolder`，再判断此 `ViewHolder` 是否需要绑定数据，若需要则调用 `tryBindViewHolderByDeadline()` 方法绑定数据，然后将 `ViewHolder` 返回。

``` java
ViewHolder tryGetViewHolderForPositionByDeadline(int position, boolean dryRun, long deadlineNs) {
    ...
    if (holder == null) {
        long start = getNanoTime();
        if (deadlineNs != FOREVER_NS
                && !mRecyclerPool.willCreateInTime(type, start, deadlineNs)) {
            // abort - we have a deadline we can't meet
            return null;
        }
        holder = mAdapter.createViewHolder(RecyclerView.this, type);
    }
}
```

这里在调用 `createViewHolder()、tryBindViewHolderByDeadline()` 之前都会判断调用方法消耗的事件是否会超过下一帧刷新的时间，若耗时超过则返回 `null`，以防影响流畅度。

总结来说，`RecyclerView` 预取功能是通过判断用户的滑动预判即将加载的 `ViewHolder` 将其提前放置在缓存中以达到优化滑动体验的功能。
