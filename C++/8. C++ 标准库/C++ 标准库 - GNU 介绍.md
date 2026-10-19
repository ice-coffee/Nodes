[toc]

## GNU

### 简介
**`全称：`**

> **GNU = “GNU's Not Unix”**

这是一个**递归缩写**，意为 “GNU 不是 Unix”，但**与 Unix 兼容**。

**`定义：`**

**GNU 是一个自由软件操作系统的项目**，目标是创建一个完全自由、开放源代码、兼容 Unix 的操作系统。

它由 **理查德·斯托曼（Richard Stallman）** 于 1983 年发起，并于 1984 年成立了自由软件基金会（FSF, Free Software Foundation）来支持这个项目。

### GNU 的组成

GNU 提供了大量操作系统组件，比如：

| 组件           | 作用                              |
| ------------ | ------------------------------- |
| `glibc`      | GNU C 标准库，实现了 C 标准函数            |
| `gcc`        | GNU 编译器套件，支持多种语言                |
| `bash`       | GNU 的 Shell 解释器                 |
| `coreutils`  | 常用命令（如 `ls`, `cp`, `rm`, `cat`） |
| `make`       | 自动构建工具                          |
| `gdb`        | 调试器                             |
| `tar`/`gzip` | 打包和压缩工具                         |

### GNU 与 Linux 的关系

**Linux 是一个内核**，而不是一个完整的操作系统。

很多我们说的 “Linux 系统”，其实更准确的说法是：

> **GNU/Linux 操作系统**
> （Linux 内核 + GNU 工具链）

所以 Ubuntu、Debian、CentOS 等其实都是 GNU/Linux 发行版。

## glibc

### 简介
**`定义：`**

`glibc` 是 GNU 项目的 C 标准库实现。它为 C/C++ 程序提供系统调用的封装和标准函数，如：

* 内存分配（`malloc` / `free`）
* 字符串处理（`strlen`, `strcmp`, `strcpy`）
* 文件操作（`fopen`, `read`, `write`）
* 线程（`pthread_create` 等）

几乎所有使用 `gcc` 编译的程序在运行时都依赖 `glibc`。

**`特点：`**

* 支持 POSIX、ISO C/C++ 标准
* 提供线程支持（pthreads）
* 与内核进行系统调用交互的桥梁
* 兼容性较强，许多 Linux 发行版默认使用它

**`安装路径（Linux, x86_64）：`**

通常头文件在：

```
/usr/include/
```

动态库在：

```
/lib/x86_64-linux-gnu/libc.so.6
```

命令查看版本：

```bash
ldd --version
```

## GCC

**`全称：`**

> **GCC = GNU Compiler Collection**

最初是 "GNU C Compiler"，现在已发展为**一个支持多种语言的编译器套件**。

**`定义：`**

`GCC` 是一个自由软件编译器系统，由 `GNU` 项目维护，广泛用于 `Linux`、`UNIX` 和嵌入式平台，是现代软件开发中最关键的基础工具之一。

**`GCC 安装路径（Linux, x86_64）：`**
头文件	
```
/usr/include, /usr/include/c++/version/
```

标准库 
```
/usr/lib/gcc/x86_64-linux-gnu/<version>/
```

编译器前端	
```
/usr/lib/gcc/x86_64-linux-gnu/<version>/cc1
```

配置文件	
```
/usr/lib/gcc/x86_64-linux-gnu/<version>/specs
```

查看版本：
```bash
gcc --version
```

**支持语言：**

| 编程语言        | 编译器前端              | 状态说明         |
| ----------- | ------------------ | ------------ |
| C           | `gcc` → `cc1`      | 最早支持，最成熟     |
| C++         | `g++` → `cc1plus`  | 非常成熟         |
| Objective-C | `gcc`              | 支持           |
| Fortran     | `gfortran`         | 支持           |
| Ada         | `gnat`             | 支持（需安装）      |
| Go          | `gccgo`            | 部分支持         |
| D           | `gdc`              | 社区支持，非官方默认   |
| Rust（间接）    | 通过 `rustc` 使用 LLVM | 不属于 GCC 直接支持 |

### GCC 架构与编译流程

`GCC` 的架构由多个阶段组成，每个阶段负责处理一部分任务：

```text
源码（.c/.cpp）
   ↓
预处理（cpp）  → 处理 #include, #define 等
   ↓
编译（cc1/cc1plus） → 生成中间表示（IR）
   ↓
优化阶段        → 中间代码层面的优化
   ↓
汇编（as）      → 生成平台相关汇编代码（.s）
   ↓
目标文件（.o）
   ↓
链接（ld）      → 与其他 .o 和库链接，生成最终可执行文件
```

> 每个阶段都可以通过命令行参数控制并导出中间结果（如 `-E`, `-S`, `-c`）

### GCC 组件

| 组件            | 说明                          |
| ------------- | --------------------------- |
| `gcc` / `g++` | 前端驱动，调用其它组件                 |
| `cpp`         | 预处理器，处理宏、头文件                |
| `cc1`         | C 语言前端编译器                   |
| `cc1plus`     | C++ 语言前端编译器                 |
| `as`          | GNU 汇编器                     |
| `ld`          | GNU 链接器                     |
| `collect2`    | 链接辅助器，处理构造函数、异常等            |
| `libgcc`      | GCC 自带的运行支持库                |
| `libstdc++`   | C++ 标准库实现（STL、IOStream、异常等） |

### 常用命令与参数

#### 1. 基本用法

```bash
gcc main.c -o main         # 编译 C
g++ main.cpp -o main       # 编译 C++
```

#### 2. 分阶段编译

```bash
gcc -E main.c    # 只预处理，输出 .i 文件
gcc -S main.c    # 输出汇编代码（.s）
gcc -c main.c    # 编译为目标文件（.o）
gcc main.o -o main   # 链接生成可执行文件
```

#### 3. 添加调试信息

```bash
gcc -g main.c -o main   # 含调试符号，便于 gdb 使用
```

#### 4. 优化选项

| 优化等级     | 说明            |
| -------- | ------------- |
| `-O0`    | 不优化（默认）       |
| `-O1`    | 基础优化          |
| `-O2`    | 常用优化，推荐       |
| `-O3`    | 强优化，代价是编译时间增加 |
| `-Os`    | 针对代码体积进行优化    |
| `-Ofast` | 激进优化（不完全遵守标准） |

### 与系统库的关系

#### 链接 glibc

```bash
ldd ./main
# 显示链接的动态库，常见包括 libc.so.6, libstdc++.so.6 等
```

#### 链接静态库

```bash
gcc main.c -static -o main
# 生成完全静态链接的程序（无运行时依赖）
```

#### 交叉编译与多平台支持

GCC 支持多平台目标（cross-compiling），例如：

```bash
aarch64-linux-gnu-gcc main.c -o main_arm
```

用于从 x86\_64 编译目标为 ARM 架构的程序。可广泛用于嵌入式开发、安卓、物联网等。

---

### GCC 与 Clang

| 对比项    | GCC       | Clang/LLVM  |
| ------ | --------- | ----------- |
| 编译速度   | 相对较慢      | 通常更快        |
| 报错信息   | 较为传统，信息较少 | 更详细、易读的错误提示 |
| 可扩展性   | 灵活但较复杂    | 使用 IR 更易扩展  |
| 编译标准支持 | 非常完整      | 标准支持更紧跟前沿   |
| 静态分析   | 较弱        | 内置强大的分析工具   |
