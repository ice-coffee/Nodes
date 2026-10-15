[toc]
[AndroidX Fragment 核心原理分析](https://juejin.cn/post/6970998913754988552#heading-14)

### 是什么
Fragment （碎片）是 Android 中的行为或用户界面部分。

### 为什么
在 Android 中引入 Fragment 主要是为了给大屏幕 (如平板电脑) 上更加动态和灵活的UI设计提供支持。使用Fragment可以在app适配平板时无需大范围的更改布局。下图是google提供的一个示例图：
![enter image description here](https://developer.android.com/images/fundamentals/fragments.png)
如上两幅图中可以看出, 通过使用两个 Fragment 进行不同的排列组合可以很好的适配平板和手机两种不同布局风格, 而减少大量的布局开发作业.

### 时间点
Android 在 Android 3.0（API 级别 11）中引入了片段,  如果使用v4包可以兼容到 Android 1.6;
> 如果使用 V4 包的话需要注意一些地方:
> 1. 果你使用了v4包下的 Fragment , 那么所在的那个Activity就要继承`FragmentActivity`.
> 2. 如果要使用FragmentManager必须使用`getSupportFragmentManager()`;

### 怎么用

#### 1. 生命周期
![enter image description here](https://developer.android.com/images/fragment_lifecycle.png)

管理 Fragment 的生命周期与管理 Activity 的生命周期非常相似，片段也以三种状态存在：

```
1. 继续
片段在运行中的 Activity 中可见。

2. 暂停
另一个 Activity 位于前台并具有焦点，但此片段所在的 Activity 仍然可见（前台 Activity 部分透明，或未覆盖整个屏幕）。

3. 停止
片段不可见。宿主 Activity 已停止，或片段已从 Activity 中移除，但已添加到返回栈。 停止片段仍然处于活动状态（系统会保留所有状态和成员信息）。 不过，它对用户不再可见，如果 Activity 被终止，它也会被终止。
```

Fragment 与 Activity 的生命周期最显著的区别是它们各自返回栈中的存储方式, 和 Activity 停止时自动放入由系统管理的 Activity 	返回栈不同, Fragment 仅在被移除的事务执行期间调用`addToBackStack()`显示请求保存实例时, 系统才会将 Fragment 放入由宿主 Activity 管理的返回栈.

Fragment 与 Activity 的生命周期具有协调一致性, 这体现在 Activity 的每次生命周期回调都会引发每个片段的类似回调. 例如, 当 Activity 收到 onPause() 时, Activity 中的每个片段也会收到 onPause(). Fragment中还有一些额外的方法: 

```
onAttach()
在片段已与 Activity 关联时调用（Activity 传递到此方法内）。

onCreateView()
调用它可创建与片段关联的视图层次结构。

onActivityCreated()
在 Activity 的 onCreate() 方法已返回时调用。

onDestroyView()
在移除与片段关联的视图层次结构时调用。

onDetach()
在取消片段与 Activity 的关联时调用。
```

使用 `<fragment>` 标签引入 Fragment  的 Activity 的创建到销毁, 生命周期方法调用的顺序:

```
 -Fragment: onCreate
 -Fragment: onCreateView 
 -Fragment: onViewCreated
 -Activity: onCreate
 -Fragment: onActivityCreated
 -Activity: onStart
 -Fragment: onStart
 -Activity: onResume
 -Fragment: onResume
 -Fragment: onPause
 -Activity: onPause
 -Fragment: onStop
 -Activity: onStop
 -Fragment: onDestroyView
 -Fragment: onDestroy
 -Fragment: onDetach
 -Activity: onDestroy
```

#### 2. 管理 Fragment
要想管理 Activity 中的 Fragment, 需要使用 FragmentManager. 可以从 Activity 中调用 getFragmentManager() 获取.

可以使用 FragmentManager 执行的操作包括：

- 通过 findFragmentById()（对于在 Activity 布局中提供 UI 的片段）或 findFragmentByTag()（对于提供或不提供 UI 的片段）获取 Activity 中存在的片段。
- 通过 popBackStack()（模拟用户发出的返回命令）将片段从返回栈中弹出。
- 通过 addOnBackStackChangedListener() 注册一个侦听返回栈变化的侦听器。

> 注意: 在 Fragment 的嵌套情况下在父 Fragment 中使用 getFragmentManager() / getSupportFragmentManager() 获取 FragmentManager; 在子 Fragment 中需要使用getChildFragmentManager 来获取. 

#### 3. Fragment的简单使用
> - 使用< fragment >标签在布局中添加碎片
> - 通过 android:name 属性来显式指明要添加的碎片类名，注意一定要将类的包名也加上。

```
<fragment
            android:id = "@+id/left_fragment"
            android:name = "com.example.FragmentTest.fragment.HomeFragment"
            android:layout_width = "1dp"
            android:layout_height = "match_parent"
            android:layout_weight = "1"
            tools:layout = "@layout/left_fragment"/>
```
> 注：每个片段都需要一个唯一的标识符，重启 Activity 时，系统可以使用该标识符来恢复片段（您也可以使用该标识符来捕获片段以执行某些事务，如将其移除）。 可以通过三种方式为片段提供 ID：
> - 为 android:id 属性提供唯一 ID。
> - 为 android:tag 属性提供唯一字符串。
> - 如果您未给以上两个属性提供值，系统会使用容器视图的 ID。

#### 4. 动态添加Fragment
> 碎片真正的强大之处在于，它可以在程序运行时动态地添加到活动当中

1. 创建待添加的碎片实例。
2. 获取到 FragmentManager，在活动中可以直接调用 getFragmentManager()方法得到。
3. 开启一个事务，通过调用 beginTransaction()方法开启。
4. 向容器内加入碎片，可以使用 replace() 或 add() 方法实现，需要传入容器的 id 和待添加的碎
片实例。
5. 提交事务，调用 commit()方法来完成。

```
<LinearLayout
    android:id="@+id/fg_main"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical" />
```

```
FragmentTransaction ft = getFragmentManager().beginTransaction();
ft.add(R.id.fg_main, new MainFragment());
ft.addToBackStack(null);
ft.commit();
```

> 注意：
> 1. 调用 commit() 不会立即执行事务，而是在 Activity 的 UI 线程（“主”线程）可以执行该操作时再安排其在线程上运行。不过，如有必要，您也可以从 UI 线程调用 executePendingTransactions() 以立即执行 commit() 提交的事务。通常不必这样做，除非其他线程中的作业依赖该事务。
> 2. 您只能在 Activity 保存其状态（用户离开 Activity）之前使用 commit() 提交事务。如果您试图在该时间点后提交，则会引发异常。 这是因为如需恢复 Activity，则提交后的状态可能会丢失。 对于丢失提交无关紧要的情况，请使用 commitAllowingStateLoss()。

#### 5. Fragment 和 Activity 之间进行通讯
1. 在 Activity 中获取相应 Fragment 的实例, 可以通过 FragmentManager 使用 findFragmentById() 或 findFragmentByTag().

```
RightFragment rightFragment = (RightFragment) getFragmentManager().findFragmentById(R.id.right_fragment);
```

2. 得到当前碎片相关联的活动实例

```
MainActivity activity = (MainActivity) getActivity();
```

3. 两个 Fragment 之间如何传递信息
我认为这个其实蛮简单的, 就是通过 FragmentManager 开启一个事务来实现, 在使用 add() / replace() 切换Fragment时通过目标Fragment的实例进行传递数据等各种操作; 关键是如何把`事务`抽取出来作为公共的方法.(个人意见, 可能)

4. 在 Fragment 中也可以使用 `startActivity()` 和 `startActivityForResult()`来启动Activity并进行交互操作.

- Fragment中启动，Activity中接收结果：使用getActivity().startActivityForResult()
- Fragment中启动，Fragment中接收结果：使用startActivityForResult()，且在Activity的onActivityResult()中调用super.onActivityResult()

#### `commit vs commitNow`
`commit`：通过发送 `Handler` 消息在主线程执行事务。
`commitNow`：立即执行事务；会检查当前线程是否是主线程，在其他线程会报错。

#### `commit vs commitAllowStateLose`
`commit`：当前宿主处于非活动状态时报错。 
`commitAllowStateLose`：不会报错，依旧会发送 `Handler` 消息，但在执行事务时会判断当前状态是否满足事务执行条件，不满足则不执行。

如果 `commitAllowStateLose` 提交事务前宿主活动停止，但执行事务时宿主状态正好更新符合执行事务的条件，那么 `commitAllowStateLose` 提交的事务将正常执行。

#### Fragment 是如何存储以及恢复的
[Fragment 是如何被存储与恢复的](https://www.wanandroid.com/wenda/show/12574)

#### Fragment 本质
[你真的懂 Fragment 吗？—— AndroidX Fragment 核心原理分析](https://juejin.cn/post/6970998913754988552#heading-26)

### 遇到的坑
> 对于Fragment中的各种坑推荐大神的[Fragment全解析系列](http://www.jianshu.com/p/d9143a92ad94), 以及大神所写的[Fragmentation库](https://github.com/YoKeyword/Fragmentation), 以下就只写一些我自己遇到的问题了.

#### 1. getActivity() return null
原因:
> 大部分原因是由于在 Fragment 与 Activity 断开关系 (onDetach() 被调用) 后使用 getActivity() (e.g. 异步网络访问中onDetach() 被调用, 获取访问结果后调用 getActivity() 操作布局)

解决:
> 1. 最好的办法就是我们应该避免在已经onDetach这种情况之后再去调用宿主Activity对象，比如取消这些异步任务; 
> 2. 还可以在Fragment基类里设置一个Activity mActivity的全局变量，在onAttach(Activity activity)里赋值，使用mActivity代替getActivity()，保证Fragment即使在onDetach后，仍持有Activity的引用（有引起内存泄露的风险，但是异步任务没停止的情况下，本身就可能已内存泄漏，相比Crash，这种做法“安全”些），即：

```
protected Activity mActivity;
Override
public void onAttach(Activity activity) 
{
    super.onAttach(activity);
    this.mActivity = activity;
}

/**
*  如果你用了support 23的库，上面的方法会提示过时，有强迫症的小伙伴，可以用下面的方法代替
*/
Override
public void onAttach(Context context) 
{
    super.onAttach(context);
    this.mActivity = (Activity)context;
}
```

#### 2. 异常：Can not perform this action after onSaveInstanceState
原因：
> 在你离开当前Activity等情况下，系统会调用onSaveInstanceState()帮你保存当前Activity的状态、数据等，直到再回到该Activity之前（onResume()之前），你使用commit()提交了Fragment事务，就会抛出该异常！

解决：
1. （不推荐）该事务使用`commitAllowingStateLoss()`方法提交, 但是有可能导致该次提交无效！（在此次离开时恰巧Activity被强杀时）
2. （推荐）在重新回到该Activity的时候（onResumeFragments()或onPostResume()）, 再执行该事务！

#### 3. 在fragment中onActivityResult 设置requestCode 返回的code不对
Fragment跳转到Activity，需要在startActivityForResult前面加上getActivity()。

#### 4. not attached to a context.

```
java.lang.IllegalStateException

Fragment VideoRecordFragment{3d49313} not attached to a context.

```

在getResources()时需要Context，而这时Fragment可能与Activity不在绑定状态，所以在Fragment处理异步操作时，一定要记着加判断：isAdded()。确保不会出问题。

```
if (isAdded()) {
    tvRecordSecond.setText(getString(R.string.v_record_second));
}
```


### 扩展
#### 1. 数据传递
对Fragment传递数据，建议使用`setArguments(Bundle args)`，而后在onCreate中使用`getArguments()`取出，在 “内存重启”前，系统会帮你保存数据，不会造成数据的丢失。和Activity的Intent恢复机制类似。

#### 2. 创建 Fragment 对象
使用`newInstance(参数) `创建Fragment对象，优点是调用者只需要关系传递的哪些数据，而无需关心传递数据的Key是什么。
```
public static class TestFragment extends Fragment 
{

  private static final String ARG = "arg";
             
  public static Fragment newInstance(String arg)
  {
        TestFragment fragment = new TestFragment();
        Bundle bundle = new Bundle();
        bundle.putString( ARG, arg);
        fragment.setArguments(bundle);
        return fragment;
  }
             
  @Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) 
  {
        View rootView = inflater.inflate(R.layout. fragment_main, container, false);
        TextView tv = (TextView) rootView.findViewById(R.id. tv);
        tv.setText(getArguments().getString( ARG));
        return rootView;
  }

}
```

#### 3. add() 和 replace()
1. add() 和 replace() 的区别
- show()，hide()最终是让Fragment的View setVisibility(true还是false)，不会调用生命周期；
- replace()的话会销毁视图，即调用onDestoryView、onCreateView等一系列生命周期；

2. 使用推荐
如果你有一个很高的概率会再次使用当前的Fragment，建议使用show()，hide()，可以提高性能。

在我使用Fragment过程中，大部分情况下都是用show()，hide()，而不是replace()。

3. onHiddenChanged()
当使用add() +  show()，hide()跳转新的Fragment时，旧的Fragment回调`onHiddenChanged()`，不会回调onStop()等生命周期方法，而新的Fragment在创建时是不会回调onHiddenChanged()，这点要切记。

> 注意：如果你的app有大量图片，这时更好的方式可能是replace，配合你的图片框架在Fragment视图销毁时，回收其图片所占的内存。

#### 懒加载新方案
使用 `ViewPager + Fragment` 时重写 `setUserVisiableHint` 的方案在 `Androidx` 中已经过时，`FragmentPagerAdapter` 内通过 `setMaxLifecycle` 使得 `ViewPager` 中的 `Fragment` 的 `onResume、onPause` 方法可以被正常回调。

#### 4. 使用 ViewPager + Fragment

##### 1. 懒加载（过时）
[原文链接](http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2014/1021/1813.html)
- 为什么我们要做懒加载呢?
> 我们在做应用开发的时候，一个Activity里面可能会以viewpager（或其他容器）与多个Fragment来组合使用，而如果每个fragment都需要去加载数据，或从本地加载，或从网络加载，那么在这个activity刚创建的时候就变成需要初始化大量资源。这样的结果，我们当然不会满意。那么，能不能做到当切换到这个fragment的时候，它才去初始化(不同于View的初始化,这里指的是数据的加载)呢？

- 答案就在Fragment里的setUserVisibleHint这个方法里具体可查看[android API](http://androiddoc.qiniudn.com/reference/packages.html)
> 该方法用于告诉系统，这个Fragment的UI是否是可见的。所以我们只需要继承Fragment并重写该方法，即可实现在fragment可见时才进行数据加载操作，即Fragment的懒加载。 

- 为什么不使用ViewPager的预加载功能呢
现在大体上放置ViewPager预加载的方法有两种:

1. 在使用ViewPager嵌套Fragment的时候，由于VIewPager的几个Adapter的设置来说，都会有一定的预加载(默认是左右各一个Frament)。通过设置`setOffscreenPageLimit`（int number) 来设置预加载的页面数量，在V4包中，默认的预加载是1，即使你设置为0，也是不起作用的，设置的只能是大于1才会有效果的。我们需要通过更改V4包中的默认属性才可以。

2. 限制预加载，会出现滑动过程中卡顿现象。其实Fragment中防止预加载主要是防止数据的预加载，Fragment中的VIew预加载是有好处的，我们可以通过Fragment中的一个方法来达到预加载View 但是不加载数据，在Fragment显示的时候才去加载数据。

```
public abstract class AbstractBaseFragment extends Fragment
{

    /**
     * toast类型. true:默认, false:自定义
     */
    protected final boolean isToastDefault = true;

    protected Context mContext;
    private View mRootview;
    private LoadingDialog loadingDialog;
    private VaryViewHelperController mVaryViewHelperController;

    private boolean isPageResume;
    private boolean isFirstVisible = true;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        this.mContext = context;
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        /**
         * 加载布局
         * viewpager和fragment一起使用, fragment切换时, fragment的生命周期会在 onCreateView --> onDestroyView 之间调用
         * 这样会造成布局重绘, 无法保持Fagment原有的状态, 所以需要如下操作
         */
        if (null == mRootview)
        {
            mRootview = inflater.inflate(getContentViewLayoutId(), container, false);
        }
        ViewGroup mViewGroup = (ViewGroup) mRootview.getParent();
        if (mViewGroup != null)
        {
            mViewGroup.removeView(mRootview);
        }

        //初始化操作
        initViews(mRootview);

        return mRootview;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState)
    {
        super.onViewCreated(view, savedInstanceState);

        if (null != getLoadingTargetView())
        {
            mVaryViewHelperController = new VaryViewHelperController(getLoadingTargetView());
        }
    }

    @Override
    public void onResume() {
        if (!isPageResume && !isHidden() && getUserVisibleHint()) {
            onPageResume();
        }
        super.onResume();
    }

    @Override
    public void onPause() {
        if (isPageResume) {
            onPagePause();
        }
        super.onPause();
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        if (hidden) {
            if (isPageResume && getUserVisibleHint()) {
                onPagePause();
            }
        } else {
            if (!isPageResume && getUserVisibleHint()) {
                onPageResume();
            }
        }
        super.onHiddenChanged(hidden);
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        if (isVisibleToUser) {
            if (!isPageResume && !isHidden()) {
                onPageResume();
            }
        } else {
            if (isPageResume && !isHidden()) {
                onPagePause();
            }
        }

        super.setUserVisibleHint(isVisibleToUser);
    }

    private void onPageResume() {
        isPageResume = true;
        if (isFirstVisible) {
            onFirstUserVisible();
            isFirstVisible = false;
        } else {
            onUserVisible();
        }
    }

    private void onPagePause() {
        isPageResume = false;
        onUserInvisible();
    }

    /**
     * bind layout resource file
     *
     * @return id of layout resource
     */
    protected abstract int getContentViewLayoutId();

    protected abstract void initViews(View rootview);

    protected abstract void initData();

    /**
     * this method like the fragment's lifecycle method first onResume()
     */
    protected void onFirstUserVisible(){

        initData();
    }

    /**
     * this method like the fragment's lifecycle method onResume()
     */
    protected void onUserVisible(){

    }

    /**
     * this method like the fragment's lifecycle method onPause()
     */
    protected void onUserInvisible(){

    }
}
```
> 注意: 在使用viewpager + fragment时由于默认的预加载数为1, 所以如果需要在viewpager中展示的页面过多的话, 那就不免会出现fragment被销毁后重新加载的问题, 这时候需要通过`setOffscreenPageLimit`修改viewpager的预加载页面. 这样就能保证fragment不会再viewpager的切换中销毁了.

##### 2. setUserVisibleHint 调用时机
对于单个 Fragment，setUserVisibleHint 是不会被调用的，只有该 Fragment 在 ViewPager 里才会被调用。

滑动到指定Fragment前一个Fragment的Log日志如下:
```
E/NearByFragment: setUserVisibleHint..............false
E/NearByFragment: onCreateView
E/NearByFragment: onViewCreated
E/NearByFragment: onActivityCreated
E/NearByFragment: onStart
E/NearByFragment: onResume
```
滑动到指定Fragment的Log日志如下:
```
E/NearByFragment: setUserVisibleHint..............true
```
滑出指定Fragment的Log日志如下:
```
E/NearByFragment: setUserVisibleHint..............false
E/NearByFragment: onPause
E/NearByFragment: onStop
E/NearByFragment: onDestroyView
```

##### 3. Fragment布局重复加载
viewpager和fragment一起使用, fragment切换时, fragment的生命周期会在 onCreateView --> onDestroyView 之间调用这样会造成布局重绘, 无法保持Fagment原有的状态, 所以需要如下操作

```
Override
public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
{
    /**
     * 加载布局
     * viewpager和fragment一起使用, fragment切换时, fragment的生命周期会在 onCreateView --> onDestroyView 之间调用
     * 这样会造成布局重绘, 无法保持Fagment原有的状态, 所以需要如下操作
     */
    if (null == mRootview)
    {
        mRootview = inflater.inflate(getLayoutID(), container, false);
        ButterKnife.bind(this, mRootview);
    }
    /*缓存的rootView需要判断是否已经被加过parent， 如果有parent需要从parent删除，要不然会发生这个rootview已经有parent的错误。*/
    ViewGroup mViewGroup = (ViewGroup) mRootview.getParent();
    if (mViewGroup != null)
    {
        mViewGroup.removeView(mRootview);
    }

    return mRootview;
}
```
