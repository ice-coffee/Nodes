[toc]

## 编译过程
C/C++ 编译过程通常包括以下几个阶段：

**`预处理阶段（Preprocessing）`**：

* 作用：在预处理阶段，预处理器（如 cpp）会处理源代码中的预处理指令（以 # 开头的指令），如 #include、#define、#ifdef、#endif 等，将宏定义展开、头文件包含替换为文件内容等。
* 输出：预处理后的源文件，通常以 .i 为扩展名。

**`编译阶段（Compilation）`**：

* 作用：在编译阶段，编译器（如 gcc、g++）将预处理后的源文件翻译成汇编语言代码。
* 输出：汇编语言代码文件，通常以 .s 为扩展名。

**`汇编阶段（Assembly）`**：

* 作用：在汇编阶段，汇编器（如 as）将汇编语言代码翻译成机器语言代码（二进制目标文件）。
* 输出：目标文件，通常以 .o 或 .obj 为扩展名。

**`链接阶段（Linking）`**：

* 作用：在链接阶段，链接器（如 ld）将多个目标文件以及库文件链接在一起，解析外部符号引用，符号重定位，生成最终的可执行文件或共享库。
* 输出：可执行文件（或共享库），通常没有扩展名或以 .out、.exe、.so、.dll 等为扩展名。

在 `C/C++` 编译过程中，每个阶段都有特定的工具负责执行相应的任务。预处理阶段由预处理器执行，编译阶段由编译器执行，汇编阶段由汇编器执行，链接阶段由链接器执行。这些阶段按顺序执行，前一个阶段的输出作为后一个阶段的输入，最终生成可执行文件或库文件。

在实际编译过程中，编译器通常会将多个阶段合并在一起，例如将预处理、编译和汇编合并成一个步骤，称为编译。然后再执行链接阶段，生成最终的可执行文件或库文件。

## 使用 CMake 编译

### 项目结构

编写一个最简单的 `C++` 项目：

`Main.cpp`：
```c++
#include <iostream>

int main(int argc, char *argv[])
{
   std::cout << "Hello CMake!" << std::endl;
   return 0;
}
```

在 `Main.cpp` 的同级目录创建 `CMakelist.txt` 文件。一个最简单的 `CMakelist.txt` 文件包含三个命令：

```cmake
# 设置当前项目编译所需 `CMake` 的最低版本：
cmake_minimum_required(VERSION 3.5)
# 设置项目名
project (hello_cmake)
# 创建和项目同名的可执行对象
add_executable(hello_cmake main.cpp)
```

> **`注意`**：任何项目的 `CMakeLists.txt` 文件都必须首先使用 `cmake_minimum_required()` 命令指定 `CMake` 的最小版本，以保证后面命令可以正常执行。

这样就得到了一个最简单的项目，项目结构如下：

```
├── CMakeLists.txt
├── main.cpp
```

### 编译 C++ 项目 

1. 创建编译目录，用于存放项目编译是产生的文件。

```bash
mkdir build
```

2. 执行 `cmake` 生成适用于当前平台的构建系统文件。

```cmake
cd build/
cmake ..
```

通过 `-B` 指定编译目录：

```cmake
cmake -B build/
```

3. 执行构建

```cmake
make
```

4. 执行编译产物

```shell
./hello_cmake

# 输出：
Hello CMake!
```
