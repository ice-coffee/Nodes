[toc]
### 关联地址
[RecyclerView源码分析](https://www.jianshu.com/p/9ddfdffee5d3)

[Frank-Zhu](http://frank-zhu.github.io/android/2015/01/16/android-recyclerview-part-1/)

[Hongyang](http://blog.csdn.net/lmj623565791/article/details/45059587)

[RecyclerView数据更新神器 进化版- AsyncListDiffer](https://blog.csdn.net/IO_Field/article/details/79804299)

### 是什么
> RecyclerView is a more advanced and flexible version of ListView. This widget is a container for large sets of views that can be recycled and scrolled very efficiently. Use the RecyclerView widget when you have lists with elements that change dynamically.

> 简单说就是当你需要动态展示一组数据的时候就会需要用到它. 它比ListView更加灵活 

#### 为什么
RecyclerView架构，提供了一种插拔式的体验，高度的解耦，异常的灵活，通过设置它提供的不同LayoutManager，ItemDecoration , ItemAnimator实现令人瞠目的效果。
- 你想要控制其显示的方式，请通过布局管理器LayoutManager
- 你想要控制Item间的间隔（可绘制），请通过ItemDecoration
- 你想要控制Item增删的动画，请通过ItemAnimator
- 你想要控制点击、长按事件，请自己写
#### 时间点
* *
#### 怎么用
1. gradle文件中添加包的引用（配合官方CardView使用）

```
compile 'com.android.support:cardview-v7:21.0.3'
compile 'com.android.support:recyclerview-v7:21.0.3'
```

2. 通过布局管理器LayoutManager, 控制其不同的显示方式
```
mRecyclerView.setLayoutManager(new LinearLayoutManager(this));//这里用线性显示 类似于listview
mRecyclerView.setLayoutManager(new GridLayoutManager(this, 2));//这里用线性宫格显示 类似于grid view
mRecyclerView.setLayoutManager(new StaggeredGridLayoutManager(2, OrientationHelper.VERTICAL));//这里用线性宫格显示 类似于瀑布流
mRecyclerView.setAdapter(new NormalRecyclerViewAdapter(this));
```
        
2. 多Item布局实现

```
@(android 控件药店)Override
public int getItemViewType(int position) 
{
    return super.getItemViewType(position);
}
```

```
public static enum ITEM_TYPE 
{
    ITEM_TYPE_IMAGE,
    ITEM_TYPE_TEXT
}
@Override
public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) 
{
    if (viewType == ITEM_TYPE.ITEM_TYPE_IMAGE.ordinal()) 
    {
        return new ImageViewHolder(mLayoutInflater.inflate(R.layout.item_image, parent, false));
    } else 
    {
        return new TextViewHolder(mLayoutInflater.inflate(R.layout.item_text, parent, false));
    }
}
```
`getItemViewType`方法是用来获取当前项Item(position参数)是哪种类型的布局, 函数`onCreateViewHolder(ViewGroup parent, int viewType)`这里的第二个参数就是View的类型，可以根据这个类型判断去创建不同item的ViewHolder。

3. item动画

RecyclerView本身就已经实现了item的动画，只需要调用以下几个函数来增删Item即可出现默认动画。

```
 notifyItemChanged(int)
 notifyItemInserted(int)
 notifyItemRemoved(int)
 notifyItemRangeChanged(int, int)
 notifyItemRangeInserted(int, int)
 notifyItemRangeRemoved(int, int)
```

也可以自定义实现RecyclerView.ItemAnimator的接口方法，实现代码可以参考DefaultItemAnimator. 当然开源库是有的[recyclerview-animators](https://github.com/wasabeef/recyclerview-animators)

#### 遇到的坑
#### 扩展
##### 1. 禁止滑动

```
LinearLayoutManager linearLayoutManager = new LinearLayoutManager(context)
{
	@Override
	public boolean canScrollVertically()
	{
		return false;
	}
};
setLayoutManager(linearLayoutManager);
```

##### 2. getlayoutposition vs getadapterposition
[论坛链接](http://stackoverflow.com/questions/29684154/recyclerview-viewholder-getlayoutposition-vs-getadapterposition)
> When adapter contents change (and you call notify*) RecyclerView requests a new layout. From that moment, until layout system decides to calculate a new layout (<16 ms), the layout position and adapter position may not match because layout has not reflected adapter changes yet.
当适配器中数据集合改变(并调用notify……)Recyclerview请求一个新的布局, 从这一刻起, 直到布局系统决定计算一个新的布局( <16ms ) , 布局位置和适配器位置可能不匹配, 因为适配器的修改还未反映到布局.

- 调用notifyDataSetChanged, Recyclerview不知道ViewHolder的适配器位置, 直到新布局产生. 在这种情况下, getAdapterPosition将返回Recyclerview # NO_POSITION (-1).
- 调用notifyItemInserted之后, Layout不能马上获取到新的position, 因为布局还没更新(需要<16ms的时间刷新视图), 所以只能获取到旧的, 但是Adapter中的position就可以马上获取到最新的position.
- 正在使用LinearLayoutManager并想要访问当前点击项目上方的ViewHolder。在这种情况下，您应该使用布局位置来获取上面的项目。mRecyclerView.findViewHolderForLayoutPosition（myViewHolder.getLayoutPosition（） - 1）您必须使用布局位置，因为它匹配用户当前在屏幕上看到的。
- 总结: 在列表数据长度不改变的情况下选择`getlayoutposition`, 否则选择`getAdapterPosition`

##### 3. [DiffUtil](https://blog.csdn.net/zxt0601/article/details/52562770)

##### 4. 加载 RecyclerView 莫名自动滚动
[原文](https://github.com/alibaba/vlayout/issues/225)

```
android:descendantFocusability="blocksDescendants" 父布局里，加这句
android:overScrollMode="never" recycleView里加这局
```

##### 5. SnapHelper
[让你明明白白的使用RecyclerView——SnapHelper详解](https://www.jianshu.com/p/e54db232df62)
RecyclerView在24.2.0版本中新增了SnapHelper这个辅助类，用于辅助RecyclerView在滚动结束时将Item对齐到某个位置。特别是列表横向滑动时，很多时候不会让列表滑到任意位置，而是会有一定的规则限制，这时候就可以通过SnapHelper来定义对齐规则了。

##### 6. 滑动到Item顶部
[RecyclerView滑动到item顶部的解决办法](https://www.jianshu.com/p/bde672af4e11)
实现此功能有如下方法：
```
//平滑滚动
recyclerView.smoothScrollToPosition(position);
//非平滑滚动
recyclerView.scrollToPosition(position);

LinearLayoutManager manager = (LinearLayoutManager)recyclerView.getLayoutManager();
//平滑滚动
manager.scrollToPosition(position)
```
上述方法以外，RecyclerView还有`scrollBy`、`smoothScrollBy`这两个方法(RecyclerView不支持scrollTo)，可以实现滑动到指定位置，但是使用这三个方法滑动到对应item位置，需要计算item的高度或宽度

注意：
调用scrollToPosition或者smoothScrollToPosition滑动RecyclerView时若目标item可见，则不执行滑动。

##### 7. notifyItemChanged 闪烁问题
[原文](https://blog.csdn.net/java_goodstudy/article/details/55669077)
问题描述：
调用notifyItemChanged时页面闪烁
问题原因：
RecyclerView默认动画所致
解决方案：
((SimpleItemAnimator)recyclerView.getItemAnimator()).setSupportsChangeAnimations(false);
加上这一句就可以了，设置为false，动画就不显示了。

另外一种方案：
recyclerView.getItemAnimator().setChangeDuration(0)；
通过设置动画执行时间为0来解决问题

##### 8. 局部刷新的几种方式

```
notifyItemChanged(int position, Object payload)
```

```
RecyclerView.ViewHolder viewHolder = mRecyclerView.findViewHolderForAdapterPosition(i);
if (viewHolder != null && viewHolder instanceof ItemHolder) {
	ItemHolder itemHolder = (ItemHolder) itemHolder 
	Button mButton = itemHolder.mButton
	//dosomething
}
```

```
mAdapter.getViewByPosition(rvPayMethod, selectedPosition, R.id.iv_pay_method_select);
//dosomething
```
