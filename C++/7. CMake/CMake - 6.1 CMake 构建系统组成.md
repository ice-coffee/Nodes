[toc]

`CMake` 构建系统主要由五种逻辑目标（target）组成，每个目标对应一个可执行文件或库，或是一个包含自定义命令的自定义目标。

### 可执行文件
可执行文件包含项目入口，例如 `main`。
通过 `add_executable()` 命令定义一个可执行目标。

**命令结构：**

```cmake
add_executable (<name> [option] [source1] [source2 ...])
```

**参数说明：**

* `name`：可执行目标的名称；
* `option` 用于设置 `target` 属性，包括 `WIN32（WIN32_EXECUTABLE）`、`MACOSX_BUNDLE`、`EXCLUDE_FROM_ALL`，可多选；
* `source1 source2 ...`：源文件列表；

**示例：**

```cmake
add_executable(mytool mytool.cpp)
```

编译完成后会在目标目录生成 `mytool` 可执行文件。

### 静态库
在 `CMake` 中通过 `add_library` 构建静态库、共享库、模块库、对象库（3.12及以上版本）
、接口库（3.15及以上版本）或者用于定义导入的外部库。

**命令结构：**

```cmake
add_library(<name> [type] [EXCLUDE_FROM_ALL] <source1> <source2> ...)
```

**`参数说明：`**

* `<name>` 库目标的名称，必须是项目全局唯一的；
* `type`：指定库的类型；
    * `STATIC`：静态库；
    * `SHARED`：动态库，或者叫共享库；
    * `MODULE`：模块库；
    * `OBJECT`：对象库；
    * `INTERFACE`：接口库；
* `EXCLUDE_FROM_ALL`：可选项，表示将此库排除在构建目标之外，即不会在默认的构建目标中包含此库。
* `<source1> <source2> ...`：要构建库的源文件列表。

**示例：**

```cmake
add_library(archive STATIC archive.cpp zip.cpp lzma.cpp)
```

编译流程如下：

1. 编译每个源文件 `*.cpp` --> 生成目标文件 `*.o`。
2. 链接这些 `*.o` 文件 → 打包成一个归档文件 `libarchive.a`。

**静态库** 可以看做是目标文件的归档（压缩包）。
**可执行文件**、**共享库** 和 **模块库** 都可以链接到静态库作为依赖项。

### 共享库

**示例：**

```cmake
add_library(archive SHARED archive.cpp zip.cpp lzma.cpp)
```

生成 `libarchive.so` 二进制文件。

### 模块库

**示例：**

```cmake
add_library(archivePlugin MODULE 7z.cpp)
```

生成 `libarchivePlugin.so` 二进制文件。
与共享库不同的是模块库不能被其他二进制文件作为依赖项链接——不要在 `target_link_libraries()` 命令的右侧命名它们。相反，模块库是应用程序可以在运行时按需动态加载的插件，例如通过 `dlopen`。

### 对象库

**示例：**

```cmake
add_library(archiveObjs OBJECT archive.cpp zip.cpp lzma.cpp)
```

**对象库**在 **CMake** 中主要用于将一组源文件编译成目标文件，以便在其他可执行文件或库中重用。这种方式避免了多次编译同一份源文件，减少了构建时间。

**编译对象库时并不生成实际的文件**。可以将其看成不进行最后归档的静态库。

`对象库` 主要有两种方式使用：
1. 创建其它库或可执行文件时使用**生成器表达式**语法 `$<TARGET_OBJECTS:name>` 将对象文件指定为源输入：

```cmake
add_library(archiveExtras STATIC $<TARGET_OBJECTS:archiveObjs> extras.cpp)

add_executable(test_exe $<TARGET_OBJECTS:archiveObjs> test.cpp)
```

2. 将对象库指定为其他目标的链接依赖项：

```cmake
add_library(archiveExtras STATIC extras.cpp)
target_link_libraries(archiveExtras PUBLIC archiveObjs)

add_executable(test_exe test.cpp)
target_link_libraries(test_exe archiveObjs)
```

### 接口库

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

### 导入外部库

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

使用 `IMPORTED` 关键字生成的 `target` 可以像使用 `SHARED/STATIC` 关键字生成的一样使用，但是需要指定二进制文件和头文件的位置。

* `IMPORTED_LOCATION`：指定二进制文件的位置；
* `INTERFACE_INCLUDE_DIRECTORIES`：指定头文件位置；
