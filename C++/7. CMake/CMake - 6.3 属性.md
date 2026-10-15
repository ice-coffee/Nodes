[TOC]

## 属性
在 `CMake` 构建和使用中我们已经知道通过 `target_link_libraries` 等命令可以很方便的修改某个库的相关属性，但是还有很多属性并没有专用的命令来操作，这时候 `set_property` 命令就可以派上用场了。

### set_property

用于在指定作用域设置属性。

**`格式：`**

```cmake
set_property(<GLOBAL                      |
              DIRECTORY [<dir>]           |
              TARGET    [<target1> ...]   |
              SOURCE    [<src1> ...]
                        [DIRECTORY <dirs> ...]
                        [TARGET_DIRECTORY <targets> ...] |
              INSTALL   [<file1> ...]     |
              TEST      [<test1> ...]
                        [DIRECTORY <dir>] |
              CACHE     [<entry1> ...]    >
             [APPEND] [APPEND_STRING]
             PROPERTY <name> [<value1> ...])
```

简化：

```cmake
set_property(<scope> <name> [APPEND] [APPEND_STRING] PROPERTY <property_name> [value1 [value2 ...]])
```

`set_property` 命令主要分为：

* `<scope>`：指定属性的作用范围，可以是 `GLOBAL、DIRECTORY、TARGET、SOURCE、TEST、CACHE` 等。
* `<name>`：指定要设置属性的对象名称，例如目标、文件名、测试名称等。
* `[APPEND] [APPEND_STRING]`
* `PROPERTY <property_name>`：要设置的属性名称。
* `[value1 [value2 ...]]`：属性值，可以有一个或多个。

**`作用域取值：`**
`GLOBAL`：

* 概念：全局作用域，表示属性适用于整个项目，即在项目中的所有位置都有效。
* 使用：在 `set_property()` 命令中指定 `GLOBAL` 参数即可将属性设置为全局属性。

`DIRECTORY`：

* 概念：目录作用域，表示属性适用于指定的目录以及其子目录中的所有文件和目标。
* 使用：在 `set_property()` 命令中指定 `DIRECTORY` 作用域即可将属性限定为指定目录。通常用于设置目录范围内的编译选项或预处理器定义。

`TARGET`：

* 概念：目标作用域，表示属性适用于特定的目标，如可执行文件、静态库、动态库等。
* 使用：在 `set_property()` 命令中指定 `TARGET` 作用域，并提供目标名称即可将属性设置为目标特定的属性。通常用于设置目标的编译选项、链接库等。

`SOURCE`：

* 概念：源文件作用域，表示属性适用于指定的源文件。
* 使用：在 `set_property()` 命令中指定 `SOURCE` 作用域，并提供源文件名称即可将属性设置为源文件特定的属性。通常用于设置源文件的编译选项。

`INSTALL`：

* 概念：安装作用域，表示属性适用于安装过程中的文件或目标。
* 使用：在 `install()` 命令中指定 `COMPONENT` 参数，将属性设置为安装目标的特定属性。通常用于设置安装文件的权限、安装路径等。

`TEST`：

* 概念：测试作用域，表示属性适用于测试目标，如通过 add_test() 命令定义的测试。
* 使用：在 `set_property()` 命令中指定 `TEST` 作用域，并提供测试名称即可将属性设置为测试特定的属性。通常用于设置测试的超时时间、依赖关系等。

`CACHE`：

* 概念：缓存作用域，表示属性适用于 CMake 缓存中的变量。
* 使用：在 `set_property()` 命令中指定 `CACHE` 作用域，并提供变量名称即可将属性设置为缓存变量特定的属性。通常用于设置缓存变量的描述、类型等。

**`APPEND / APPEND_STRING：`**
`APPEND` 和 `APPEND_STRING` 选项都用于向属性中追加值。它们的具体作用如下：

`APPEND`：

* 用于将一个或多个值追加到属性的值列表中。
* 如果属性不存在，则创建属性并将值添加到属性中。
* 如果属性已存在，则将值追加到属性的末尾。
* 适用于属性值为列表类型的情况。

`APPEND_STRING`：

* 用于将一个字符串追加到属性的字符串值中。
* 如果属性不存在，则创建属性并将字符串添加到属性中。
* 如果属性已存在，则将字符串追加到属性的末尾。
* 适用于属性值为字符串类型的情况。

### get_property

获取指定作用域的属性。

**`格式：`**

```cmake
get_property(<variable>
             <GLOBAL             |
              DIRECTORY [<dir>]  |
              TARGET    <target> |
              SOURCE    <source>
                        [DIRECTORY <dir> | TARGET_DIRECTORY <target>] |
              INSTALL   <file>   |
              TEST      <test>
                        [DIRECTORY <dir>] |
              CACHE     <entry>  |
              VARIABLE           >
             PROPERTY <name>
             [SET | DEFINED | BRIEF_DOCS | FULL_DOCS])
```

### 其它 property 相关命令
针对对应作用域的 `get_property` 命令：
* `get_cmake_property`
* `get_directory_property`
* `get_source_file_property`
* `get_target_property`
* `get_test_property`

## 常见属性

### target 属性

#### POSITION_INDEPENDENT_CODE

**`命令：`**
```cmake
set_property(TARGET mylib PROPERTY POSITION_INDEPENDENT_CODE ON)
```

**`g++ 命令：`**
```
g++ -c foo.cpp -fPIC -o foo.o
```

**`说明：`**
设置 `POSITION_INDEPENDENT_CODE` 属性告诉 `CMake` 生成的目标文件 (.o) 是否应当编译为 “位置无关代码”（`PIC，Position Independent Code`）。

在汇编层面上，普通的机器代码在访问全局变量或函数时，往往使用固定地址（绝对地址引用）。
但是动态库会在运行时被加载到任意内存地址（不是编译时决定的），如果代码中用了固定地址，加载后地址错位，代码就失效。

位置无关代码 (PIC) 的核心思想是：不依赖固定地址，而是通过 相对地址（相对当前指令指针）访问全局符号。

这样，动态库就可以安全地被加载到任意位置运行。

**`使用场景：`**

| 目标类型 | 默认值 | 说明 | 
| --- | --- | --- | 
| **SHARED 库** | `ON` | 动态库必须是位置无关的 |
| **MODULE 库** | `ON` | 插件库一般也需要位置无关 |
| **STATIC 库 / 可执行文件** | `OFF` | 默认不需要，除非下游要求 |

##### CMAKE_POSITION_INDEPENDENT_CODE

> 因为 `POSITION_INDEPENDENT_CODE` 是 `TARGET` 属性，所以不能通过 `set_property(GLOBAL ...)` 的方式全局设置。

但是 `CMake` 提供了一个专门的变量自动为所有支持的位置相关目标（STATIC / SHARED / MODULE library、executable）启用 `POSITION_INDEPENDENT_CODE` 属性：

```cmake
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
```

> 这行放在 **项目最顶层的 `CMakeLists.txt`** 中即可。

等价于为每个 `target` 设置 `POSITION_INDEPENDENT_CODE` 属性：

```cmake
set_property(TARGET <每个目标> PROPERTY POSITION_INDEPENDENT_CODE ON)
```

#### 扩展：其它设置 IPC 的方法
1. `cmake .. -DCMAKE_CXX_FLAGS=-fPIC`
2. `set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")`
3. `add_compile_options(-fPIC)`
4. `g++ -fPIC -c file.cpp`

这几种方法可以看做是等价的，它们效果是：给 **当前目录及所有子目录** 下的所有编译单元，**无条件地** 添加 `-fPIC` 编译选项。

它不会考虑目标类型（比如可执行文件、静态库、动态库），也不会做兼容性检查。
CMake 也不会知道你这么做的语义，只是单纯地在编译时追加标志。

**使用场景：**

* 当你清楚地知道所有代码都需要生成位置无关的对象文件（例如后续都要打包进 `.so`）；
* 或者你在编译 **第三方库** 时，只想“强制”添加某个编译标志；例如本地编译 `protobuf` 库。

**缺点：**

* 没有目标级的控制，容易污染其他模块。
* 对可执行文件等不需要 PIC 的目标也会生效（可能造成不必要的性能损耗）。
* 对 MSVC 等非 GCC/Clang 编译器不兼容。
