[toc]

`CMake` 提供了两个常用的自定义构建指令的命令：

* `add_custom_target`
* `add_custom_comment`

它们用于执行给定的命令，尤其是需要在标准编译流程之外添加自定义操作时。

### add_custom_target
`add_custom_target` 用于定义自定义 `target`，在构建过程中不产出库文件。

**`格式：`**

```cmake
add_custom_target(Name [ALL] [command1 [args1...]]
                  [COMMAND command2 [args2...] ...]
                  [DEPENDS depend depend depend ... ]
                  [BYPRODUCTS [files...]]
                  [WORKING_DIRECTORY dir]
                  [COMMENT comment]
                  [JOB_POOL job_pool]
                  [JOB_SERVER_AWARE <bool>]
                  [VERBATIM] [USES_TERMINAL]
                  [COMMAND_EXPAND_LISTS]
                  [SOURCES src1 [src2...]])
```

* `Name`：指定自定义目标的名称。
* `ALL`：在默认编译中执行，也就是每次编译都会执行。
* `COMMAND`：定义要执行的命令（多个命令将依次执行）。
* `DEPENDS`：指定此目标依赖的其他目标或文件。
* `BYPRODUCTS`：命令产生的附加文件，CMake 使用这些文件来判断目标是否已生成。
* `WORKING_DIRECTORY`：指定命令的工作目录。
* `COMMENT`：添加命令注释，在构建输出中显示。
* `VERBATIM`：保持命令的原样，避免对特殊字符进行转义。
* `USES_TERMINAL`：表示命令运行需要交互式终端。
* `COMMAND_EXPAND_LISTS`：展开命令行参数列表。

**`示例：`**

```cmake
add_custom_target(CopyTask
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/config ${CMAKE_CURRENT_SOURCE_DIR}/etc
  )
```

执行：
```
mkdir build && cd build
cmake ..
make CopyTask
```

##### COMMAND

```cmake
COMMAND ${CMAKE_COMMAND} -E copy_directory
```

`${CMAKE_COMMAND}`：
`copy_directory`：[内置命令行工具](https://cmake.org/cmake/help/latest/manual/cmake.1.html#run-a-command-line-tool)。

### add_custom_comment

`add_custom_comment` 可以用于自定义构建命令。这个命令可以在构建过程中执行一个自定义操作，例如生成文件、运行脚本等。

`add_custom_comment` 主要有两种用法：
