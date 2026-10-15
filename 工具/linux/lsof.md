---
id: 20260908-001
tags: [Linux, 命令行工具, 系统排查, 文件描述符, 网络排查]
aliases: [lsof, list open files, 列出打开的文件]
created: 2026-09-08
updated: 2026-09-08
source: ""
status: draft
---

# lsof

## 一句话定义
`lsof`（list open files）是 Linux/Unix 上用于列出进程当前打开的文件的命令，由于「一切皆文件」，它同时也是查看端口占用、socket 连接、挂载点占用和已删除但未释放文件的通用排查工具。

## 核心理解
- **是什么**：遍历内核中每个进程的文件描述符表，把「哪个进程打开了哪个文件/socket/管道/设备」以表格形式打印出来。
- **为什么需要它**：进程与资源的关联关系在系统里是隐式的，出问题时（端口被占、磁盘不释放、目录无法卸载）你只能看到症状，看不到持有者。
- **它解决了什么问题**：把资源反查到进程（PID），从而可以定位、kill 或修复。

## 详细解释

### 能力地图
`lsof` 的用法可以分成四类，后文按这个顺序展开：

1. **按对象反查进程**：文件、目录、设备、端口、地址 → 谁在用它
2. **按进程正查对象**：PID、进程名、用户 → 它打开了什么
3. **筛选与组合**：多条件的 OR/AND 语义、`-a`、排除语法
4. **输出解释**：FD、TYPE、SIZE/OFF、NODE、NAME 各列含义

### 输出列含义
```
COMMAND   PID   USER   FD      TYPE  DEVICE SIZE/OFF   NODE NAME
nginx    1234   root   6u     IPv4  123456      0t0    TCP *:80 (LISTEN)
```
- `COMMAND`：进程名（默认截断到 9 字符，用 `+c 0` 显示完整）
- `FD`：文件描述符编号 + 访问模式。`r` 读、`w` 写、`u` 读写；特殊值有 `cwd`（当前目录）、`rtd`（根目录）、`txt`（程序文本，即可执行文件）、`mem`（内存映射文件）、`DEL`（已删除）
- `TYPE`：`REG` 普通文件、`DIR` 目录、`CHR`/`BLK` 字符/块设备、`FIFO` 管道、`unix` Unix domain socket、`IPv4`/`IPv6` 网络 socket
- `SIZE/OFF`：文件大小，或 `0t0` 形式的偏移量
- `NODE`：inode 号，网络行里则是协议（TCP/UDP）
- `NAME`：文件路径，或 `本地地址->远端地址 (状态)`

### 权限模型
`lsof` 只能看到当前用户有权限查看的进程。排查系统级问题时基本都要 `sudo`，否则会出现「明明端口被占却查不到」的假阴性，同时还会打印一堆 `Permission denied` 的 WARNING（可用 `-w` 关掉）。

## 常用用法

### 按端口查占用进程：-i
最高频用法，服务起不来时第一反应。

```bash
sudo lsof -i :8080              # 谁占用了 8080
sudo lsof -i tcp:8080           # 只看 TCP
sudo lsof -i -P -n              # 所有网络连接，不解析端口名和主机名（更快）
sudo lsof -i @192.168.1.10      # 与某个远端地址相关的连接
```

`-P` 不把 80 显示成 `http`，`-n` 不做 DNS 反解，两者都能显著加速并让输出可 grep。

### 只看监听状态：-sTCP:LISTEN
```bash
sudo lsof -nP -iTCP -sTCP:LISTEN     # 列出所有监听端口，等价于 netstat -ltnp
sudo lsof -nP -iTCP -sTCP:ESTABLISHED
```

### 按文件/目录反查：直接给路径
```bash
lsof /var/log/nginx/access.log       # 谁打开了这个文件
lsof /mnt/data                       # 只匹配这个目录本身
lsof +D /mnt/data                    # 递归目录下所有文件（慢，会 stat 整棵树）
lsof +d /mnt/data                    # 只看该目录下一层
```
`umount: target is busy` 时用 `lsof +D <挂载点>` 找出持有者。

### 按进程查：-p / -c / -u
```bash
lsof -p 1234                   # 指定 PID 打开的全部资源
lsof -p 1234 | wc -l           # 粗算该进程的 fd 数量，排查 fd 泄漏
lsof -c nginx                  # 按进程名前缀匹配
lsof -u miaozepeng             # 某用户打开的文件
lsof -u ^root                  # 排除 root（^ 表示取反）
```

### 找已删除但未释放的文件
磁盘明明删了文件但 `df` 空间不降，典型原因是进程还持有已删除的 fd。

```bash
sudo lsof -nP +L1                    # 链接数 < 1，即已删除仍被占用
sudo lsof | grep deleted
```
定位后重启该进程（或 `: > /proc/<pid>/fd/<n>` 截断）才能真正回收空间。

### 持续监控：-r
```bash
sudo lsof -i :3306 -r 2              # 每 2 秒重复输出一次
```

### 输出给脚本消费：-t / -F
```bash
lsof -t -i :8080                     # 只输出 PID，便于 kill $(lsof -t -i :8080)
lsof -F pcn -i :8080                 # 字段化输出，供程序解析
```

## 关键要点
- 端口排查记住一条组合就够：`sudo lsof -nP -iTCP -sTCP:LISTEN`。
- 多个不同类型的条件之间默认是 **OR**，要变成 AND 必须加 `-a`：`lsof -u root -i` 是「root 的文件 **或** 网络连接」，`lsof -a -u root -i` 才是「root 的网络连接」。
- 不加 `sudo` 的结果不可信，容易得出「没人占用」的错误结论。
- `+D` 会递归遍历整个目录树，在大目录上非常慢，优先用 `lsof <dir>` 或 `+d`。
- `FD` 列的 `txt`/`mem`/`cwd` 不是普通文件读写，误当泄漏会看错。

## 例子与边界

### 正例：端口被占导致服务启动失败
```bash
$ sudo lsof -nP -i :8080
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
java    9527 app    98u  IPv6 812345      0t0  TCP *:8080 (LISTEN)
$ kill 9527
```

### 正例：磁盘空间不释放
```bash
$ df -h /var        # 90% 使用率
$ sudo lsof -nP +L1 | head
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NLINK   NODE NAME
java    9527 app    12w  REG  253,1  8.2G         0 131074 /var/log/app.log (deleted)
```
日志被 `rm` 了但进程还在写，重启进程或做 logrotate 的 `copytruncate` 才能释放。

### 反例：条件被当成 AND
```bash
lsof -u root -c nginx     # 实际是「root 的文件」∪「nginx 的文件」，结果远超预期
lsof -a -u root -c nginx  # 正确写法
```

### 反例：以为没被占用
```bash
$ lsof -i :443            # 无输出（当前用户看不到 root 进程）
$ sudo lsof -i :443       # 才看到 nginx
```

### 边界情况
- macOS 上 `lsof` 存在但部分选项（如 `+L1` 的语义、`-i` 的输出细节）与 Linux 有差异。
- 容器场景下宿主机的 `lsof` 看到的是宿主 PID namespace 视角，容器内进程名/路径可能对不上，需结合 `nsenter`。
- 高连接数机器上 `lsof -i` 不加 `-n -P` 会因 DNS 反解卡住很久。

## 关系与连接
- **前置知识**：文件描述符、inode、硬链接与 unlink 语义、TCP 连接状态、`/proc/<pid>/fd`
- **关联概念**：`ss`、`netstat`、`fuser`、`pidof`、`strace`、`ulimit -n`
- **容易混淆**：`lsof` 是「资源 → 进程」的反查工具，`ps` 是「进程 → 属性」；`ss` 只覆盖 socket，不覆盖普通文件。
- **上位/下位知识**：上位是 Linux 一切皆文件的资源模型；下位是 `/proc` 文件系统的读取方式。

### 与相近工具对比
- `ss -ltnp` / `netstat -ltnp`：只查网络，比 `lsof` 快很多，端口排查更推荐 `ss`。
- `fuser -v /path`：同样能找占用进程，输出更简洁，且支持 `-k` 直接杀掉占用者，但信息量远小于 `lsof`。
- `lsof`：唯一能同时覆盖普通文件、目录、管道、Unix socket、已删除文件和网络连接的工具，代价是慢。

## 常见误区
- 认为多个筛选条件是 AND 关系，忘记加 `-a`，结果集被放大。
- 用 `lsof | grep <port>` 代替 `lsof -i :<port>`，既慢又可能匹配到无关的 inode 数字。
- 看到 `mem`/`txt` 类型的条目就判定为文件描述符泄漏。
- 删除大文件后只看 `df` 不看 `+L1`，误以为是文件系统问题。

## 应用场景
- **适合用在**：端口占用排查、`umount` 失败定位、fd 泄漏诊断、磁盘空间未释放、确认某配置文件被哪个进程加载。
- **不适合用在**：只需要看网络连接（用 `ss` 更快）、需要高频轮询采集指标（开销大）、容器内跨 namespace 精确定位（需配合 `nsenter`）。

## 参考来源
- `man lsof`
- lsof 项目文档 FAQ（AND/OR 选项语义、`+L` 用法）

## 我的理解
把 `lsof` 当成系统的「反向索引」：平时你从进程找资源，出问题时你手里只有一个资源（端口、路径、挂载点），需要反查是谁在拿着它。记两句话就够用：端口用 `sudo lsof -nP -i :端口`，磁盘不释放用 `sudo lsof +L1`；多条件筛选一定别忘 `-a`。
