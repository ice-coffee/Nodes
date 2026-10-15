`perf` 命令（performance 的缩写）讲起，它是 `Linux` 系统原生提供的性能分析工具，会返回 `CPU` 正在执行的函数名以及调用栈（`stack`）。

但是 `perf` 录制的数据不易读，所以有了火焰图

在 `Linux` 项目中生成火焰图主要分为三步：**采样 → 生成折叠栈文件 → 绘制 SVG**。

### 火焰图
火焰图是基于 `perf` 结果产生的 `SVG` 图片，用来展示 `CPU` 的调用栈。

![d2b2b79d2235e42689df14e0bdecae6d.jpeg](evernotecid://A498B3CC-C986-483E-9ADA-6CC5416667AC/appyinxiangcom/10744683/ENNote/p953?hash=d2b2b79d2235e42689df14e0bdecae6d)

**`y 轴`**：表示调用栈，每一层都是一个函数。调用栈越深，火焰就越高，顶部就是正在执行的函数，下方都是它的父函数。

**`x 轴`**：表示抽样数，如果一个函数在 `x` 轴占据的宽度越宽，就表示它被抽到的次数多，即执行的时间长。注意 `x` 轴不代表时间，而是所有的调用栈合并后，按字母顺序排列的。

火焰图就是看顶层的哪个函数占据的宽度最大。只要有"平顶"（plateaus），就表示该函数可能存在性能问题。

颜色没有特殊含义，因为火焰图表示的是 `CPU` 的繁忙程度，所以一般选择暖色调。

### 安装

你需要：

* **perf**：Linux 自带的性能分析工具，内核需支持；
* **FlameGraph 脚本**：Brendan Gregg 写的火焰图生成工具；

安装：

```sh
# perf
sudo apt install linux-tools-common linux-tools-$(uname -r)   # Ubuntu/Debian

# FlameGraph（下载到本地）
git clone https://github.com/brendangregg/FlameGraph.git
```

❗️配置
默认情况下，`perf` 可能需要 `sudo` 权限来收集系统范围的性能数据。为了方便使用，可以调整一个内核参数，允许普通用户进行性能分析（这在开发环境中通常是安全的）。

```sh
# 临时允许（重启后失效）
sudo sysctl -w kernel.perf_event_paranoid=-1
# 永久允许
echo 'kernel.perf_event_paranoid = -1' | sudo tee /etc/sysctl.d/99-perf.conf
```

### 使用

#### 采样

假设你要分析 PID 为 `12345` 的进程：

```sh
sudo perf record -F 99 -p 12345 -g -- sleep 30
```

* `-F 99`：采样频率 99Hz
* `-p 12345`：指定进程 PID（可以换成 `-a` 全局）
* `-g`：记录调用栈
* `-- sleep 30`：采样 30 秒

采样完成后会生成 `perf.data` 文件。

#### 转换为折叠栈格式

```sh
sudo perf script > out.perf
```

```sh
./FlameGraph/stackcollapse-perf.pl out.perf > out.folded
```

#### 生成火焰图 SVG

```sh
./FlameGraph/flamegraph.pl out.folded > flamegraph.svg
```

然后用浏览器打开 `flamegraph.svg`，可以放大/缩小/搜索。

### Java / Python / Go 项目

* **Java**：可以用 [async-profiler](https://github.com/async-profiler/async-profiler) 直接生成火焰图（支持 CPU/内存分配采样）。
* **Python**：用 `py-spy` 或 `scalene` 采样再转火焰图。
* **Go**：内置 `pprof`，可导出火焰图格式。

### 实例
```bash
#!/bin/bash

#===================================================================================
#
#          FILE: profile_and_generate_flamegraph.sh
#
#         USAGE: ./profile_and_generate_flamegraph.sh /path/to/your/json_file.json
#
#   DESCRIPTION: 使用 perf 监控 test_demo 进程及其子进程启动后的前30秒，
#                并自动生成CPU火焰图。
#
#===================================================================================

# --- 配置区 ---
# !!! 重要: 请将此路径修改为您克隆 FlameGraph 工具的实际路径 !!!
FLAMEGRAPH_DIR="$HOME/FlameGraph" # <--- 修改这里

# 监控持续时间（秒）
MONITOR_DURATION=30
# --- 配置区结束 ---


# 脚本开始，设置 -e 选项，使得任何命令执行失败时立即退出
set -e

# 检查前提条件
if ! command -v perf &> /dev/null; then
    echo "错误: 'perf' 命令未找到。" >&2
    echo "请运行 'sudo apt update && sudo apt install linux-tools-common linux-tools-$(uname -r)' 进行安装。" >&2
    exit 1
fi

if [ ! -f "${FLAMEGRAPH_DIR}/flamegraph.pl" ]; then
    echo "错误: FlameGraph 工具未在 '${FLAMEGRAPH_DIR}' 目录中找到。" >&2
    echo "请确认 FLAMEGRAPH_DIR 变量已正确设置为您克隆 https://github.com/brendangregg/FlameGraph 的路径。" >&2
    exit 1
fi

# 获取脚本所在目录作为工作区
workspace=$(cd "$(dirname "$0")"; pwd)

PERF_DATA_FILE="${workspace}/perf.data"
FLAME_GRAPH_FILE="${workspace}/cpu_flamegraph.svg"

# 定义需要监控的命令
# 注意: 为了让 timeout 和 perf 正确处理带参数的命令，我们使用 sh -c "..." 的方式来执行
TARGET_CMD="xxxxxxxxxxxx"  # 这里可以体换成自己的启动bin的命令

# 使用 timeout 命令来确保 perf 和目标进程只运行指定的时间
# -F 99: 采样频率为 99Hz。这是一个常用的值，可以避免与某些定时器同步产生偏差。
# -g: 记录调用图 (call graphs)，这是生成火焰图所必需的。
# --: 分隔 perf 的参数和要执行的命令。
# perf 在启动一个父命令时，默认会监控其所有子进程，因此 msdk_mgr 会被自动包含。
timeout ${MONITOR_DURATION}s perf record -F 99 -g -o "${PERF_DATA_FILE}" -- sh -c "${TARGET_CMD}" || true
# `|| true` 用于防止在进程被timeout正常终止时，脚本因非零退出码而停止（set -e 的效果）

echo ">>> [步骤 4/4] 生成火焰图..."

# 使用 perf script、stackcollapse 和 flamegraph 管道处理生成SVG文件
perf script -i "${PERF_DATA_FILE}" | "${FLAMEGRAPH_DIR}/stackcollapse-perf.pl" | "${FLAMEGRAPH_DIR}/flamegraph.pl" > "${FLAME_GRAPH_FILE}"

echo "======================================================================"
echo "🎉 成功!"
echo "火焰图已生成: ${FLAME_GRAPH_FILE}"
echo "您现在可以使用 Chrome、Firefox 或其他支持SVG的浏览器打开此文件进行交互式分析。"
echo "======================================================================"

exit 0
```

### 参考
[如何读懂火焰图？](https://www.ruanyifeng.com/blog/2017/09/flame-graph.html)
