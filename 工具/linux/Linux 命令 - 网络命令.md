### ping

### telnet
**简介：**
`telnet` 是一个经典的网络调试命令，它可以验证 **TCP 层的连通性**，
是排查端口是否可访问的基础工具之一。

`telnet`（TELecommunication NETwork）最初是一种远程登录协议，现在更多用作**TCP 端口连通性测试工具**。

**作用：**
* 域名能否解析为 IP
* 对方主机是否在线
* 指定端口是否开放
* 是否被防火墙或代理阻断

**命令基本格式：**

```bash
telnet [主机名或IP] [端口号]
```

**示例：**

```bash
telnet intelligentmap-api.baidu.com 443
```

**常见用法示例：**

1. 测试是否能访问 `HTTP` 服务（端口 80）

```bash
// 如果显示 `Connected`，表示 TCP 连接成功。
telnet www.baidu.com 80
```

2. 测试是否能访问 `HTTPS` 服务（端口 443）

```bash
telnet www.baidu.com 443
```

如果结果是：
```
Connected to www.baidu.com.
Escape character is '^]'.
Connection closed by foreign host.
```

说明：

* DNS 正常
* 端口 443 正常
* TCP 建立后被远端关闭（因为 telnet 不是 HTTPS 协议）

3. 检查本机 `8080` 服务（如本地开发服务器、Tomcat、Spring Boot）

```bash
telnet 127.0.0.1 8080
```

### nc
`nc`（**netcat** 的缩写）是网络调试、端口扫描、和数据传输中最常用的底层工具之一。
它被称为：“网络界的瑞士军刀（Swiss Army Knife of Networking）”。

用于：
* 测试 TCP/UDP 端口是否开放
* 在两台主机之间建立 TCP/UDP 连接
* 传输文件或数据
* 模拟服务器或客户端

**格式：**

```bash
nc [选项] 主机名 端口号
```

例如：

```bash
nc intelligentmap-api.baidu.com 443
```

**常见用法：**

1. 检查端口是否开放（最常见）

```bash
nc -vz intelligentmap-api.baidu.com 443
```

输出示例：

```
Connection to intelligentmap-api.baidu.com 443 port [tcp/https] succeeded!
```

含义：

* `-v`：显示详细信息（verbose）
* `-z`：扫描模式，不发送数据，只探测端口状态

如果失败，会提示：

```
nc: connect to intelligentmap-api.baidu.com port 443 (tcp) failed: Connection refused
```

2. 检查多个端口

```bash
nc -vz intelligentmap-api.baidu.com 80 443 8080
```

或指定范围：

```bash
nc -vz intelligentmap-api.baidu.com 1-1024
```

3. 监听端口（模拟服务器）

```bash
nc -l 9999
```

意思是：

> 本机在 9999 端口上监听 TCP 连接。

另一台机器可以连接：

```bash
nc <你的IP> 9999
```

两边就能互相聊天（或发送数据）。

4. 传输文件

发送端：

```bash
nc -l 1234 < file.txt
```

接收端：

```bash
nc sender_host 1234 > file.txt
```

这相当于一个简易的文件传输服务，甚至可以跨平台使用。

5. 模式

默认是 TCP，如需测试 UDP：

```bash
nc -u -vz 192.168.1.10 53
```

（常用于 DNS 服务端口测试）

6. 设置超时时间

```bash
nc -vz -w 5 intelligentmap-api.baidu.com 443
```

* `-w 5`：设置连接超时为 5 秒。

#### ping/telnet/nc 对比

| 工具              | 工作层           | 协议      | 能测试什么         | 无法测试什么              | 常见用途           |
| --------------- | ------------- | ------- | ------------- | ------------------- | -------------- |
| **ping**        | 网络层 (ICMP)    | ICMP    | 主机是否可达、网络延迟   | 端口是否开放              | 基础连通性、网络延迟测试   |
| **telnet**      | 传输层 (TCP)     | TCP     | 指定端口是否可连接     | 不支持 UDP、不支持 SSL/TLS | 检查端口是否通、简单交互   |
| **nc (netcat)** | 传输层 (TCP/UDP) | TCP/UDP | TCP/UDP 端口连通性 | 不会显示加密协议层信息         | 测试端口、监听端口、脚本调试 |
