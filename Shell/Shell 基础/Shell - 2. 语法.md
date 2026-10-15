[toc]

## 变量
因为 `shell` 是弱类型语言，所以不需要在定义时指定变量类型，而是根据赋值内容来确定类型。

> 如果非要划分的话，可以有：「字符串」、「布尔值」、「整数」和「数组」。

```sh
# 定义变量
my_var="Hello, world!"

# 使用变量：`$`
echo $my_var

# 修改变量为只读
readonly my_var

# 删除变量
unset my_var
```

> `注意`：
> * `shell` 变量定义时 `=` 两侧不能有空格。
> * 不能删除只读变量。

**使用变量**：使用变量时有如下几种方式：

```sh
1. $my_var
2. ${my_var}
3. "$my_var"
4. "${my_var}"
```

使用变量时双引号 `""` 和大括号 `{}` 的作用：

* 双引号 `""`：完整输出变量，防止变量中存在空格、换行或特殊字符时导致字符被错误拆解和拆分。

```sh
#!/bin/bash

my_var[0]="hello world"

for var in "$my_var"; do
    echo $var
done
```

* 大括号 `{}`：明确变量边界，保证变量名可以被正确解析。

```sh
#!/bin/bash

my_var="hello world"

echo "${var}!"
```

### 布尔值
定义布尔变量：

```sh
truth=true
falsy=false
```

需要注意的是 `shell` 中布尔值判断，举个例子：

```sh
value=false
if $value; then
  echo 'Done'
fi
```

以上示例，是用于判断 `value` 变量是否定义，而不是想象中 `value` 是否为 `true`。

因此，布尔值正确的判断方式，应使用 test 命令，或使用 test 的简写语法 [ ] 或 [[ ]]。比如：

```sh
value=false

if [ $value = true ]; then
  echo 'Done'
fi

if [ $value = false ]; then
  echo 'Error'
fi
```

### 环境变量
环境变量是指在当前 `Shell` 环境和其子环境中都可以使用的变量，类似于全局变量。

**`- 默认环境变量：`**

* `PATH`：包含了 `Shell` 用于查找可执行文件的路径列表。
* `HOME`：当前用户的主目录路径。
* `PWD`：当前工作目录的路径。

**`- 自定义环境变量：`**
使用 `export` 和 `declare` 关键字都可以将变量定义为环境变量：
> * `export 变量名=value` --> (**`常用方式`**)
> * `变量名=value; export 变量名`
> * `declare -x 变量名=value`

**`- 取消环境变量：`**

* 可以使用 `unset` 关键字取消本地变量或环境变量。

**`- 查看环境变量：`**

* `env`：查看所有环境变量。
* `$变量名`：查看目标变量名。

### 数组变量
`bash` 支持一维数组（不支持多维数组），并且没有限定数组的大小。获取数组中的元素要利用下标，下标可以是整数或算术表达式，其值应大于或等于 `0`，且超过数组大小也不会报错只是没有返回值。

**`定义数组：`**
在 `Shell` 中，用 **`()`** 来表示数组，数组元素用 **`空格`** 符号分割开。定义数组的一般形式为：

> `数组名=(值1 值2 ... 值n)`

例如：
```sh
array_name=(value0 value1 value2 value3)

# 或者
array_name=(
value0
value1
value2
value3
)

# 还可以单独定义数组的各个分量：
array_name[0]=value0
array_name[1]=value1
array_name[n]=valuen
```

**`读取数组：`**

> `${数组名[下标]}`

例如：

```sh
valuen=${array_name[n]}
# 使用 @ 符号可以获取数组中的所有元素
echo ${array_name[@]}
```

**`获取数组的长度：`**
获取数组长度的方法与获取字符串长度的方法相同，例如：

```sh
# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
length=${#array_name[n]}
```

**`数组遍历：`**

```sh
#!/bin/bash

my_array=("apple" "banana" "cherry")
for index in "${!my_array[@]}"; do
    echo "Index: $index, Value: ${my_array[index]}"
done
```

### 字典
在 `Bash` 中，`declare -A` （`base 4.0` 以上）用于声明关联数组（也称为哈希表或字典）。关联数组是一种键值对数据结构，允许你使用自定义的键来访问值，而不是依赖于数值索引。

**`语法：`**

```sh
declare -A array_name
```

**`示例：`**

```sh
# 声明
declare -A fruits

# 赋值
fruits["apple"]="red"
fruits["banana"]="yellow"
fruits["cherry"]="red"

# 访问
echo ${fruits["apple"]}  # 输出：red

# 列出所有键
echo ${!fruits[@]}  # 输出：apple banana cherry

# 列出所有值
echo ${fruits[@]}  # 输出：red yellow red

# 删除元素
unset fruits["banana"]

# 遍历
for key in "${!fruits[@]}"; do
    echo "$key -> ${fruits[$key]}"
done
```

## 流程控制
### if
语法：
```sh
if condition1
then
    command1
elif condition2 
then 
    command2
else
    commandN
fi
```

也有把 `if` 和 `then` 关键字写在一行的，这时要在条件语句后加 `;` 表示结束。

if else 的 `[...]` 判断语句中大于使用 `-gt`，小于使用 `-lt`。
```sh
if [ "$a" -gt "$b" ]; then
    ...
fi
```

如果使用 `((...))` 作为判断语句，大于和小于可以直接使用 `>` 和 `<`。
```sh
if (( a > b )); then
    ...
fi
```

### for
语法：
```sh
for var in item1 item2 ... itemN
do
    command1
    command2
    ...
    commandN
done

# 无限循环
for (( ; ; ))
```

示例：
```sh
# 输出当前目录文件
for file in $(ls)
do
    echo "$file"
done
```

### while
语法：
```sh
while condition
do
    command
done

# 无限循环
while :
do
    command
done

# 或
while true
do
    command
done
```

### until
`until` 循环执行一系列命令直至条件为 **`true`** 时停止。与 `while` 循环在处理方式上刚好相反。

语法：
```sh
until condition
do
    command
done
```

### case ... esac
与其他语言中的 `switch ... case` 语句类似，是一种多分支选择结构。

语法：
```sh
case 值 in
模式1)
    command
    ;;
模式2)
    command
    ;;
esac
```

* `case`：开始标记；
* `*)`：每个分支用`)`结束；
* `;;`：表示 break，即分支执行结束；
* `esac`：（就是 `case` 反过来）作为结束标记；

## 函数

**`语法：`**

```sh
[ function ] funname [()]

{

    action;

    [return int;]

}
```

**`示例：`**

```sh
#!/bin/bash

funWithParam {
    param_idx=1
    for param in $*; do
    	echo "第${param_idx}个参数${param}"
    	((param_idx++))
    done
    return $#
}
funWithParam 1 2 3 4 5 6 7 8 9 34 73

echo "参数总数：$?"
```

## 命令

### echo
`echo`：输出内容到控制台，默认添加换行符。

### printf
`printf`：和 `echo` 作用一致，但默认不添加换行符。

### declare
`declare`：声明变量和设置变量属性。

格式如下：
```sh
declare [-afFirtx] [-p] [name[=value] ...]
```

参数说明：
* `-a`：声明变量为数组类型。
* `-f`：显示函数定义。
* `-F`：声明函数名为函数名称，并且不进行函数体定义。
* `-i`：声明变量为整数类型。
* `-r`：声明只读变量，不可被修改。
* `-t`：声明变量为带有 `trace` 属性的变量。
* `-x`：声明变量为环境变量。
* `-p`：显示所有声明过的变量和函数的定义。
* `-A`：声明关联数组（字典）。

示例：
```sh
# -i
declare -i num=10      # 声明整数变量 num，并赋值为 10
num=3.2               # num为3
num="abc"             # num为0

declare -r readonlyvar="readonly"   # 声明只读变量
declare -a myarray     # 声明数组变量 myarray
declare -x MYVAR="value"   # 声明环境变量
```

## 脚本参数

1. 使用 `getopts` 命令来解析命令行参数。

示例：
```sh
#!/bin/bash

# 使用getopts解析命令行参数
while getopts 'p:a:j:m:z:cdnhy' option
do
    case "$option" in
        p)
            echo "选项 -p 被指定，参数值为 $OPTARG"
            ;;
        a)
            echo "选项 -a 被指定，参数值为 $OPTARG"
            ;;
        j)
            echo "选项 -j 被指定，参数值为 $OPTARG"
            ;;
        m)
            echo "选项 -m 被指定，参数值为 $OPTARG"
            ;;
        z)
            echo "选项 -z 被指定，参数值为 $OPTARG"
            ;;
        c|d|n|h|y)
            echo "选项 -$OPTARG 被指定"
            ;;
        \?)
            echo "未知选项: -$OPTARG"
            ;;
    esac
done
```

在 `Shell` 脚本中，`:` 是一个特殊的字符，用于表示选项后面需要接一个参数。

2. 使用 `$*`，`$*` 表示所有位置参数（命令行参数）作为一个单词（以空格分隔）被扩展，并赋值给变量。

示例：
```sh
# example.sh
for param in $*
do
echo "参数: $param"
done
```
```sh
./example.sh apple banana cherry
输出：
参数: apple
参数: banana
参数: cherry
```

* 使用特殊符号 `$1, $2, ...`；
