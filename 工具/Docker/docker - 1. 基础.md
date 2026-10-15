[toc]

### 资料
[Docker 安装](https://yeasy.gitbook.io/docker_practice/install/ubuntu)
[Docker 命令大全](https://www.runoob.com/docker/docker-command-manual.html)


检查 Docker 服务状态：

```Bash
sudo systemctl status docker
# 如果未运行，启动服务
sudo systemctl start docker
```

### 镜像
**1. 加载本地镜像：**
```Bash
# 加载本地镜像
docker load -i <***.tar>

# 加载镜像仓库中的镜像
docker pull [选项] [Docker Registry 地址[:端口号]/]仓库名[:标签]
```

示例：
```sh
docker pull ubuntu:11.04
docker pull ubuntu:18.04
```

**2. 查看镜像：**
```Bash
docker images
```

**3. 删除镜像：**
```Bash
docker rmi <IMAGE ID>
```

### 容器

**1. 新建并启动容器：**

```Bash
docker run -d -it --name ubuntu18 --mount type=bind,source=/home/miaozepeng/workspace_docker,target=/workspace --network=host f9a80a55f492
```

* `-d：`后台运行；
* `-it：`交互模式，保持输入流打开；重要，没有这两个开关容器会自动退出；
* `--name：`指定容器名字, 随意；
* `--mount type=bind,source=<SRC_PATH>,target=<DEST_PATH>：`设置 `mount` 模式，这里使用 `bind` 模式，适合容器共享宿主系统已存在的目录，`source` 和 `target` 分别指定了宿主系统中的目录和它在容器中的挂载目录；
* `--network=host`：容器共享宿主机网络；
* `f9a80a55f492`：镜像ID；

其它选项：
1. 环境变量

| 选项 | 说明 | 示例 |
| --- | --- | --- |
| -e | <变量名>=<值> | 设置环境变量 | -e MYSQL_ROOT_PASSWORD=123456 |
| --env-file | <文件路径> | 从文件加载环境变量 | --env-file .env |

**2. 以交互模式运行：**
```Bash
docker exec -it my_container /bin/bash
```

> 注意：`docker exec` 的作用实际是在用于在容器中执行某个命令。

**3. 停止容器：**
```Bash
docker stop <容器名称或ID>
# 立即终止容器进程
docker kill <容器名称或ID>
```

**4. 删除容器：**
```Bash
docker rm <容器名称或ID>
```

**5. 重启容器：**
```Bash
docker start -ai <容器名称或ID>
```

### 数据移动

```bash
# 将宿主机上的文件拷贝到容器
docker cp [OPTIONS] SRC_PATH CONTAINER:DEST_PATH
# 将容器上的文件拷贝到宿主机
docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH
```

### 容器迁移
**1. 将容器环境固化为镜像**

**方法 1**：通过 `docker commit` 快速打包（临时方案）

```bash
# 1. 确认容器ID或名称
docker ps -a

# 2. 提交容器为新镜像（保留所有修改）
docker commit <容器名或ID> my_custom_env:latest

# 3. 验证镜像
docker images | grep my_custom_env
```

**方法 2**：通过 `Dockerfile` 构建标准化镜像（推荐）
```bash
# 1. 在容器内生成安装记录（可选）
docker exec <容器名> sh -c "dpkg --get-selections > /packages.list"

# 2. 创建 Dockerfile
cat > Dockerfile <<EOF
FROM ubuntu:22.04  # 基础镜像需与原容器一致
COPY packages.list /
RUN apt-get update && \
    xargs -a /packages.list apt-get install -y && \
    rm -rf /var/lib/apt/lists/*
# 添加其他配置（如复制文件、设置环境变量等）
COPY ./app /app
WORKDIR /app
EOF

# 3. 构建镜像
docker build -t my_custom_env:stable .
```

**2. 迁移镜像到新电脑**

**方案 1**：通过文件导出（离线环境适用）
```bash
# 1. 导出镜像为压缩文件
docker save my_custom_env:latest | gzip > my_env.tar.gz

# 2. 将文件传输到新电脑（U盘/SCP等）
scp my_env.tar.gz user@new_pc:/path/

# 3. 在新电脑加载镜像
docker load -i my_env.tar.gz
```

**方案 2**：推送至镜像仓库（有网络时推荐）
```bash
# 1. 登录 Docker Hub（或其他私有仓库）
docker login

# 2. 标记并推送镜像
docker tag my_custom_env:latest username/my_env:2023
docker push username/my_env:2023

# 3. 在新电脑拉取镜像
docker pull username/my_env:2023
```
