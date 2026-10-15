3. ADASIS：https://cloud.tencent.com/developer/article/191133
4. reverse，android端口转发：https://developer.android.com/tools/adb?hl=zh-cn
5. Android studio JNI调试：https://agroup.baidu.com/rjgj/md/article/4711652
6. gdb调试
7. ndk-stack:https://developer.android.com/ndk/guides/ndk-stack?hl=zh-cn
8. MD5、SHA1、CRC32
https://cloud.tencent.com/developer/article/1912817

9. grpc 了解
10. resolutionstrategy使用
11. ./gradlew app:dependencies --configuration unityDebugCompileClasspath

12. byte[] 转 bytebuffer
可以
```
ByteBuffer buffer = ByteBuffer.allocateDirect(msg.getDataSize());
buffer.put(msg.getData());
```

不可以
```
/**
 * byte 数组转byteBuffer
 * @param byteArray
 */
public static ByteBuffer byte2Byffer(byte[] byteArray) {

    //初始化一个和byte长度一样的buffer
    ByteBuffer buffer=ByteBuffer.allocate(byteArray.length);
    // 数组放到buffer中
    buffer.put(byteArray);
    //重置 limit 和postion 值 否则 buffer 读取数据不对
    buffer.flip();
    return buffer;
}
```

13. Intellij Idea Java 项目 jar 打包
https://juejin.cn/post/7031717860003020814

14. 软连接
ln -s 目标文件 软连接:新建软连接
ln -snf 目标文件 软连接:更新软连接

15. Android NDK之Strip裁减so库：https://blog.csdn.net/hexingen/article/details/124860298

16. addr2line 输出分析
17. proto 数据反编译
18. 编译参数：-g；调试信息和符号表
19. strip

在 C++ 项目编译时，`-g` 和 `strip` 主要与**调试信息**有关，作用如下：  

## -g、strip
### 1. `-g` 选项的作用  
`-g` 是 GCC（或 Clang）编译器的一个选项，它的作用是：  
- 生成**调试符号**，用于 GDB、LLDB 等调试器进行源码级调试。  
- 使编译后的二进制文件包含源代码的变量名、函数信息、行号等调试信息。  
- **不会影响代码优化**，可以与 `-O2` 或 `-O3` 组合使用（但优化可能会导致代码行号对应不准确）。  

示例：
```sh
g++ -g -o my_program my_program.cpp
```
这样生成的 `my_program` 体积会比**不加 `-g`** 时大，因为它包含了调试信息。

---

### 2. `strip` 的作用  
`strip` 是一个用于**去除二进制文件中符号表和调试信息**的工具，作用包括：  
- **减小可执行文件体积**（去掉不必要的符号表）。  
- **防止反编译或源码泄露**（去掉符号信息后，二进制文件不包含函数名、变量名等信息）。  
- **通常用于发布 Release 版本**，因为调试信息在运行时不需要。  

示例：
```sh
strip my_program
```
这个命令会删除 `my_program` 中的所有调试信息，使其变得更小但无法进行源码级调试。

---

### 3. `-g` 和 `strip` 配合使用  
开发过程中，可以使用 `-g` 选项生成带调试信息的可执行文件，而在发布 Release 版本时，使用 `strip` 去除调试信息。例如：
```sh
g++ -g -O2 -o my_program my_program.cpp  # 编译带调试信息的优化版本
strip my_program                         # 去除调试信息，发布 Release 版本
```
或者，更好的方式是：
```sh
g++ -g -O2 -o my_program my_program.cpp  # 编译带调试信息的优化版本
objcopy --only-keep-debug my_program my_program.debug  # 提取调试信息
strip --strip-debug --strip-unneeded my_program        # 删除调试信息
```
这样：
- `my_program` 是精简后的可执行文件（用于部署）。
- `my_program.debug` 是调试符号文件（用于调试）。  

**如果程序崩溃**，可以用 `gdb my_program my_program.debug` 进行调试，即使 `my_program` 被 `strip` 了。

---

### 总结：
| 选项/命令 | 作用 |
|-----------|------|
| `-g` | 生成调试符号，方便调试 |
| `strip` | 删除调试符号，减小体积，防止源码泄露 |
| `objcopy --only-keep-debug` | 提取调试符号到单独的文件 |

对于**开发环境**，建议使用 `-g` 以便调试；  
对于**生产环境**，建议 `strip` 或分离调试信息，以保证可执行文件精简但仍能调试。
