[TOC]
### 注意
当前笔记只为后续学习 Gradle 内容记录，内容并不详细。

### 关联地址
[深入理解 Android 之 Gradle](https://blog.csdn.net/innost/article/details/48228651)
[Groovy SDK](http://www.groovy-lang.org/download.html#gvm)
[Groovy api](http://www.groovy-lang.org/api.html)

### Groovy 环境变量配置（Mac）
1. Groovy是依赖于Java的，所以首先要配置好JDK。
2. 在[Groovy SDK](http://www.groovy-lang.org/download.html#gvm)下载 Groovy SDK。
3. 下载后解压。
4. 配置 Groovy 环境变量。
```
open ~/.bash_profile
```
写入 Groovy bin 目录地址
```
export PATH=$PATH:/Users/****/groovy-2.4.4/bin
```
使配置生效
```
source ~/.bash_profile
```
5. 测试
```
groovy -v
```
输出如下代表配置成功。
```
Groovy Version: 3.0.6 JVM: 1.8.0_131 Vendor: Oracle Corporation OS: Mac OS X
```

### Groovy 定义
`Groovy` 是在 java 平台上的、 具有像 `Python`、`Ruby` 和 `Smalltalk` 语
言特性的灵活动态语言，`Groovy` 保证了这些特性像 Java 语法一样被 Java 开发者使用。

`Groovy` 和 Java 一样，也运行于 Java 虚拟机 中。 Groovy Code 在真正执行的时候已经变成了 Java 字节码，所以 JVM 根本不知道自己运行的是 Groovy 代码。

简单粗暴点儿看，你可以认为 Groovy 扩展了 Java 语言。

### 第一个 Groovy 脚本

创建一个 test.groovy 文件，里边只有一行代码:
```
println "hello groovy"
```
执行 groovy 脚本
```
groovy test.grooovy
hello groovy
```

### Groovy 语法

#### 换行
Groovy 语句可以不用分号结尾。直接回车换行。

#### 注释
与 Java 一样，`Groovy` 支持单行（或行末）与多行（块）注释。
```
// 这是一个行注释
/* 这是一个多行的
   块注释。 */
```

#### 变量
Groovy 中支持动态类型，即定义变量的时候可以不指定其类型。
Groovy 中，变量定义可以使用关键字 `def`。
> 注意，虽然 def 不是必须的，但是为了代码清晰，建议还是使用 def 关键字。

```
def varable2 = "I am a person"
def int x = 1 //变量定义时，也可以直接指定类型
```

#### 函数
如下，带有两个 String 参数，返回 String 的函数：
```
String testFunction(String arg1, String arg2){
	return arg1 + " " + arg2
}
```
以上示例与 Java 中函数的定义一模一样。

Groovy 函数的参数可以不指定类型：
```
String testFunction(arg1, arg2){
	return arg1 + " " + arg2
}
```

Groovy 函数的返回值也可以不指定类型，但无类型的函数声明，必须使用 `def` 关键字：
```
def testFunction(arg1, arg2){
    return arg1 + " " + arg2
}
```

Groovy 的函数里，可以不使用 return xxx 来设置 xxx 为函数返回 值。如果不使用 return 语句的话，则函数里最后一句代码的执行结果将成为函数的返回值。
```
def testFunction(arg1, arg2){
    arg1 + " " + arg2
}
```

Groovy 中函数调用的时候还可以不加括 号。比如:
```
println("test") ---> println "test"
```
> 注意，虽然写代码的时候，对于函数调用可以不带括号，但是 Groovy 经常把属性和函数调 用混淆。比如
```
def getSomething(){ 
    "hello"
}
getSomething() //如果不加括号的话，Groovy 会误认为 getSomething 是一个变量。运行会报错。
```
所以如果这个函数是 Groovy API 或者 Gradle API 中比较常用的，比如 println，就可以不带括号。否则还是带括号较好。

#### 字符串
Groovy对字符串支持相当强大，充分吸收了一些脚本语言的优点:
1 单引号''中的内容严格对应 Java 中的 String，不对$符号进行转义 
```
def singleQuote='I am $ dolloar' //输出就是 I am $ dolloar
```
2 双引号""的内容则和脚本语言的处理有点像，如果字符中有$号的话，则它会$表达式先求值。 
```
def doubleQuoteWithoutDollar = "I am one dollar" //输出 I am one dollar
def x = 1
def doubleQuoteWithDollar = "I am $x dolloar" //输出 I am 1 dolloar
```
3 三个引号'''xxx'''中的字符串支持随意换行 比如 
```
def multieLines = ''' begin
line 1 
line 2 
end '''
```

#### 数据类型
1. 基本数据类型
Groovy 世界中的所有事物都是对象。所以，int，boolean 这些 Java 中 的基本数据类型，在 Groovy 代码中其实对应的是它们的包装数据类型。比如 int 对应为 Integer，boolean 对应为 Boolean。这一点与 Kotlin 相同。

2. 容器
Groovy 中的容器类很简单，就三种:

- List：链表，其底层对应 Java 中的 List 接口，一般用 ArrayList 作为真正的实 现类。
- Map：键-值表，其底层对应 Java 中的 LinkedHashMap。
- Range：范围，它其实是 List 的一种拓展。

3. 闭包

##### List
初始化
Groovy 中 List 变量使用 `[]` 初始化：
```
def aList = [5,'string',true] //List 由[]定义，其元素可以是任何对象
```

操作
可以直接通过索引存取，而且不用担心索引越界。如果索引超过当前链表长度，List 会自动 往该索引添加元素。
```
assert aList[1] == 'string'
assert aList[5] == null //第 6 个元素为空
aList[100] = 100 //设置第 101 个元素的值为 10
assert aList[100] == 100

println aList.size  //101
println aList[102]  //null
```

##### Map
初始化
Groovy 中 Map 变量使用 `[:]` 初始化：
```
def aMap = ['key1':'value1','key2':true]
```
> key 必须是字符串，value 可以是任何对象。

操作
```
//这种表达方法好像 key 就是 aMap 的一个成员变量一样 
println aMap.keyName
//这种表达方法更传统一点
println aMap['keyName']
//为 map 添加新元素
aMap.anotherkey = "i am map"
```

##### Range
Range 是 Groovy 对 List 的一种拓展，变量定义和大体的使用方法如下:
```
/*Range 类型的变量 由 begin 值+两个点+end 值表示 
下边这个 aRange 包含 1,2,3,4,5 这 5 个值*/
def aRange = 1..5
```
如果不想包含最后一个元素，则
```
//包含 1,2,3,4 这 4 个元素 
def aRangeWithoutEnd = 1..<5
```

```
println aRange.from
println aRange.to
```

##### 闭包
闭包是 Groovy 中很重要的一个概念所以单独来讲。

#### 闭包（Closure）
闭包，也是一种数据类型，它代表了一段可执行的代码。

##### 闭包声明
如下：
```
def aClosure = {params -> code}
//或者
def aClosure = {code}
```

##### 闭包调用
如下：
```
aClosure.call(params1, params2)
//或者
aClosure(params1, params2)
```

##### it 的使用
> 注意：如果闭包没定义参数的话，则隐含有一个参数，这个参数名字叫 `it`，它代表闭包的参数。

比如:
```
def greeting = { "Hello, $it!" }
println greeting('Patrick')
//等同于:
def greeting = { it -> "Hello, $it!" }
println greeting('Patrick')
```

但是，如果在闭包定义时，采用下面这种写法，则表示闭包没有参数!
```
def noParamClosure = { -> true } 
```
这个时候，我们就不能给 noParamClosure 传参数了! 
```
noParamClosure ("test") //报错喔!
```

##### 使用注意
1. 省略圆括号

Groovy中，当函数的最后一个参数是闭包的话，可以省略圆括号。比如：
```
def testClosure(int a1,String b1, Closure closure){
	println a1 + b1
	closure()
}

//那么调用的时候，就可以免括号!
testClosure (4, "test", { 
	println "i am in closure"
})

testClosure 4, "test", { 
	println "i am in closure"
}
```
2. 如何确定 Closure 的参数
> 最正确的方式是 。。。。查 API 文档。

### 高级用法

#### 脚本类
> 我通过 groovyc 编译出来的 class 文件和[阿拉神农](https://blog.csdn.net/innost/article/details/48228651)博客中写的不太一样，没看懂，这里就只写结论了。
1. 编译 Groovy 脚本
使用 `groovyc` 命令编译 Groovy 文件。
```
groovyc -d classes hello.groovy
```
2. 脚本中导入其他类
Groovy 中导入类也是通过关键字 `import` 和 Java 是一样的。
```
import groovy.transform.Field;
@Field x = 1
def printX() {
	println x
}

printX()

def test = new hello()
println test.x
```
3. 脚本中的变量和作用域

```
def x = 1
def printX() {
	println x
}
//报错 No such property: x for class: hello
printX()

x = 1
def printX() {
	println x
}
//输出 1
printX()
```
Groovy 脚本中 def 修饰的变量无法在函数中被访问。

如果需要在别的脚本文件中使用需要通过 Field 声明变量为成员变量。
```
import groovy.transform.Field;
@Field x = 1
def printX() {
	println x
}

printX()
```

#### 操作文件
读文件
```
//打开文件
def targetFile = new File("hello.groovy")
//逐行读取文件
targetFile.eachLine {
	println it
}
//读取文件字节码
println targetFile.bytes
//操作输入流
def inputStream = targetFile.newInputStream() 

//操作输入流，最后记得关掉
inputStream.close

//使用闭包操作 inputStream，以后在 Gradle 里会常看到这种搞法 
targetFile.withInputStream{ ism ->
//操作 ism. 不用 close。Groovy 会自动替你 close 
}
```

写文件
> 这种写文件的方式会将目标文件原有内容覆盖。
```
//文件写入
def srcFile = new File("src.groovy")
targetFile.withOutputStream{ os->
srcFile.withInputStream{ ins->
os << ins //利用 OutputStream 的<<操作符重载，完成从 inputstream 到 OutputStream //的输出
} }
targetFile.eachLine {
	println it
}
```

#### XML 操作
Groovy 中，XML 的解析 提供了和 XPath 类似的方法，名为 GPath。
test.xml
```
<response version-api="2.0">
    <value>
        <books>
            <book available="20" id="1">
                <title>Don Xijote</title>
                <author id="1">Manuel De Cervantes</author>
            </book>
            <book available="14" id="2">
                <title>Catcher in the Rye</title>
                <author id="2">JD Salinger</author>
            </book>
            <book available="13" id="3">
                <title>Alice in Wonderland</title>
                <author id="3">Lewis Carroll</author>
            </book>
            <book available="5" id="4">
                <title>Don Xijote</title>
                <author id="4">Manuel De Cervantes</author>
            </book>
        </books>
    </value>
</response>
```
test.groovy
```
def xparser = new XmlSlurper()
def targetFile = new File("test.xml")
//轰轰的 GPath 出场
def gpathResult = xparser.parse(targetFile)
//开始玩 test.xml。现在我要访问 id=4 的 book 元素。 
//下面这种搞法，gpathResult 代表根元素 response。通过 e1.e2.e3 这种
//格式就能访问到各级子元素....
def book4 = gpathResult.value.books.book[3] 
//得到 book4 的 author 元素
def author = book4.author
//再来获取元素的属性和 textvalue 
println author.text()
println author.@id
//属性一般是字符串，可通过 toInteger 转换成整数 
println author.@id.toInteger() == 4
```

再一个例子，访问 AndroidManifest.xml 中的package属性
```
def androidManifest = new XmlSlurper().parse("app/src/main/AndroidManifest.xml")
println androidManifest.@package
```
