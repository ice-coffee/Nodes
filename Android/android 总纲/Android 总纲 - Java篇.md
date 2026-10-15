[toc]

### 序列化的两种方式以及差别
Serializable:

- Serializable是java提供的可序列化接口
- Serializable的序列化与反序列化需要大量的IO操作,效率比较低
- Serializable实现起来很简单

Parcelable:

- Parcelable是Android特有的可序列化接口
- Parcelable的效率比较高
- Parcleable实现起来比较复杂

### Switch能否用string做参数？
在 Java 7  之前, switch 只能支持byte,short,char,int 或者其对应的封装类以及 Enum 类型。在JAVA 7中,String 支持被加上了。   

### ==、equals与hashCode
1. ==：比较的是值是否相等
- 如果作用于基本数据类型的变量，则直接比较其存储的 “值”是否相等；
- 如果作用于引用类型的变量，则比较的是所指向的对象的地址
2. equals：equals方法不能作用于基本数据类型的变量，equals继承Object类，比较的是是否是同一个对象
- 如果没有对equals方法进行重写，则比较的是引用类型的变量所指向的对象的地址；
- 诸如String、Date等类对equals方法进行了重写的话，比较的是所指向的对象的内容。

### Object有哪些公用方法？
方法equals测试的是两个对象是否相等
方法clone进行对象拷贝
方法getClass返回和当前对象相关的Class对象
方法notify,notifyall,wait都是用来对给定对象进行线程同步的

### Java的四种引用，强弱软虚，用到的场景

### String、StringBuffer与StringBuilder的区别
- String 类型和 StringBuffer 类型的主要性能区别其实在于 String 是不可变的对象
- StringBuffer和StringBuilder底层是 char[]数组实现的
- StringBuffer是线程安全的，而StringBuilder是线程不安全的

### Override和Overload的含义去区别
- Overload顾名思义是重新加载，它可以表现类的多态性，可以是函数里面可以有相同的函数名但是参数名、返回值、类型不能相同；或者说可以改变参数、类型、返回值但是函数名字依然不变。
- Override就是ride(重写)的意思，在子类继承父类的时候子类中可以定义某方法与其父类有相同的名称和参数，当子类在调用这一函数时自动调用子类的方法，而父类相当于被覆盖（重写）了。

### 抽象类和接口的区别
一个类只能继承单个类，但是可以实现多个接口
接口强调特定功能的实现，而抽象类强调所属关系
抽象类中的所有方法并不一定要是抽象的，你可以选择在抽象类中实现一些基本的方法。而接口要求所有的方法都必须是抽象的

### 解析XML的几种方式的原理与特点：DOM、SAX、PULL
- DOM：消耗内存：先把xml文档都读到内存中，然后再用DOM API来访问树形结构，并获取数据。这个写起来很简单，但是很消耗内存。要是数据过大，手机不够牛逼，可能手机直接死机
- SAX：解析效率高，占用内存少，基于事件驱动的：更加简单地说就是对文档进行顺序扫描，当扫描到文档(document)开始与结束、元素(element)开始与结束、文档(document)结束等地方时通知事件处理函数，由事件处理函数做相应动作，然后继续同样的扫描，直至文档结束。
- PULL：与 SAX 类似，也是基于事件驱动，我们可以调用它的next（）方法，来获取下一个解析事件（就是开始文档，结束文档，开始标签，结束标签），当处于某个元素时可以调用XmlPullParser的getAttributte()方法来获取属性的值，也可调用它的nextText()获取本节点的值。

### Java 内存模型
- 内存分配
- 栈数据共享
- String初始化的两种方式

### JAVA 垃圾回收机制

### JAVA多态的实现原理 
抽象的来讲，多态的意思就是同一消息可以根据发送对象的不同而采用多种不同的行为方式。（发送消息就是函数调用）
实现的原理是动态绑定，程序调用的方法在运行期才动态绑定，追溯源码可以发现，JVM 通过参数的自动转型来找到合适的办法。

### 讲讲 Java 中的集合有多少种，区别是什么？
- ArrayList、LinkedList、Vector的区别：ArrayList 和Vector底层是采用数组方式存储数据，Vector由于使用了synchronized方法（线程安全）所以性能上比ArrayList要差，LinkedList使用双向链表实现存储，随机存取比较慢
- HashMap的底层源码实现：当我们往HashMap中put元素的时候，先根据key的hashCode重新计算hash值，根据hash值得到这个元素在数组中的位置（即下标），如果数组该位置上已经存放有其他元素了，那么在这个位置上的元素将以链表的形式存放，新加入的放在链头，最先加入的放在链尾。如果数组该位置上没有元素，就直接将该元素放到此数组中的该位置上。
- Fail-Fast机制:在使用迭代器的过程中有其他线程修改了map，那么将抛出ConcurrentModificationException，这就是所谓fail-fast机制。这一机制在源码中的实现是通过modCount域，modCount顾名思义就是修改次数，对HashMap内容的修改都将增加这个值，那么在迭代器初始化过程中会将这个值赋给迭代器的expectedModCount。在迭代过程中，判断modCount跟expectedModCount是否相等，如果不相等就表示已经有其他线程修改了Map.
- HashMap和 HashTable 的区别：
		- HashTable比较老，是基于Dictionary 类实现的，HashTable 则是基于 Map接口实现的
		- HashTable 是线程安全的， HashMap 则是线程不安全的
		- HashMap可以让你将空值作为一个表的条目的key或value


### ArrayList和Vector的区别
ArrayList是在java1.2引入的, 用于替换Vector
Vector:
- 线程同步
- 当Vector中元素超过它的初始大小时, 它的容量将翻倍
ArrayList:
- 线程不同步, 但是性能很好
- 当ArrayList中元素超过它的初始大小时, 它的容量只会增加50%的大小

### 对抽象、继承、多态的理解

### 泛型的作用及使用场景

### 枚举的特点及使用场景

### JAVA反射机制

### Java 类加载机制
