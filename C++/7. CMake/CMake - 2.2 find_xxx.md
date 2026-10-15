[toc]

`CMake` 提供了用于查找外部文件、库、路径和程序有五个非常常用的命令：

* `find_file()`：查找文件并返回其路径；
* `find_library()`：查找库文件并返回其路径；
* `find_path()`：查找特定文件（通常是头文件）的路径，返回其所在的目录；
* `find_program()`：查找可执行程序的路径，并返回其完整路径；
* `find_package()`：和其它 `find_xxx` 不同，...；

`find_file`、`find_library`、`find_path`、`find_program` 主要用于查找文件路径、库路径、头文件路径和程序路径。它们的主要目标是定位文件。而且它们的用法和参数也都是一致的，下面会以 `find_library` 举例说明。

`find_package` 则是查找并配置整个库包或工具，涉及的内容更为复杂，可以包含版本检查、包组件的查找和配置等。

### find_library
`find_library()` 用于查找静态库或共享库文件（如 `.lib、.a、.so、.dll` 等），并返回其路径。

**`基本语法：`**

```cmake
find_library(<VAR> name [path1 path2 ...])
```

* `<VAR>`：用于存储查找结果的变量名，如果没有找到则变量赋值为 `<VAR>-NOTFOUND`。
* `name`：要查找的库名（不包括库文件扩展名），可以是多个。
* `path1 path2 ...`：指定查找的路径列表（可选）。如果不提供，`CMake` 会在默认的系统路径中查找。

示例：

```cmake
find_library(MY_LIB NAMES mylib PATHS /usr/local/lib /opt/lib)
```

这个命令将会在 `/usr/local/lib` 和 `/opt/lib` 中查找名为 `libmylib.so`、`mylib.lib`、或 `mylib.a` 的库文件，并将找到的路径存储在 `MY_LIB` 变量中。

一般来说使用 `find_xxx` 的简单语法模式就可以满足绝大部分场景，下面详细语法适当了解一下即可。

**`详细语法：`**

```cmake
find_library(
    <VAR>
    name | NAMES name1 [name2 ...] 
    [NAMES_PER_DIR]
    [HINTS [path | ENV var]... ]
    [PATHS [path | ENV var]... ]
    [REGISTRY_VIEW (64|32|64_32|32_64|HOST|TARGET|BOTH)]
    [PATH_SUFFIXES suffix1 [suffix2 ...]]
    [VALIDATOR function]
    [DOC "cache documentation string"]
    [NO_CACHE]
    [REQUIRED]
    [NO_DEFAULT_PATH]
    [NO_PACKAGE_ROOT_PATH]
    [NO_CMAKE_PATH]
    [NO_CMAKE_ENVIRONMENT_PATH]
    [NO_SYSTEM_ENVIRONMENT_PATH]
    [NO_CMAKE_SYSTEM_PATH]
    [NO_CMAKE_INSTALL_PREFIX]
    [CMAKE_FIND_ROOT_PATH_BOTH |
     ONLY_CMAKE_FIND_ROOT_PATH |
     NO_CMAKE_FIND_ROOT_PATH]
)
```

* `<VAR>`：存储库文件路径的变量名。
* `NAMES name1 [name2 ...]`：指定要查找的库名称，可以指定多个名字，CMake 会依次尝试查找这些名字。
* `NAMES_PER_DIR`：启用此选项后，`CMake` 在每个目录中查找所有指定的 NAMES。
* `HINTS`：提供额外的提示路径，优先用于搜索。
* `PATHS`：额外的搜索路径，优先级低于 `HINTS`。
* `REGISTRY_VIEW`：`Windows` 特有选项。
* `PATH_SUFFIXES`：在搜索路径末尾追加的路径后缀，用于更精确地定位库。
* `VALIDATOR`：指定用于验证找到的库是否有效的函数。
* `DOC`：为找到的路径变量提供缓存文档说明。
* `NO_CACHE`：防止在 `CMake` 缓存中存储结果。
* `REQUIRED`：如果库未找到，将导致配置错误。
* `NO_DEFAULT_PATH`：`NO_DEFAULT_PATH` 以及其后的参数都是用于控制查找路径和查找优先级的。

### find_package

> [“轻松搞定CMake”系列之find_package用法详解](https://blog.csdn.net/zhanghm1995/article/details/105466372)

`find_package` 命令用于查找并引入 `本地已安装` 的库。该库可能也是由 `CMake` 构建的，也可能使用了完全不同的构建系统，它甚至可能只是一个根本不需要编译的文件集合。

#### 基础用法

**`语法：`**
```cmake
find_package(<PackageName> [<version>] [REQUIRED] [COMPONENTS <components>...])
```

* `<PackageName>`：唯一必要参数，要查找的包的名称。例如，`find_package(Boost)` 会查找 `Boost` 库。
* `<version>`：可选参数，指定所需的包的版本号。`CMake` 会确保找到的包符合该版本要求。
* `REQUIRED`：可选参数，表示此包是必需的。如果未找到该包，`CMake` 将停止配置并报告错误。
* `COMPONENTS <components>...`：可选参数，指定要查找的包组件。例如，对于某些大型库，可以只查找特定模块，如 `find_package(Boost 1.75 REQUIRED COMPONENTS filesystem system)`。

**`示例：`**
```cmake
find_package(OpenCV REQUIRED)

# 创建目标
add_executable(my_project main.cpp)

# 包含 OpenCV 的头文件目录
target_include_directories(my_project PRIVATE ${OpenCV_INCLUDE_DIRS})

# 链接 OpenCV 的库文件
target_link_libraries(my_project PRIVATE ${OpenCV_LIBS})
```

#### 搜索模式

`find_package` 命令有两种搜索模式：

Module 

#### 常见变量
使用 `find_package` 查找外部库时，`CMake` 会设置多个变量，以便可以使用目标库的头文件、库文件和版本号等信息。常见变量如下：

* `<PackageName>_DIR`：字符串，目标库的安装目录或构建目录。通常指向包含配置文件（如 `<PackageName>Config.cmake` 或 `<PackageNane>Config-version.cmake`）的目录。
* `<PackageName>_INCLUDE_DIRS`：列表，目标库的头文件路径，包含核心头文件及各模块的头文件。
* `<PackageName>_LIBRARIES`：字符串或列表，这个变量包含了目标库所有需要链接的库文件。
* `<PackageName>_VERSION`：字符串，目标库版本号。
* `<PackageName>_FOUND`：布尔值，表示是否找到目标库。

**`示例：`**

```cmake
// 在本地查找 OpenSSL 库
find_package(OpenSSL REQUIRED)
// 判断是否查找到 OpenSSL
if(OPENSSL_FOUND)
    message(STATUS "OpenSSL is found")
else()
    message(STATUS "OpenSSL is not found")
endif()
// 打印 OpenSSL 信息
message(STATUS "found OpenSSL_DIR: ${OpenSSL_DIR}")
message(STATUS "found OpenSSL_INCLUDE_DIRS: ${OpenSSL_INCLUDE_DIRS}")
message(STATUS "found OpenCV_VERSION: ${OpenCV_VERSION}")
// 判断是否是动态库
if(OPENSSL_STATIC)
    message(STATUS "Using static OpenSSL")
else()
    message(STATUS "Using dynamic OpenSSL")
endif()
```

### 搜索顺序

`find_xxx` 命令搜索目标文件时，会先在系统默认路径中搜索，然后如果设置了额外搜索路径则会接着在指定路径中搜索。

一些 `CMake` 环境变量会影响 `find_xxx` 的搜索过程：

* `CMAKE_PREFIX_PATH`：用于指定搜索前缀路径，格式为 `<prefix>/lib`。例如，如果设置为 `/usr/local;/opt/custom`, `find_library` 会在 `/usr/local/lib` 和 `/opt/custom/lib` 等路径中查找库。
* `CMAKE_LIBRARY_ARCHITECTURE`：用于指定检索目标架构目录的变量，格式为 `<prefix>/lib/<arch>`。例如，设置为 `x86_64-linux-gnu` 后，`find_library` 会在 `<prefix>/lib/x86_64-linux-gnu` 中进行查找。
* `NO_DEFAULT_PATH`：只允许在指定目录中，禁止 `CMake` 在其默认路径中搜索目标文件。

`CMake` 还提供了一些用于控制查找路径的优先级和范围的变量：

1. `CMAKE_FIND_USE_PACKAGE_ROOT_PATH`
* 功能：控制是否使用包的根路径（通常与交叉编译或自定义路径相关）来查找依赖项。
* 默认值：FALSE。
* 作用：如果设置为 TRUE，CMake 会在查找包时优先使用包的根路径。如果未设置为 TRUE，CMake 将按照默认的查找顺序（如 CMAKE_PREFIX_PATH）进行查找。

2. `CMAKE_FIND_USE_CMAKE_PATH`
* 功能：控制是否使用 CMake 自身的查找路径来查找依赖项。
* 默认值：TRUE。
* 作用：如果设置为 TRUE，CMake 会在其内部的查找路径中搜索包和依赖项。通常这些路径包括 CMake 的安装目录和标准路径。

3. `CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH`
* 功能：控制是否使用由环境变量指定的查找路径（如 PATH 和其他相关环境变量）。
* 默认值：TRUE。
* 作用：如果设置为 TRUE，CMake 会使用环境变量中的路径来查找依赖项。例如，PATH 环境变量中的路径将用于查找可执行文件，而 CMAKE_LIBRARY_PATH 中的路径将用于查找库。

4. `CMAKE_FIND_USE_INSTALL_PREFIX`
* 功能：控制是否使用安装目录（CMAKE_INSTALL_PREFIX）中的路径来查找包。
* 默认值：TRUE。
* 作用：如果设置为 TRUE，CMake 将在安装目录下（即 CMAKE_INSTALL_PREFIX 指定的路径）查找依赖项。通常用于查找由 make install 安装的库和其他文件。

5. `CMAKE_FIND_USE_CMAKE_SYSTEM_PATH`
* 功能：控制是否使用系统级的 CMake 查找路径（如操作系统的默认路径）。
* 默认值：TRUE。
* 作用：如果设置为 TRUE，CMake 会在系统的标准路径（如 /usr/lib、/usr/local/lib、/System/Library/Frameworks 等）中查找依赖项。

6. `CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH`
* 功能：控制是否使用系统环境变量（如 PATH、LD_LIBRARY_PATH）中的路径来查找依赖项。
* 默认值：TRUE。
* 作用：如果设置为 TRUE，CMake 会检查操作系统环境中指定的路径来查找依赖项。它利用操作系统的环境变量来增强查找范围。

7. `CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY`
* 功能：控制是否使用系统级包注册表来查找已安装的包。
* 默认值：TRUE。
* 作用：如果设置为 TRUE，CMake 会在系统级的包注册表中查找已安装的包。这个功能可以帮助 CMake 找到系统中已安装的库和包。

8. `CMAKE_FIND_USE_PACKAGE_REGISTRY`
* 功能：控制是否使用包注册表来查找依赖项。
* 默认值：TRUE。
* 作用：如果设置为 TRUE，CMake 会在 CMake 的包注册表中查找包，这通常用于查找通过 find_package 导入的包。
