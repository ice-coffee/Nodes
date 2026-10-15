[toc]

### test、[]、[[]]、(())
`test` 命令用于检查某个条件是否成立，它可以进行数值、字符和文件三个方面的测试。

例如：
```sh
num1="ru1noob"
num2="runoob"
if test $num1 == $num2
then
    echo '两个字符串相等!'
else
    echo '两个字符串不相等!'
fi
```

在 `shell` 脚本中 `[]` 是 `test` 命令的别名，所以上面的例子可以修改为：

```sh
num1="ru1noob"
num2="runoob"
if [ $num1 == $num2 ]
then
    echo '两个字符串相等!'
else
    echo '两个字符串不相等!'
fi
```

> **注意**：`[ `、` ]` 必须紧跟一个空格。 

`[[]]` 除了支持正则表达式和逻辑运算符 `&&、||` 外，和 `[]` 的能力基本一致。

```sh
my_var="ru1noob"
if [[ $my_var == *"noo"* ]]
then
    echo '匹配成功!'
else
    echo '匹配失败!'
fi
```

`(())` 用于支持整数类型计算，在括号中的表达式和运算符只要符合 `C` 语言规则都可以用。

```sh
num1=10
num2=20
if (( num1 == num2 ))
then
    echo '两值相等!'
else
    echo '两值不相等!'
fi
```

> **注意**：在 `(())` 中使用变量不用带 `$` 符号。

### 条件测试

下面来看下常见的条件测试场景

#### 变量是否定义
```sh
definition=false
if [ $definition ]
then
    echo '已定义'
else
    echo '未定义'
fi
```

#### 字符串测试
| 参数| 说明 |
| --- | --- |
| =、==	| 等于则为真 |
| != | 不相等则为真 |
| -z 字符串 | 字符串的长度为零则为真 |
| -n 字符串 | 字符串的长度不为零则为真 |

示例：
```sh
num1="ru1noob"
num2="runoob"
if [ $num1 = $num2 ]
then
    echo '两个字符串相等!'
else
    echo '两个字符串不相等!'
fi
```
#### 文件检测

| 参数| 说明 |
| --- | --- |
| -e | 文件是否存在(exist) |
| -f | 文件是否存在且为普通文件(file) |
| -d | 文件是否存在且为目录(directory) |
| -b | 文件是否存在且为块设备(block device) |
| -c | 文件是否存在且为字符设备(character device) |
| -S | 文件是否存在且为套接字文件(Socket) |
| -p | 文件是否存在且为命名管道文件FIFO(pipe) |
| -L | 文件是否存在且是一个链接文件(Link) |

示例：

```sh
file_path="..."
if [[ -f $file_path ]]; then
	echo "文件存在"
else
	echo "文件不存在"
fi
```

#### 逻辑运算

| 参数| 说明 |
| --- | --- |
| `-a或&&` | (and)两表达式同时为true时才为true。"-a"只能在test或[]中使用，&&只能在[[]]中使用 |
| `-o或||` | (or)两表达式任何一个true则为true。"-o"只能在test或[]中使用，||只能在[[]]中使用 |
| `!` | 对表达式取反 |

### 参考链接
[shell测试命令test、\[ \]、\[\[ \]\] ](https://www.cnblogs.com/f-ck-need-u/p/7427357.html)
