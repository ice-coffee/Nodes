### NumberFormat / DecimalFormat 数字格式化

@(android 项目开发)

[原文](https://blog.csdn.net/kongbaidepao/article/details/79942783)

#### NumberFormat  

```
//返回当前缺省语言环境的缺省数值格式。
NumberFormat.getInstance().format(myNumber); 23,323.332
 
//返回当前缺省语言环境的通用格式
NumberFormat.getCurrencyInstance().format(myNumber); ￥23,323.33
 
//返回当前缺省语言环境的通用数值格式。 
NumberFormat.getNumberInstance().format(myNumber); 23,323.332
 
//返回当前缺省语言环境的百分比格式。
NumberFormat.getPercentInstance().format(test); 34%
 

NumberFormat format = NumberFormat.getInstance()
设置数值的小数部分允许的最大位数。 
format.setMaximumFractionDigits(3) 
 
设置数值的小数部分允许的最小位数。 
format.setMinimumFractionDigits(5) 
 
设置数值的整数部分允许的最大位数。 
format.setMaximumIntegerDigits(10)  
 
设置数值的整数部分允许的最小位数.
format.setMinimumIntegerDigits(0)  
 
format.format(2132323213.23266666666)   2,132,323,213.23267
```

#### DecimalFormat格式化数字  ---- 这个更好用一些

DecimalFormat也是Format的一个子类，主要的作用是用来格式化数字，当然，在格式化数字的时候要比直接使用NumberFormat更加方便，
因为可以直接指定按用户自定义的方式进行格式化操作，
与SimpleDateFormat类似，如果要想进行自定义格式化操作，则必须指定格式化操作的模板。

```
"0" 数字 代表阿拉伯数字，每一个0表示一位阿拉伯数字，如果该位不存在则显示0
 
"#" 数字 代表阿拉伯数字，每一个#表示一位阿拉伯数字，如果该位不存在则不显示
 
"." 数字 小数点分隔符或货币的小数分隔符
 
"-" 数字 代表负号
 
"," 数字 分组分隔符
 
"E" 数字 分隔科学计数法中的尾数和指数
 
";" 子模式边界 分隔正数和负数子模式
 
"%" 前缀或后缀 数字乘以100并显示为百分数
 
"\u2030" 前缀或后缀 乘以1000并显示为千分数
 
"\u00A4" 前缀或后缀 货币记号，由货币号替换。如果两个同时出现，则用国际货币符号替换。
        如果出现在某个模式中，则使用货币小数分隔符，而不使用小数分隔符。
 
"," 前缀或后缀 用于在前缀或或后缀中为特殊字符加引号，例如 "'#'#" 将 123 格式化为 "#123"。要创建单引号本身，请连续使用两个单引号："# o''clock"。
```

```
public class FormatDemo {
 
    public void format(String pattern,double value){
        DecimalFormat df=new DecimalFormat(pattern);
        String str=df.format(value);
        System.out.println("使用" + pattern+ "\t格式化数字"+value+"：\t" + str);
    }
    public static void main(String[] args) {
        FormatDemo demo=new FormatDemo();
        demo.format("###,###.###", 111222.34567);
        demo.format("000,000.000", 11222.34567);
        demo.format("###,###.###$", 111222.34567);
        demo.format("000,000.000￥", 11222.34567);
        demo.format("##.###%", 0.345678);        // 使用百分数形式
        demo.format("00.###%", 0.0345678);        // 使用百分数形式
        demo.format("###.###\u2030", 0.345678);    // 使用千分数形式
    }
}
 
```

#### RoundingMode枚举类
- HALF_EVEN
向最接近数字方向舍入的舍入模式，如果与两个相邻数字的距离相等，则向相邻的偶数舍入。如果舍弃部分左边的数字为奇数，则舍入行为
同 RoundingMode.HALF_UP；如果为偶数，则舍入行为同 RoundingMode.HALF_DOWN。注意，在重复进行一系列计算时，此舍入模式可以在统计上将累加错误减到最小。
此舍入模式也称为“银行家舍入法”，主要在美国使用。此舍入模式类似于 Java 中对 float 和 double 算法使用的舍入策略。
- HALF_UP
此舍入模式就是通常学校里讲的四舍五入。
- HALF_DOWN
应该按上面的理解话，是五舍六入。
- FLOOR
向负无限大方向舍入的舍入模式，此舍入模式始终不会增加计算值。白话文就是向下取整。
- CEILING
向正无限大方向舍入的舍入模式。此舍入模式始终不会减少计算值。向上取整
- UP
这个也是向上取整，但是，如果是坐标轴的话，这个都是远离零的方向取整，5.5->6; -2.5->-3
- DOWN
这个也是向下取整，但是，如果是坐标轴的话，这个都是靠近零的方向取整，5.5->5; -2.5->-2
