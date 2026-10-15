
[toc]

### 参考
[深入解析String#intern](https://tech.meituan.com/2014/03/06/in-depth-understanding-string-intern.html)：美团的这篇文章对于字符串相加和字符串常量相加的结果有错误，可能是因为 `Java` 有优化改动。

### 创建字符串
```
String s = new String(“xyz”);
```

如果 `xyz` 不存在与常量池，那以上代码会创建两个对象：

* 类常量池内的常量
* 堆内存中创建的实例对象

### 字符串相加
[转自](https://blog.csdn.net/u010775025/article/details/86507090)

有一道这样的程序：
 
```java
 1 public class TestStringDemo {
 2 
 3     public static void main(String[] args) {
 4 
 5         String s1 = "Programming";
 6         String s2 = new String("Programming");
 7         String s3 = "Program";
 8         String s4 = "ming";
 9         String s5 = "Program" + "ming";
10         String s6 = s3 + s4;
11         System.out.println(s1 == s2);
12         System.out.println(s1 == s5);
13         System.out.println(s1 == s6);
17     }
18 }

程序的输出：
false
true
false
```

第一个输出：false，我们还可以理解；
第二输出：true，跟我们的结果不一样，为什么输出 true？不是说好了吗？字符串的 + 操作其本质是 new StringBuilder() 对象进行 append 操作，拼接后调用 toString() 返回 String 对象？

我们可以用以下命令获得 `.class` 文件对应的字节码指令：

```
javap -c StringEqualTest.class
```

JVM字节码指令：

![24febca41c81aadc11beaf43075ae6d6.png](<../../attachment/F8E24D32-1B47-4C8F-95CE-43BA79205ABD.png>)
 
第20~22行，我们通过对比知道，String s5 = "Program" + "ming";在被编译器优化成了String s5 = "Programming"; 
 也可以得出字符串常量相加，不会用到StringBuilder对象，有一点要注意的是：字符串常量和字符串是不同的概念，字符串常量储存于方法区，而字符串储存于堆(heap)。
 
第三个输出：false ;通过以上的分析，自然也就明白了为森马是false了

我们来分析一下JVM字节码指令：

![f1490ba97f4ae7645b7ce07445cf8495.png](<../../attachment/26451C0F-7519-4CBD-8578-F3A69117A979.png>)

第24行：使用new 了 StringBuider对象
第25行：进行StringBuider对象初始化
第26行：使用append() 方法拼接s3的内容
第27行：再使用append() 方法拼接s4的内容
第28行：最后调用toString() 返回String对象

总结：

* `字符串常量相加`：在预编译的时候 “+” 会被优化，相当于把两个或者两个以上字符串常量自动合成一个字符串常量。
* `字符串相加`：其本质是 `new StringBuilder` 对象进行 `append` 操作，拼接后调用 `toString()` 返回 `String` 对象。
