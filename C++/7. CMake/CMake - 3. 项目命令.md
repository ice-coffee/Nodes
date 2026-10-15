[TOC]

### 参考
[cmake-commands](https://cmake.org/cmake/help/latest/manual/cmake-commands.7.html)

### add_executable
操作可执行文件。这里的可执行文件操作分为三类：

* 生成可执行文件

```cmake
add_executable (<name> [option]
      [source1] [source2 ...])
```

* `name`：可执行目标的名称；
* `option` 用于设置 `target` 属性，包括 `WIN32（WIN32_EXECUTABLE）`、`MACOSX_BUNDLE`、`EXCLUDE_FROM_ALL`，可多选；
* `source1 source2 ...`：源文件列表；

* 导入可执行文件

```cmake
add_executable (<name> IMPORTED [GLOBAL])
```

* 为可执行文件设置别名

```cmake
add_executable (<name> ALIAS <target>)
```

[Cmake命令之add_executable介绍](https://www.jianshu.com/p/19765d4932a4)

### add_library
`add_library` 在 `CMake` 中用于构建静态库、共享库、模块库、生成对象库（3.12及以上版本）
、生成接口库（3.15及以上版本）或者用于定义导入的外部库。

**`格式：`**

```cmake
add_library(<name> [type] [EXCLUDE_FROM_ALL] <source1> <source2> ...)
```

**`参数详解：`**

* `<name>` 库目标的名称，必须是项目全局唯一的；
* `type`：指定库的类型；
* `EXCLUDE_FROM_ALL`：可选项，表示将此库排除在构建目标之外，即不会在默认的构建目标中包含此库。
* `<source1> <source2> ...`：要构建库的源文件列表。

**`库类型：`**

* `STATIC`：静态库；
* `SHARED`：动态库、共享库；
* `MODULE`：模块库；
* `OBJECT`：对象库；
* `INTERFACE`：接口库；

#### 对象库
对象库（OBJECT library）在 `CMake` 中主要用于将一组源文件编译成目标文件，以便在其他 `target`（可执行文件或库）中重用。这种方式避免了多次编译同一份源文件，减少了构建时间。

编译对象库时并不生成实际的文件。其它 `target` 引用对象库时使用表达式：

> `$<TARGET_OBJECTS:objlibname>`

**`示例：`**
```cmake
add_library(my_object_lib OBJECT file1.cpp file2.cpp)

add_library(my_static_lib STATIC $<TARGET_OBJECTS:my_object_lib> ...)
```

#### 接口库

**`示例：`**

```cmake
add_library(my_interface_lib INTERFACE)
```

接口库是一种特殊类型的库，它不会生成物理的目标文件（如静态库或共享库），也不包含源文件。它的主要作用是为其他目标提供编译选项、包含目录、编译定义等属性，而不进行编译。

接口库特别适合用于抽象和共享库之间的配置，使得多个目标可以共享相同的编译设置或依赖项。

##### 接口库的创建与使用
1. 创建接口库
使用 `add_library` 命令，并指定 INTERFACE 关键字来创建接口库：

```cmake
add_library(my_interface_lib INTERFACE)
```

这个命令定义了一个名为 `my_interface_lib` 的接口库，它没有任何源文件，也不会生成物理库文件。

2. 为接口库添加属性
通过 `target_include_directories`, `target_compile_definitions`, `target_link_libraries` 等命令，可以为接口库添加编译选项、定义、包含路径等。这些属性会传递给链接了这个接口库的其他目标。

```cmake
# 添加公共的包含路径
target_include_directories(my_interface_lib INTERFACE ${CMAKE_SOURCE_DIR}/include)

# 添加公共的编译定义
target_compile_definitions(my_interface_lib INTERFACE USE_MY_INTERFACE_LIB)

# 链接其他库作为依赖
target_link_libraries(my_interface_lib INTERFACE some_other_lib)
```

3. 链接接口库到其他目标
当其他目标链接到接口库时，它们会自动继承接口库的编译选项、包含路径和编译定义。

```cmake
add_executable(my_executable main.cpp)

# 链接接口库到可执行文件
target_link_libraries(my_executable PRIVATE my_interface_lib)
```

在这个示例中，`my_executable` 会继承 `my_interface_lib` 的所有属性，比如包含目录和编译定义。

##### 接口库的常见使用场景
**1. 共享公共编译选项**
接口库可以在多个目标之间共享公共的编译选项、包含目录或编译定义，而不需要实际生成库文件。

**2. 头文件库**
如果库只是一个头文件库（即不包含任何源文件，所有逻辑都在头文件中，例如模板库），接口库是理想的方式来管理和组织这些头文件库的依赖。

**3. 跨平台配置**
在需要为不同平台设置不同编译选项时，接口库可以定义特定平台的配置，并在其他目标中应用这些配置。

**4. 模块化项目结构**
接口库可以帮助将项目配置模块化，让每个模块的依赖、编译选项和包含路径集中在一个地方，简化管理。

#### 导入外部库

使用 `IMPORTED` 关键字用以导入已编译好的库或可执行文件非常常用，它们不需要 `CMake` 重新编译和生成。

**`示例：`**

```cmake
add_library(foo STATIC IMPORTED)   # 或 SHARED
set_target_properties(foo PROPERTIES
    IMPORTED_LOCATION "/path/to/libfoo.a"
    INTERFACE_INCLUDE_DIRECTORIES "/path/to/include"
)

add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE foo)
```

使用 `IMPORTED` 关键字生成的 `target` 可以像使用 `SHARED/STATIC` 关键字生成的一样使用，但是需要使用 `IMPORTED_LOCATION` 属性指定目标库或可执行文件的位置。

### add_subdirectory
[Cmake命令之add_subdirectory介绍](https://www.jianshu.com/p/07acea4e86a3)

添加一个子目录并构建该子目录。

**`格式：`**

```cmake
add_subdirectory (source_dir [binary_dir] [EXCLUDE_FROM_ALL])
```

* **`source_dir`**：该参数指定一个子目录，子目录下应该包含 `CMakeLists.txt` 文件和代码文件。子目录可以是相对路径也可以是绝对路径，如果是相对路径，则是相对当前目录的一个相对路径。
* **`binary_dir`**：该参数指定一个目录，用于存放输出文件。可以是相对路径也可以是绝对路径，如果是相对路径，则是相对当前输出目录的一个相对路径。如果该参数没有指定，则默认的输出目录使用 `source_dir`。
* **`EXCLUDE_FROM_ALL`**：当指定了该参数，则子目录下的目标不会被父目录下的目标文件包含进去，父目录的 `CMakeLists.txt` 不会构建子目录的目标文件，必须在子目录下显式去构建。例外情况：当父目录的目标依赖于子目录的目标，则子目录的目标仍然会被构建出来以满足依赖关系（例如使用了 `target_link_libraries`）。

### add_definitions
用于向编译器添加预处理器定义。

**`格式：`**

```cmake
add_definitions(-D<macro>)
```

**`示例：`**

添加预定义常量 `_OE_LINUX`：
```cmake
add_definitions(-D_OE_LINUX)
```

等同于在执行 `cmake` 命令时的 `-D<var>[:<type>]=<value>` 命令。

```c++
#ifndef _OE_LINUX
using namespace baidu_passport;
#endif
```

> **注意**： `add_definitions` 命令会将预处理器定义应用于整个项目，因此会影响到所有的源文件。如果只想对特定的目标或源文件添加预处理器定义，可以使用 `target_compile_definitions` 命令（对目标）或 `add_compile_definitions` 命令（对源文件）来实现。

### aux_source_directory
创建一个列表变量并将指定目录中的所有源文件添加到列表中，用于创建 `target` 时方便导入源文件。

**`格式：`**

```cmake
aux_source_directory(<dir> <variable>)
```

* `<dir>`：指定目录
* `<variable>`：列表变量

> **`注意`**：尽管 `aux_source_directory` 看起来很方便，但在现代 `CMake` 项目中不推荐使用它。原因是它不够灵活，且可能会引入不必要的复杂性和错误。手动列出源文件（或通过工具自动生成 `CMake` 配置文件）更加可控且易于维护。

### target_link_libraries、link_libraries
将指定的库文件（静态库、动态库等）或其他目标与当前目标进行链接，使得当前目标可以调用被链接库中定义的函数和符号。

具体包括：

* **`链接库文件`**：将指定的库文件与当前 `target` 进行链接，使得当前 `target` 可以调用被链接库中定义的函数和符号。
* **`链接其他目标`**：将其他目标与当前目标进行链接，使得当前目标可以调用其他目标中定义的函数和符号。
* **`传递依赖关系`**：如果被链接的库文件或其他目标依赖于其他库文件或目标，那么这些依赖关系也会被传递到当前目标中。

**`格式：`**

```cmake
target_link_libraries(<target>
                      <PRIVATE|PUBLIC|INTERFACE> <item>...
                     [<PRIVATE|PUBLIC|INTERFACE> <item>...]...)
```

可见性修饰符：

* `PRIVATE`：对自身可见，对依赖当前 `target` 的目标可不见。
* `INTERFACE`：对自身不可见，对依赖当前 `target` 的目标可见。
* `PUBLIC`：对自身和依赖当前 `target` 的目标都可见。

**`link_libraries：`**

`target_link_libraries` 和 `link_libraries` 都用于设置库链接，不同的是它们的作用范围：

* `link_libraries` 用于全局设置链接库，简单易用，但可能导致命名冲突和路径污染，适合小型项目或共享库较少的情况。
* `target_link_libraries` 是推荐的现代用法，允许对每个目标进行细粒度控制，提供了更好的模块化和维护性，适合大型项目和复杂的依赖关系管理。

在大多数情况下，使用 `target_link_libraries` 是更好的选择。

其它还有 `target_link_directories - link_directories`、`target_include_directories - include_directories` 等，区别都在于作用范围不同。


### target_link_directories、link_directories

### target_include_directories、include_directories
`target_include_directories` 是 `CMake` 中用于为指定目标（`target`）添加头文件搜索路径的命令。它告诉编译器在编译目标时从哪里查找头文件。

**`格式：`**

```cmake
target_include_directories(<target> [SYSTEM] [AFTER|BEFORE]
  <INTERFACE|PUBLIC|PRIVATE> [items1...]
  [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
```

* `<target>`：要为其添加头文件目录的目标。
* `AFTER|BEFORE`：~。
* `<INTERFACE|PUBLIC|PRIVATE>`：定义头文件路径的作用范围。
* `SYSTEM`：设置目标目录为系统级别的头文件目录，这意味着更高的搜索优先级。可以用于处理编译警告。但应该谨慎使用。

`AFTER|BEFORE`：控制包含目录的添加顺序，从而影响编译器对头文件目录的搜索顺序和优先级。`AFTER（默认）` 表示将目录添加到已有搜索路径的末尾，`BEFORE` 则添加到开头。

* 使用场景：在项目中可能会存在多个头文件具有相同名称的情况，但内容不同。通过设置 `AFTER|BEFORE` 属性，可以确保编译器首先搜索新添加的包含目录，从而解决头文件冲突问题。

> 注意：需要注意的是虽然 `AFTER|BEFORE` 属性可以帮助解决一些问题，但必须谨慎使用，避免出现意外结果和项目结构混乱的情况。

### include
`include()` 命令用于在当前的 `CMakeLists.txt` 文件中引入并执行另一个 `CMake` 文件。`CMake` 文件通常以 `.cmake` 为后缀。

`include()` 命令可以帮助分离项目中的不同逻辑模块或复用已有的 `CMake` 配置。

**`格式：`**

```cmake
include(<file|module> [OPTIONAL] [RESULT_VARIABLE <var>] [NO_POLICY_SCOPE])
```

* `<file|module>`：要加载的 `CMake` 文件名或模块名。如果是文件名，则需要提供文件的完整路径或相对路径。如果是模块名，则会在 `CMake` 模块路径下查找对应的模块文件。它们通常都以 `.cmake` 为扩展名。
* `OPTIONAL`：可选项，表示如果文件不存在，也不会报错，CMake 将继续执行后续的指令。
* `RESULT_VARIABLE <变量名>`：可选项，用于将 include 命令的执行结果保存到指定的变量中。如果指定了此选项，则当 include 命令执行完毕后，指定的变量将包含执行结果。如果文件不存在，执行结果为 `NOTFOUND`。

#### include_guard
`include_guard` 命令用于防止 `CMake` 脚本被重复加载。

### target_sources
[CMake - 使用 target_sources\(\) 提高源文件处理能力](https://blog.csdn.net/guaaaaaaa/article/details/125601766)
