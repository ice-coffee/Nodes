[Url](http://www.noobyard.com/article/p-zccqmhsw-tz.html)

### Python 版本切换
使用 `update-alternatives` 管理 `Python` 版本。

**1. 添加 `Python 2` 和 `Python 3` 到 `alternatives` 管理：**

```bash
update-alternatives --install /usr/bin/python python /usr/bin/python2 1
update-alternatives --install /usr/bin/python python /usr/bin/python3 2
```
* `/usr/bin/python` 是指向的目标
* `/usr/bin/python2` 和 `/usr/bin/python3` 是候选版本
* 数字 `1` 和 `2` 表示优先级（数字越大优先级越高）

**2. 手动选择默认 `Python`：**

```bash
update-alternatives --config python
```
示例输出：
```
There are 2 choices for the alternative python (providing /usr/bin/python).
  Selection    Path                Priority   Status------------------------------------------------------------
  * 0            /usr/bin/python3    2         auto mode
    1            /usr/bin/python2    1         manual mode
    2            /usr/bin/python3    2         manual mode

Press <enter> to keep the current choice[*], or type selection number:
```
输入 `1`，回车，选择 `Python 2`。

**3. 验证：**
```bash
python --version
```

4. 删除 `python` 版本在 `update-alternatives` 中的绑定：

```
update-alternatives --remove python /usr/bin/python3
```
