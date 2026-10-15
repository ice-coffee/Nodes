i### <include>
在 `LayoutInflater.inflate()` 解析布局的过程中，如果发现 `<include>` 标签，则获取其 `name` 属性，

> 注意：`<include>` 标签不可用在根布局
> `<include>` 和其它组件标签一样，都可以使用 `layout` 属性来设置布局文件的宽高和位置，但需要注意的是：必须要复写 `android:layoutwidth` 和 `android:layoutheight` 属性才能使用其它属性，这样可以避免 `include` 引用 `layout` 中的子组件属性影响到 `include` 的布局效果

### <merge>
在 `LayoutInflater.inflate()` 解析布局的过程中，如果发现 `<merge>` 标签则通过其父布局的 `AttributeSet` 解析子布局，并将子布局添加到父布局中。

> 注意：`<merge>` 标签必须用在根布局

### <ViewStub>
`<ViewStub>` 只有在调用其 `setVisiable(VISIBLE \ INVISIBLE)` 方法时才会解析：

```
public void setVisibility(int visibility) {
    if (mInflatedViewRef != null) {
        View view = mInflatedViewRef.get();
        if (view != null) {
            view.setVisibility(visibility);
        } else {
            throw new IllegalStateException("setVisibility called on un-referenced view");
        }
    } else {
        super.setVisibility(visibility);
        if (visibility == VISIBLE || visibility == INVISIBLE) {
            inflate();
        }
    }
}
```

`inflate()` 在 `ViewStub` 类内被重写，用于解析子布局，解析成功后，调用 `replaceSelfWithView` 替换 `ViewStub` 在父布局中的位置。

```
private void replaceSelfWithView(View view, ViewGroup parent) {
    final int index = parent.indexOfChild(this);
    parent.removeViewInLayout(this);

    final ViewGroup.LayoutParams layoutParams = getLayoutParams();
    if (layoutParams != null) {
        parent.addView(view, index, layoutParams);
    } else {
        parent.addView(view, index);
    }
}
```

> 注意：由 `ViewStub.setVisibility()` 可知，`ViewStub` 仅生效一次。

### 尽量使用 `VIEW.GONE`
