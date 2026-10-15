### --branch <name>, -b <name>
拉取代码库时指定拉去分支，而非默认分支。支持 `tag`。

### --single-branch
只拉取指定分支的历史记录。若使用 `-b <name>` 指定目标分支则只拉取 `<name>` 分支到本地，若未指定则只拉取默认分支。

使用 `--single-branch` 后，若还想拉取其它分支：

```
git remote set-branches origin <name>
git fetch --depth=1 origin
git checkout -b <name> origin/<name>
```

### --depth=1
浅克隆，只拉取目标分支指定数量的最新提交记录。

使用 `--depth=1` 后，若想拉取当前分支所有的提交记录：

```
git fetch --unshallow
```

或者可以拉取指定数量的提交记录：

```
git fetch --depth=50
```
