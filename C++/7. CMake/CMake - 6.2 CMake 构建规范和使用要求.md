[toc]

### 构建和使用规则

如果将 `CMake` 构建系统中的可执行文件和库看做一个一个的对象的话，那么可以通过命令给它们设置或修改属性。

以 `target_link_libraries` 命令举例，它通过修改某个 `target` 的 `LINK_LIBRARIES`、`INTERFACE_LINK_LIBRARIES` 属性，影响它们在编译时的依赖关系。

* `LINK_LIBRARIES`：自身编译时使用；
* `INTERFACE_LINK_LIBRARIES`：使用当前库作为依赖项的库编译时使用；

> 对比命令和属性可以看到属性名的命名规则。

**格式：**

```cmake
target_link_libraries(<target>
	<PRIVATE|PUBLIC|INTERFACE> <item>...
	[<PRIVATE|PUBLIC|INTERFACE> <item>...]...)
```

* **`PRIVATE`**：表示将 <item> 追加到 `LINK_LIBRARIES` 属性；
* **`INTERFACE`**：表示将 <item> 追加到 `INTERFACE_LINK_LIBRARIES` 属性；
* **`PUBLIC`**：表示 `LINK_LIBRARIES` 和 `INTERFACE_LINK_LIBRARIES` 属性都会追加 <item>；

> 就好像 `Java` 中的作用域控制符一样：`public`、`private`、`protect`。

**示例：**

```cmake
# 1. 创建库 A/B/C
add_library(A STATIC a.cpp)
add_library(B STATIC b.cpp)
add_library(C STATIC c.cpp)

# 2. 创建库 obj，演示可见性
add_library(obj STATIC obj.cpp)

# 示例 1: PRIVATE / PUBLIC / INTERFACE
target_link_libraries(obj
    PRIVATE A      # obj 自己会链接 A，但依赖 obj 的 target 不会
    PUBLIC  B      # obj 自己会链接 B，依赖 obj 的 target 也会链接 B
    INTERFACE C    # obj 自己不会链接 C，但依赖 obj 的 target 会链接 C
)

# 3. 创建可执行文件 app，依赖 obj
add_executable(app main.cpp)

# 链接 obj
target_link_libraries(app PRIVATE obj)
```

> 在 `CMake` 中 `target_link_libraries` 的 **链接**，既指 **编译阶段是否告诉编译器/链接器去使用这个库的符号**，也间接影响 **是否可以在代码里使用库里的函数或变量**。

下面是其它一些在使用时需要设置属性生效范围的命令。

### 编译阶段

#### `target_sources`

* **作用**：编译阶段输入，给目标追加源文件。
* **对应编译参数**：

  * 直接就是编译命令里的源文件列表。

```cmake
target_sources(myapp PRIVATE foo.cpp bar.cpp)
```

生成：

```bash
g++ ... foo.cpp bar.cpp
```

#### `target_compile_definitions`

* **作用**：添加宏定义。
* **对应编译参数**：

  * `-DNAME`
  * `-DNAME=value`

例如：

```cmake
target_compile_definitions(myapp PRIVATE FOO=1 BAR)
```

会生成：

```bash
g++ -DFOO=1 -DBAR ...
```

#### `target_compile_options`

* **作用**：直接添加编译选项（不做解释，直接透传给编译器）。
* **对应编译参数**：

  * 比如 `-Wall`、`-O2`、`-fPIC`、`/W4`（MSVC）等

```cmake
target_compile_options(myapp PRIVATE -Wall -O2)
```

生成：

```bash
g++ -Wall -O2 ...
```

#### `target_compile_features`

* **作用**：声明 C++/C 语言特性需求，让 CMake 自动推导 `-std=...`。
* **对应编译参数**：

  * `-std=c++11`、`-std=c++17`、`-std=c99` 等

```cmake
target_compile_features(myapp PRIVATE cxx_std_17)
```

生成：

```bash
g++ -std=gnu++17 ...
```

#### `target_include_directories`

* **作用**：添加头文件搜索路径。
* **对应编译参数**：

  * `-I<dir>`

```cmake
target_include_directories(myapp PRIVATE /path/to/include)
```

生成：

```bash
g++ -I/path/to/include ...
```

#### `target_precompile_headers`

* **作用**：指定预编译头（PCH）。
* **对应编译参数**（取决于编译器）：

  * GCC/Clang: `-include header.hpp`
  * MSVC: `/FI header.hpp`

CMake 会生成相应的 `.pch` 文件并自动注入到编译命令。

### 链接阶段
#### `target_link_libraries`

* **作用**：给目标添加要链接的库。
* **对应编译/链接参数**：

  * `-l<lib>` （例如 `-lpthread`）
  * `-L<dir>`（库路径，如果库不是系统路径）
  * 还可能是直接指定 `.a` 或 `.so` 的绝对路径

#### `target_link_directories`

* **作用**：添加库搜索路径。
* **对应链接参数**：

  * `-L<dir>`

```cmake
target_link_directories(myapp PRIVATE /path/to/lib)
```

生成：

```bash
g++ ... -L/path/to/lib -lfoo
```

#### `target_link_options`

* **作用**：直接添加链接器选项。
* **对应参数**：

  * `-Wl,option`（GCC/Clang）
  * `/LINK option`（MSVC）

```cmake
target_link_options(myapp PRIVATE -Wl,--as-needed -Wl,-rpath,/opt/lib)
```

生成：

```bash
g++ ... -Wl,--as-needed -Wl,-rpath,/opt/lib
```
