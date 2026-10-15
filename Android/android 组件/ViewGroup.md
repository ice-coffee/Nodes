## ViewGroup
[toc]
### View与ViewGroup有什么区别？
- Android的UI界面都是由View和ViewGroup及其派生类组合而成的。
- 其中，View是所有UI组件的基类，而 ViewGroup是容纳这些组件的容器，其本身也是从View派生出来的.
- View对象是Android平台中用户界面体现的基础单位。
- View类是它称为“widgets(工具)”的子类的基础，它们提供了诸如文本输入框和按钮之类的UI对象的完整实现。
- ViewGroup类同样为其被称为“Layouts(布局)”的子类奠定了基础，它们提供了象流式布局、表格布局以及相对布局之类的布局架构。
- 一般来说，开发Android应用程序的UI界面都不会直接使用View和ViewGroup，而是使用这两大基类的派生类。

### LayoutAnimationController的使用
[源码链接](http://pan.baidu.com/s/1i3DCjpr)
> LayoutAnimationController用于为布局或者ViewGroup的子视图添加动画效果.有一点需要强调，开发者不可以为每个子视图分别指定不同的动画效果，但是 LayoutAnimation-Controller 可以决定各个子视图显示动画效果的时间.

通过例子来理解如何使用 LayoutAnimationController 是一个好方法。在下面的例子中，我们将结合透明度渐变动画（alpha
animation）和位移动画（translate animation）演示如何给 ListView的子视图添加动画效果。使用 LayoutAnimationController 的方法有两种：直接在代码中使用或者在 XML 文件中配置。

1. 获取ListView的引用

```
mListView = (ListView) findViewById(R.id.my_listview_id);
```

2. 创 建默认动画集合对象,添加透明度渐变动画和位移动画

```
AnimationSet set = new AnimationSet(true);

Animation animation = new AlphaAnimation(0.0f, 1.0f);
animation.setDuration(50);
set.addAnimation(animation);

animation = new TranslateAnimation(Animation.RELATIVE_TO_SELF, 0.0f,Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF,-1.0f, Animation.RELATIVE_TO_SELF, 0.0f);
animation.setDuration(100);
set.addAnimation(animation);
```

3. 创 建 LayoutAnimationController 对象并设置子视图动画效果持续时间

```
LayoutAnimationController controller = new LayoutAnimationController(set, 0.5f);
```

4. 将 LayoutAnimationController对象设置到ListView 中

```
mListView.setLayoutAnimation(controller);
```
