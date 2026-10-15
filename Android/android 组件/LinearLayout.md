## LinearLayout

### 遇到的坑

#### 使用weight的问题
> Layout weights require a widget to be measured twice. When a LinearLayout with non-zero weights is nested inside another LinearLayout with non-zero weights, then the number of measurements increase exponentially.

布局权重需要调用`measured`测量两次。当具有非零权重的LinearLayout嵌套在具有非零权重的另一个LinearLayout中时，测量次数呈指数增长。

可以使用`RelativeLayout`来替换, 但是要实现类似`weight`的效果可以使用`Percent Support Lib`

[Percent Support Lib](https://github.com/JulienGenoud/android-percent-support-lib-sample)
