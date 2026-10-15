### 关于 HTTP 协议
[HTTP响应头和请求头信息对照表](http://tools.jb51.net/table/http_header)

HTTP协议是Hyper Text Transfer Protocol（超文本传输协议）的缩写,是用于从万维网（WWW:World Wide Web ）服务器传输超文本到本地浏览器的传送协议。

HTTP是一个基于TCP/IP通信协议来传递数据（HTML 文件, 图片文件, 查询结果等）。

HTTP是一个属于应用层的面向对象的协议。

### HTTP请求构建

![image](https://static001.geekbang.org/resource/image/10/74/10ff27d1032bf32393195f23ef2f9874.jpg)

HTTP 的请求报文大概分为三大部分。==请求行==、==请求头==、==请求体==。

实例：

```
POST /mistats/v3 HTTP/1.1
Content-Type: application/x-www-form-urlencoded
User-Agent: Dalvik/2.1.0 (Linux; U; Android 8.0.0; MIX 2 MIUI/V10.3.1.0.ODECNXM)
Host: data.mistat.xiaomi.com
Connection: Keep-Alive
Accept-Encoding: gzip
Content-Length: 729

p=N5WVkjzNRPtuNK3FjXCw6ut8NsA5y6ljg%2B5iofv
```

```
GET /api/recommend/product/code?recommendCode=WNTJ&currentPage=1&pageSize=20 HTTP/1.1
token: 
num: 0
terminalId: android|f5801e8c-9cb9-39c6-81b7-c1616a69bb5c
channel: vivo
version: 2.1.1
Host: api.test.vipchosen.com
Connection: Keep-Alive
Accept-Encoding: gzip
User-Agent: okhttp/3.9.1
```

1. 请求行

[请求方法][请求URL][协议名称及版本号]

请求方法：
- GET
- POST
- PUT
- DELETE
- 等等

注意：
> ==纠正一个问题不管请求方法是GET还是POST，请求参数都可以存在于请求行中的请求地址里，也可以在请求体中==。

> ==请求URL和请求头的Host属性组成完整的请求URL==。

2. 请求头

请求行下面就是我们的首部字段。首部是 key value，通冒号分隔。这里面，往往保存了一些非常重要的字段。

注意：
> ==开发中经常说的在请求头中添加参数就是添加在请求首部。==

3. 请求体

传递数据

### HTTP 返回构建

![image](https://static001.geekbang.org/resource/image/1c/c1/1c2cfd4326d0dfca652ac8501321fac1.jpg)

HTTP 的响应构建分为==响应状态行==、==响应头==、==响应体==。
