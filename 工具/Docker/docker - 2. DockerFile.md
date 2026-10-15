**1. 新建 `DockerFile` 文件，内容如下：**

```bash
# 使用 Ubuntu 18.04 作为基础镜像
FROM ubuntu:18.04

# 设置环境变量避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新软件源并安装必要组件
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    zip \
    file \
    python2.7 \
    && rm -rf /var/lib/apt/lists/*

# 验证 Python 2.7 安装
RUN python2.7 --version

# 设置默认工作目录
WORKDIR /app

# 指定默认 shell（可选）
SHELL ["/bin/bash", "-c"]
```

**2. 在 `DockerFile` 文件目录下执行构建命令：**

```bash
docker build -t ubuntu18-py27:latest .
```
