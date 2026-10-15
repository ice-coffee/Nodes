### DrawerLayout的使用
[toc]

@(android 控件药店)

> DrawerLayout是v4包中提供的控件,所以想要使用它就必须在项目中导入v4包,它所提供的功能是侧滑抽屉效果

#### 1. 使用方法

    <android.support.v4.widget.DrawerLayout
        android:id="@+id/home_drawer"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1">

        <com.github.obsessive.library.widgets.XViewPager
            android:id="@+id/home_container"
            android:layout_width="match_parent"
            android:layout_height="match_parent"/>

        <LinearLayout
            android:layout_width="@dimen/home_menu_width"
            android:layout_height="match_parent"
            android:layout_gravity="left">

            <ImageView
                android:id="@+id/home_navigation_top_image"
                android:layout_width="match_parent"
                android:layout_height="220dp"
                android:layout_alignParentTop="true"
                android:src="@drawable/banner"/>

            <ListView
                android:id="@+id/home_navigation_list"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:background="@android:color/white"
                android:cacheColorHint="@android:color/transparent"
                android:divider="@null"
                android:dividerHeight="0dp"
                android:overScrollMode="never"
                android:scrollbars="none"/>
        </LinearLayout>

    </android.support.v4.widget.DrawerLayout>

根据以上xml布局, 将需要实现抽屉效果的布局放到DrawerLayout标签内, 通过`android:layout_gravity`属性设置左滑(`start/left`)和右滑(`end/right`)

#### 2. Toolbar和DrawerLayout组合使用,实现炫酷效果

> xml代码

    <include
        android:id="@+id/common_toolbar"
        layout="@layout/common_toolbar"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"/>

    <android.support.v4.widget.DrawerLayout
        android:id="@+id/home_drawer"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1">

		<!--此处代码与上方代码一致-->

	</android.support.v4.widget.DrawerLayout>

> java代码


    ActionBarDrawerToggle mActionBarDrawerToggle = new ActionBarDrawerToggle(this, mDrawerLayout, mToolbar, R.string.drawer_open, R.string.drawer_close) {

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                setTitle("###");
            }

            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
                setTitle("$$$");
            }
        };

	Toolbar mToolbar = (Toolbar) findById(R.id.common_toolbar);
	//使用Toolbar替代原有的ActionBar
	setSupportActionBar(mToolbar);
	//左上角的图标是否可以点击,true 图标可以点击  false 不可以点击
    getSupportActionBar().setHomeButtonEnabled(true);
    //给左上角图标的左边加上一个返回的图标
    getSupportActionBar().setDisplayHomeAsUpEnabled(true);
    //同步Toolbar左上角图标和抽屉的状态
    mActionBarDrawerToggle.syncState();
    //设置是否启用抽屉图标
    mActionBarDrawerToggle.setDrawerIndicatorEnabled(true);
    //抽屉状态监听
    mDrawerLayout.setDrawerListener(mActionBarDrawerToggle);

> 这里有几个需要注意的地方:
	1. 调用setSupportActionBar(mToolbar);必须是在NoActionBar的格式或者ActionBar隐藏的格式下, 不然会报ActionBar重复错误.
	2. syncState();方法不调用的话返回的箭头图标没有炫酷动画
	3. 如果app的style设置`android:windowBackground`属性的值为white那么Toolbar的标题部分会变成一个白色的长条,因为它的背景色被设置成了white

#### 3. 使用DrawerLayout实现如QQ般滑动效果
> 根据鸿祥大神的博客, 实现QQ侧滑效果需要nineoldandroids的支持,链接如下
[QQ侧滑](http://blog.csdn.net/lmj623565791/article/details/41531475)
