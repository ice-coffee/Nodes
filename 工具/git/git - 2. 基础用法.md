[toc]

#### 提交本地代码
提交代码的方法非常简单,只需要使用 `add` 和 `commit` 命令就可以了。`add` 是用于把想要提交的代码先添加进来，而 `commit` 则是真正地去执行提交操作。

* 添加文件：`git add AndroidManifest.xml`
* 添加目录：`git add src`
* 添加所有文件：`git add .`
* 提交文件: `git commit -m "First commit."`
* 推送文件: `git push origin <分支>`

#### 查看修改内容
* 查看文件修改情况: `git status`
* 查看文件的更改内容: `git diff 文件路径`

#### 撤销
- 撤销文件: `git checkout -- 文件路径`；
- 撤销 `add`: `git reset HEAD 文件路径`；
- 撤销 `commit`、`push`: `git reset --soft HEAD^`
- 本地版本回滚同步到远程库: `git push -f`

#### 分支管理
* 查看分支: `git branch`
* 创建分支: `git branch <name>`
* 切换分支: `git checkout <name>`
* 创建+切换分支: `git checkout -b <name>`
* 拉取远程分支：`git checkout -b <name> <remote_name>`
* 删除分支: `git branch -d <name>`
* 强制删除分支: `git branch -D <name>` 未合并的分支删除时会提示, 这时需要进行强制删除
* 查看分支来源：`git reflog --date=local|grep <name>`

####  标签管理
发布一个版本时，我们通常先在版本库中打一个标签，这样，就唯一确定了打标签时刻的版本。将来无论什么时候，取某个标签的版本，就是把那个打标签的时刻的历史版本取出来。所以，标签也是版本库的一个快照。

* `git tag <name>`：用于新建一个标签，默认为HEAD，也可以指定一个commit id；
* `git tag -a <tagname> -m "blablabla..."`：可以指定标签信息；
* `git tag -s <tagname> -m "blablabla..."` ：可以用PGP签名标签；
* `git tag`可以查看所有标签。
* `git push origin <tagname>`：可以推送一个本地标签；
* `git push origin --tags`：可以推送全部未推送过的本地标签；
* `git tag -d <tagname>`：可以删除一个本地标签；
* `git push origin :refs/tags/<tagname>`：可以删除一个远程标签。

#### 查看修改历史
* 查看命令操作记录: `git reflog`
* 查看所有记录: `git log`
* 查看简化提交记录: `git log --pretty=oneline`

8. 远程版本库协作

1. 下载代码到本地: 
* git clone 远程版本库地址
2. 本地修改的内容同步到远程版本库中:
* git push origin amster (origin 部分指定的是远程版本库的 Git 地址， master 部分指定的是同步到哪一个分支上，上述命令就完成了将本地代码同步到远程版本库的master 分支上的功能)
3. 远程版本库中的修改同步到本地
Git 提供了两种命令来完成此功能，分别是 fetch 和 pull， fetch 的语法规则和 push 是差不多的
1. 使用fetch命令
    1. 
远程版本库上的代码同步到本地 
   git fetch origin master
    2. 
不过同步下来的代码并不会合并到任何分支上去，而是会存放在到一个 origin/master 分支上，这时可以通过 diff 命令来查看远程版本库上到底修改了哪些东西 
    git diff origin/master
    3. 
之后再调用 merge 命令将 origin/master 分支上的修改合并到主分支上即可： 
    git merge origin/master
2. 
使用pull命令 
        git pull origin master
9. 代码托管到GitHub

1. 注册GitHub
2. 创建远程代码库
3. 打开Git Bash进入要托管的项目目录,输入: git clone 远程代码库地址把远程版本库克隆到本地
4. 关联GitHub版本库:git remote add origin git@github.com:xxx/xxx.git
5. 把克隆下来的目录中的文件全部复制到项目根目录中(.git 是一个隐藏目录，在复制的时候千万不要漏掉)
6. 
然后把所有文件添加到版本控制中 
    1. git add . 
    2. git commit -m "First commit" 
    3. git push origin master
10. 忽略特殊文件

忽略某些文件时，需要编写.gitignore; gitignore文件本身要放到版本库里,  并且可以对.gitignore做版本管理！
在GitHub上创建版本库时会自动生成.gitignore文件, 拿来即可
11. 配置别名

1. git config --global alias.<别名> <命令>
例如
    1. git config --global alias.ci commit
    2. git config --global alias.br branch
12. 搭建Git服务器

环境Linux, 推荐Ubuntu或Debian
假设你已经有sudo权限的用户账号，下面，正式开始安装。
1. 安装git：$ sudo apt-get install git
2. 创建一个git用户，用来运行git服务：$ sudo adduser git
3. 
创建证书登录： 
收集所有需要登录的用户的公钥，就是他们自己的id_rsa.pub文件，把所有公钥导入到/home/git/.ssh/authorized_keys文件里，一行一个。
4. 
初始化Git仓库： 
先选定一个目录作为Git仓库，假定是/srv/sample.git，在/srv目录下输入命令： 
$ sudo git init --bare sample.git 
Git就会创建一个裸仓库，裸仓库没有工作区，因为服务器上的Git仓库纯粹是为了共享，所以不让用户直接登录到服务器上去改工作区，并且服务器上的Git仓库通常都以.git结尾。然后，把owner改为git： 
$ sudo chown -R git:git sample.git
5. 
禁用shell登录： 
出于安全考虑，第二步创建的git用户不允许登录shell，这可以通过编辑/etc/passwd文件完成。找到类似下面的一行： 
git:x:1001:1001:,,,:/home/git:/bin/bash 
改为： 
git:x:1001:1001:,,,:/home/git:/usr/bin/git-shell 
这样，git用户可以正常通过ssh使用git，但无法登录shell，因为我们为git用户指定的git-shell每次一登录就自动退出。
6. 克隆远程仓库：$ git clone git@server:/srv/sample.git
管理公钥
如果团队很小，把每个人的公钥收集起来放到服务器的/home/git/.ssh/authorized_keys文件里就是可行的。如果团队有几百号人，就没法这么玩了，这时，可以用Gitosis来管理公钥。这里我们不介绍怎么玩Gitosis了，几百号人的团队基本都在500强了，相信找个高水平的Linux管理员问题不大
管理权限
有很多不但视源代码如生命，而且视员工为窃贼的公司，会在版本控制系统里设置一套完善的权限控制，每个人是否有读写权限会精确到每个分支甚至每个目录下。因为Git是为Linux源代码托管而开发的，所以Git也继承了开源社区的精神，不支持权限控制。不过，因为Git支持钩子（hook），所以，可以在服务器端编写一系列脚本来控制提交等操作，达到权限控制的目的。Gitolite就是这个工具。这里我们也不介绍Gitolite了，不要把有限的生命浪费到权限斗争中。
遇到的问题

Move or commit them before merge

原文链接
在使用git pull时,经常会遇到报错:
Please move or remove them before you can merge
这是因为本地有修改,与云端别人提交的修改冲突,又没有merge.
如果确定使用云端的代码,最方便的解决方法是删除本地修改,可以使用以下命令:
git clean -d -fx ""
d  -----删除未被添加到git的路径中的文件
f  -----强制运行
x  -----删除忽略文件已经对git来说不识别的文件
注意:该命令会删除本地的修改,最好先备份再使用
git clean 参数 
- n 显示 将要 删除的 文件 和 目录 
- f 删除 文件，-df 删除 文件 和 目录
git clean -n 
git clean -df 
git clean -f
