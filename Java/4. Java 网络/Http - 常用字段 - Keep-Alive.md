什么是Keep-Alive模式？

> 我们知道HTTP协议采用“请求-应答”模式，当使用普通模式，即非KeepAlive模式时，每个请求/应答客户和服务器都要新建一个连接，完成之后立即断开连接（HTTP协议为无连接的协议）；当使用Keep-Alive模式（又称持久连接、连接重用）时，Keep-Alive功能使客户端到服务器端的连接持续有效，当出现对服务器的后继请求时，Keep-Alive功能避免了建立或者重新建立连接。

![image](http://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/HTTP_persistent_connection.svg/450px-HTTP_persistent_connection.svg.png)

http 1.0中默认是关闭的，需要在http头加入"Connection: Keep-Alive"，才能启用Keep-Alive；http 1.1中默认启用Keep-Alive，如果加入"Connection: close "，才关闭。

在Keep-Alive模式下，客户端如何判断请求所得到的响应数据已经接收完成？

> Keep-Alive关闭模式下，HTTP协议中客户端发送一个小请求，服务器响应以所期望的信息（例如一个html文件或一副gif图像）。服务器通常在发送回所请求的数据之后就关闭连接。这样客户端读数据时会返回EOF（-1），就知道数据已经接收完全了。

Keep-Alive模式下发送完数据HTTP服务器不会自动断开连接，所有不能再使用返回EOF（-1）来判断（当然你一定要这样使用也没有办法，可以想象那效率是何等的低）！有绍两种来判断方法。

1. 使用消息首部字段Conent-Length
> Conent-Length表示实体内容长度，客户端（服务器）可以根据这个值来判断数据是否接收完成。
2. 使用消息首部字段[Transfer-Encoding](https://zh.wikipedia.org/wiki/%E5%88%86%E5%9D%97%E4%BC%A0%E8%BE%93%E7%BC%96%E7%A0%81)
> 然而，使用分块传输编码，数据分解成一系列数据块，并以一个或多个块发送，这样服务器可以发送数据而不需要预先知道发送内容的总大小。通常数据块的大小是一致的，但也不总是这种情况。

==如果一个HTTP消息（请求消息或应答消息）的Transfer-Encoding消息头的值为chunked，那么，消息体由数量未定的块组成，并以最后一个大小为0的块为结束。==

每一个非空的块都以该块包含数据的字节数（字节数以十六进制表示）开始，跟随一个CRLF （回车及换行），然后是数据本身，最后块CRLF结束。在一些实现中，块大小和CRLF之间填充有白空格（0x20）。

最后一块是单行，由块大小（0），一些可选的填充白空格，以及CRLF。最后一块不再包含任何数据，但是可以发送可选的尾部，包括消息头字段。

消息最后以CRLF结尾。

编码的应答
```
HTTP/1.1 200 OK
Content-Type: text/plain
Transfer-Encoding: chunked

25
This is the data in the first chunk

1C
and this is the second one

3
con

8
sequence

0
```

解码的数据
```
This is the data in the first chunk
and this is the second one
consequence
```
