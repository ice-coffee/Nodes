# PopupWindow药店
[toc]

### 1. PopupWindow使用
示例
1. 编写PopupWindow主体代码
```
public class SelectPopupWindow extends PopupWindow
{
    public SelectPopupWindow(Activity context)
    {
        super(context);

		//获取屏幕宽高
        View view = View.inflate(context, R.layout.pop_layout, null);
        Point point = new Point();
        context.getWindowManager().getDefaultDisplay().getSize(point);
        int h = point.y;
        int w = point.x;
        // 设置按钮监听
        // 设置SelectPicPopupWindow的View
        this.setContentView(view);
        // 设置SelectPicPopupWindow弹出窗体的宽
        this.setWidth(w / 2);
        // 设置SelectPicPopupWindow弹出窗体的高
        this.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        // 设置SelectPicPopupWindow弹出窗体可点击
        this.setFocusable(true);
        // 设置SelectPicPopupWindow弹出窗体动画效果
        this.setAnimationStyle(R.style.mystyle);
        // 实例化一个ColorDrawable颜色为半透明
        ColorDrawable dw = new ColorDrawable(0000000000);
        // 设置SelectPicPopupWindow弹出窗体的背景
        this.setBackgroundDrawable(dw);
    }
}
```

2. PopupWindow显示

```
public void showWindow(View view)
{
    SelectPopupWindow menuWindow2 = new SelectPopupWindow(this);
    // 显示窗口并设置layout在PopupWindow中显示的位置
    menuWindow2.showAtLocation(bt_show, Gravity.TOP | Gravity.RIGHT, 0, 60);
}
```
> 注意:PopupWindow showAtLocation用法
> [原文链接](http://www.pocketdigi.com/20130218/987.html)

- PopupWindow显示的方法有三个,showAsDropDown(anchor),showAsDropDown(anchor, xoff, yoff)和showAtLocation(parent, gravity, x, y)。

- 前两个showAsDropDown方法是让PopupWindow相对于某个控件显示，而showAtLocation是相对于整个窗口的。

- 第一个参数是View类型的parent,虽然这里参数名是parent，其实，不是把PopupWindow放到这个parent里，并不要求这个parent是一个ViewGroup，这个参数名让人误解。官方文档”a parent view to get the android.view.View.getWindowToken() token from“,这个parent的作用应该是调用其getWindowToken()方法获取窗口的Token,所以，只要是该窗口上的控件就可以了,选哪个并没有什么差别。

- 第二个参数是Gravity，可以使用|附加多个属性，如Gravity.LEFT|Gravity.BOTTOM。

- 第三四个参数是x,y偏移。
