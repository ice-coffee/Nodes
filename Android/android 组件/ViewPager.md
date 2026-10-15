## ViewPager

@(android 控件药店)


### ViewPager使用小知识点
	1. 设置 ScaleType的属性为FIT_XY可以调整在viewpager上轮播网络图片,图片的左右两侧距离屏幕有间隔的问题也可以用来修改,ImageLoader插件下载的图片没有完全填充你所设置ImageView的情况 (如果差别较大,就是图片本身的问题了)

### FragmentStatePagerAdapter vs FragmentPagerAdapter
#### 1. 文档翻译

- FragmentStatePagerAdapter
```
继承自android.support.v4.view.PagerAdapter，每页都是一个Fragment，并且所有的Fragment实例一直保存在Fragment manager中。所以它适用于少量固定的fragment，比如一组用于分页显示的标签。除了当Fragment不可见时，它的视图层（view hierarchy）有可能被销毁外，每页的Fragment都会被保存在内存中。（翻译自代码文件的注释部分）
```
- FragmentPagerAdapter

```
继承自android.support.v4.view.PagerAdapter，每页都是一个Fragment，当Fragment不被需要时（比如不可见），整个Fragment都会被销毁，除了saved state被保存外（保存下来的bundle用于恢复Fragment实例）。所以它适用于很多页的情况。（翻译自代码文件的注释部分）
```
#### 2. 图解: 

![enter image description here](https://upload-images.jianshu.io/upload_images/1976768-649bb20f838b3592.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

![enter image description here](https://upload-images.jianshu.io/upload_images/1976768-b18a02d6f7940270.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

#### 3. 总结
二者使用方法基本相同，唯一的区别就在卸载不再需要的fragment时，采用的处理方式不同：
```
使用FragmentStatePagerAdapter会销毁掉不需要的fragment。事务提交后，可将fragment从activity的FragmentManager中彻底移除。类名中的“state”表明：在销毁fragment时，它会将其onSaveInstanceState(Bundle) 方法中的Bundle信息保存下来。用户切换回原来的页面后，保存的实例状态可用于恢复生成新的fragment.
FragmentPagerAdapter的做法大不相同。对于不再需要的fragment，FragmentPagerAdapter则选择调用事务的detach(Fragment) 方法，而非remove(Fragment)方法来处理它。也就是说，FragmentPagerAdapter只是销毁了fragment的视图，但仍将fragment实例保留在FragmentManager中。因此， FragmentPagerAdapter创建的fragment永远不会被销毁。
(摘抄自《Android权威编程指南11.1.4》)
```

#### 4. 使用
如果想要实现类似书籍阅读器的应用程序，则不希望立即将所有片段加载到内存中。您希望Fragments在用户阅读时加载和销毁。在这种情况下，应该使用FragmentStatePagerAdapter。
如果想要实现类似TabHost，那么应该使用FragmentPagerAdapter。
