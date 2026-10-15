#### 安装
[下载地址](http://msysgit.github.io/)
下载完成之后点击安装,然后一直点击”next”安装完成

#### 配置身份:
```
* git config --global user.name "Tony"
* git config --global user.email "tony@gmail.com"
```
#### 检验
```
* git config --global user.name
* git config --global user.email
```

#### 创建SSH Key

运行
```
ssh-keygen -t rsa
```
然后一路回车，使用默认值即可，由于这个 `Key` 也不是用于军事目的，所以也无需设置密码。如果一切顺利的话, 可以在用户主目录里找到 `.ssh` 目录, 里面有 `id_rsa` 和 `id_rsa.pub` 两个文件, 这两个就是 `SSH Key` 的秘钥对, `id_rsa` 是私钥不能泄露出去, `id_rsa.pub` 是公钥，可以放心地告诉任何人。

#### 创建代码库

1. 先使用 `cd` 命令进入当前项目的根目录;
2. 然后使用 `git init` 创建代码仓库;
3. 仓库创建完成后，会在项目的根目录下生成一个隐藏的 `.git` 文件夹，这个文件夹就是用来记录本地所有的 `Git` 操作的，可以通过 `ls -al` 命令查看;
4. 如果你想要删除本地仓库，只需要删除这个文件夹就行了;
