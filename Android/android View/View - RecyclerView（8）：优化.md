> 每一个人都会总结 `RecyclerView` 的优化。

### 关联地址
[RecyclerView 性能优化](https://mthli.xyz/recyclerview-optimization/)

[RecyclerView 性能优化](https://zhuanlan.zhihu.com/p/49338922)

* 只在 `onBindViewHolder()` 中执行数据的绑定操作，而不应处理数据逻辑（例如日期格式化、数据格式化等）。
* 对于数据变更不要无脑使用 `notifyDataSetChanged()` 方法，应视情况使用 `notifyItem*()` 方法，处理数据更新时推荐使用 `DiffUtil、AsyncListDiffer` 处理。
* 通过 `setViewCacheSize()` 方法修改 `RecyclerView` 滑动缓存数量，优化滑动频繁的操作。
* 设置 `RecyclerView.addOnScrollListener()` 来在滑动过程中停止加载的操作。
* `RecyclerView` 嵌套情况下调用 `setInitialItemsPrefetchCount()` 方法设置预取数。
* 通过 `setRecycledViewPool()` 设置公共缓存池，根据不同布局的 `itemtype` 缓存全局 `RecyclerView.Holder`。
