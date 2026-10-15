
### 简介
**`protobuf`**：是一种 **序列化数据格式** 和 **通信协议标准**。根据使用平台的不通 `protobuf` 具有不同的表现形式。
**`protoc`**：是 **Protocol Buffers 的编译器**，用来将 `.proto` 文件编译生成 `.pb.cc/.pb.h`（C++）、`.pb.go`（Go）、`.pb.py`（Python）等语言文件。`protoc` 本身是一个可执行文件。

> `protoc` 和 `protobuf` 版本需要保持兼容。

#### 安装 protoc 
要**安装指定版本的 `protoc` 编译器**（Protocol Buffers 编译器），最可靠的方式是从 **源码构建** 或下载 **预编译的 release 包**。下面分别介绍两种方法。

方法一：下载官方预编译版本（简单快捷）

1. 打开 GitHub Release 页面

👉 [https://github.com/protocolbuffers/protobuf/releases](https://github.com/protocolbuffers/protobuf/releases)

找到你要的版本，比如 `v3.21.12`，然后选择与你系统匹配的预编译包：

* `protoc-<version>-linux-x86_64.zip`
* `protoc-<version>-osx-x86_64.zip`
* `protoc-<version>-win64.zip`

2. 下载并安装

```bash
VERSION=20.0
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.$VERSION/protoc-3.$VERSION-linux-x86_64.zip
unzip protoc-3.$VERSION-linux-x86_64.zip -d protoc-3.$VERSION
sudo cp -r protoc-3.$VERSION/bin/* /usr/local/bin/
sudo cp -r protoc-3.$VERSION/include/* /usr/local/include/
```

3. 验证

```bash
protoc --version
# 输出：libprotoc 3.20.0
```

方法二：从源码编译指定版本（更灵活）

1. 克隆指定版本源码

```bash
git clone https://github.com/protocolbuffers/protobuf.git
cd protobuf
git checkout v3.20.0
git submodule update --init --recursive
```

2. 构建 & 安装

```bash
mkdir build && cd build
cmake .. && make -j$(nproc)
sudo make install
sudo ldconfig
```

如果你没有 `cmake`，可以使用传统方式：

```bash
./autogen.sh
./configure
make -j$(nproc)
sudo make install
sudo ldconfig
```

#### protobuf 在 python 上使用

安装 `protobuf`：

```python
pip install protobuf
```

安装指定版本的 `protobuf`：

```python
pip install protobuf==3.20.3
```

查看版本：

```python
pip show protobuf
```

在 `MAC` 安装 `protobuf` 时可能提示：**error: externally-managed-environment**，这是由于新版本 `macOS` 默认使用 `homebrew` 等包管理工具安装的库，不建议使用 `pip` 安装。推荐方式：

```bash
brew install protobuf
```

`brew` 命令会同时安装 `protoc` 编译器以及相关的库但不方便安装指定版本，安装指定版本推荐用虚拟环境 + pip。

```bash
python -m venv myenv
source myenv/bin/activate
pip install protobuf==3.20.3
deactivate
```

protobuf 的 Python 库版本需要和 `protoc` 编译器版本对应，否则可能出现生成代码不兼容的问题。常见做法是保持两者的大版本号一致即可（如 protoc 3.20.0 配 protobuf 3.20.3）。
版本差异较大时的典型报错：
`TypeError: Descriptors cannot be created directly`。

#### protobuf 在 Android 上使用

[protobuf-gradle-plugin](https://github.com/google/protobuf-gradle-plugin)

`protobuf` 在使用时有多个版本：

* `protobuf-java`：是功能最全的版本，适用于完整功能需求的场景。
* `protobuf-lite`：是轻量级版本，主要面向移动设备和资源受限的环境。
* `protobuf-javalite`：是 protobuf-lite 的现代化改进版本，特别为 Android 优化，同时支持一些较新的 Java 功能。


### 参考
[ubuntu安装protobuf](https://www.jianshu.com/p/aad9b0253cbe)

[Protobuf的简单使用](https://www.cnblogs.com/sherlock-lin/p/16518917.html)

[Android 中使用 Protobuf](https://juejin.cn/post/7135365943282122765)

[protobuf-gradle-plugin 插件简介](https://blog.csdn.net/shulianghan/article/details/116161354)
