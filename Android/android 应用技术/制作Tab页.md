## 制作Tab页

@(android 应用技术)


[TOC]
### 1. radiogroup+framelayout制作Tab页
> 这个是我在`八戒宝app`中使用的[下载链接](http://pan.baidu.com/s/1c0hWp6g)

1. 首先获得FragmentTransaction对象

```
FragmentManager fm = getSupportFragmentManager();
```
2. 开启Fragment事务(
> 一系列对和FragmentManager相关联的Fragment的操作集合,FragmentTranscation中使用`队列`的数据模型保存操作的

```
FragmentTransaction ft = fm.beginTransaction();
```
3. 在进行进行FragmentTranscation.add()操作前先隐藏所有已经被添加到容器中的Fragment
```
private void hideAllFragment(FragmentTransaction ft)
    {
        if (null != ft)
        {
            if (null != bjbFragment)
            {
                ft.hide(bjbFragment);
            }

            if (null != investFragment)
            {
                ft.hide(investFragment);
            }

            if (null != accountCenterFragment)
            {
                ft.hide(accountCenterFragment);
            }
        }
    }
```
4. 通过switch语句判断用户的操作意图然后判断是否目标Fragment是否已经添加到了容器中,如果是那么由于之前已经调用了hide()方法,所以我们直接调用show()方法即可显示目标Fragment,如果没有那么调用add()方法把目标Fragment添加到容器中

```
if (accountCenterFragment.isAdded())
{
	ft.show(accountCenterFragment);
}
else
{
	ft.add(R.id.fl_home_content, accountCenterFragment);
}
```
> 在此之前应先判断当前Fragment的实例是否已经创建,这样能避免Fragment实例被多次创建,耗费资源

```
if (null == accountCenterFragment)
{
	accountCenterFragment = new WealthCenterFragment();
}
```
> 这块的代码最好生成写在单独的函数中,方便阅读

5. 对于FragmentManager相关联的Fragment操作之后谨记要调用commit()提交

完整的代码如下所示

xml文件

```
	<FrameLayout
            android:id="@+id/fl_home_content"
            android:layout_width="match_parent"
            android:layout_height="0dip"
            android:layout_weight="1.0"
            />

    <View
            android:layout_width = "match_parent"
            android:layout_height = "@dimen/item_space"
            android:background="#d7d7d7"/>

    <RadioGroup
            android:id="@+id/main_radio"
            android:layout_width="fill_parent"
            android:layout_height="49dp"
            android:layout_gravity="bottom"
            android:background="@color/color_F9F9F9"
            android:gravity="center_vertical"
            android:orientation="horizontal"
            android:paddingTop="2dp" >

        <RadioButton
                android:id="@+id/rb_bjb"
                style="@style/main_tab_bottom"
                android:drawableTop="@drawable/icon_bjb"
                android:text="@string/tab_news_center" />

        <RadioButton
                android:id="@+id/rb_invest"
                style="@style/main_tab_bottom"
                android:drawableTop="@drawable/icon_invest"
                android:text="@string/tab_invest" />

        <RadioButton
                android:id="@+id/rb_account_center"
                style="@style/main_tab_bottom"
                android:drawableTop="@drawable/icon_account_center"
                android:text="@string/tab_account_center" />

    </RadioGroup>
```
RadioGroup设置点击事件
```
	main_radio.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener()
        {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId)
            {
                changeFragment(checkedId);
            }
        });

	((RadioButton) main_radio.findViewById(R.id.rb_bjb)).setChecked(true);
```
> 如此写法`((RadioButton) main_radio.findViewById(R.id.rb_bjb)).setChecked(true);`可以避免onCheckedChanged多次调用的问题
```
private void hideAllFragment(FragmentTransaction ft)
    {
        if (null != ft)
        {
            if (null != bjbFragment)
            {
                ft.hide(bjbFragment);
            }

            if (null != investFragment)
            {
                ft.hide(investFragment);
            }

            if (null != accountCenterFragment)
            {
                ft.hide(accountCenterFragment);
            }
        }
    }
```

```
private void changeToBjbFragment(FragmentTransaction ft)
    {
        if (null != ft)
        {
            if (null == bjbFragment)
            {
                bjbFragment = new BajiebaoFragment();
            }

            if (bjbFragment.isAdded())
            {
                ft.show(bjbFragment);
            }
            else
            {
                ft.add(R.id.fl_home_content, bjbFragment);
            }
        }
    }
```
......
```	
private void changeFragment(int checkedId)
    {
        //Fragment事物对象
        FragmentManager fm = getSupportFragmentManager();
        FragmentTransaction ft = fm.beginTransaction();

        hideAllFragment(ft);

        /**
         * 每次Fragment切换时都需要实时修改标题内容
         */
        switch (checkedId)
        {
            case R.id.rb_bjb:
                changeToBjbFragment(ft);

                break;

            case R.id.rb_invest:
                changeToInvestFragment(ft);

                break;

            case R.id.rb_account_center:
                changeToWealthCenterFragment(ft);

                break;
        }
        ft.commit();
    }
```
### 技术总结
#### 1. FragmentTransaction add 和 replace 区别
[原文链接](http://www.binkery.com/archives/317.html)
> 在大部分情况下，这两个的表现基本相同。因为，一般，咱们会使用一个FrameLayout来当容器，而每个Fragment被add 或者 replace 到这个FrameLayout的时候，都是显示在最上层的。所以你看到的界面都是一样的。但是，使用add的情况下，这个FrameLayout其实有多层，多层肯定要比一层的来得浪费，所以还是推荐使用replace。当然有时候还是需要使用add的。比如要实现轮播图的效果，每个轮播图都是一个独立的Fragment，而他的容器FrameLayout需要add多个Fragment，这样他就可以根据提供的逻辑进行轮播了。
> 而至于返回键的时候，这个跟事务有关，跟使用add还是replace没有任何关系。
这个函数看起来没有什么问题,事实上运行起来也没有问题;但是由于我在某些Fragment中进行了登录判断,当我登录成功之后由于一些原因需要通过广播(我是这样处理的)调用HomeActivity中的这个方法,来显示HomeFragment;在这种情况下就会报错:
> Can not perform this action after onSaveInstanceState

#### 2. FragmentTransaction的commit和commitAllowingStateLoss的区别
1. 要解决这个问题首先我们来看一下什么是FragmentTransaction
使用Fragment时，可以通过用户交互来执行一些动作，比如增加、移除、替换等。所有这些改变构成一个集合，这个集合被叫做一个transaction。`可以调用FragmentTransaction中的方法来处理这个transaction`，并且可以将transaction存进由activity管理的back stack中，这样用户就可以进行fragment变化的回退操作。可以这样得到FragmentTransaction类的实例：

```
FragmentManager  mFragmentManager = getSupportFragmentManager();  
FragmentTransaction  mFragmentTransaction = mFragmentManager.beginTransaction();
```

2、commit()和commitAllowingStateLoss()的区别
- 用add(), remove(), replace()方法，把所有需要的变化加进去，然后调用commit()方法，将这些变化应用。
- 在commit()方法之前，你可以调用addToBackStack()，把这个transaction加入back stack中去，这个back stack是由activity管理的，当用户按返回键时，就会回到上一个fragment的状态。
- 你只能在activity存储它的状态（当用户要离开activity时）之前调用commit()，如果在存储状态之后调用commit()，将会抛出一个异常。
- 这是因为当activity再次被恢复时commit之后的状态将丢失。如果丢失也没关系，那么使用commitAllowingStateLoss()方法。

3、为什么在存储状态之后调用commit会报异常？
commit和executePendingTransactions这个两个方法区别就在传参判断后的处理方法checkStateLoss，那接下来，让我们查看一下checkStateLoss方法，看对参数进行判断后，做了什么样的处理。

```
private void checkStateLoss() {
        if (mStateSaved) {
            throw new IllegalStateException(
                    "Can not perform this action after onSaveInstanceState");
        }
        if (mNoTransactionsBecause != null) {
            throw new IllegalStateException(
                    "Can not perform this action inside of " + mNoTransactionsBecause);
        }
    }
```

当使用commit方法时，系统将进行状态判断，如果已经调用onSaveInstanceState方法状态（mStateSaved已经保存），将发生"Can not perform this action after onSaveInstanceState"错误。
如果mNoTransactionsBecause已经存在，将发生"Can not perform this action inside of " + mNoTransactionsBecause错误。

### 2. 使用RadioGroup + ViewPager + FragmentPagerAdapter制作Tab页
[源码下载](http://pan.baidu.com/s/1dD4UMv3)
xml文件

```
	<android.support.v4.view.ViewPager
        android:id="@+id/id_viewpager"
        android:layout_width="fill_parent"
        android:layout_height="0dp"
        android:layout_weight="1" >
    </android.support.v4.view.ViewPager>
```

```
	private ViewPager mViewPager;
	private FragmentPagerAdapter mAdapter;
	private List<Fragment> mFragments = new ArrayList<Fragment>();
	
	
	/**
	 * 底部四个按钮
	 */
	private LinearLayout mTabBtnWeixin;
	private LinearLayout mTabBtnFrd;
	private LinearLayout mTabBtnAddress;
	private LinearLayout mTabBtnSettings;


	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		mViewPager = (ViewPager) findViewById(R.id.id_viewpager);

		
		initView();
		
		

		mAdapter = new FragmentPagerAdapter(getSupportFragmentManager())
		{

			@Override
			public int getCount()
			{
				return mFragments.size();
			}

			@Override
			public Fragment getItem(int arg0)
			{
				return mFragments.get(arg0);
			}
		};
		
		mViewPager.setAdapter(mAdapter);
		
		
		mViewPager.setOnPageChangeListener(new OnPageChangeListener()
		{

			private int currentIndex;

			@Override
			public void onPageSelected(int position)
			{
				resetTabBtn();
				switch (position)
				{
				case 0:
					((ImageButton) mTabBtnWeixin.findViewById(R.id.btn_tab_bottom_weixin))
							.setImageResource(R.drawable.tab_weixin_pressed);
					break;
				case 1:
					((ImageButton) mTabBtnFrd.findViewById(R.id.btn_tab_bottom_friend))
							.setImageResource(R.drawable.tab_find_frd_pressed);
					break;
				case 2:
					((ImageButton) mTabBtnAddress.findViewById(R.id.btn_tab_bottom_contact))
							.setImageResource(R.drawable.tab_address_pressed);
					break;
				case 3:
					((ImageButton) mTabBtnSettings.findViewById(R.id.btn_tab_bottom_setting))
							.setImageResource(R.drawable.tab_settings_pressed);
					break;
				}

				currentIndex = position;
			}

			@Override
			public void onPageScrolled(int arg0, float arg1, int arg2)
			{

			}

			@Override
			public void onPageScrollStateChanged(int arg0)
			{
			}
		});

	}
	
	protected void resetTabBtn()
	{
		((ImageButton) mTabBtnWeixin.findViewById(R.id.btn_tab_bottom_weixin))
				.setImageResource(R.drawable.tab_weixin_normal);
		((ImageButton) mTabBtnFrd.findViewById(R.id.btn_tab_bottom_friend))
				.setImageResource(R.drawable.tab_find_frd_normal);
		((ImageButton) mTabBtnAddress.findViewById(R.id.btn_tab_bottom_contact))
				.setImageResource(R.drawable.tab_address_normal);
		((ImageButton) mTabBtnSettings.findViewById(R.id.btn_tab_bottom_setting))
				.setImageResource(R.drawable.tab_settings_normal);
	}

	private void initView()
	{

		mTabBtnWeixin = (LinearLayout) findViewById(R.id.id_tab_bottom_weixin);
		mTabBtnFrd = (LinearLayout) findViewById(R.id.id_tab_bottom_friend);
		mTabBtnAddress = (LinearLayout) findViewById(R.id.id_tab_bottom_contact);
		mTabBtnSettings = (LinearLayout) findViewById(R.id.id_tab_bottom_setting);

		MainTab01 tab01 = new MainTab01();
		MainTab02 tab02 = new MainTab02();
		MainTab03 tab03 = new MainTab03();
		MainTab04 tab04 = new MainTab04();
		mFragments.add(tab01);
		mFragments.add(tab02);
		mFragments.add(tab03);
		mFragments.add(tab04);
	}
```

### 3. 使用Tabhost制作Tab页
> 由于TabHost已经过时这里仅附上链接就不再做讲解了[TabHost使用详解 ](http://blog.csdn.net/harvic880925/article/details/17120325)
### 4. 使用FragmentTabhost代替Tabhost制作tab页
[源码下载](http://pan.baidu.com/s/1dDpvI85)
1. 编写home_tab_activity.xml文件

```
	<FrameLayout
            android:id="@+id/fl_main"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1">

    </FrameLayout>

    <android.support.v4.app.FragmentTabHost
        android:id="@+id/th_main"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="@drawable/maintab_toolbar_bg">

    </android.support.v4.app.FragmentTabHost>
```
> 在xml文件中FragmentLayout作为Fragment的容器, FragmentTabHost用于保存相应Fragment的标签

2. 编写标签的显示内容的布局xml文件,一般都是一个图片一个文字

```
	<ImageView
            android:id="@+id/imageview"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:focusable="false"
            android:padding="3dp"
            android:src="@drawable/selector_main_home">
    </ImageView>

    <TextView
            android:id="@+id/textview"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="首页"
            android:textSize="10sp"
            android:textColor="#ffffff">
    </TextView>
```

2. 编写完成xml文件之后编写HomeTabActivity中的代码

```
public class HomeTabActivity extends FragmentActivity
{
    //定义FragmentTabHost对象
    private FragmentTabHost tabHost;
    //定义数组存放标题名称
    private int[] titles_str = {R.string.home, R.string.product, R.string.detail, R.string.more};
    //定义数组存放标题图片
    private int[] tities_icon = {R.drawable.selector_main_home, R.drawable.selector_main_product, R.drawable.selector_main_detail, R.drawable.selector_main_more};
    //定义数组存放Fragment引用
    private Class[] frags = {Fragment_Home.class, Fragment_product.class, Fragment_detail.class, Fragment_more.class};

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_tab);

        init();
    }

    /**
     * 初始化
     */
    public void init()
    {
        //实例化FragmentTabHost得到tabHost
        tabHost = (FragmentTabHost) findViewById(R.id.th_main);
        //得到tabHost后得初始化
        tabHost.setup(this, getSupportFragmentManager(), R.id.fl_main);

        addTabHost();
    }

    /**
     * 添加tab页
     */
    private void addTabHost()
    {
        if (null == tabHost)
        {
            return;
        }

        //获取Fragment类的个数
        int length = frags.length;
        for (int i = 0; i < length; i++)
        {
            TabSpec tabSpec = tabHost.newTabSpec(getString(titles_str[i])).setIndicator(getTabItemView(i));
            //添加tab页
            tabHost.addTab(tabSpec, frags[i], null);
            //设置Tab按钮背景
            tabHost.getTabWidget().getChildAt(i).setBackgroundResource(R.drawable.selector_background_tab);

        }
    }

    /**
     * 给tab按钮设置文字和图标
     */
    public View getTabItemView(int i)
    {
        //初始化布局
        View view = View.inflate(this, R.layout.tab_item_activity, null);
        ImageView iv = (ImageView) view.findViewById(R.id.imageview);
        TextView tv = (TextView) view.findViewById(R.id.textview);

        tv.setText(titles_str[i]);
        iv.setImageResource(tities_icon[i]);
        return view;
    }
}
```
1. 使用FragmentTabHost首先应该进行初始化,初始化会调用setup()方法;此方法需要三个参数,第一个不用多说Context(上下文)直接传this就好;第二个FragmentManager,由于我们使用的是V4包下的Fragment所以这里获取FragmentManager使用getSupportFragmentManager();第三个参数为我们在xml文件中定义的FragmentLayout容器的ID.
2. 然后我们需要确定要添加到FragmentTabHost的标签个数,通常由我们所定义在HomeTab页进行切换的Fragment类的个数来定;
3. 调用FragmentTabHost.addTab();方法来添加tab页和标签并使两者产生关联关系;addTab()方法也需要传入三个 参数:第一个参数是一个标签TabSpec,TabSpec是TabHost的内部类可以通过通过FragmentTabHost的newTabSpec();方法获得TabSpec的类对象,newTabSpec()方法传入一个参数用于作为此标签的指示;TabSpec调用setIndicator()方法传入一个View作为标签的内容显示;第二个参数就是此标签相对应的Fragment的引用;第三个参数不知道;
4. 通过FragmentTabHost.getTabWidget().getChildAt(i).setBackgroundResource()设置标签的点击效果;

### 5. PagerSlidingTabStrip框架实现替代ActionBar Tab的功能制作tab页
> 注意: 刷新ViewPager的同时要刷新tab
[原文链接](http://blog.csdn.net/guolin_blog/article/details/26365683)
[源码下载](http://pan.baidu.com/s/1gdyLgGz)
1. 把PagerSlidingTabStrip库文件导入到本地,或者添加一段代码到builde.gradle

```
dependencies {
    compile 'com.astuetz:pagerslidingtabstrip:1.0.1'
}
```

2. 在xml文件中添加PagerSlidingTabStrip控件和Viewpager控件
> PagerSlidingTabStrip控件通常放到顶部,如果放到底部的话功能实现会出现问题,具体原因以及解决办法待查看;

```
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"  
    xmlns:tools="http://schemas.android.com/tools"  
    android:layout_width="match_parent"  
    android:layout_height="match_parent" >  
  
    <com.astuetz.PagerSlidingTabStrip  
        android:id="@+id/tabs"  
        android:layout_width="match_parent"  
        android:layout_height="40dp" />  
  
    <android.support.v4.view.ViewPager  
        android:id="@+id/pager"  
        android:layout_width="match_parent"  
        android:layout_height="wrap_content"  
        android:layout_below="@+id/tabs" />  
  
</RelativeLayout>  
```
3. 在onCreate()方法(在Fragment中的onCreateView())中,把PagerSlidingTabStrip控件和Viewpager控件进行绑定

```
// Initialize the ViewPager and set an adapter
ViewPager pager = (ViewPager) findViewById(R.id.pager);
pager.setAdapter(new TestAdapter(getSupportFragmentManager()));

// Bind the tabs to the ViewPager
PagerSlidingTabStrip tabs = (PagerSlidingTabStrip) findViewById(R.id.tabs);
tabs.setViewPager(pager);
```
4. 对PagerSlidingTabStrip的各项属性进行配置.

```
		// 设置Tab是自动填充满屏幕的
		tabs.setShouldExpand(true);
		// 设置Tab的分割线是透明的
		tabs.setDividerColor(Color.TRANSPARENT);
		// 设置Tab底部线的高度
		tabs.setUnderlineHeight((int) TypedValue.applyDimension(
				TypedValue.COMPLEX_UNIT_DIP, 1, dm));
		// 设置Tab Indicator的高度
		tabs.setIndicatorHeight((int) TypedValue.applyDimension(
				TypedValue.COMPLEX_UNIT_DIP, 4, dm));
		// 设置Tab标题文字的大小
		tabs.setTextSize((int) TypedValue.applyDimension(
				TypedValue.COMPLEX_UNIT_SP, 16, dm));
		// 设置Tab Indicator的颜色
		tabs.setIndicatorColor(Color.parseColor("#45c01a"));
		// 设置选中Tab文字的颜色 (这是我自定义的一个方法)
		tabs.setSelectedTextColor(Color.parseColor("#45c01a"));
		// 取消点击Tab时的背景色
		tabs.setTabBackground(0);
```

5. 编写PagerAdapter

```
	public class MyPagerAdapter extends FragmentPagerAdapter {

		public MyPagerAdapter(FragmentManager fm) {
			super(fm);
		}

		private final String[] titles = { "聊天", "发现", "通讯录" };

		@Override
		public CharSequence getPageTitle(int position) {
			return titles[position];
		}

		@Override
		public int getCount() {
			return titles.length;
		}

		@Override
		public Fragment getItem(int position) {
			switch (position) {
			case 0:
				if (chatFragment == null) {
					chatFragment = new ChatFragment();
				}
				return chatFragment;
			case 1:
				if (foundFragment == null) {
					foundFragment = new FoundFragment();
				}
				return foundFragment;
			case 2:
				if (contactsFragment == null) {
					contactsFragment = new ContactsFragment();
				}
				return contactsFragment;
			default:
				return null;
			}
		}

	}
```
