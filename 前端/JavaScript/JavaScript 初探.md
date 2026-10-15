## JavaScript 初探

@(JavaScript)

[toc]

> js区分大小写

### 1. 使用JavaScript

- 定义内嵌脚本
- 定义外部脚本

```
<!doctype html>
<html>
<head>
	<title>Example</title>
</head>

<body>
	<script type="text/javascript">			    	
		document.writeln("Hello")
    </script>
</body>
</html>
```

> script元素位于文档中其他内容之后

### 2. 语句
JavaScript的基本元素是语句. 一条语句代表着一条命令, 通常以分号`;`结尾, 分号可有可无, 一行可以书写多条语句.

### 3. 定义和使用函数

```
function 函数名()
{
	JS语句;
}
```

#### 3.1 定义带参数的函数
> - JavaScript是一门弱类型的语言, 所以定义函数的时候不必声明参数的数据类型
> - 调用函数时提供的参数数目不必与函数定义中的参数数目相同. 如果提供的参数值更少, 那么所有未提供值得参数值均为`undefined`. 如果提供的参数值更多, 那么多出的值会被忽略;

```
<script type="text/javascript">			    	
	function myFunc(name, weather)
	{
		document.writeln("Hello " + name + ".");
		document.writeln("It is " + weather + " today");
	}
	
	myFunc("Adam", "sunny");
</script>
```

#### 3.2 定义会返回结果的函数
```
function 函数名()
{
	return JS语句;
}
```

### 4. 使用变量和类型
#### 4.1. 定义变量
定义变量要使用var关键字.

局部变量和全局变量

```
<body>
	<script type="text/javascript">		
		var myGlobalVar = "apples";
			    	
		function myFunc(name)
		{
			var myLocalVar = "sunny";
			return ("Hello " + name + ". Today is " + myLocalVar + ".");
		}
		
		document.writeln(myFunc("Adam"));
    </script>
    <script type="text/javascript">
    	document.writeln("I like " + myGlobalVar);
    </script>
</body>
```


#### 4.2. 变量类型
JavaScript是一种弱类型语言, 但这不代表它没有类型, 而是指不用明确声明变量的类型以及可随心所欲地用同一变量表示不同类型的值.

定义字符串变量
```
var firstString = "This is a string";
```
定义布尔变量
```
var firstBool = true;
var secondBool = false;
```
定义数值变量
```
var daysInWeek = 7;
var p1 = 3.14;
var hexValue = 0xFFFF;
```

> 定义number类型变量时不必言明所用的是那种数值, 只消写出需要的值即可, JavaScript会酌情处理.

### 5. 对象操作
#### 5.1 创建对象
方式一: 通过调用new Object()的方式创建;
```
//通过调用new Object()的方式创建对象, 将其赋给 myData 变量
var myData = new Object();

//通过赋值的方式定义属性
myData.name = "Adam";
myData.weather = "sunny";

//获取属性值并输出
document.writeln("Hello " + myData.name + ".");
document.writeln("Today is " + myData.weather + ".");
```
方式二: 使用对象字面量;

```
//创建对象及其属性
var myData = {
	name : "Adam",
	weather : "sunny"
}

//获取属性值并输出
document.writeln("Hello " + myData.name + ".");
document.writeln("Today is " + myData.weather + ".");
```

#### 5.2 在对象中添加方法

```
//创建对象及其属性
var myData = {
	name : "Adam",
	weather : "sunny"

	//定义一个名为 printMessages 的方法
	printMessages : function(){
		//获取属性值并输出, 注意,这里使用 this 关键字
		document.writeln("Hello " + this.name + ".");
		document.writeln("Today is " + this.weather + ".");
	}
}

//方法调用
myData.printMessages();
```

#### 5.3 读取和修改对象属性值
方式一: 通过句点将对象名和属性名连接到一起;

```
myData.name = "Joe";
```

方式二: 类似数组索引;

```
myData["weather"] = "raining";
```

#### 5.4 枚举对象属性
使用 for...in 语句枚举对象属性
```
var myData = {
	name : "Adam",
	weather : "sunny"
	printMessages : function(){
		document.writeln("Hello " + this.name + ".");
		document.writeln("Today is " + this.weather + ".");
	}
}

//属性遍历
for(var prop in myData){
	document.writeln("Name: " + prop + "Value: " + myData[prop]);
}
```

#### 5.5 增删属性和方法
```
//创建对象及其属性
var myData = {
	name : "Adam",
	weather : "sunny"
}

//添加方法
myData.sayHello = function(){
	document.writeln("Hello");
}

//添加属性
myData.dayOfWeek = "Monday";
myData["dayOfMonth"] = "12";

//删除属性和方法
delete myData.name;
delete myData["weather"];
delete myData.sayHello;
```

#### 5.6 判断对象是否具有某个属性
使用 `in` 表达式判断对象是否具有某个属性

```
var myData = {
	name : "Adam",
	weather : "sunny"
}

var hasName = "name" in myData;
var hasDate = "date" in myData;

document.writeln("HashName: " + hasName);
document.wirteln("HashDate: " + hasDate);
```

### 6. JavaScript 运算符
#### 6.1 相等和等同运算符
相等运算符由两个等号组成(`==`)测试两个值是否相等, 不管其类型. 
等同运算符由三个等号组成(`===`)测试值和类型是否都相等.
> - != 不相等
> - !== 不等同

#### 6.2 显式类型转换
1. 数值转换成字符串
数值转换成字符串有两种方法:
- 使用`toString()`方法
- 使用`String函数`

数值转换成字符串的常用转换方法

| 方法      |     说明 |   返回值   |
| :-------- | :--------:| :------: |
| toString()    |  以十进制形式表示数值  |  字符串  |
| toString(2)    |  ...二进制...  |  字符串  |
| toString(8)    |  ...八进制...  |  字符串  |
| toString(16)    |  ...十六进制...  |  字符串  |
| toFixed(n)   |  以小数点后有n位数字的形式表示实数  |  字符串  |
| toExponential(n)    |  以指数表示法表示数值,小数点前1位数字,小数点后n位数字  |  字符串  |
| toPrecision(n)    |  用n位有效数字表示数值, 在必要的情况下使用指数表示法  |  字符串  |

2. 字符串转换成数值
字符串转换成数值的常用函数

| 函数      |     说明 |
| :-------- | :--------:|
| Number(str)    |  通过分析制定字符串,生成一个整数或实数值  |
| parseInt(str)    |  通过分析制定字符串,生成一个整数值  |
| parseFloat(str)    |  通过分析制定字符串,生成一个整数或实数值  |

> Number函数解析字符串的方式很严格, 在这方面`parseInt`和`parseFloat`函数更为灵活, 这两个函数还会忽略数字字符后面的非数字字符

### 7. 使用数组
#### 7.1 数组创建和赋值
在JavaScript中创建数组的方式有两种:
- 调用`new Array()`创建
- 使用数组字面量

```
<script type="text/javascript">
	<!--方式 1-->
	var myArray1 = new Array();
	myArray1[0] = 100;
	myArray1[1] = "Adam";
	myArray1[2] = true;

	<!--方式 2-->
	var myArray2 = [100, "Adam", true];
</script>
```
> 注意: 创建数组的时候不需要声明数组中元素的个数, JavaScript数组会自动调整大小以便容纳所有元素. 也不必声明数组所含数据的类型, JavaScript数组可以混合包含各种类型的数据.

#### 7.2 读取和修改数组内容
在JavaScript中读取和修改数组内容与在java中的方式都是通过数组下标来完成的
```
<script type="text/javascript">
	var myArray = [100, "Adam", true];
	myArray[0] = "Tuesday";
	document.writenln("index0: " + myArray[0]);
	document.writenln("index1: " + myArray[1]);
</script>
```

#### 7.3 枚举数组内容
使用方式与java中for循环语法类似
```
<script type="text/javascript">
	var myArray = [100, "Adam", true];
	for(var i = 0; i < myArray.length; i++)
	{
		document.writenln("index" + i + ":" + myArray[i]);
	}
</script>
```

#### 7.4 数组方法

| 方法      |     说明 |   返回值   |
| :-------- | :--------:| :------: |
| concat(otherArray)    |  合并数组, 可指定多个  |  数组  |
|  join(separator)   |  将所有数据元素连接为一个字符串, 各元素使用指定字符分割  |  字符串  |
|  pop()   |  把数组当做栈使用, 删除并返回数组的最后一个元素  |  对象  |
|  push(item)   |  把数组当做栈使用, 将指定的数据添加到数组中  |  void  |
|  reverse()   |  反转数据元素的次序  |  数组  |
|  shift()   |  类似pop,但操作的是数组的第一个元素  |  对象  |
|  slice(start, end)   |  返回一个子数组  |  数组  |
|  sort()   |  数组排序  |  数组  |
|  unshift(item)   |  类似push,但新元素被插到数组的开头位置  |  void  |

### 8. 处理错误

```
<script type="text/javascript">
	try {
		var myArray;
		for (var i = 0; i < myArray.length; i++) {
			document.writeln("Index" + i + ": " + myArray[i]);
		}
	} catch (e) {
		document.writeln("Error: " + e);
	} finally {
		document.writeln("Statements here are always executed");
	}
</script>
```

Error 对象属性

| 属性      |     说明 |   返回   |
| :-------- | :--------:| :------: |
|  message   |  对错误条件的说明  |  字符串  |
|  name   |  错误的名称,默认为Error  |  字符串  |
|  number   |  该错误的错误代号(如果有的话)  |  数值  |

### 8. 比较 undefined 和 null 值
- undefined: 表示在未定义值得情况下得到的值
- null: 表示已经赋值, 但该值不是一个有效的值(也就是说定义的是一个无值[no value])

```
<script type="text/javascript">
	var myData = {
		name: "Adam"
	}

	document.writeln("Var: " + myData.weather);

	myData.weather = null;
	document.writeln("Var: " + myData.weather);
</script>

输出:
Var: undefined
Var: null
```

#### 8.1 检查变量或属性是否为 undefined 或 null
可以使用 if 语句和逻辑非运算符( ! )进行检查
```
<script type="text/javascript">
	var myData = {
		name: "Adam"
	}

	if (!myData.name) {
		document.writeln("name is null or undefined");
	}
	else {
		document.writeln("name is not null or undefined");
	}

	if (!myData.weather) {
		document.writeln("name is null or undefined");
	}
	else {
		document.writeln("name is not null or undefined");
	}
</script>
```

#### 8.2 区分 null 和 undefined
如果想同等对待 undefined 值和 null 值, 那么应该使用相等运算符( == ), 让 JavaScript 进行类型转换.
如果想区分 undefined 和 null 值, 则应使用等同运算符 ( === ).

```
<script type="text/javascript">
	var firstVal = null;
	var secondVal;

	var equality = firstVal == secondVal;
	var identity = firstVal === secondVal;

	document.writeln("Equality: " + equality);
	document.writeln("Identity: " + identity);
</script>	

输出:
Equality: true
Identity: false
```
