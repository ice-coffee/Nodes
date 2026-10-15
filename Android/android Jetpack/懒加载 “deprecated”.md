[Fragment新功能，setMaxLifecycle了解一下](https://juejin.im/post/5cdb7c15f265da036c57ac66)

在androidx中使用setUserVisibleHint时提示==deprecated==已过期。

使用FragmentTransaction.setMaxLifecycle()替换。

在androidx中使用ViewPager + Fragment时应修改如下：

```
public class HomePageAdapter extends FragmentPagerAdapter {

    public HomePageAdapter(@NonNull FragmentManager fm, int behavior) {
        super(fm, behavior);
    }

    @NonNull
    @Override
    public Fragment getItem(int position) {
        switch (position) {
            case 0:
                return new OneFragment();
            case 1:
                return new TwoFragment();
            case 2:
                return new ThreeFragment();
        }
        return null;
    }

    @Override
    public int getCount() {
        return 3;
    }
}
```


```
HomePageAdapter pageAdapter = new HomePageAdapter(getSupportFragmentManager(), FragmentPagerAdapter.BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
vp.setAdapter(pageAdapter);
```

按如上设置了==FragmentPagerAdapter.behavior==后ViewPager中的Fragment中onResume、onPause会被正常调用。
