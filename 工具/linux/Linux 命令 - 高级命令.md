### xargs
**简介：**
`xargs` 常用于组合命令，它常和管道符（|）一同使用，用于将上一个命令的输出作为参数传给另一个命令。

**`语法：`**
```sh
some_command | xargs target_command
```

**`示例：`**
1. 查找对外接口：
```sh
# 查找 java 文件并过滤前缀为 pulic 的内容，将结果输出到目标文件
find * -name *.java | xargs cat | grep -aiE "public*" > ~/Download/out.txt
```

2. 删除文件
```bash
# 查找所有 .tmp 文件并删除
find . -name "*.tmp" | xargs rm

# 相当于：rm ./file1.tmp ./file2.tmp ./file3.tmp
```
这里：
- `find` 输出文件名（每行一个）
- `xargs` 将这些文件名作为参数传给 `rm`


3. 处理大量文件
```bash
# 当文件太多时，xargs 可以分批处理
find /var/log -name "*.log" | xargs -n 5 grep "critical"

# -n 5 表示每次只给 grep 传递5个文件名参数
```

### chmod
**简介：**
`chmod`（change mode）用于改变文件或目录的权限。它是 Linux/Unix 系统中最重要的命令之一。

**格式：**
```bash
chmod [选项] 权限模式 文件或目录
```

**权限基础：**

1. 三类用户
- **u**：文件所有者（user）
- **g**：文件所属组（group）  
- **o**：其他用户（others）
- **a**：所有用户（all）

2. 三种权限
- **r**：读权限（read）- 数字表示为 4
- **w**：写权限（write）- 数字表示为 2
- **x**：执行权限（execute）- 数字表示为 1

**权限设置：**

1. 符号模式（相对模式）

语法：`[用户类别][操作符][权限]`
操作符：
- `+`：添加权限
- `-`：移除权限
- `=`：设置精确权限

```bash
# 给所有者添加执行权限
chmod u+x script.sh

# 同时设置多种权限
chmod u+x,go-w script.sh
```

2. 数字模式（绝对模式）

语法：3位或4位八进制数
计算方式：将权限对应的数字相加
- 读(r) = 4
- 写(w) = 2  
- 执行(x) = 1

```bash
# 基本权限
chmod 777 open.file   # rwxrwxrwx (谨慎使用！)
```

**查看当前权限：**

使用 `ls -l` 查看文件权限：
```bash
$ ls -l file.txt
-rw-r--r-- 1 user group 0 Jan 1 12:00 file.txt
# ↑权限位
```

第一个字符：
- `-`：普通文件
- `d`：目录
- `l`：符号链接

后面9个字符分三组，分别对应：所有者(u)、组(g)、其他用户(o)的权限。

**一张图总结：**
![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/rwx-standard-unix-permission-bits.png)
