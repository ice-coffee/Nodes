[toc]

## protobuf 数据说明

`protobuf` 的二进制里**根本不存名字**——既没有包名、也没有消息名，连字段名都没有。解析靠的是字段编号。

```proto
message Frame {
  string topic = 1;
  bytes value = 2;
}
```

给 `topic` 赋值 `"ab"` 后，序列化结果只有 4 个字节：

```
0A 02 61 62
│  │  └──┴── "ab" 的 UTF-8 字节
│  └─ 长度 = 2
└─ tag: 0x0A = 0b00001010 → 字段号 1，wire type 2（length-delimited）
```

tag 的计算方式是 `(字段号 << 3) | wire_type`。整条消息就是一串 `(字段号, 类型, 值)` 三元组的拼接。

`wire_type` 占 3 bit，标识字段值在字节流中该按什么方式解析：

| wire_type 值 | 名称 | 含义 | 对应字段类型 |
|---|---|---|---|
| 0 | VARINT | 变长整数编码 | int32, int64, uint32, uint64, sint32, sint64, bool, enum |
| 1 | I64 | 固定 8 字节 | fixed64, sfixed64, double |
| 2 | LEN | 先写长度再写内容，长度可变 | string, bytes, embedded messages, packed repeated 字段 |
| 3 | SGROUP（已废弃） | 分组开始 | 旧版 group 语法 |
| 4 | EGROUP（已废弃） | 分组结束 | 旧版 group 语法 |
| 5 | I32 | 固定 4 字节 | fixed32, sfixed32, float |

`wire_type` 只决定"按几个字节/哪种方式读"，不携带字段名和具体类型信息（如 `wire_type`=0 无法区分是 `int32` 还是 `bool`），这也是为什么 `protoc --decode_raw` 只能看到字段号和 `wire_type`，无法还原字段语义。

反序列化时读到 tag `0x0A`，就知道「1 号字段、变长类型」，再去本地那份 `.proto` 编译出的代码里查 1 号字段该填哪个变量。两端只要**字段编号和类型对齐**就能通信，各自把类叫什么名、放在哪个包下，对方不知道也不需要知道。

这也解释了 protobuf 的几个特性其实是同一个原因：

* 字段改名不破坏兼容性（名字不在 wire 上）
* 字段编号绝对不能复用（编号是唯一的身份标识）
* 收到不认识的编号可以安全跳过（靠 wire type 就知道跳几个字节）

## protobuf 结构说明

### 标量类型

**整数类型**

* `int32` / `int64` — 变长编码，适合正数（负数编码效率低）
* `uint32` / `uint64` — 无符号整数
* `sint32` / `sint64` — 变长编码，采用 ZigZag 编码，适合负数较多的场景
* `fixed32` / `fixed64` — 固定 4/8 字节编码，数值较大时比 varint 更省空间
* `sfixed32` / `sfixed64` — 固定字节的有符号版本

**浮点类型**

* `float` — 32 位单精度浮点数
* `double` — 64 位双精度浮点数

**布尔类型**

* `bool` — true/false

**字符串与字节**

* `string` — UTF-8 或 7-bit ASCII 文本，长度上限约 2^32
* `bytes` — 任意二进制数据

**其他**

* `enum` — 枚举，底层按 `int32` 的 varint 编码

这几种类型和前面 `wire_type` 表格是对应的：VARINT 对应各种 int/uint/sint/bool/enum，I64/I32 对应 fixed 系列和 float/double，LEN 对应 string/bytes/嵌套 message。

### 类型定义

#### message

定义消息类型，proto 中最基本的数据结构，每个字段都有类型、字段名和字段号。

#### oneof

在 **Protocol Buffers（proto）** 中，`oneof` 表示一个字段组中 **同一时刻最多只能设置一个字段**。

**`示例：`**

```proto
message MyMessage {
  oneof result {
    string name = 1;
    int32 value = 2;
  }
}
```

**`说明：`**

* `oneof result` 表示定义了一个互斥字段集合。
* `name` 和 `value` 共用**同一块内存空间**，节省空间。
* **任意时刻只允许其中一个字段设置有值**。如果你设置了 `name`，再设置 `value` 就会被清除。
* 默认值时，`oneof` 中未设置任何字段。


```cpp
MyMessage msg;
msg.set_value(123);       // 设置 value 字段
std::cout << msg.value(); // 输出 123

msg.set_name("Bob");   // 设置 name，会自动清除 value
std::cout << msg.name();  // 输出 "Bob"
```

**`判断当前设置的是哪个字段：`**

```proto
oneof <name> {
  ...
}
```

会自动生成一个方法：

```cpp
<name>_case()
```

所以判断当前设置的是那个字段可以通过如下判断：

```cpp
switch (msg.result_case()) {
  case MyMessage::kName:
    std::cout << "Name: " << msg.name();
    break;
  case MyMessage::kValue:
    std::cout << "Value: " << msg.value();
    break;
  case MyMessage::RESULT_NOT_SET:
    std::cout << "No field is set";
    break;
}
```

#### enum

定义枚举类型。

### 文件级声明

#### syntax

指定 proto 语法版本，如 `syntax = "proto3"`。

#### option

设置文件/消息/字段级选项，如 `java_package`、`deprecated` 等都是通过 `option` 语法实现的。

#### package、import

| 关键字            | 管什么             | 作用域                  |
| -------------- | --------------- | -------------------- |
| `import`       | 找文件（磁盘路径）       | protoc 编译期解析依赖       |
| `package`      | proto 世界里的类型全名  | 跨文件引用、gRPC 路径、Any    |

**`说明：`**

* `import` 的值是文件**相对 `-I` 根目录的真实路径**。protoc 拿它去磁盘上做路径拼接，**不看被导入文件里写的 package 是什么**。
* `package` 给文件里所有 message 加前缀。import 进来后引用类型要用这个全名（同 package 下可省略前缀）。它和文件放在哪个目录**没有任何关系**。

#### java_package

`java_package` 管的是 Java 世界里的包名，只在生成 Java 代码那一步起作用，**输出目录由 protoc 按它自动创建**，不用手动建。

它和 `package` 是两套独立的命名空间：`package` 影响的是 proto 层面的类型全名（跨文件引用、gRPC 路径、`Any` 的 type URL），`java_package` 只影响生成的 `.java` 文件放在哪个包下，两者可以不一致，互不影响。

#### reserved

保留已废弃的字段号或字段名，防止后续被误复用。

**`示例：`**

```proto
message Foo {
  reserved 2, 15, 9 to 11;   // 保留字段号
  reserved "foo", "bar";     // 保留字段名
}
```

**`说明：`**

* 删除或改动一个字段后，字段号（和 JSON/文本序列化会用到的字段名）不能立刻被新字段复用，否则旧数据用新定义解析时会张冠李戴——这正是前面提到的"字段编号是唯一身份标识"的直接体现。
* `reserved` 就是把这些废弃的编号/名字登记下来，protoc 编译时如果发现有新字段占用了被保留的编号或名字，会直接报错，防止团队里其他人不知情而误用。
* 字段号和字段名的 `reserved` 是两条独立的语句，不能写在一起（如上面示例分两行）。
* 编号区间用 `to` 表示闭区间，如 `9 to 11` 表示 9、10、11 都被保留。

**`典型场景：`**

下线某个字段时，与其直接删掉字段定义，更安全的做法是先把字段标记为 `deprecated`，确认没有历史数据/调用方依赖后再删除定义并加上 `reserved`，而不是让编号空出来被后人无意中复用。

### 字段修饰符

#### repeated

重复字段，对应目标语言的列表/数组。

#### optional

显式可选字段，proto3 中用于区分"未设置"和"取默认值"。

**`背景：`**

proto3 早期版本中，所有单值字段（非 `repeated`、非 `message`）都没有"是否被设置"的概念，序列化后拿到的默认值（如 `0`、`""`、`false`）既可能是对方显式赋的值，也可能是压根没赋值。proto3.15 之后重新引入了 `optional` 关键字来解决这个问题。

**`示例：`**

```proto
message MyMessage {
  optional int32 age = 1;
  int32 score = 2;   // 不加 optional，默认值和"未设置"无法区分
}
```

**`说明：`**

* 加了 `optional` 的字段会生成一个 `has_<字段名>()` 方法（C++/Java）或对应语言的判断方式（如 Python 的 `HasField`），用来判断字段是否被显式设置过，而不用去猜是不是默认值。
* 底层实现上，`optional` 字段其实是被编译成了一个只含该字段的隐藏 `oneof`，复用了 `oneof` 自带的"是否设置"语义（这也是为什么 `optional` 字段和 `oneof` 字段不能同时用在同一个字段上）。
* `message` 类型的字段本身天然就能区分"未设置"（指针为空/为 None）和"空对象"，所以不需要、也不能加 `optional`；`optional` 只用于标量类型字段。
* proto2 中所有字段默认就是 `optional` 语义（相对 `required` 而言），proto3 引入的 `optional` 关键字是把这种"可判断是否设置"的能力选择性地加回来，而不是恢复 proto2 的 `required`/`optional` 体系。

#### map

`map<K, V>` 映射类型字段，`key` 只能是整型或 `string`，不能是 `repeated`。