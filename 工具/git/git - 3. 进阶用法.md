[toc]
#### git stash
`git stash` 语法:
* `git stash apply`：语句恢复后，stash列表中内容并不删除；
* `git stash drop`：语句恢复后，stash列表中内容会被删除
* `git stash list`：查看stash list 列表
* `git stash apply stash@[0]`：恢复指定stash
* `git stash push -m "message" **/*.java`：stash 部分文件

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

#### 版本回退

**回退单个提交**：
* `git revert 'commit-id'`
* `git push origin '分支'`

**回退多个连续提交**：
* `git revert -n 'commit-id0..commit-idn'`
* `git push origin '分支'`

**回退多个不连续提交**：
* `git revert -n 'commit-id0'`
* `git revert -n 'commit-id3'`
* `git push origin '分支'`

或（[Git 回滚篇git revert](https://segmentfault.com/a/1190000022160845)）
* `git rebase -i 'commit-id0'`
* `git rebase -i 'commit-id3'`
* `git push origin '分支'`

#### 修改 commit
修改 `Message` 内容：
* `git commit --amend -m "新内容" `

新增修改合入当前未 `push` 的 ` commit`：
* `git add .`
* `git commit --amend --no-edit`
* `git push origin '分支'`

#### 合并分支

**`merge`**：

-  首先进入主分支中: `git checkout master`
-  然后合并分支:  `git merge <name>`

> 合并分支时, `git` 会使用 `Fast forward` 模式, 但是在这种模式下, 删除分支后, 会丢掉分支信息, 这种情况下可以使用 `--no-ff` 模式合并分支：
> `git merge --no-ff -m "merge with no-ff" dev`

**`rebase`**：

[git rebase详解（图解+最简单示例，一次就懂）-CSDN博客](https://blog.csdn.net/weixin_42310154/article/details/119004977)

#### cherry-pick
[git cherry-pick 教程](https://www.ruanyifeng.com/blog/2020/04/git-cherry-pick.html)

合入

* 合入单个：`git cherry-pick (commit id)`

冲突

* 解决冲突，继续合入：`git cherry-pick --continue`
* 放弃合入，回到合入前：`git cherry-pick --abort`
* 放弃合入，保持现状：`git cherry-pick --quit`

#### git patch
直接使用 IDEA 编辑器。

#### git rebase
[git rebase详解](https://blog.csdn.net/weixin_42310154/article/details/119004977)

ebase，变基，可以直接理解为改变基底。

feature分支是基于master分支的B拉出来的分支，feature的基底是B。而master在B之后有新的提交，就相当于此时要用master上新的提交来作为feature分支的新基底。实际操作为把B之后feature的提交先暂存下来，然后删掉原来这些提交，再找到master的最新提交位置，把存下来的提交再接上去（接上去是逐个和新基底处理冲突的过程），如此feature分支的基底就相当于变成了M而不是原来的B了。（注意，如果master上在B以后没有新提交，那么就还是用原来的B作为基，rebase操作相当于无效，此时和git merge就基本没区别了，差异只在于git merge会多一条记录Merge操作的提交记录）
