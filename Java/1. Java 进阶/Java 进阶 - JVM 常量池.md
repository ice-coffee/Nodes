[toc]

## 总结
`常量池的本质是对象的共享，避免频繁的创建和销毁对象而影响系统性能。`

常量池种类：

* Class常量池（编译期）
* 运行时常量池（运行期）
* 全局字符串常量池（运行期）

## 概念
#### 池化技术
类比于线程池的实现；定义数据结构保存保存线程对象的引用。

应用：线程池、内存池、HttpClient连接池等

#### 符号引用 vs 直接引用
[java -- JVM的符号引用和直接引用](https://www.cnblogs.com/qlky/p/7643524.html)
**符号引用：**
符号引用以一组符号来描述所引用的目标，符号可以是任何形式的字面量，只要使用时能够无歧义的定位到目标即可。

例如，在Class文件中它以CONSTANT_Class_info、CONSTANT_Fieldref_info、CONSTANT_Methodref_info等类型的常量出现。符号引用与虚拟机的内存布局无关，引用的目标并不一定加载到内存中。在Java中，一个java类将会编译成一个class文件。在编译时，java类并不知道所引用的类的实际地址，因此只能使用符号引用来代替。比如org.simple.People类引用了org.simple.Language类，在编译时People类并不知道Language类的实际内存地址，因此只能使用符号org.simple.Language（假设是这个，当然实际中是由类似于CONSTANT_Class_info的常量来表示的）来表示Language类的地址。各种虚拟机实现的内存布局可能有所不同，但是它们能接受的符号引用都是一致的，因为符号引用的字面量形式明确定义在Java虚拟机规范的Class文件格式中。

 
**直接引用：**
直接引用可以是

1. 直接指向目标的指针（比如，指向“类型”【Class对象】、类变量、类方法的直接引用可能是指向方法区的指针）；
2. 相对偏移量（比如，指向实例变量、实例方法的直接引用都是偏移量）；
3. 一个能间接定位到目标的句柄；

直接引用是和虚拟机的布局相关的，同一个符号引用在不同的虚拟机实例上翻译出来的直接引用一般不会相同。如果有了直接引用，那引用的目标必定已经被加载入内存中了。

## Class常量池
我们写的每一个 `Java` 类被编译后，就会形成一份 `class` 文件；`class` 文件中除了包含类的版本、字段、方法、接口等描述信息外，还有一项信息就是常量池(constant pool table)，用于存放编译器生成的各种字面量(Literal)和符号引用(Symbolic References)；

```java
package jvm;
public class JavaBean {
	public String name0 = "张三";
	final int value0 = 101;
	public static void main(String[] args) {
		JavaBean bean = new JavaBean();
		bean.run();
	}

	private void run() {
		String name1 = "李四";
	 	final int value1 = 102;
	 	int value2 = 103;
	}
}
```

```java
// 编译 java 文件
javac JavaBean.java
// 解析 class 文件
javap -v JavaBean.java
```

```c++
// **解析后的内容如下**：
public class jvm.JavaBean
  minor version: 0
  major version: 52
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #9.#25         // java/lang/Object."<init>":()V
   #2 = String             #26            // 张三
   #3 = Fieldref           #5.#27         // jvm/JavaBean.name0:Ljava/lang/String;
   #4 = Fieldref           #5.#28         // jvm/JavaBean.value0:I
   #5 = Class              #29            // jvm/JavaBean
   #6 = Methodref          #5.#25         // jvm/JavaBean."<init>":()V
   #7 = Methodref          #5.#30         // jvm/JavaBean.run:()V
   #8 = String             #31            // 李四
   #9 = Class              #32            // java/lang/Object
  #10 = Utf8               name0
  #11 = Utf8               Ljava/lang/String;
  #12 = Utf8               value0
  #13 = Utf8               I
  #14 = Utf8               ConstantValue
  #15 = Integer            101
  #16 = Utf8               <init>
  #17 = Utf8               ()V
  #18 = Utf8               Code
  #19 = Utf8               LineNumberTable
  #20 = Utf8               main
  #21 = Utf8               ([Ljava/lang/String;)V
  #22 = Utf8               run
  #23 = Utf8               SourceFile
  #24 = Utf8               JavaBean.java
  #25 = NameAndType        #16:#17        // "<init>":()V
  #26 = Utf8               张三
  #27 = NameAndType        #10:#11        // name0:Ljava/lang/String;
  #28 = NameAndType        #12:#13        // value0:I
  #29 = Utf8               jvm/JavaBean
  #30 = NameAndType        #22:#17        // run:()V
  #31 = Utf8               李四
  #32 = Utf8               java/lang/Object
  
......
```

#### 字面量

* 声明在任意位置的文本字符串；
```c++
  #23 = Utf8               张三
  #26 = Utf8               李四
```
* 用 `final` 修饰的变量的值，包括静态变量、实例变量和局部变量（`存疑1`）；
```c++
  #13 = Integer            101
```

> **`注意：字面量均是指数据的值。`**

#### 符号引用

* 类和接口的全限定名
```c++
  #5 = Class              #29            // jvm/JavaBean
  #29 = Utf8               jvm/JavaBean
```
* 字段（即变量）的名称和描述符
* 方法的名称和描述符，也即参数类型+返回值

> **`存疑1`**：实际测试中局部变量的字面量和符号引用未出现在 `Constant pool` 中，不知道是不是由于版本的问题；

## 运行时常量池

> `摘自《Java虚拟机规范》`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`运行时常量池（runtime constant pool）是 class 文件中每一个类或接口的常量池表（constannt pool trable）的运行时表示形式，它包括了若干种不同的常量，从编译期可知的数值字面量到必须在运行期解析后才能获得的方法或字段引用。运行时常量池类似于传统语言中的符号表（symol table），不过它存储数据的范围比通常意义上的符号表要更为广泛。`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`每一个运行时常量池都在Java虚拟机的方法区中分配，在加载类和接口到虚拟机后，就创建对应的运行时常量池。`

根据描述可以知道：

* 每个类或接口都有自己的运行时常量池；
* 运行时常量池在加载类和接口到虚拟机时（“后->时”）创建。（**`备注`**：这里的加载指的应该是类加载过程中的加载阶段）

类加载过程中：

* 加载：会将class常量池的数据加载进运行时常量池；
* 解析：将字符引用解析为直接引用。

所以运行时常量池中存储的内容为引用，

## 全局字符串常量池
字符串常量池是 `JVM` 所维护的一个字符串实例的引用表，在 `HotSpot VM` 中，它是一个叫做 `StringTable` 的全局表。在字符串常量池中维护的是字符串实例的引用，底层C++实现就是一个 `Hashtable`。这些被维护的引用所指的字符串实例，被称作"被驻留的字符串"或"`interned string`"或通常所说的"进入了字符串常量池的字符串"。

当程序创建字符串时，虚拟机会先根据字符串常量池缓存的引用查询内存是否有 `String.equals() == true` 的字符串对象，如果有则直接返回已有对象的引用，如果没有就在堆中创建一个新的对象，把引用存放到字符串常量池，在把引用赋值给字符串变量。

> **`注意`**：运行时常量池和字符串常量池不是一个概念。

### String 字面量进入字符串常量池的过程

## 基本数据类型封装类及常量池

## String.intern()

## 参考
[彻底弄懂java中的常量池](https://cloud.tencent.com/developer/article/1450501)

常量池种类：
class 文件常量池
运行时常量池：每个 class 对应一个运行时常量池
全局字符串常量池：JVM中只有一个
Java 基本类型的封装类及对应常量池

String.intern()

[深入解析String#intern](https://tech.meituan.com/2014/03/06/in-depth-understanding-string-intern.html)

[JVM类加载流程及常量池介绍](https://zhuanlan.zhihu.com/p/429670865)

[类和对象在JVM中是如何存储的](https://www.cnblogs.com/javazhiyin/p/13984328.html)

https://www.zhihu.com/question/268546130
https://zhuanlan.zhihu.com/p/107776367
https://www.zhihu.com/question/451498490
https://juejin.cn/post/6854573216824819719
https://developer.aliyun.com/article/901551

## 扩展

### 常量池位置变化的原因

### 两种创建字符串方式的区别

几个引用，几个对象
