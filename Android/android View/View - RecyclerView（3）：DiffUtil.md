[toc]

### 数据更新

#### DiffUtil
`DiffUtil` 是 `Android` 工程师提供的用于规范使用 `notify*()` 方法刷新数据的工具类。

在使用 `RecyclerView` 时经常会用到如下方法更新数据：

* notifyItemRangeInserted()
* notifyItemRangeRemoved()
* notifyItemMoved()
* notifyItemRangeChanged()

当某条数据发生变化（如移除、修改等）时调用以上方法可用于更新数据以及 `UI` 显示。
想象如下场景，若列表中大量数据产生变化，怎么办呢？一般操作是调用它：

* notifyDataSetChanged()

将列表从头到尾无脑更新一遍，这时候就出现问题了：

* 图片闪烁
* 性能低，触发布局重新绘制
* item 动画不会触发

联想实际开发中，列表刷新操作是不是就调用了 `notifyDataSetChanged()`。

基于上述问题我们有了更高效的解决方案，那就是 - `DiffUtil`。`DiffUtil` 使用 `Eugene W. Myers` 的差分算法计算两列数据之间的最小更新数，将旧的列表转换为新的列表，并针对不同的数据变化，执行不同的调用，而不是无脑的 `notifyDataSetChanged()`。

关于 `Eugene W. Myers` 差分算法分析可以参考这篇文章：
[Myers 差分算法 \(Myers Difference Algorithm\) —— DiffUtils 之核心算法（一）](https://cloud.tencent.com/developer/article/1488583)

`DiffUtil` 用法很简单，一共三步：
 
* 计算新、旧数据间的最小更新数
* 更新列表数据
* 更新 `RecyclerView`

具体实现如下：
``` java
//第一步：调用 DiffUtil.calculateDiff 计算最小数据更新数
val diffResult = DiffUtil.calculateDiff(object : Callback() {
    override fun areItemsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
        return oldStudentList[oldItemPosition].id == newStudentList[newItemPosition].id
    }

    override fun getOldListSize(): Int {
        return oldStudentList.size
    }

    override fun getNewListSize(): Int {
        return newStudentList.size
    }

    override fun areContentsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
        return oldStudentList[oldItemPosition].name == newStudentList[newItemPosition].name
    }
})

//第二步：更新旧数据集合
oldStudentList.clear()
oldStudentList.addAll(newStudentList)

//第三部：更新 RecyclerView
diffResult.dispatchUpdatesTo(diffAdapter)
```

第二步、第三部都很简单，主要来看下 `DiffUtil.Callback` 中四个方法的含义。
``` java
public abstract static class Callback {
    /**
     * 旧数据 size
     */
    public abstract int getOldListSize();

    /**
     * 新数据 size
     */
    public abstract int getNewListSize();

    /**
     * DiffUtil 调用判断两个 itemview 对应的数据对象是否一样. 由于 DiffUtil 是对两个不同数据集合的对比, 所以比较对象引用肯定是不行的, 一般会使用 id 等具有唯一性的字段进行比较.
    
     * @param oldItemPosition 旧数据集合中的下标
     * @param newItemPosition 新数据集合中的下标
     * @return True 返回 true 及判断两个对象相等, 反之则是不同的两个对象.
     */
    public abstract boolean areItemsTheSame(int oldItemPosition, int newItemPosition);

    /**
     * Diffutil 调用判断两个相同对象之间的数据是否不同. 此方法仅会在 areItemsTheSame() 返回 true 的情况下被调用.
     *
     * @param oldItemPosition 旧数据集合中的下标
     * @param newItemPosition 新数据集合中用以替换旧数据集合数据项的下标
     * @return True 返回 true 代表 两个对象的数据相同, 反之则有差别.
     */
    public abstract boolean areContentsTheSame(int oldItemPosition, int newItemPosition);

    /**
     * 当 areItemsTheSame() 返回true areContentsTheSame() 返回 false 时, 此方法将被调用, 来完成局部刷新功能.
     */
    @Nullable
    public Object getChangePayload(int oldItemPosition, int newItemPosition);
}
```

各个方法的含义都加在注释中了，理解不难，用法更简单。

具体 `DiffUtil` 是怎么更新 `RecyclerView` 的呢，看下 `dispatchUpdatesTo()` 方法中都做了什么

``` java
public void dispatchUpdatesTo(@NonNull final RecyclerView.Adapter adapter) {
    dispatchUpdatesTo(new AdapterListUpdateCallback(adapter));
}
```

`adapter` 作为参数创建了一个类 `AdapterListUpdateCallback` 的对象，`AdapterListUpdateCallback` 类中实现的就是具体的更新操作了。

``` java
public final class AdapterListUpdateCallback implements ListUpdateCallback {

    @Override
    public void onInserted(int position, int count) {
        mAdapter.notifyItemRangeInserted(position, count);
    }

    @Override
    public void onRemoved(int position, int count) {
        mAdapter.notifyItemRangeRemoved(position, count);
    }

    @Override
    public void onMoved(int fromPosition, int toPosition) {
        mAdapter.notifyItemMoved(fromPosition, toPosition);
    }

    @Override
    public void onChanged(int position, int count, Object payload) {
        mAdapter.notifyItemRangeChanged(position, count, payload);
    }
}
```

> 注意：通过了解 `DiffUtil` 的工作模式，我们了解到 `DiffUtil` 的通过对两列数据进行对比，产生对比结果来更新列表的。也就是说即使只更新列表中某个对象中的某个元素也要提供新的列表给 `DiffUtil`。所以可以想到在开发中最符合 `DiffUtil` 的使用场景应该就是列表数据的刷新了。如果只是某个对象的变化自己调用 `notifyItem*()` 就可以了，没必要使用 `DiffUil`。 

#### AsyncListDiffer
由于 `DiffUtil` 计算两个数据集合是在主线程中计算的，那么数据量大耗时的操作势必会影响到主线程代码的执行。`Android` 中最常用的异步执行耗时操作，更新主线程 `UI` 的方法就是用到 `Handler` 了。不过不用担心，贴心的 `Android` 工程师已经为我们考虑到了这中情况并提供你了 `ListAdapter` 和 `AsyncListDiffer` 两个工具类。
 
以 `AsyncListDiffer` 为例看下它的用法：
首先注册 `AsyncListDiffer` 的实例对象，来看下它的构造函数：
``` java
public class AsyncListDiffer<T> {
    public AsyncListDiffer(@RecyclerView.Adapter adapter, DiffUtil.ItemCallback<T> diffCallback) {
    this(new AdapterListUpdateCallback(adapter),
            new AsyncDifferConfig.Builder<>(diffCallback).build());
    }
}
```
可以看到 `AsyncListDiffer` 类声明中有一个泛型，用于指定集合的数据类型。构造函数中接收两个参数一个是 `Adapter` 对象。`Adapter` 对象的作用和 `DiffUtil` 中的作用一样，作为参数创建 `AdapterListUpdateCallback` 对象，在其内是具体执行列表更新的方法。

另一个是 `DiffUtil.ItemCallback` 对象，其作为参数构建了类 `AsyncDifferConfig` 的对象。
``` java
AsyncDifferConfig.class
public final class AsyncDifferConfig<T> {

    private final Executor mMainThreadExecutor;
    private final Executor mBackgroundThreadExecutor;
    private final DiffUtil.ItemCallback<T> mDiffCallback;

    public static final class Builder<T> {
        
        public AsyncDifferConfig<T> build() {
            if (mBackgroundThreadExecutor == null) {
                synchronized (sExecutorLock) {
                    if (sDiffExecutor == null) {
                        sDiffExecutor = Executors.newFixedThreadPool(2);
                    }
                }
                mBackgroundThreadExecutor = sDiffExecutor;
            }
            return new AsyncDifferConfig<>(
                    mMainThreadExecutor,
                    mBackgroundThreadExecutor,
                    mDiffCallback);
        }
    }
}
```
`AsyncDifferConfig` 对象中保存了两个重要变量，`mMainThreadExecutor` 和 `mBackgroundThreadExecutor`，`mBackgroundThreadExecutor` 是一个最多容纳两个线程的线程池，用于异步执行 `DiffUtil.calculateDiff` 。`mMainThreadExecutor` 中实际真正执行的是 `Handler` 的调用。如下：

``` java
AsyncListDiffer.class -> MainThreadExecutor.class
private static class MainThreadExecutor implements Executor {
    final Handler mHandler = new Handler(Looper.getMainLooper());
    MainThreadExecutor() {}
    @Override
    public void execute(@NonNull Runnable command) {
        mHandler.post(command);
    }
}
```

创建 `AsycnListDiffer` 对象，首先声明 `DiffUtil.ItemCallback` 对象：
``` java
//1. 声明 DiffUtil.ItemCallback 回调
private val itemCallback = object : DiffUtil.ItemCallback<StudentBean>() {
    override fun areItemsTheSame(oldItem: StudentBean, newItem: StudentBean): Boolean {
        return oldItem.id == newItem.id
    }

    override fun areContentsTheSame(oldItem: StudentBean, newItem: StudentBean): Boolean {
        return oldItem.name == newItem.name && oldItem.age == newItem.age
    }
}
```
`DiffUtil.ItemCallback` 同样具有 `areItemTheSame()`、`areContentsTheSame()`、`getChangePayload()` 方法，用法与 `DiffUtil.Callback` 相同。

接下来创建 `AsycnListDiffer` 对象：
``` java
//2. 创建 AsyncListDiff 对象
private val mDiffer = AsyncListDiffer<StudentBean>(this, itemCallback)
```

最后一步，更新列表数据：
``` java
fun submitList(studentList: List<StudentBean>) {
    //3. 提交新数据列表
    mDiffer.submitList(studentList)
}
```
`AsycnListDiffer` 的用法就是这么简单。总结其实就两步：

* 创建 `AsyncListDiffer` 对象。
* 调用 `submitList()` 更新数据。

完整代码如下：
``` java
class StudentAdapter(context: Context) : RecyclerView.Adapter<StudentAdapter.MyViewHolder>() {

    private val girlColor = "#FFD6E7"
    private val boyColor = "#BAE7FF"

    private val layoutInflater: LayoutInflater = LayoutInflater.from(context)

    //1. 声明 DiffUtil.ItemCallback 回调
    private val itemCallback = object : DiffUtil.ItemCallback<StudentBean>() {
        override fun areItemsTheSame(oldItem: StudentBean, newItem: StudentBean): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: StudentBean, newItem: StudentBean): Boolean {
            return oldItem.name == newItem.name && oldItem.age == newItem.age
        }
    }

    //2. 创建 AsyncListDiff 对象
    private val mDiffer = AsyncListDiffer<StudentBean>(this, itemCallback)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StudentAdapter.MyViewHolder {
        return MyViewHolder(layoutInflater.inflate(R.layout.item_student, parent, false))
    }

    override fun getItemCount(): Int {
        return mDiffer.currentList.size
    }

    fun submitList(studentList: List<StudentBean>) {
        //3. 提交新数据列表
        mDiffer.submitList(studentList)
    }

    override fun onBindViewHolder(holder: StudentAdapter.MyViewHolder, position: Int) {
        //4. 从新数据列表中获取最新数据
        val studentBean = mDiffer.currentList[position]
        when (studentBean.gender) {
            StudentBean.GENDER_GRIL -> {
                holder.rlRoot.setBackgroundColor(Color.parseColor(girlColor))
                holder.ivIcon.setBackgroundResource(R.mipmap.girl)
            }
            StudentBean.GENDER_BOY -> {
                holder.rlRoot.setBackgroundColor(Color.parseColor(boyColor))
                holder.ivIcon.setBackgroundResource(R.mipmap.boy)
            }
        }
        holder.tvName.text = studentBean.name
        holder.tvAge.text = studentBean.age.toString()
    }

    class MyViewHolder(view: View) : RecyclerView.ViewHolder(view) {

        val rlRoot: RelativeLayout = view.findViewById(R.id.rl_student_root)
        val ivIcon: ImageView = view.findViewById(R.id.iv_student_icon)
        val tvName: TextView = view.findViewById(R.id.tv_student_name)
        val tvAge: TextView = view.findViewById(R.id.tv_student_age)
    }
}
```

看下 `submitList` 中都做了什么：

``` java
public void submitList(@Nullable final List<T> newList,
        @Nullable final Runnable commitCallback) {
    // 累计调用次数, 多次执行 submitList() 仅生效最后一次调用
    final int runGeneration = ++mMaxScheduledGeneration;

    // 新\旧 数据集合对象相等时直接返回
    if (newList == mList) {
        // nothing to do (Note - still had to inc generation, since may have ongoing work)
        if (commitCallback != null) {
            commitCallback.run();
        }
        return;
    }

    final List<T> previousList = mReadOnlyList;

    // 新数据空, 所有 item 执行 remove 操作
    if (newList == null) {
        //noinspection ConstantConditions
        int countRemoved = mList.size();
        mList = null;
        mReadOnlyList = Collections.emptyList();
        // notify last, after list is updated
        mUpdateCallback.onRemoved(0, countRemoved);
        onCurrentListChanged(previousList, commitCallback);
        return;
    }

    // 第一次插入数据, 统一执行 inserted 操作
    if (mList == null) {
        mList = newList;
        mReadOnlyList = Collections.unmodifiableList(newList);
        // notify last, after list is updated
        mUpdateCallback.onInserted(0, newList.size());
        onCurrentListChanged(previousList, commitCallback);
        return;
    }

    final List<T> oldList = mList;
    // 异步执行 DiffUtil.calculateDiff 计算数据最小更新数
    mConfig.getBackgroundThreadExecutor().execute(new Runnable() {
        @Override
        public void run() {
            final DiffUtil.DiffResult result = DiffUtil.calculateDiff(new DiffUtil.Callback() {
                @Override
                public int getOldListSize() {
                    return oldList.size();
                }

                @Override
                public int getNewListSize() {
                    return newList.size();
                }

                @Override
                public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
                    T oldItem = oldList.get(oldItemPosition);
                    T newItem = newList.get(newItemPosition);
                    if (oldItem != null && newItem != null) {
                        return mConfig.getDiffCallback().areItemsTheSame(oldItem, newItem);
                    }
                    // If both items are null we consider them the same.
                    return oldItem == null && newItem == null;
                }

                @Override
                public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                    T oldItem = oldList.get(oldItemPosition);
                    T newItem = newList.get(newItemPosition);
                    if (oldItem != null && newItem != null) {
                        return mConfig.getDiffCallback().areContentsTheSame(oldItem, newItem);
                    }
                    if (oldItem == null && newItem == null) {
                        return true;
                    }
                    // There is an implementation bug if we reach this point. Per the docs, this
                    // method should only be invoked when areItemsTheSame returns true. That
                    // only occurs when both items are non-null or both are null and both of
                    // those cases are handled above.
                    throw new AssertionError();
                }

                @Nullable
                @Override
                public Object getChangePayload(int oldItemPosition, int newItemPosition) {
                    T oldItem = oldList.get(oldItemPosition);
                    T newItem = newList.get(newItemPosition);
                    if (oldItem != null && newItem != null) {
                        return mConfig.getDiffCallback().getChangePayload(oldItem, newItem);
                    }
                    // There is an implementation bug if we reach this point. Per the docs, this
                    // method should only be invoked when areItemsTheSame returns true AND
                    // areContentsTheSame returns false. That only occurs when both items are
                    // non-null which is the only case handled above.
                    throw new AssertionError();
                }
            });

            //主线程中更新列表
            mMainThreadExecutor.execute(new Runnable() {
                @Override
                public void run() {
                    if (mMaxScheduledGeneration == runGeneration) {
                        latchList(newList, result, commitCallback);
                    }
                }
            });
        }
    });
}
```

最后贴一张图：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/recyclerview_diffutil.gif)

下次遇到异步执行计算，根据计算结果主线程更新 `UI` 也可以学习 `AsyncListDiffer` 写一个工具类出来 `^_^`。
