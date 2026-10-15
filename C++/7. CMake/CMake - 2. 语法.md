[toc]

## 参考
[Cmake 命令](https://cmake.org/cmake/help/latest/)
[Cmake 命令 - 中文版](https://cmake.com.cn/cmake/help/latest/index.html)
[Cmake 构建](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html)

## 变量
### set
通过 `set` 命令可以设置普通变量、缓存变量和环境变量。

这里重点说明普通变量和缓存变量的区别：
作用范围：

* 普通变量：仅作用在变量定义的作用域，不会超过 `CMakeList.txt` 文件范围。
* 缓存变量：在整个项目的构建过程中使用，包括配置、编译和安装阶段。

设置方式：

* 普通变量：在 `CMakeList.txt` 文件中通过 `set()` 命令设置。
* 缓存变量：除通过 `set()` 命令设置外，还可以在 `cmake` 命令中通过 `-D<variable>=<value>` 的方式设置。

> 当存在同名普通变量和缓存变量时，优先取一般变量的值，一般变量中没有再取缓存变量的值。

#### 普通变量
普通变量可以多次设置，变量值以最近一次设置的值为准。

**`格式：`**

```cmake
# 定义
set(<variable> <value>... [PARENT_SCOPE])
# 使用
${<variable>}
```
* `variable`: 变量名
* `value`: 变量值列表
* `[PARENT_SCOPE]` 字段表示该 `set` 命令作用于父作用域，也就是设置或修改父作用域中的变量，对当前作用域无影响。

**`示例：`**

```cmake
# Parent CMakeLists.txt
set(MY_VAR "Parent Value")
add_subdirectory(subdir)
message("Parent Scope MY_VAR: ${MY_VAR}")  # 输出 "Parent Scope MY_VAR: Subdirectory Value"

# subdir/CMakeLists.txt
set(MY_VAR "Subdirectory Value" PARENT_SCOPE)
message("Subdir Scope MY_VAR: ${MY_VAR}")  # 输出 "Subdir Scope MY_VAR: " (空的，因为它没有在当前作用域创建)
```

在 `subdir/CMakeLists.txt` 中，`MY_VAR` 仅影响父作用域，并不会在当前作用域定义。因此，输出为空。

#### 缓存变量

**`格式：`**

```cmake
# 定义
set(<variable> <value>... CACHE <type> <docstring> [FORCE])
# 使用
${<variable>}
```
* `variable`: 变量名
* `value`: 变量值列表
* `CACHE`: 缓存变量
* `type`: 缓存变量类型
* `docstring`: 变量概述
* `[FORCE]`: 修改缓存变量时使用，或定义缓存变量时不清楚是否已经定义且新值可以覆盖旧值时使用

**`变量类型：`**

* `BOOL`: 布尔值 `OFF/ON`。
* `FILEPATH`: 文件地址，如果变量值为相对路径那么 `set` 命令将把该路径视为相对于当前工作目录的路径，并将其转换为绝对路径；
* `PATH`: 文件目录地址，同 `FILEPATH`；
* `STRING`: 字符串；
* `INTERNAL`: 内部变量，不在 `cmake-gui` 展示，也就是用户无法通过 `cmake-gui` 修改内部变量；

缓存变量是在第一次运行 `cmake` 时，被写入到缓存文件中的变量(即编译目录下的 `CMakeCache.txt` 文件)。

当再次运行 `cmake` 时，这些变量会直接使用缓存值，缓存变量可以在 `cmake` 的整个构建过程中生效。

缓存变量一旦定义，通常不会直接被 `set` 命令重新修改，除非明确指定。修改缓存变量可以通过如下三种方式：

* 在 `set` 命令中添加 `[FORCE]` 选项；
* 通过 `cmake-gui` 或 `ccmake` 修改；
* 删除 `CMakeCache.txt` 文件后重新运行 `cmake` 命令；

##### 通过 camke 命令行参数设置缓存变量
设置缓存变量还可以在调用 `cmake` 命令时通过命令行参数来设置，格式如下：

```
cmake -D<var>=<value>
```

通过这种方式设置缓存变量时，没有 `type` 类型。这时再调用 `set` 命令时会为缓存变量添加变量类型。

#### 环境变量

**`格式：`**

```cmake
# 定义
set(ENV{<variable>} [<value>])
# 使用
$ENV{<variable>}
```

**`示例：`**

```cmake
set(ENV{MY_VARIABLE} "Hello World")
set(MY_VAR $ENV{MY_VARIABLE})
message("MY_VAR: ${MY_VAR}")
```

环境变量的作用：

* 读取环境变量：在 `CMake` 编译过程中根据外部环境变量执行不同的逻辑；例如交叉编译。

* 设置环境变量：为外部程序或脚本传递环境变量，在  `add_custom_command()`、`execute_process()` 中使用环境变量。

```sh
set(ENV{MY_PATH} "/opt/custom/path")

add_custom_command(
  OUTPUT dummy_output.txt
  COMMAND bash -c "echo Env Path: \$MY_PATH > dummy_output.txt"
  COMMENT "Generating dummy_output.txt using custom env var"
)
```

#### 消除变量
消除变量的方式有两种：

* 使用 `unset(<variable>)` 命令；
* 使用 `set(<variable> "")` 命令；

### list
**`创建：`**

使用 `set()` 命令定义变量时可以设置多个值，由 `;` 或空格作为间隔，此时变量被识别为列表变量。

**`示例：`**

```cmake
# 创建列表变量 list_test，值为 a，b，c，d
set(list_test a;b;c;d)
```

> 注意：单个元素的列表变量和普通变量没什么不同。也就是说普通变量也可以使用 `APPEND` 添加元素变成列表变量。

#### 列表变量操作

列表操作分为 `读取`、`查找`、`修改`、`排序`。

```cmake
set(jni_source dir1;dir2;dir3;dir4;dir5)
```

[Cmake命令之list介绍](https://www.jianshu.com/p/89fb01752d6f)

##### 读取

* `list(LENGTH <list> <out-var>)`：读取列表长度；
* `list(GET <list> <element index> [<index> ...] <out-var>)`：根据索引查询元素，可指定多个索引；
* `list(JOIN <list> <glue> <out-var>)`：使用指定连接符将列表中的元素连接成一个字符串；
* `list(SUBLIST <list> <begin> <length> <out-var>)`：获取子列表；

**`LENGTH：`**
读取列表长度。

示例：
```cmake
list(LENGTH jni_source jni_source_length)
# 输出3
message(${jni_source_length})
```

**`GET：`**
读取列表中指定索引的的元素，可以指定多个索引。

示例：
```cmake
# 创建列表变量 jni_source_sub 并存放 jni_source 中的第 1 2 3 项
list(GET jni_source 1 2 3 jni_source_sub)
```

##### 查找

* `list(FIND <list> <value> <output variable>)`：返回列表中指定元素的索引，如果没有找到则返回 `-1`。

##### 修改
* `list(APPEND <list> [<element>...])`：向列表添加元素
* `list(FILTER <list> {INCLUDE | EXCLUDE} REGEX <regex>)`：
* `list(INSERT <list> <index> [<element>...])`：在指定位置将元素（一个或多个）插入到列表中；
* `list(POP_BACK <list> [<out-var>...])`：将列表中最后元素移除；
* `list(POP_FRONT <list> [<out-var>...])`：将列表中第一个元素移除
* `list(PREPEND <list> [<element>...])`：将元素插入到列表的0索引位置
* `list(REMOVE_ITEM <list> <value>...)`：移除指定元素
* `list(REMOVE_AT <list> <index>...)`：根据索引移除元素
* `list(REMOVE_DUPLICATES <list>)`：用于移除列表中的重复元素
* `list(TRANSFORM <list> <ACTION> [...])`：

##### 排序
先不加~

### option
用于设置布尔变量。

**`格式：`**

```cmake
option(<variable> "<help_text>" [value])
```

* `<variable>`：变量名
* `"<help_text>"`：描述
* `[value]`：`OFF / ON`

当已存在同名的普通、缓存变量时 `option` 命令无效。

### String（缺）
`CMake` 提供的 `String` 可以用于以下操作：

* **字符串替换**
* **字符串截取**
* **`HASH` 算法（MD5、SH1、...）**
* **字符串转换（十六进制、时间格式化）**

## 流程控制

### if
格式：
```cmake
if(<condition>)
  <commands>
elseif(<condition>) # optional block, can be repeated
  <commands>
else()              # optional block
  <commands>
endif()
```
`condition` 条件表达式可选的值有:常量、变量、字符串和运算符；

#### 常量

| 逻辑值 | 常量值 |
| --- | --- |
| true | 1、ON、YES、TRUE、Y、非0数字 |
| false | 0、OFF、NO、FALSE、N、IGNORE、NOTFOUNT、空字符串、-NOTFOUND结尾字符串 |

#### 变量

变量的值不是上述定义的 `false` 常量时其逻辑值为 `true`，否则逻辑值为 `false`。

注意：
* 宏参数不是变量；
* 环境变量不可作为条件；
* 使用变量时，不要用${}表示变量，直接使用变量名即可；

#### 字符串
当条件表达式是字符串时，除如下情况都为 `false`：
* 字符串内容为上述定义的`true`常量；
* 策略 CMP0054 未设置为 NEW，并且字符串的值恰好是受 CMP0054 行为影响的变量名称。

#### 运算符
逻辑运算：
```cmake
if(NOT <condition>) # 非运算
if(<cond1> AND <cond2>) # 与运算
if(<cond1> OR <cond2>) #或运算
if((condition) AND (condition OR (condition))) # 有括号时，先计算括号的逻辑值
```

#### 存在性判断

* `if(COMMAND <command-name>)`：给定参数是可调用的命令、宏、函数时为 `true`；
* `if(POLICY policy-id)`：给定的策略存在时为 `true`；
* `if(TARGET target-name)`：给定的目标参数是通过`add_executable()、add_library() 或 add_custom_target()` 命令创建并存在时为 `true`；
* `if(TEST test-name)`：给定参数是通过 `add_test()` 创建并存在时为 `true`；
* `if(DEFINED <name>|CACHE{<name>}|ENV{<name>})`：如果变量、缓存、环境变量存在（其取值无关）时为 `true`；
* `if(<variable|string> IN_LIST <variable>)`：如果<variable|string>存在于列表变量<variable>中

示例：

```cmake
set(MY_LIST apple banana cherry)

if(banana IN_LIST MY_LIST)
    message("Item '${ITEM}' is in the list!")
else()
    message("Item '${ITEM}' is not in the list!")
endif()
```

文件运算：
```cmake
# 以下路径参数可以为相对路径或绝对路径，相对是指相对于当前执行cmake的路径。
if(EXISTS path-to-file-or-directory) # true 如果文件/目录存在，当参数是连接时表示连接指向的实体存在。
if(file1 IS_NEWER_THAN file2) # true file1比file2新
if(IS_DIRECTORY path-to-directory) # true 如果参数是目录
if(IS_SYMLINK file-name)# true 如果参数是一个链接
if(IS_ABSOLUTE path) # true 如果参数是绝对路径
```

#### 正则匹配
```cmake
if(<variable|string> MATCHES regex)
```

#### 数字比较

```cmake
if(<variable|string> LESS <variable|string>)       # <
if(<variable|string> GREATER <variable|string>)     # >
if(<variable|string> EQUAL <variable|string>)      # ==
if(<variable|string> LESS_EQUAL <variable|string>)   # <=
if(<variable|string> GREATER_EQUAL <variable|string>) # >=
```

等......。

### while
**`格式：`**

```cmake
while(<condition>)
  <commands>
endwhile()
```
`while` 命令中条件表达式的取值和 `if` 命令相同。`break()` 和 `continue()` 命令可用于退出当前循环和跳出本次循环。 

### foreach
**`格式：`**

```cmake
foreach(<loop_var> <items>)
  <commands>
endforeach()
```

* `<loop_var>`：当前元素；
* `<items>`：可遍历变量；

## 函数

`CMake` 中有两种方式可以实现函数效果 `macro` 和 `function`。

### macro

**`语法：`**

```cmake
macro(<name> [<arg1> <arg2> ...])
  # 这里是宏的主体，可以包括多个 CMake 命令
endmacro()
```

**`示例：`**

```cmake
# 定义一个宏
macro(print_hello name)
  message(STATUS "Hello, ${name}!")
endmacro()

# 调用宏输出：Hello, CMake!
print_hello("CMake")
```

> `macro` 和 `function` 所声明的函数调用时都不区分大小写，但推荐使用全小写。

### function

`function` 和 `macro` 语法和使用基本一致。

**`语法：`**

```cmake
function(<name> [<arg1> ...])
  <commands>
endfunction()
```

### macro vs function

`macro` 和 `function` 在 `CMake` 中都用于封装代码块，但它们的行为有显著区别。

* 宏是字符串替换，在调用点插入宏体的代码，而函数有局部作用域，并且是通过函数调用栈执行的。

```cmake
macro(increment_value var)
    message(STATUS "my_var before macro: ${my_var}")
    set(my_var 6)
endmacro()

# 定义一个变量
set(my_var 5)

# 调用宏并传递变量
increment_value(my_var)

# 输出修改后的值
message(STATUS "my_var after macro: ${my_var}")
```

* 宏的控制流与函数不同，`return()` 在宏中不会终止执行，而是跳过宏体后的代码。由于宏没有局部作用域，修改宏参数会影响调用点的变量。

```cmake
macro(test_macro)
  message(STATUS "Before return")
  return()
  message(STATUS "This will not be printed")
endmacro()

test_macro()
message(STATUS "out macro")

# 输出
Before return
```

* 避免在宏中使用 `return()`，并且尽量避免修改外部传入的参数，以减少潜在的作用域和命名冲突问题。

### 特殊变量
在 `CMake` 中，`macro` 和 `function` 都支持一些特殊的变量，这些变量可以用于处理不定数量的参数。

* **`${ARGC}`**：表示传递给宏的参数数量。
* **`${ARGV}`**：一个列表，包含传递给宏的所有参数。
* **`${ARGN}`**：表示从最后一个预期参数之后的所有参数。
* **`${ARGV0}, ${ARGV1}, ${ARGV2},...`**：它们是 `ARGV` 列表中的各个元素，`ARGV0` 是第一个参数，`ARGV1` 是第二个参数，依此类推。

**`示例：`**

```cmake
macro(print_args)
  message(STATUS "Number of arguments: ${ARGC}")
  
  # 打印所有的参数
  message(STATUS "All arguments: ${ARGV}")

  # 打印从第二个参数开始的所有参数
  message(STATUS "Arguments from second: ${ARGN}")
endmacro()

# 调用宏并传递多个参数
print_args("First Argument" "Second Argument" "Third Argument")
```

## 其它

### block
`block` 命令用于作用域控制。

### 输出编译信息
```cmake
message([<mode>] "message text" ...)
```
`mode` 主要类型：
* `(无)`：重要消息；
* `STATUS`：非重要消息；
* `WARNING`：CMake 警告, 会继续执行；
* `AUTHOR_WARNING`：CMake 警告 (dev), 会继续执行；
* `SEND_ERROR`：CMake 错误, 继续执行，但是会跳过生成的步骤；
* `FATAL_ERROR`：CMake 错误, 终止所有处理过程；


## 交叉编译

### 常见环境变量

**编译/构建相关变量：**

| 变量名               | 描述                             |
| ----------------- | ------------------------------ |
| `CC`              | 指定 C 编译器（如 `gcc`, `clang`）     |
| `CXX`             | 指定 C++ 编译器（如 `g++`, `clang++`） |
| `CFLAGS`          | 给 C 编译器的附加选项（如 `-O2 -Wall`）    |
| `CXXFLAGS`        | 给 C++ 编译器的附加选项                 |
| `LDFLAGS`         | 链接器参数（如 `-L/some/path -lm`）    |
| `LD_LIBRARY_PATH` | 运行时动态库的搜索路径（Linux）             |
| `LIBRARY_PATH`    | 编译时链接器查找 `.a` 静态库的路径           |
| `PKG_CONFIG_PATH` | `pkg-config` 查找 `.pc` 文件的路径    |


**CMake/工具链相关变量：**

| 变量名                    | 描述                        |
| ---------------------- | ------------------------- |
| `CMAKE_PREFIX_PATH`    | `find_package()` 搜索包的前缀路径 |
| `CMAKE_MODULE_PATH`    | 自定义模块（FindXXX.cmake）的路径   |
| `CMAKE_TOOLCHAIN_FILE` | 用于交叉编译的工具链文件路径            |
| `MAKEFLAGS`            | 传递给 `make` 命令的参数（如 `-j8`） |
