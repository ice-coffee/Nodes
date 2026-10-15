[toc]

### 字符串变量
定义字符串变量可以使用单引号和双引号，区别在于：

* 双引号里可以有变量，单引号不可以，它会原样输出；
* 双引号里可以出现转义字符，单引号不可以；

#### 字符串长度
> 语法：`${#变量名}`

```sh
str="abcd"
echo ${#str} #输出：4
```

#### 字符串拼接

```sh
#!/bin/bash

str="shell"
# 直接使用字符串变量
str="hello "$str" !"
echo $str
str="hello ${str} !"
echo $str
str="hello $str !"
echo $str

# 使用拼接字符
str="Hello"
str+=" shell !" 
echo "$str"
```

> 总结：在 `Shell` 脚本中，使用 `$` 调用变量时，只要 `Shell` 能正确识别变量名，通常就能成功解析和输出其值

#### 字符串提取
> 语法：`${变量名:开始下标:结束下标}`
```sh
str="shell"
echo ${str:1:4} #输出：hell
```

#### 字符串替换
在 `Shell` 脚本中，可以通过字符串替换语法对变量的内容进行操作。以下是常用的字符串替换方法，主要以 `bash` 为例：

* `${变量名/匹配模式/替换内容}`：替换第一次匹配的字符串
* `${变量名//匹配模式/替换内容}`：替换所有匹配的字符串
* `${变量名#匹配模式}`：删除匹配的最短前缀
* `${变量名##匹配模式}`：删除匹配的最长前缀
* `${变量名%匹配模式}`：删除匹配的最短后缀
* `${变量名%%匹配模式}`：删除匹配的最长后缀

> `匹配模式` 都支持正则表达式。

```sh
# 替换第一次匹配的字符串
str="hello world"
result=${str/hello/Hi}
echo $result  # 输出：Hi world

# 替换所有匹配的字符串
str="hello world, hello bash"
result=${str//hello/Hi}
echo $result  # 输出：Hi world, Hi bash

# 删除匹配的最短前缀
str="hello/world/example"
echo "${str#*/}"  # 输出：world/example

# 删除匹配的最长前缀
str="hello/world/example"
echo "${str##*/}"  # 输出：example


# 删除匹配的最短后缀
str="hello/world/bash"
result=${str%/*}
echo $result  # 输出：hello/world

# 删除匹配的最长后缀
str="hello/world/bash"
result=${str%%/*}
echo $result  # 输出：hello
```
