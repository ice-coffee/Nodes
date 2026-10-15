[toc]

### 信号简介
信号机制是 `Linux` 进程间通信的一种重要方式，`Linux` 信号一方面用于正常的进程间通信和同步，如任务控制(`SIGINT`, `SIGTSTP`, `SIGKILL`, `SIGCONT`, ……)；另一方面，它还负责监控系统异常及中断。 当应用程序运行异常时， `Linux` 内核将产生错误信号并通知当前进程。
当 `Linux` 应用程序在执行时发生严重错误，一般会导致程序 `crash`。其中，`Linux` 专门提供了一类 `crash` 信号，在程序接收到此类信号时，缺省操作是将 `crash` 的现场信息记录到 `core` 文件，然后终止进程。

`crash` 信号列表： 

| 信号名 | 值 | 原因 |
| --- | --- | --- |
| SIGSEGV | 11 | 无效的内存引用 |
| SIGBUS | 7 | 对内存对象中未定义部分的访问 |
| SIGFPE |  | 算术运算错误，如除零 |
| SIGILL | 4 | 非法指令 |
| SIGSYS |  | 错误的系统调用 |
| SIGXCPU |  | 超过CPU时间限制 |
| SIGXFSZ |  | 超过文件大小限制 |

### tombstone
[Android Native/Tombstone Crash Log 详细分析(转)](https://www.cnblogs.com/shakin/p/4268393.html)

**`作用`**：

`tombstone` 文件用于 `Native` 程序崩溃时记录崩溃现场信息。

**`获取`**：

文件目录为 `data/`，但是未 `root` 设备无法访问该文件夹。可以通过 `adb` 命令获取 `crash` 以及 `ANR` 文件：

```c++
adb bugreport

adb pull <生成文件目录> <存放目录>
```

**`示例`**：
```c++
ice-coffeedeMBP:~ ice-coffee$ adb bugreport
/data/user_de/0/com.android.shell/files/bugreports/bugreport-AGS3-W00D-HUAWEIAGS3-W00D-2022-10-15-16-14-34.zip: 1 file pulled. 36.2 MB/s (5088886 bytes in 0.134s)
ice-coffeedeMBP:~ ice-coffee$ adb pull /data/user_de/0/com.android.shell/files/bugreports/bugreport-AGS3-W00D-HUAWEIAGS3-W00D-2022-10-15-16-14-34.zip
```

**`文件目录`**：

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/adb_bugreport.jpg)

### tombstone 分析

#### 信息头

```
Build fingerprint: 'HUAWEI/AGS3-W00D/HWAGS3:10/HUAWEIAGS3-W00D/102.0.0.260C00:user/release-keys'
Revision: '0'
ABI: 'arm64'
Timestamp: 2022-10-15 19:30:13+0800
```

信息头，包含当前系统版本有关的信息，如果是做平台级的开发，这将有助于定位当前的系统的开发版本。

#### 寄存器信息

```
pid: 23170, tid: 23170, name: xample.hellojni  >>> com.example.hellojni <<<
uid: 10205
signal 11 (SIGSEGV), code 2 (SEGV_ACCERR), fault addr 0x78c1e3ecc0
    x0  00000078c1e3ecc0  x1  00000078c1e3ecc0  x2  00000078d86d6252  x3  00000078e9810800
    x4  0000000000000cc0  x5  00000078e932f470  x6  00000078e9855600  x7  000000796f2ca020
    x8  0101010101010101  x9  ffffffffe9810800  x10 00000078d862e4c0  x11 00000078e97ee000
    x12 000000796d7a4740  x13 7152ce1a9768fd59  x14 0000000000000006  x15 ffffffffffffffff
    x16 00000078e97ecc50  x17 000000796b9782e0  x18 00000079703f4000  x19 00000078e9905980
    x20 00000078c1e3ecc0  x21 00000078e9810800  x22 0000007fee7b38c0  x23 000000796f14a7f1
    x24 0000000000000004  x25 000000796f2ca020  x26 00000078e98108b0  x27 0000000000000001
    x28 000000796f2ca020  x29 0000007fee7b35f0
    sp  0000007fee7b3550  lr  00000078e95c9e6c  pc  000000796b9782f0
```

寄存器信息，可以通过这部分信息基本确定系统为什么会错。

* `pid == tid`：表示 `crash` 发生在父进程，反之问题发生在子进程
* `name`：`crash` 进程的名称以及在文件系统中位置。
* `signal 11 (SIGSEGV) ...`：这里的信息说明出现 crash 的原因是因为程序访问了非法的内存空间，以及访问的非法地址。

#### backtrace

```
      #00 pc 000000000006c2f0  /apex/com.android.runtime/lib64/bionic/libc.so (strlen+16) (BuildId: b91c775ccc9b0556e91bc575a2511cd0)
      #01 pc 00000000003e0e68  /apex/com.android.runtime/lib64/libart.so (art::JNI::NewStringUTF(_JNIEnv*, char const*)+60) (BuildId: 762960c75ada06c48e438df6df29b0a1)
      #02 pc 00000000000005cc  /data/app/com.example.hellojni-VV4Xn3GNZCXuZ5_OxVxRlw==/base.apk!libhello-jni.so (offset 0x1eb000) (Java_com_example_hellojni_HelloJni_stringFromJNI+64) (BuildId: a3c5eaaea97fd36b2fce9c5b81266ed28b5cb6a3)
      #03 pc 0000000000150350  /apex/com.android.runtime/lib64/libart.so (art_quick_generic_jni_trampoline+144) (BuildId: 762960c75ada06c48e438df6df29b0a1)
      #04 pc 0000000000147334  /apex/com.android.runtime/lib64/libart.so (art_quick_invoke_stub+548) (BuildId: 762960c75ada06c48e438df6df29b0a1)
      #05 pc 00000000001561b4  /apex/com.android.runtime/lib64/libart.so (art::ArtMethod::Invoke(art::Thread*, unsigned int*, unsigned int, art::JValue*, char const*)+252) (BuildId: 762960c75ada06c48e438df6df29b0a1)
      #06 pc 00000000002fd900  /apex/com.android.runtime/lib64/libart.so (art::interpreter::ArtInterpreterToCompiledCodeBridge(art::Thread*, art::ArtMethod*, art::ShadowFrame*, unsigned short, art::JValue*)+384) (BuildId: 762960c75ada06c48e438df6df29b0a1)
      #07 pc 00000000002f8bd0  /apex/com.android.runtime/lib64/libart.so (bool art::interpreter::DoCall<false, false>(art::ArtMethod*, art::Thread*, art::ShadowFrame&, art::Instruction const*, unsigned short, art::JValue*)+912) (BuildId: 762960c75ada06c48e438df6df29b0a1)
...
```

`backtrace` 信息可以大致定位 `crash` 发生的位置。

### 工具

#### addr2line
**`格式：`**
```
addr2line -e XXX.so -f -a -p -C
```

* **`-f`**：在显示文件名、行号信息的同时显示函数名。
* **`-a`**：在函数名、文件名和行号信息之前，以十六进制形式显示地址。
* **`-p`**：使打印更加人性化：每个地址(location)的信息都打印在一行上。
* **`-C`**：将低级别的符号名解码为用户级别的名字。

#### ndk-stack
[ndk-stack](https://developer.android.com/ndk/guides/ndk-stack?hl=zh-cn)
