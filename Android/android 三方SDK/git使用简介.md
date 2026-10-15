## git使用简介

@(android 工具)


[TOC]

[git 简明指南](http://rogerdudler.github.io/git-guide/index.zh.html)
[廖雪峰Git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)
[Git reset 撤销本地/远程提交版本](https://blog.csdn.net/qq_28018283/article/details/77877986)

### 1.安装
> 下载git 地址: http://msysgit.github.io/; 下载完成之后点击安装,然后一直点击"next"安装完成

### 2. 创建代码库
1. 配置身份:
- `git config --global user.name "Tony"`
- `git config --global user.email "tony@gmail.com"`
2. 检验是否成功
- `git config --global user.name`
- `git config --global user.email`

### 2+1. 创建SSH Key
1. 在Git Bash 中运行`ssh-keygen -t rsa -C "youremail@example.com"`
> 把邮件地址换成你自己的邮件地址，然后一路回车，使用默认值即可，由于这个Key也不是用于军事目的，所以也无需设置密码。如果一切顺利的话, 可以在用户主目录里找到.ssh目录, 里面有id_rsa和id_rsa.pub两个文件, 这两个就是SSH Key的秘钥对, id_rsa是私钥不能泄露出去, id_rsa是公钥，可以放心地告诉任何人。

2. 在自己的Github页面中, 添加SSH Key
> 填上任意Title，在Key文本框里粘贴id_rsa.pub文件的内容

### 2+2.创建代码库
1. 先使用"`cd`"命令进入当前项目的根目录
2. 然后使用"`git init`"创建代码仓库
3. 仓库创建完成后，会在项目的根目录下生成一个隐藏的`.git`文件夹，这个文件夹就是用来记录	 本地所有的 Git 操作的，可以通过 `ls -al` 命令查看
4. 如果你想要删除本地仓库，只需要删除这个文件夹就行了

### 3.提交本地代码
> 提交代码的方法非常简单,只需要使用add 和commit命令就可以了。add 是用于把想要提交的代码先添	 加进来，而 commit则是真正地去执行提交操作

- 添加文件：`git add AndroidManifest.xml`

- 添加目录：`git add src`

- 添加所有文件：`git add .`

- 提交文件: `git commit -m "First commit."`

### 4.查看修改内容
- 查看文件修改情况: `git status`
- 查看文件的更改内容: `git diff 文件路径 (减号代表删除的部分，加号代表添加的部分)`
例如: `git diff src/com/example/providertest/MainActivity.java`

### 4+1.查看某个文件的修改记录
1. 首先切换到要查看的文件所在的目录
2. `git log --pretty=oneline 文件名`
3. `git show 356f6def9d3fb7f3b9032ff5aa4b9110d4cca87e`

### 5.撤销未提交的修改
文件撤销修改
```
git checkout -- filePath
```
撤销`add`命令
```
git reset HEAD filePath
```
撤销`commit`命令
```
git reset --soft HEAD^
```
本地版本回滚
```
git reset --soft HEAD^
```
本地版本回滚同步到远程库
```
git push -f
```

- `--mixed`：不删除工作空间改动代码，撤销commit，并且撤销git add . 操作这个为默认参数,git reset --mixed HEAD^ 和 git reset HEAD^ 效果是一样的。
- `--soft`：不删除工作空间改动代码，撤销commit，不撤销git add。
- `--hard`：删除工作空间改动代码，撤销commit，撤销git add。注意完成这个操作后，就恢复到了上一次的commit状态。`慎用`。

- HEAD：指向的时当前分支节点，HEAD^、HEAD~1：历史前一个节点，HEAD^^^、HEAD~3：历史第三个节点，HEAD~n：历史第n个节点。HEAD也可以使用具体的commit ID（前七位）替代。

### 5.拉取代冲突、bug分支管理
当拉取代码和本地代码产生冲突时可以如下操作：
1. `git stash`：保存当前分支代码至缓存列表
2. `git pull`：拉取代码
3. `git stash pop`：还原缓存中代码

如果在开发过程中突然要求修改master分支中代码bug, 但是当前分支中的代码由于未完成无法提交的处理
1. `git stash`：保存当前dev分支: 
2. `git checkout master`：回到master分支中, 创建currant_bug分支, 在此分支上修改bug, 然后提交, 再转到master分支合并
3. `git checkout dev`：现在回到dev分支中
4. `git stash pop`：恢复缓存代码

> 注意：如果回到dev分支后，提示本地文件有修改，撤销修改后再恢复缓存代码。

git stash 语法
- `git stash apply`：语句恢复后，stash列表中内容并不删除
- `git stash drop`：语句恢复后，stash列表中内容会被删除
- `git stash list`：查看stash list 列表
- `git stash apply stash@[0]`恢复指定stash

### 6.查看提交记录 (减号代表删除部分, 加号代表添加部分)
- 查看命令操作记录：`git reflog`
- 查看所有记录：`git log`
- 查看简化提交记录:  `git log --pretty=oneline`
- 查看某一条记录: 在命令中指定该记录的ID(版本号), 并加上 `-1` 参数表示我们只想看到一行记录①
- 查看提交记录具体修改了什么内容, 可以在命令中加入 `-p` 参数②

```
①git log 2e7c0547af28cc1e9f303a4a1126fddbb704281b -1
②git log 2e7c0547af28cc1e9f303a4a1126fddbb704281b -1 –p
```

### 6+2.删除命令
- 删除文件
        `git rm file`
- 删除文件夹
        `git rm -r file`

### 7.分支
1. 查看分支：`git branch`

2. 创建分支: `git branch <name>`

3. 切换分支: `git checkout <name>`

4. 创建+切换分支: `git checkout -b <name>`

5. 将分支中的代码合并到主分支中
	- 首先进入主分支中: `git checkout master`
	- 然后合并分支:   `git merge <name>`

6. 查看分支合并图: `git log --graph`
	- 简写: `git log --graph --pretty=oneline`
	- 再简写: `git log --graph --pretty=oneline --abbrev-commit`


6. 删除分支: `git branch -d <name>`
7. 强制删除分支: `git branch -D <name>`
> 未合并的分支删除时会提示, 这时需要进行强制删除

### 7+1. 分支管理策略
> git merge 分支名, 合并分支时, Git会使用`Fast forward`模式, 但是在这种模式下, 删除分支后,会丢掉分支信息, 这种情况下呢可以使用`--no-ff`模式合并分支

1. 合并分支: `git merge --no-ff -m "merge with no-ff" dev`
2. 查看合并分支图: `git log --graph --pretty=oneline --abbrev-commit`
![Alt text](<../../attachment/:TIBY9OU1-KN8EU~SXXG10.png>)

### 7+3. 标签
> 发布一个版本时，我们通常先在版本库中打一个标签，这样，就唯一确定了打标签时刻的版本。将来无论什么时候，取某个标签的版本，就是把那个打标签的时刻的历史版本取出来。所以，标签也是版本库的一个快照。

1. `git tag <name>`用于新建一个标签，默认为HEAD，也可以指定一个commit id；

2. `git tag -a <tagname> -m "blablabla..."`可以指定标签信息；

3. `git tag -s <tagname> -m "blablabla..."`可以用PGP签名标签；

4. `git tag`可以查看所有标签。

5. `git push origin <tagname>`可以推送一个本地标签；

6. `git push origin --tags`可以推送全部未推送过的本地标签；

7. `git tag -d <tagname>`可以删除一个本地标签；

8. `git push origin :refs/tags/<tagname>`可以删除一个远程标签。

### 8.远程版本库协作
1. 下载代码到本地: 
- `git clone 远程版本库地址`

2. 本地修改的内容同步到远程版本库中:
- `git push origin amster` (origin 部分指定的是远程版本库的 Git 地址， master 部分指定的是同步到哪一个分支上，上述命令就完成了将本地代码同步到远程版本库的master 分支上的功能)

3. 远程版本库中的修改同步到本地
> Git 提供了两种命令来完成此功能，分别是 fetch 和 pull， fetch 的语法规则和 push 是差不多的

1. 使用fetch命令
	1. 远程版本库上的代码同步到本地
           `git fetch origin master`
	2. 不过同步下来的代码并不会合并到任何分支上去，而是会存放在到一个 origin/master 分支上，这时可以通过 diff 命令来查看远程版本库上到底修改了哪些东西
            `git diff origin/master`
	3. 之后再调用 merge 命令将 origin/master 分支上的修改合并到主分支上即可：
            `git merge origin/master`

2. 使用pull命令
            `git pull origin master`

### 9.代码托管到GitHub
1. [注册GitHub](http://github.com)
    
2. 创建远程代码库

3. 打开Git Bash进入要托管的项目目录,输入: `git clone 远程代码库地址把远程版本库克隆到本地`

4. 关联GitHub版本库:`git remote add origin git@github.com:xxx/xxx.git`

5. 把克隆下来的目录中的文件全部复制到项目根目录中(.git 是一个隐藏目录，在复制的时候千万不要漏掉)

6. 然后把所有文件添加到版本控制中
        1. `git add .`
        2. `git commit -m "First commit"`
        3. `git push origin master`

### 10. 忽略特殊文件 
> 忽略某些文件时，需要编写`.gitignore`; gitignore文件本身要放到版本库里,  并且可以对.gitignore做版本管理！

在GitHub上创建版本库时会自动生成`.gitignore`文件, 拿来即可

### 11. 配置别名
1. `git config --global alias.<别名> <命令>`
> 例如
> 1. `git config --global alias.ci commit`
> 2. `git config --global alias.br branch`

### 12. 搭建Git服务器
> 环境Linux, 推荐Ubuntu或Debian

假设你已经有sudo权限的用户账号，下面，正式开始安装。

1. 安装git：`$ sudo apt-get install git`
2. 创建一个git用户，用来运行git服务：`$ sudo adduser git`
3. 创建证书登录：
收集所有需要登录的用户的公钥，就是他们自己的id_rsa.pub文件，把所有公钥导入到/home/git/.ssh/authorized_keys文件里，一行一个。

4. 初始化Git仓库：
先选定一个目录作为Git仓库，假定是/srv/sample.git，在/srv目录下输入命令：
`$ sudo git init --bare sample.git`
Git就会创建一个裸仓库，裸仓库没有工作区，因为服务器上的Git仓库纯粹是为了共享，所以不让用户直接登录到服务器上去改工作区，并且服务器上的Git仓库通常都以.git结尾。然后，把owner改为git：
`$ sudo chown -R git:git sample.git`
5. 禁用shell登录：
出于安全考虑，第二步创建的git用户不允许登录shell，这可以通过编辑/etc/passwd文件完成。找到类似下面的一行：
`git:x:1001:1001:,,,:/home/git:/bin/bash`
改为：
`git:x:1001:1001:,,,:/home/git:/usr/bin/git-shell`
这样，git用户可以正常通过ssh使用git，但无法登录shell，因为我们为git用户指定的git-shell每次一登录就自动退出。

6. 克隆远程仓库：`$ git clone git@server:/srv/sample.git`

> 管理公钥

如果团队很小，把每个人的公钥收集起来放到服务器的/home/git/.ssh/authorized_keys文件里就是可行的。如果团队有几百号人，就没法这么玩了，这时，可以用Gitosis来管理公钥。这里我们不介绍怎么玩Gitosis了，几百号人的团队基本都在500强了，相信找个高水平的Linux管理员问题不大

> 管理权限

有很多不但视源代码如生命，而且视员工为窃贼的公司，会在版本控制系统里设置一套完善的权限控制，每个人是否有读写权限会精确到每个分支甚至每个目录下。因为Git是为Linux源代码托管而开发的，所以Git也继承了开源社区的精神，不支持权限控制。不过，因为Git支持钩子（hook），所以，可以在服务器端编写一系列脚本来控制提交等操作，达到权限控制的目的。Gitolite就是这个工具。这里我们也不介绍Gitolite了，不要把有限的生命浪费到权限斗争中。

### 遇到的问题
### Move or commit them before merge
[原文链接](https://blog.csdn.net/chinacmt/article/details/52221733)

在使用git pull时,经常会遇到报错:
```
Please move or remove them before you can merge
```

这是因为本地有修改,与云端别人提交的修改冲突,又没有merge.

如果确定使用云端的代码,最方便的解决方法是删除本地修改,可以使用以下命令:

```
git clean -d -fx ""
d  -----删除未被添加到git的路径中的文件
f  -----强制运行
x  -----删除忽略文件已经对git来说不识别的文件
```

注意:该命令会删除本地的修改,最好先备份再使用

git clean 参数
- n 显示 将要 删除的 文件 和 目录
- f 删除 文件，-df 删除 文件 和 目录

git clean -n
git clean -df
git clean -f
