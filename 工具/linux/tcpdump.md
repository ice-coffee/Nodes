---
id: 20260808-001
tags: [Linux, 网络抓包, tcpdump, 网络排障]
aliases: [tcpdump, packet capture, 抓包工具]
created: 2026-08-08
updated: 2026-08-08
source: ""
status: draft
---

# tcpdump

## 一句话定义
`tcpdump` 是 Linux 和 macOS 上基于 libpcap 的命令行抓包工具，用于捕获、过滤和分析经过网络接口的数据包。

## 核心理解
- **是什么**：一个在网卡或网络接口上捕获数据包，并按过滤表达式输出摘要或原始内容的命令行工具。
- **为什么需要它**：应用日志只能说明程序观察到的结果，`tcpdump` 可以直接观察 DNS、TCP、HTTP、TLS 等协议在网络上的实际交互。
- **它解决了什么问题**：帮助定位连接失败、端口不可达、DNS 异常、TCP 重传、连接建立缓慢、请求未发出或响应未返回等网络问题。

## 详细解释
### 基本工作流程
`tcpdump` 的使用通常分为四步：

1. 选择正确的网络接口。
2. 使用 BPF（Berkeley Packet Filter）表达式缩小抓包范围。
3. 选择输出方式：终端摘要、十六进制内容或 pcap 文件。
4. 结合时间戳、源/目的地址、端口和 TCP 标志分析通信过程。

基本格式：

```bash
tcpdump [选项] [过滤表达式]
```

最小示例：

```bash
sudo tcpdump -i any
```

### 抓包权限
抓取网络接口通常需要管理员权限：

```bash
sudo tcpdump -i en0
```

也可以通过系统权限配置让特定用户访问抓包能力，但在临时排障时使用 `sudo` 更直接。抓包内容可能包含账号、Cookie、请求参数等敏感信息，保存和共享 pcap 文件前应先确认合规性。

### 过滤表达式
过滤表达式在内核或捕获层尽早执行，可以降低输出噪声和分析成本。常用条件包括：

- `host 192.168.1.10`：匹配源或目的地址。
- `src host 192.168.1.10`：只匹配源地址。
- `dst host 192.168.1.10`：只匹配目的地址。
- `port 443`：匹配源端口或目的端口。
- `tcp`、`udp`、`icmp`：匹配协议。
- `and`、`or`、`not`：组合或排除条件。

过滤表达式建议使用单引号包围，避免 shell 对括号等字符进行解释。

## 常用用法
### `-D`：列出可抓包接口

作用：在不知道接口名称时先查看可用接口。

```bash
sudo tcpdump -D
```

常见接口：

- Linux 物理网卡通常类似 `eth0`、`ens33`。
- macOS 无线网卡通常类似 `en0`。
- `lo` 或 `lo0` 是本地回环接口。
- `any` 在 Linux 上表示抓取所有可用接口，但不是所有系统都支持。

### `-i`：指定网络接口

作用：只捕获指定接口上的数据包，减少无关流量。

```bash
sudo tcpdump -i en0
```

抓取本机回环通信：

```bash
sudo tcpdump -i lo0
```

注意：访问 `127.0.0.1` 或 `localhost` 的请求不会经过物理网卡，抓不到时应检查回环接口。

### `-n` / `-nn`：禁止名称解析

作用：直接显示 IP 和端口数字，避免 DNS 或服务名解析干扰抓包。

```bash
sudo tcpdump -i any -nn
```

- `-n`：不把 IP 地址解析为域名。
- `-nn`：同时不把端口解析为服务名，例如显示 `443`，而不是 `https`。

排障时通常推荐使用 `-nn`，因为输出更快、更稳定，也更容易复制搜索。

### `-c`：限制抓包数量

作用：抓取指定数量的数据包后自动退出。

```bash
sudo tcpdump -i any -nn -c 20
```

适合快速验证过滤条件和执行自动化采样，避免命令持续运行。

### `-s`：设置抓包长度

作用：控制每个数据包最多捕获多少字节。

```bash
sudo tcpdump -i any -nn -s 0
```

`-s 0` 表示尽量捕获完整数据包。默认 snaplen 较小时，可能只能看到包头，导致应用层内容被截断。完整抓包会增加磁盘和内存压力，应配合过滤条件和抓包时长使用。

### `-v` / `-vv` / `-vvv`：增加输出详细程度

作用：显示更多协议字段。

```bash
sudo tcpdump -i any -nn -vv tcp port 443
```

详细程度越高，输出越多，但并不代表一定能解析出加密的应用层内容。

### `-X` / `-A`：查看数据内容

`-X` 同时显示十六进制和 ASCII 内容：

```bash
sudo tcpdump -i any -nn -X -s 0 'tcp port 80'
```

`-A` 只尝试以 ASCII 文本显示内容：

```bash
sudo tcpdump -i any -nn -A 'tcp port 80'
```

这类方式适合观察明文 HTTP、简单文本协议或调试自定义协议。HTTPS、SSH 等加密流量通常只能分析连接元数据，不能直接读出明文请求。

### `-w` / `-r`：保存和读取 pcap 文件

保存原始数据包：

```bash
sudo tcpdump -i any -nn -s 0 -w /tmp/request.pcap 'host 10.0.0.8 and port 8080'
```

读取已有抓包文件：

```bash
tcpdump -nn -r /tmp/request.pcap
```

读取时再次过滤：

```bash
tcpdump -nn -r /tmp/request.pcap 'tcp[tcpflags] & tcp-syn != 0'
```

`-w` 输出的是 pcap 文件，不是适合直接阅读的文本；可以用 `tcpdump -r` 或 Wireshark 进一步分析。

### `-G` / `-W`：按时间轮转文件

长时间抓包时，可以按时间切分文件：

```bash
sudo tcpdump -i any -nn -s 0 -G 60 -W 10 \
  -w '/tmp/capture-%Y%m%d-%H%M%S.pcap' 'port 443'
```

这表示每 60 秒生成一个文件，并保留最多 10 个文件。具体行为可能受 tcpdump 版本影响，生产环境应先验证文件轮转和磁盘容量。

### `-tttt`：显示可读时间戳

作用：显示包含日期和时间的时间戳，便于和应用日志对齐。

```bash
sudo tcpdump -i any -nn -tttt 'host 10.0.0.8'
```

### 过滤 HTTP 端口

```bash
sudo tcpdump -i any -nn -A -s 0 'tcp port 80'
```

用于观察明文 HTTP 请求和响应的头部或内容。注意 TCP 数据可能被拆分、合并或乱序，单个输出包不一定对应完整的 HTTP 请求。

### 过滤 DNS

```bash
sudo tcpdump -i any -nn -vv 'udp port 53 or tcp port 53'
```

UDP 是常见的 DNS 传输方式；响应较大、启用 DNS over TCP 或发生截断时，也可能使用 TCP 53。

### 观察 TCP 三次握手

```bash
sudo tcpdump -i any -nn 'tcp[tcpflags] & (tcp-syn|tcp-ack) != 0'
```

更严格地只看初始 SYN：

```bash
sudo tcpdump -i any -nn 'tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack == 0'
```

通常可以看到：

1. 客户端发送 `SYN`。
2. 服务端返回 `SYN, ACK`。
3. 客户端发送 `ACK`。

如果只有 SYN 没有响应，可能涉及路由、防火墙、服务未监听或返回路径异常；不能仅凭一条抓包结果直接断定具体原因。

### 查看 TCP 重传、RST 和异常标志

```bash
sudo tcpdump -i any -nn \
  'tcp[tcpflags] & (tcp-rst|tcp-fin) != 0'
```

也可以保存完整抓包后交给 Wireshark 统计重传、重复 ACK、窗口变化和 RTT。`tcpdump` 适合快速筛选和现场采样，复杂 TCP 时序分析通常需要更专业的图形化工具。

## 关键要点
- 先用 `tcpdump -D` 确认接口，再开始抓包；抓不到包时首先检查接口和回环流量。
- 排障时通常组合使用 `-i`、`-nn`、`-s 0`、`-c` 和过滤表达式。
- `-w` 保存的是原始 pcap 数据，适合后续重复分析；不要只保存终端摘要。
- `tcpdump` 能看到加密连接的地址、端口、握手和包长，但不能直接解密 HTTPS 或 SSH。
- 抓包文件可能包含敏感数据，必须限制权限、控制保存时长，并谨慎上传或共享。

## 例子与边界
### 基础用法：确认某个地址是否有流量

```bash
sudo tcpdump -i any -nn -c 30 'host 10.0.0.8'
```

适合先确认目标主机是否确实产生或接收网络流量，再继续缩小到具体端口。

### 典型用法：排查应用访问超时

```bash
sudo tcpdump -i any -nn -tttt -s 0 \
  -w /tmp/api-timeout.pcap \
  'host 10.0.0.8 and tcp port 8443'
```

分析时重点关注：

- 是否发出了 SYN。
- 是否收到 SYN-ACK。
- 建立连接后是否有应用数据。
- 请求后是否收到服务端响应。
- 是否出现 RST、重传或长时间无数据。

### 典型用法：排查 DNS

```bash
sudo tcpdump -i any -nn -vv -c 50 \
  'udp port 53 or tcp port 53'
```

重点观察查询是否发出、响应是否返回、响应地址是否正确，以及是否发生超时或重试。

### 反例：过滤条件过宽

```bash
sudo tcpdump -i any
```

错误不在于命令不能执行，而在于输出通常包含大量无关流量，容易错过目标请求，也会增加终端输出和分析成本。应尽快增加 `host`、`port` 或协议条件。

### 反例：只抓物理网卡排查本地服务

```bash
sudo tcpdump -i en0 'port 8080'
```

如果客户端和服务端都运行在本机，并通过 `127.0.0.1:8080` 通信，流量通常出现在 `lo0` 或 `lo`，而不是 `en0`。

### 边界情况

- 在容器、虚拟机、网络命名空间中，宿主机接口未必能看到容器内的完整通信，需要在正确的命名空间或 veth 接口中抓包。
- 使用 `any` 时，Linux 上可能看不到精确的链路层头部，若需要分析 VLAN、MAC 或特定链路层信息，应选择具体接口。
- 高流量接口上抓完整包可能造成丢包、磁盘写满或性能影响，应缩小过滤范围、限制时长或使用轮转文件。
- HTTPS、HTTP/2、HTTP/3、QUIC 等协议的应用内容可能被加密或复用，不能把 tcpdump 的每个数据包简单等同于一个业务请求。

## 关系与连接
- **前置知识**：OSI/TCP-IP 分层、IP 地址、端口、TCP 三次握手、DNS、HTTP、TLS。
- **关联概念**：`libpcap`、BPF 过滤器、Wireshark、`tshark`、`ss`、`netstat`、`nc`。
- **容易混淆**：抓到 SYN 只说明看到连接尝试，不代表 TCP 连接已经成功；看到 TCP 连接成功也不代表应用协议请求成功。
- **上位/下位知识**：上位知识是网络可观测性与数据包分析；下位内容包括 TCP 标志过滤、DNS 抓包、HTTP 明文分析和 pcap 离线分析。

### 与相近工具对比

- `tcpdump`：命令行实时抓包和快速过滤，适合服务器现场排障。
- Wireshark：基于 pcap 做交互式协议解析、统计和时序分析，适合深入分析。
- `tshark`：Wireshark 的命令行版本，适合复杂协议解析和自动化。
- `ss`：查看本机 socket、监听端口、连接状态和 TCP 统计，不捕获数据包。
- `nc`：测试端口连通、监听和传输数据，不提供完整抓包分析能力。
- `ping`：基于 ICMP 验证主机可达性和延迟，不能验证 TCP 端口或应用协议。

## 常见误区
- 以为抓不到包就说明没有网络流量，实际可能是接口选错、流量发生在回环接口或另一个网络命名空间。
- 以为 `-A` 可以显示所有请求内容；加密协议和二进制协议通常无法直接以文本阅读。
- 以为看到 `SYN-ACK` 就代表业务服务正常；应用层仍可能返回错误、超时或拒绝请求。
- 以为终端输出就是完整证据；摘要可能丢失细节，关键排障应保存 pcap。
- 忘记给过滤表达式加引号，导致 shell 先处理 `(`、`)`、`|` 等字符。
- 在高流量机器上无条件使用 `-s 0` 和宽泛过滤，导致抓包进程或磁盘成为新的性能问题。

## 应用场景
- **适合用在**：连接超时、端口访问失败、DNS 异常、TCP 重传和 RST 排查、验证请求是否发出、分析服务间调用链路、生成 pcap 供后续分析。
- **不适合用在**：直接查看 HTTPS 明文内容、替代应用日志定位业务错误、替代端口状态检查工具、长期无边界地保存所有网络流量。

## 参考来源
- `tcpdump` 命令帮助：`man tcpdump`
- `pcap-filter` 过滤表达式帮助：`man pcap-filter`
- tcpdump 官方项目：<https://www.tcpdump.org/>
- Wireshark Display Filter Reference：<https://www.wireshark.org/docs/dfref/>

## 我的理解
可以把 `tcpdump` 理解成“网络线路上的黑盒录像机”：它记录谁在什么时间、通过哪个端口、发出了什么类型的数据包；它能证明网络上发生了什么，但不自动解释业务含义，也不能替你解密加密内容。排障时先确认接口，再缩小过滤范围，最后用 pcap 保留证据。
