### ELF 文件
**`ELF`（Executable and Linkable Format，可执行与可链接格式）** 是 Unix 及类 Unix 系统（如 Linux、Android）上使用的一种标准二进制文件格式。它主要用于 可**执行文件（Executables）**、**共享库（Shared Libraries）** 和 **目标文件（Object Files）**。

### readelf 命令

`readelf` 用于分析 `elf` 文件内部结构的工具。


| 命令 | 作用 |
| --- | --- |
| readelf -h | 查看 ELF 头信息 |
| readelf -l | 查看程序头（加载方式） |
| readelf -S | 查看节头（存储结构） |
| readelf -s | 查看符号表（变量和函数） |
| readelf -d | 查看动态段（共享库依赖） |
| readelf -r | 查看重定位表 |
| readelf -w | 查看调试信息（DWARF 调试段，如 -wi、-wL） |
| readelf -W | 宽输出，不按 80 列折行（可与其他选项配合，如 -sW） |
| readelf -a | 显示所有信息 |

### ldd 
`ldd（List Dynamic Dependencies）`用于显示一个可执行文件或共享库的 动态链接库依赖关系。
