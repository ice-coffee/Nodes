`protoc` 是 Protocol Buffers 的编译器，用于将 `.proto` 文件编译成目标语言的源代码（如 C++、Java、Python 等）；还可以反编译 `protobuf` 二进制数据。以下是 `protoc` 命令的详细说明，包括常用参数和使用示例。

### 示例 proto 文件

以下命令示例均基于该 `proto/my_message.proto` 文件：

```protobuf
syntax = "proto3";

package mypackage;

message MyMessage {
  int32 id = 1;
  string name = 2;
  repeated string tags = 3;
}
```

### 基本命令格式

```bash
protoc [OPTIONS] PROTO_FILES
```

### 常用参数说明

| 参数                            | 说明                          |
| ----------------------------- | --------------------------- |
| `--proto_path=PATH`、`-I PATH` | 指定 `.proto` 文件的搜索路径（可多个）    |
| `--cpp_out=DIR`               | 生成 C++ 代码并输出到指定目录           |
| `--java_out=DIR`              | 生成 Java 代码                  |
| `--python_out=DIR`            | 生成 Python 代码                |
| `--descriptor_set_out=FILE`   | 生成二进制 `.pb` 描述文件，常用于反射或插件   |
| `--plugin=NAME=PATH`          | 指定自定义插件，如 `protoc-gen-grpc` |
| `--version`                   | 显示 protoc 的版本信息             |
| `--help`                      | 显示帮助信息                      |

### 生成目标平台文件

1. **编译为 C++ 源文件：**

```bash
protoc -I=. --cpp_out=./out proto/my_message.proto
```

输出文件：

```
./out/message.pb.h
./out/message.pb.cc
```

2. **编译为 Python 文件**

```bash
protoc -I=proto --python_out=./out proto/my_message.proto
```

输出文件：

```
./out/my_message_pb2.py
```

3. **编译为 Java 文件**

```bash
protoc -I=proto --java_out=./out proto/my_message.proto
```

输出文件：

```
./out/my_message_pb2.java
```

### Protobuf 数据解析

除了编译 `.proto` 文件，`protoc` 还可以反过来解码二进制 protobuf 数据，方便调试。

1. **已知 `.proto` 定义时，按消息类型解码：**

```bash
protoc -I=proto --decode=mypackage.MyMessage proto/my_message.proto < data.bin
```

输出对应字段的文本格式（类似 proto text format），便于人工查看。

2. **不知道具体消息结构时，按原始字节解码：**

```bash
protoc --decode_raw < data.bin
```

只能看到字段编号（field number）和 wire type，无法还原字段名和语义，适合快速排查数据是否是合法的 protobuf 编码，或大致判断字段数量/类型。

3. **反向操作，将文本格式编码为二进制：**

```bash
protoc -I=proto --encode=mypackage.MyMessage proto/my_message.proto < data.txt > data.bin
```
