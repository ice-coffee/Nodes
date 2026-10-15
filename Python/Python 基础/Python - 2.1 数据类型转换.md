`Python` 数据类型转换可以分为两种：

* 隐式类型转换 - 自动完成
* 显式类型转换 - 需要使用类型函数来转换

| 函数 | 描述 |
| --- | --- |
| int(x [,base]) | 将x转换为一个整数 |
| float(x) | 将x转换到一个浮点数 |
| str(x) | 将对象 x 转换为字符串 |
| ... | ... |

### to_bytes、from_bytes
`to_bytes、from_bytes` 是整数类型包含的方法：

返回表示一个整数的字节数组：
```python
int.to_bytes(length, byteorder, *, signed=False)
```

* `length`：返回的字节数组长度。如果整数的字节表示小于指定的长度，则会进行零填充（默认情况下，填充在字节串的前面）。
如果整数无法用指定的字节数表示，会抛出 `OverflowError` 错误；
* `byteorder`：字节序，（'big'：大端序、'little'：小端序）；
* `signed`：是否为有符号整数，默认为 `False`；

返回由给定字节数组所表示的整数：
```python
int.from_bytes(bytes, byteorder, *, signed=False)
```



### struct
[struct --- 将字节串解读为打包的二进制数据](https://docs.python.org/zh-cn/3.13/library/struct.html)

在 `Python` 中，`struct` 模块用于在 `Python 数据类型` 和 `C 风格的二进制数据` 之间进行转换。它可以将 `Python` 的基本数据类型（如整数、浮点数、字符串）打包成二进制格式（字节流），也可以从二进制数据中解析出对应的 `Python` 数据类型。

这个模块特别适合用于处理低级别的二进制数据，例如网络协议、文件格式、嵌入式开发中的数据交换。


#### 常用方法

* `struct.pack(fmt, v1, v2, ...)`

根据指定的格式字符串 `fmt`，将数据 v1, v2, ... 打包成字节对象。

**示例**:
```python
import struct

# 将整数 1 和浮点数 2.5 打包为二进制数据
data = struct.pack('i f', 1, 2.5)
print(data)  # 输出：b'\x01\x00\x00\x00\x00\x00 @'
```

* `struct.unpack(fmt, buffer)`

根据格式字符串 `fmt`，从二进制数据 buffer 中解包出对应的 Python 数据。

**示例**:
```python
import struct

# 解包之前的数据
data = b'\x01\x00\x00\x00\x00\x00 @'
result = struct.unpack('i f', data)
print(result)  # 输出：(1, 2.5)
```

* `struct.calcsize(fmt)`

返回指定格式字符串 `fmt` 所对应的结构的字节大小。

**示例**:
```python
import struct

size = struct.calcsize('i f')
print(size)  # 输出：8
```

* `struct.iter_unpack(fmt, buffer)`

类似于 `unpack`，但适用于解包多个相同格式的结构。

**示例**:
```python
import struct

data = b'\x01\x00\x00\x00\x00\x00 @\x02\x00\x00\x00\x00\x00\x10@'
for item in struct.iter_unpack('i f', data):
    print(item)
# 输出：
# (1, 2.5)
# (2, 4.0)
```

#### 格式字符串
每个格式字符串都是由两部分组成：

* **一个可选前缀字符**：表示字节顺序，大小和对齐方式；
* **一个或多个格式字符**：表示实际数据类型。

**前缀字符**：
| 字符 | 字节顺序 | 大小 | 对齐方式 |
| --- | --- | --- | --- |
| `@` | 按原字节 | 按原字节 | 按原字节 |
| `=` | 按原字节 | 标准 | 无 |
| `<` | 小端 | 标准 | 无 |
| `>` | 大端 | 标准 | 无 |
| `!` | 网络（=大端） | 标准 | 无 |

> 注意：如果你希望在不同平台上结果一致，建议使用显式的字节序（`<` 或 `>`）和无对齐规则（`=` 或 `!`）。

**格式字符**：
见 `struct` 链接。

#### 字节对齐
