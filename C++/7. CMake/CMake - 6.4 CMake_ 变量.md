CMake 中所有以 **`CMAKE_` 开头** 的变量，都属于 **CMake 内部或全局配置变量**，
用于控制整个构建系统的行为，比如编译器选择、构建类型、安装路径、系统检测结果等。

这些变量大致可以分为几大类：

### 构建配置相关

| 变量 | 含义 | 示例值 |
|  :--- |  :--- |  :--- |
| `CMAKE_BUILD_TYPE` | 构建类型（单配置生成器，如 Makefile/Ninja） | `Debug` / `Release` / `RelWithDebInfo` |
| `CMAKE_VERBOSE_MAKEFILE` | 是否输出详细编译命令 | `ON` / `OFF` |

### 编译器相关

| 变量 | 说明 | 示例值 |
|  :--- |  :--- |  :--- |
| `CMAKE_C_COMPILER` | C 编译器路径 | `/usr/bin/gcc` |
| `CMAKE_CXX_COMPILER` | C++ 编译器路径 | `/usr/bin/g++` |
| `CMAKE_AR` | 静态库归档工具 | `/usr/bin/ar` |
| `CMAKE_RANLIB` | 库索引工具 | `/usr/bin/ranlib` |
| `CMAKE_LINKER` | 链接器路径 | `/usr/bin/ld` |
| `CMAKE_OBJCOPY` | 对象复制工具 | `/usr/bin/objcopy` |
| `CMAKE_STRIP` | 可执行文件剥离工具 | `/usr/bin/strip` |

### 编译选项与标准控制

| 变量 | 说明 | 示例 |
|  :--- |  :--- |  :--- |
| `CMAKE_C_FLAGS` | 全局 C 编译选项 | `-Wall -O2` |
| `CMAKE_CXX_FLAGS` | 全局 C++ 编译选项 | `-Wall -std=c++17` |
| `CMAKE_C_FLAGS_DEBUG` | Debug 模式特有的 C 选项 | `-g` |
| `CMAKE_CXX_FLAGS_RELEASE` | Release 模式特有的 C++ 选项 | `-O3 -DNDEBUG` |
| `CMAKE_POSITION_INDEPENDENT_CODE` | 是否生成位置无关代码（`-fPIC`） | `ON` / `OFF` |
| `CMAKE_CXX_STANDARD` | C++ 标准版本 | `17` |
| `CMAKE_CXX_STANDARD_REQUIRED` | 是否必须使用指定标准 | `ON` |
| `CMAKE_CXX_EXTENSIONS` | 是否允许 GNU 扩展（`gnu++17`） | `OFF` |

### 系统与平台信息

| 变量 | 说明 | 示例 |
|  :--- |  :--- |  :--- |
| `CMAKE_SYSTEM_NAME` | 操作系统名称 | `Linux` / `Android` / `Windows` |
| `CMAKE_SYSTEM_VERSION` | 操作系统版本 | `5.15.0` |
| `CMAKE_SYSTEM_PROCESSOR` | 架构 | `x86_64` / `aarch64` |
| `CMAKE_HOST_SYSTEM_NAME` | 主机系统名称（非目标系统） | `Linux` |
| `CMAKE_HOST_SYSTEM_PROCESSOR` | 主机 CPU 架构 | `x86_64` |
| `CMAKE_SYSROOT` | 交叉编译时 sysroot 路径 | `/opt/aarch64-linux-gnu/sysroot` |

### 安装路径控制

| 变量 | 说明 | 示例 |
|  :--- |  :--- |  :--- |
| `CMAKE_INSTALL_PREFIX` | 默认安装前缀 | `/usr/local` |
| `CMAKE_INSTALL_BINDIR` | 可执行文件安装路径 | `bin` |
| `CMAKE_INSTALL_LIBDIR` | 库文件安装路径 | `lib` |
| `CMAKE_INSTALL_INCLUDEDIR` | 头文件路径 | `include` |
| `CMAKE_INSTALL_DATADIR` | 数据文件路径 | `share` |

这些路径通常与 `GNUInstallDirs` 模块配合使用。

### 项目路径与文件系统

| 变量 | 含义 | 示例 |
|  :--- |  :--- |  :--- |
| `CMAKE_SOURCE_DIR` | 顶层 `CMakeLists.txt` 所在路径 | `/home/user/project` |
| `CMAKE_CURRENT_SOURCE_DIR` | 当前处理的源目录 | `/home/user/project/src` |
| `CMAKE_BINARY_DIR` | 构建输出目录（build 目录） | `/home/user/project/build` |
| `CMAKE_CURRENT_BINARY_DIR` | 当前目录对应的 build 子目录 | `/home/user/project/build/src` |
| `CMAKE_COMMAND` | CMake 可执行文件路径 | `/usr/bin/cmake` |
| `CMAKE_CACHEFILE_DIR` | CMakeCache.txt 所在目录 | `/home/user/project/build` |

### 目标与依赖相关

| 变量 | 含义 |
|  :--- |  :--- |
| `CMAKE_PROJECT_NAME` | 当前工程名（来自 `project()`） |
| `CMAKE_PROJECT_VERSION` | 工程版本号 |
| `CMAKE_EXPORT_COMPILE_COMMANDS` | 是否生成 `compile_commands.json` |
| `CMAKE_INCLUDE_PATH` | 头文件搜索路径（find_path() 使用） |
| `CMAKE_LIBRARY_PATH` | 库文件搜索路径（find_library() 使用） |
| `CMAKE_PREFIX_PATH` | 模块搜索前缀路径 |
| `CMAKE_MODULE_PATH` | 自定义 `FindXXX.cmake` 搜索路径 |
| `CMAKE_FIND_ROOT_PATH` | 交叉编译时的根路径 |

### 交叉编译 / 工具链相关

| 变量 | 含义 |
|  :--- |  :--- |
| `CMAKE_TOOLCHAIN_FILE` | 指定交叉编译工具链文件路径 |
| `CMAKE_SYSTEM_NAME` | 目标系统名称 |
| `CMAKE_FIND_ROOT_PATH_MODE_PROGRAM` | 搜索程序时是否使用 sysroot |
| `CMAKE_FIND_ROOT_PATH_MODE_LIBRARY` | 搜索库时是否使用 sysroot |
| `CMAKE_FIND_ROOT_PATH_MODE_INCLUDE` | 搜索头文件时是否使用 sysroot |

这些变量一般出现在 ARM、Android、嵌入式交叉编译场景中。

### 示例：在命令行中设置 CMAKE_ 变量

```bash
cmake .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_CXX_STANDARD=17 \
 -DCMAKE_INSTALL_PREFIX=/opt/mylib \
 -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
 -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++
```
