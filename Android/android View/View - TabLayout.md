[toc]
### 简介

`TabLayout` 是由 `material design` 包提供的页面切换指示器。

`TabLayout` 可以通过创建 `TabLayout.Tab` 实例添加选项卡。示例如下：
```
TabLayout tabLayout = ...;
tabLayout.addTab(tabLayout.newTab().setText("Tab 1"));
tabLayout.addTab(tabLayout.newTab().setText("Tab 2"));
tabLayout.addTab(tabLayout.newTab().setText("Tab 3"));
```
`TabLayout.Tab` 实例可以分别通过 `setText`和 `setIcon` 更改选项卡的标签或图标。

### TabLayout + ViewPager
如果 `ViewPager` 和 `TabLayout` 合用，可以通过 `setupWithViewPager(ViewPager)` 关联两者，此时 `TabLayout` 将使用 `Pager Title` 填充选项卡。`ViewPager + TabLayout` 示例如下：

```
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">

    <com.google.android.material.tabs.TabLayout
        android:id="@+id/tabLayout"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="20dp"/>

    <androidx.viewpager.widget.ViewPager
        android:id="@+id/viewpager"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

</LinearLayout>
```

```
class MyFragmentPagerAdapter(private val context: Context, fragmentManager: FragmentManager, private val pagerFragments: List<Fragment>): FragmentPagerAdapter(fragmentManager, FragmentPagerAdapter.BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT) {
    override fun getItem(position: Int): Fragment {
        return pagerFragments[position]
    }

    override fun getCount(): Int {
        return pagerFragments.size
    }

    override fun getPageTitle(position: Int): CharSequence? {
        return String.format(context.resources.getString(R.string.appbar_sample_format), position)
    }
}
```

```
viewPager.adapter = MyFragmentPagerAdapter(this, supportFragmentManager, pagerFragmengs)
tabLayout.setupWithViewPager(viewPager)
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/tablayout.gif)

### 事件监听
`TabLayout` 添加 `OnTabSelectedListener` 监听选项卡事件，`OnTabSelectedListener` 详情如下：
```
/**
 * 选项卡被选中时回调
 */
public void onTabSelected(T tab);

/**
 * 选项卡取消选中回调
 */
public void onTabUnselected(T tab);

/**
 * 当已被选中的选项卡再次选中时回调
 */
public void onTabReselected(T tab);
```

### TabLayout xml 属性

| 属性 | 简介 | 值 |
| --- | --- | --- |
| tabIndicatorColor | 指示器颜色 | color |
| tabIndicatorHeight | 指示器高度 | dp\sp |
| tabIndicatorFullWidth | 指示器宽度是否为选项卡宽度 | boolean |
| tabBackground | 选项卡背景 | color\drawable |
| tabMode | 选项卡在布局中的行为模式 | `scrollable` 可滑动; `fixed` 占满屏幕宽度; `auto` 自适应 |
| tabInlineLabel | 文字和Icon 是否在水平线上 | boolean |
| tabMinWidth | 选项卡最小宽度 | dp\sp |
| tabMaxWidth | 最大宽度 | dp\sp |
| tabTextAppearance | 文字样式 | style |
| tabTextColor | 文字颜色 | color |
| tabSelectedTextColor | 文字选中颜色 | color |
| tabIconTint | Icon 颜色混合 | color |
| tabIconTintMode | 颜色混合模式 |  |
| tabRippleColor | 点按水波纹效果颜色 | color |
| tabUnboundedRipple | 是否使用无边界水波纹效果 | boolean |

### 自定义 Tab
`TabLayout` 是由 `Tab` 组成的，可以通过 `getTabAt` 方法获取指定的 `Tab`，通过 `setIcon` 和 `setText` 修改图标和文字。也可以使用自定义的布局替代 `Tab`  布局，使用 `setCustomView` 方法修改 `Tab` 的布局。

自定义 `TabLayout` 布局示例如下：

```
val view = LayoutInflater.from(this).inflate(R.layout.item_tab_layout, null)
val ivTabIcon = view.findViewById<ImageView>(R.id.ivTabIcon)
val tvTabContent = view.findViewById<TextView>(R.id.tvTabContent)
ivTabIcon.setImageResource(tabIcons[i])
tvTabContent.text = pageTitles[i]
tabLayout.getTabAt(i)?.customView = view
```

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/tablayout_custom.gif)
