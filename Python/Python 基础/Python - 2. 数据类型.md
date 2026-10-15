
[toc]

`Python` 中的变量赋值不需要类型声明。
每个变量在使用前都必须赋值，变量赋值以后该变量才会被创建。

```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-

counter = 100 # 赋值整型变量
print(counter)
counter = 1000.0 # 浮点型
print(counter)
counter = "John" # 字符串
print(counter)
```

#### 多个变量赋值

`Python` 允许你同时为多个变量赋值。例如：

```python
a = b = c = 1
```

以上实例，创建一个整型对象，值为1，三个变量被分配到相同的内存空间上。

您也可以为多个对象指定多个变量。例如：

```python
a, b, c = 1, 2, "john"
```

以上实例，两个整型对象 1 和 2 分别分配给变量 a 和 b，字符串对象 "john" 分配给变量 c。

#### 标准数据类型

`Python3` 中常见的数据类型有：

* `Number`（数字）
* `String`（字符串）
* `bool`（布尔类型）
* `List`（列表）
* `Tuple`（元组）
* `Set`（集合）
* `Dictionary`（字典）

`Python3` 的六个标准数据类型中：

* **不可变数据**：Number（数字）、String（字符串）、Tuple（元组）；
* **可变数据**：List（列表）、Dictionary（字典）、Set（集合）。

此外还有一些高级的数据类型，如: 字节数组类型(**`bytes`**)。

#### 查询数据类型
`Python` 内置的 `type()` 函数可以用来查询变量所指的对象类型。

```python
>>> a, b, c, d = 20, 5.5, True, 4+3j
>>> print(type(a), type(b), type(c), type(d))
<class 'int'> <class 'float'> <class 'bool'> <class 'complex'>
```

此外还可以用 `isinstance` 来判断：

```python
>>> a = 111
>>> isinstance(a, int)
True
```

`isinstance` 和 `type` 的区别在于：

* `type`：不会认为子类是一种父类类型。
* `isinstance`：会认为子类是一种父类类型。

#### Numbers
`Python3` 支持 `int`、`float`、`bool`、`complex`（复数）。

在 `Python3` 里，只有一种整数类型 `int`，表示为长整型，没有 `python2` 中的 `Long`。

#### bool
布尔类型即 `True` 或 `False`，`True` 和 `False` 是 `Python` 的关键字。

`bool` 是 `int` 的子类，因此布尔值可以被看作整数来使用，其中 `True` 等价于 `1`，`false` 等价于 `0`。

可以使用 `bool()` 函数将其他类型的值转换为布尔值。
以下值在转换为布尔值时为 `False`：

* **None**
* **False**
* **零 (0、0.0、0j)**
* **空序列（如 ''、()、[]）**
* **空映射（如 {}）**

其他所有值转换为布尔值时均为 `True`。

#### String
[Python3 字符串](https://www.runoob.com/python3/python3-string.html)

`Python` 的字串列表有2种取值顺序:

* 从左到右：索引默认从0开始，最大范围是字符串长度少1
* 从右到左：索引默认从-1开始，最大范围是字符串开头

| - | - | - | - | - | - |
| --- | --- | --- | --- | --- | --- |
| a | b | c | d | e | f |
| 0 | 1 | 2 | 3 | 4 | 5 |
| -6 | -5 | -4 | -3 | -2 | -1 |

##### 字符串截取

可以使用 **[头下标:尾下标]** 来截取相应的字符串，下标可以是正数或负数表示从左到右或从右到左截取，下标可以为空表示取到头或尾。

```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
str = 'Hello World!'
 
print str           # 输出完整字符串
print str[0]        # 输出字符串中的第一个字符
print str[2:5]      # 输出字符串中第三个至第六个之间的字符串
print str[2:]       # 输出从第三个字符开始的字符串
print str * 2       # 输出字符串两次
print str + "TEST"  # 输出连接的字符串
```

#### List

在 `Python` 中列表用 `[ ]` 标识，内部元素用逗号 `,` 隔开。列表中的任意元素可以是字符，数字，字符串甚至可以包含列表（即嵌套）。

列表中值的切割也可以用到 **[头下标:尾下标]**，从左到右索引默认 0 开始，从右到左索引默认 -1 开始，下标可以为空表示取到头或尾。

```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
list = [ 'runoob', 786 , 2.23, 'john', 70.2 ]
tinylist = [123, 'john']
 
print list               # 输出完整列表
print list[0]            # 输出列表的第一个元素
print list[1:3]          # 输出第二个至第三个元素 
print list[2:]           # 输出从第三个开始至列表末尾的所有元素
print tinylist * 2       # 输出列表两次
print list + tinylist    # 打印组合的列表
```

#### Tuple

元组是另一个数据类型，类似于 `List`（列表）。
在 `Python` 中元组用 `()` 标识，内部元素用逗号 `,` 隔开。但是元组不能二次赋值，相当于只读列表。

```python
#!/usr/bin/python3
# -*- coding: UTF-8 -*-

tuple = ( 'runoob', 786 , 2.23, 'john', 70.2 )
tinytuple = (123, 'john')

print(tuple)               # 输出完整元组
print(tuple[0])            # 输出元组的第一个元素
print(tuple[1:3])          # 输出第二个至第四个（不包含）的元素 
print(tuple[2:])           # 输出从第三个开始至列表末尾的所有元素
print(tinytuple * 2)       # 输出元组两次
print(tuple + tinytuple)   # 打印组合的元组

tuple[2] = 1000    # 修改元组中的元素是非法操作
```

#### Set

在 `Python` 中，集合使用大括号 `{}` 表示，元素之间用逗号 `,` 分隔。

另外，也可以使用 `set()` 函数创建集合。

> 注意：创建一个空集合必须用 `set()` 而不是 `{ }`，因为 `{ }` 是用来创建一个空字典。

创建格式：

```python
parame = {value01,value02,...}
或者
set(value)
```
