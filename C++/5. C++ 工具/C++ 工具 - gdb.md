[toc]

### gdb 使用

### 断点调试

下面是一个 **GDB 常用命令 + 简写对照表大全**，尤其适合你在调试 C/C++ 程序时快速上手、提效。

#### 断点操作类

| 功能 | 完整命令 | 简写 | 示例 |
| --- | --- | --- | --- |
| 设置断点 | `break` | `b` | `b main`、`b 42` |
| 临时断点（触发一次自动删除） | `tbreak` | `tb` | `tb func` |
| 按正则设置多个断点 | `rbreak` | `rb` | `rb MyClass::.*` |
| 查看断点 | `info breakpoints` | `info b` | `info b` |
| 删除断点 | `delete` | `d` | `d 2` |
| 禁用断点 | `disable` | `dis` | `dis 1` |
| 启用断点 | `enable` | `en` | `en 1` |
| 清除指定位置断点 | `clear` | （无） | `clear main` |
| 条件断点 | `break <位置> if <条件>` | `b ... if` | `b 50 if x == 3` |

#### 程序执行控制类

| 功能 | 完整命令 | 简写 | 说明 |
| --- | --- | --- | --- | 
| 运行程序 | `run` | `r` | 启动调试目标程序 |
| 继续执行 | `continue` | `c` | 从断点处继续运行 |
| 单步执行（不进入函数） | `next` | `n` | 执行下一行 |
| 单步执行（进入函数） | `step` | `s` | 进入调用函数内部 |
| 执行到函数返回 | `finish` | （无简写） | 运行到当前函数返回 |
| 执行到当前作用域外 | `until` | （无简写） | 跳出循环或函数体 |
| 重新启动程序 | `run` | `r` | 程序会从头重新开始 |
| 退出 GDB | `quit` | `q` | 结束调试 |

#### 程序状态查看类

| 功能 | 完整命令 | 简写 | 示例 | 
| --- | --- | --- | --- |
| 打印变量 | `print` | `p` | `p x`、`p *ptr` |
| 监视变量变化 | `watch` | （无简写） | `watch count` |
| 打印所有局部变量 | `info locals` | — | 查看当前函数变量 |
| 打印堆栈回溯 | `backtrace` | `bt` | `bt` |
| 查看当前栈帧 | `frame` | `f` | `f 2` 切换到第 2 帧 |
| 查看寄存器 | `info registers` | `i r` | `i r` |
| 查看线程 | `info threads` | `i th` | `i th` |
| 切换线程 | `thread` | `th` | `th 3` |
| 查看源代码 | `list` | `l` | `l` 或 `l 100` |
| 显示当前行 | `where` | `w` | 等价于 `bt` |

#### 内存与表达式操作类

| 功能 | 完整命令 | 简写 | 示例 |
| --- | --- | --- | --- |
| 查看内存 | `x` | `x` | `x/10xw 0x7fffabc`（查看 10 个 word） |
| 修改变量 | `set var` | `set` | `set var i=5` |
| 执行表达式 | `print` | `p` | `p x+1` |
| 反汇编 | `disassemble` | `disas` | `disas main` |

#### 运行信息和调试辅助

| 功能 | 完整命令 | 简写 | 示例 | 
|  --- |  --- |  --- |  --- |
| 加载符号 | `symbol-file` | — | `symbol-file a.out` |
| 加载共享库符号 | `sharedlibrary` | `share` | `share` |
| 查看当前程序信息 | `info program` | `i prog` | `i prog` |
| 查看共享库 | `info sharedlibrary` | `i sh` | `i sh` |
| 查看线程栈 | `thread apply all bt` | — | 查看所有线程栈 |

### core dump
要让 Linux 程序在崩溃时生成 core dump 文件，你需要满足以下几个条件。下面是 **从允许、配置到验证 core dump 文件生成** 的完整指南。

#### 1. 开启 core dump 功能

默认有些系统是关闭 core dump 的，需要打开。

* **临时开启（当前 shell 有效）**

```bash
ulimit -c unlimited
```

验证：

```bash
ulimit -c
# 应该输出 unlimited
```

---

* **永久开启（写入配置）**

对于 bash 用户：

```bash
echo "ulimit -c unlimited" >> ~/.bashrc
source ~/.bashrc
```

或者系统级别修改 `/etc/security/limits.conf`：

```conf
*               soft    core            unlimited
*               hard    core            unlimited
```

---

#### 2. 设置 core 文件保存路径和文件名格式

Linux 默认 core 文件路径和格式可能不直观（如 `core`、`core.pid`）。你可以通过以下方法配置。

查看当前设置：

```bash
cat /proc/sys/kernel/core_pattern
```

常见默认值：

```bash
core
```

你可以设置更清晰的路径和命名：

```bash
sudo sysctl -w kernel.core_pattern=core.%e.%p
```

示例含义：

* `%e`: 程序名
* `%p`: 进程号
* `%t`: 时间戳
* `%h`: 主机名
* `%u`: UID

更高级配置（建议使用完整路径保存）：

```bash
sudo sysctl -w kernel.core_pattern=/tmp/core.%e.%p.%t
```

让设置永久生效：

```bash
echo 'kernel.core_pattern=/tmp/core.%e.%p.%t' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

---

#### 3. 编译时包含调试信息

编译程序时加上 `-g`，确保 GDB 能识别调试符号：

```bash
g++ -g -o test test.cpp
```

---

#### 4. 手动制造一次崩溃试试

创建一个有意制造段错误的程序测试 core dump：

```cpp
// crash.cpp
#include <iostream>

int main() {
    int *ptr = nullptr;
    *ptr = 42;  // 崩溃
    return 0;
}
```

```bash
g++ -g -o crash crash.cpp
ulimit -c unlimited
./crash
# 应会看到：Segmentation fault (core dumped)
```

然后就会在当前目录或你配置的路径生成一个 core 文件，如：

```bash
core.crash.12345.1721372473
```

---

#### 5. 使用 GDB 分析 core 文件

```sh
// gdb <可执行程序> <core dump文件>
gdb ./crash core.crash.12345.1721372473
```

然后在 GDB 中使用：

```gdb
(gdb) bt          # 打印调用栈
(gdb) frame 0     # 定位到崩溃位置
(gdb) list        # 查看源码行
(gdb) info locals # 查看局部变量
```

---

#### 常见问题

| 问题               | 解决办法                                   |
| ---------------- | -------------------------------------- |
| core 文件未生成       | 检查 `ulimit -c` 是否为 `unlimited`         |
| core 文件生成在别处     | 查看 `cat /proc/sys/kernel/core_pattern` |
| core 文件权限不足      | 确保当前用户有写权限到生成目录                        |
| core 文件大小为 0     | 某些系统默认屏蔽或限制 core 文件内容                  |
| 没有调试信息（GDB 无法分析） | 编译加 `-g`，不要加 `-s` 或 `-Wl,-s`           |

---

如果你在尝试过程中遇到问题（比如 core 没生成，GDB 无法识别），你可以贴出相关命令和输出，我可以帮你进一步分析。
