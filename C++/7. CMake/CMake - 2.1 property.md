[TOC]

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

针对对应作用域的 `get_property` 命令：
* `get_cmake_property`
* `get_directory_property`
* `get_source_file_property`
* `get_target_property`
* `get_test_property`
