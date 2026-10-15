### ArgbEvaluator
> 此评估器可用于在表示ARGB颜色的整数值之间执行类型插值, 通俗点讲就是可以得到在两个颜色之间的过渡值.

#### evaluate(float fraction, Object startValue, Object endValue)
> 此函数返回给定整数的颜色的计算中间值;

- fraction : 从开始到结束值的分数中间值
- startValue : 起始色值, 32bit 整数型
- endValue : 结束色值, 32bit 整数型
