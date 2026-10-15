[大文件上传 - 分片上传 + 断点续传](https://juejin.cn/post/6844904046436843527#comment)

[HTTP 断点续传](https://blog.csdn.net/liang19890820/article/details/53215087)

#### 断点续传
断点续传根据 `Http 1.1` 提供的 `Range` 和 `Content-Range` 实现。

##### `Range`

用于请求头中，指定第一个字节的位置和最后一个字节的位置，一般格式：

```
Range:(unit=first byte pos)-[last byte pos]
```

`Range` 头部的格式有以下几种情况：

`Range: bytes=0-499`：表示第 0-499 字节范围的内容
`Range: bytes=500-999`：表示第 500-999 字节范围的内容
`Range: bytes=-500`：表示最后 500 字节的内容
`Range: bytes=500-`：表示从第 500 字节开始到文件结束部分的内容
`Range: bytes=0-0,-1`：表示第一个和最后一个字节
`Range: bytes=500-600,601-999`：同时指定几个范围

##### `Content-Range`

用于响应头中，在发出带 `Range` 的请求后，服务器会在 `Content-Range` 头部返回当前接受的范围和文件总大小。一般格式：

```
Content-Range: bytes (unit first byte pos) - [last byte pos]/[entity legth]
```

例如：

```
Content-Range: bytes 0-499/22400
```

0－499 是指当前`接收/发送？`的数据的范围，而 22400 则是文件的总大小。

而在响应完成后，返回的响应头内容也不同：

* HTTP/1.1 200 Ok（不使用断点续传方式）
* HTTP/1.1 206 Partial Content（使用断点续传方式）

#### 分片上传
