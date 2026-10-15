[toc]

### 特殊符号
常见特殊符号：

* `$0`：当前脚本的文件名（或方法名）。
* `$1, $2, ...`：获取脚本（方法）参数。
* `$#`：参数的个数。
* `$@`：所有参数列表。
* `$*`：所有参数列表。
* `$?`：最后运行的命令的结果或返回值。
* `$$`：`Shell` 本身的 `PID`。 
* `*`：作为匹配文件名扩展的一个通配符，能自动匹配给定目录下的每一个文件。	
* `~`：波浪号。和环境变量 `HOME` 一样，默认表示当前用户根目录。
* `--`：两个减号，与 `~` 相同。	
* `~+`：当前工作目录。和环境变量 `PWD` 一样。
* `~-`：前一个工作目录。和内部变量 `OLDPWD` 一致。
* `-`：减号。和 `~-` 一样。
* `.`：点号。表示当前目录。
* `..`：两个点号。表示上一层目录。

`$*`、`$@` 的区别： 

* 没有双引号包裹：功能相同，都表示由参数组成的数组。
* 有双引号包裹：`$@` 能力没有变化，`$*` 表示所有参数拼接组成的一个字符串。

```sh
#!/bin/sh
 
some_func() {
    for var in "$@"
    do
        echo ${var}
    done
}
 
#---
 
other_func() {
    for var in "$*"
    do
        echo ${var}
    done
}
 
some_func 1 2 3 4
other_func 1 2 3 4

// 输出
1
2
3
4
1 2 3 4
```

### 各种括号
#### 小括号

**`单小括号 ()`**：

1. **命令替换**：在 `$(cmd)` 结构中，表示在一个 `子 shell` 中执行 `cmd` 命令，并将其输出作为字符串返回。多个命令使用 `;` 分割，命令和括号之间不必有空格。
2. **初始化数组**：`array=("value1" "value2")`。

**`示例：`**

```sh
dir=$(pwd)
echo "当前目录：$dir"
```

> `注意`：在 `shell` 中反引号（\`\`）也可以用作命令替换，但是反引号在处理转义字符时没有小括号好用，所以推荐使用小括号。 

**`双小括号 (())`**：

1. **数值运算**：

```sh
value=1
((value++))
echo $value
```

2. **数值条件判断**：

```sh
if ((0))
then
    echo "is true"
elif
then
    echo "is false"
fi
```

```sh
if ((value < 10))
then
  echo "value < 10"
fi
```

```sh
for ((i = 0; i < 5; i++))
do
  echo "$i"
done
```

可以看到在 `(())` 中数值的操作更接近于 `C++/Java` 等编程语言。而且在 `(())` 中引用变量不需要 `&`。

#### 中括号
> 当中括号用于条件判断时：`[[]] > [] = test`

**`单中括号 []`**：

1. **条件判断**
2. **数组元素访问**

```sh
#!/bin/bash

# 定义一个变量
num="123"

# 判断字符串变量是否为空
if [ -z "$num" ]; then
    echo "字符串变量为空。"
else
    # 判断变量是否为非数字
    if ! [[ $num =~ ^[0-9]+$ ]]; then
        echo "变量不是一个数值。"
    else
        echo "变量是一个数值。"
    fi
fi

```

**`双中括号 [[]]`**：

1. **条件判断**：推荐使用 `[[]]` 替代 `[]`，因为这样中括号中的条件表达式更接近于 `C++/Java` 等编程语言的写法。
2. **支持正则表达式**

> `注意`：在使用中括号时命令和括号之间需要添加空格。

#### 大括号

1. **字符串提取和替换**
2. **变量使用**：在使用变量时使用 `{}` 避免歧义。

| 符号 | 作用 | 示例 |
| --- | --- | --- |
`$` | 美元符放在变量前用于取变量的值 | echo $PATH 打印环境变量 PATH 的值 |
`${}` | 美元符加上大括号，大括号中放变量的名称，也是用于读取变量的值 | echo ${PATH}path,访问变量PATH，而不是变量 PATHpath，注意和上面 $ 的区别 |
`${:-}` | 用法 `${var:-word}`。表示如果变量 var 为空或已被删除(unset)，那么返回 word，但不改变 var 的值。| |
`${:+}` | 用法 `${var:+word}`。如果变量 var 被定义，那么返回 word，但不改变 var 的值。| |
`${:=}` | 用法 `${var:=word}`。如果变量 var 为空或已被删除(unset)，那么返回 word，并将 var 的值设置为 word。| |
`${:?}` | 用法 `${var:?message}`。如果变量 var 为空或已被删除（unset），那么将消息 message 送到标准错误输出，可以用来检测变量 var 是否可以被正常赋值。若此替换出现在Shell脚本中，那么脚本将停止运行。| |
`${#}` | 用法 `${#var}`。获取字符串变量 var 的长度 | string="abcd"; echo ${#string} 输出 4 |
`${:}` | 字符串提取，用法 `${var:n}` 。若n为正数，n从0开始，表示在变量var中提取第n个字符到末尾的所有字符。若n为负数，提取字符串最后面n的绝对值个字符，使用时在冒号后面加空格或一个算术表达式或整个num加上括号，如${var: -2}、${var:1−3}或 ${var:(-2)} 均表示提取字符串最后两个字符。 | a="abcde";echo ${a:1-4}输出 cde。|
`${::}` | 字符串提取，用法 `${var:n1:n2}`。 | string="tencent is a great company";echo ${string:1:4}输出 ence。|
`{,}` | 顺序扩展，用法 `${value1,value2,value3}`，逗号分隔一般用于文件列表的扩展。| echo {a,b}.txt输出 a.txt b.txt。|
`{..}` | 顺序扩展，用法 `${value1..value2}`，双点号分隔一般用于文件列表的扩展。| echo {a..d}.txt输出 a.txt b.txt c.txt d.txt |
`${#}` | 模式匹配截断，不改变原变量。用法 `${var#pattern}`，在 var 中查找给定的模式 pattern，把 var 中的内容去掉左边最短的匹配模式。 | `var=testcase; echo ${var#*s}` 输出 tcase。|
`${##}` | 模式匹配截断，不改变原变量。用法 `${var##pattern}`，在 var 中查找给定的模式 pattern，把 var 中的内容去掉左边最长的匹配模式。| `var=testcase; echo ${var##*s}` 输出 e。|
`${%}` | 模式匹配截断，不改变原变量。用法 `${var%pattern}`，在 var 中查找给定的模式 pattern，把 var 中的内容去掉右边最短的匹配模式。 | `var=testcase; echo ${var%s*e}` 输出 testca。|
`${%%}` | 模式匹配截断，不改变原变量。用法 `${var%%pattern}`，在 var 中查找，把 variable 中的内容去掉右边最长的匹配模式。 | `var=testcase;echo ${var%%s*e}`输出 te。|
`${变量/匹配模式/替换内容}` | 替换变量中第一个符合匹配模式的内容 | var=/home/centos;echo ${var/o/h}输出 /hhme/centos |
`${变量//匹配模式/替换内容}` | 替换变量中所有符合匹配模式的内容 | var=/home/centos;echo ${var//o/h}输出 /hhme/cenths。|

### IFS 

`IFS` 在 `Shell` 中是一个全局变量，默认值是 `空格、Tab键、换行符`。

**`作用：`**

* 在 `变量替换(扩展)`、`命令替换(扩展)`、`算术替换(扩展)`时，如果它们的结果没有使用引号包围，则尝试使用IFS将结果进行单词划分。
* 在 `read` 命令中，根据 `IFS` 将所读取的内容划分为单词分别赋值给指定的变量。

**`示例：`**
1. `IFS` 在变量替换(扩展)中生效：

```sh
IFS=:
for item in "a:b:c:d"; do
    # 输出 a:b:c:d
    printf "$item"
done

IFS=:
var="a:b:c:d"
for item in $var; do
    # 输出 abcd
    printf "$item"
done
```

2. `IFS` 在 `read` 中：

```sh
IFS=,
echo "1,2,3,4" | while read -r a b c; do
    echo "a=$a, b=$b, c=$c"
done
```

> 注意：在 `Shell` 脚本中，`IFS` 是一个全局变量，一旦被修改，会影响脚本后续的行为。为了恢复或避免影响其他部分的代码，通常有以下几种方法来处理 `IFS` 恢复问题：
> 1. 手动恢复 `IFS=$' \t\n'`；
> 2. 在子 `shell` 中修改 `IFS` 或在某个命令范围内使用 `IFS`，不会影响全局。

**`示例：`**

```sh
# 1 ~
old_IFS=$IFS
IFS=,          # 修改 IFS
# 一些操作
IFS=$old_IFS   # 恢复为原值

# 2 ~
IFS=,
echo "1,2,3,4" | while read -r a b c; do
    echo "a=$a, b=$b, c=$c"
done
```

### 参考链接
[shell 特殊字符大全](https://blog.csdn.net/K346K346/article/details/51819236)

[shell 中各种括号的作用](https://www.runoob.com/w3cnote/linux-shell-brackets-features.html)

[Shell脚本深入教程：Bash IFS用法详解](https://junmajinlong.github.io/shell/script_course/shell_ifs/index.html)
