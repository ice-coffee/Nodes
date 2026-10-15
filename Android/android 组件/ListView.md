### ListView

@(android 控件药店)


#### 1. ListView怎么和ScrollView兼容
> 由于listView在scrollView中无法正确计算它的大小, 故只Listview显示一行。

1. 最完美的方案`NestedScrollView`
> 用`NestedScrollView`替换`ScrollView`，兼容问题不存在噻.

2. 重写ListView, 覆盖onMeasure()方法

	    public class MyListView extends ListView {
		    public WrapperListView(Context context) {
		        super(context);
		    }
		    public MyListView (Context context, AttributeSet attrs) {
		        super(context, attrs);
		    }
		    public MyListView (Context context, AttributeSet attrs, int defStyleAttr) {
		        super(context, attrs, defStyleAttr);
		    }
		    /**
		     * 重写该方法，达到使ListView适应ScrollView的效果
		     */
		    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		        int expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2, MeasureSpec.AT_MOST);
		        super.onMeasure(widthMeasureSpec, expandSpec);
		    }
		}

3. 动态设置listview的高度，不需要重写ListView
> 这时最好给ListView之外嵌套一层LinearLayout，不然有时候这种方法会失效，

		    public void setListViewHeightBasedOnChildren(ListView listView)
		    {
		        // 获取ListView对应的Adapter
		        ListAdapter listAdapter = listView.getAdapter();
		        if (listAdapter == null)
		        {
		            return;
		        }
		        int totalHeight = 0;
		        for (int i = 0, len = listAdapter.getCount(); i < len; i++)
		        {
		            // listAdapter.getCount()返回数据项的数目
		            View listItem = listAdapter.getView(i, null, listView);
		            // 计算子项View 的宽高
		            listItem.measure(0, 0);
		            // 统计所有子项的总高度
		            totalHeight += listItem.getMeasuredHeight();
		        }
		        ViewGroup.LayoutParams params = listView.getLayoutParams();
		        params.height = totalHeight + (listView.getDividerHeight() * (listAdapter.getCount() - 1));
		        // listView.getDividerHeight()获取子项间分隔符占用的高度
		        // params.height最后得到整个ListView完整显示需要的高度
		        listView.setLayoutParams(params);
	    }
4. 在xml文件中，直接将Listview的高度写死
> 除非你能正确的写出listview的高度, 否则这种方式就是个鸡肋.

5. 避免使用ScrollView
> 某些情况下，其实我们可以完全避免ScrollView嵌套Listview，比如使用listview的addHeader() 函数来实现预期效果或者利用布局的特性达到预期效果，当然，具体怎么用，只有在开发中慢慢琢磨，慢慢总结了.

#### 2. ListView的优化
1. 复用convertView
> 减少了很多不必要的View的创建

2. ViewHolder，封装Listview Item条目中所有的组件
> - 减少findviewbuid生成很多不必要组件
> - 提倡ViewHolder内部类声明成static, 这样就不会隐式持有外围对象的引用了

3. 采用分页加载和图片异步加载

#### 3. ScrollView页面嵌套ListVew, ListView的默认起始位置不是最顶部
1. 把套在里面的ListVew 不让获取焦点即可. 

	    listview.setFocusable(false)

> 注意：在xml布局里面设置android：focusable=“false”不生效

2. myScrollView.smoothScrollTo(0,0).
