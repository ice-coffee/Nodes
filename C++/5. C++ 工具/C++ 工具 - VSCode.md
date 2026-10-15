### 下载

### 安装扩展

* Better C++ Syntax
* C/C++
* C/C++ Extension Pack
* C/C++ Themes
* CMake
* CMake Tools
* Code Runner
* Chinese：中文扩展包
* GitLens：git 插件

### 设置

#### c++11运行环境配置
[vscode C++ 简易配置（支持c++11以上）](https://zhuanlan.zhihu.com/p/269244754)

* 点击 `Code Runner` 的齿轮，打开扩展设置；
* 找到 `Code-runner:Executor Map` 点击，在 `settings.json` 中编辑；
![](https://pic2.zhimg.com/80/v2-67648d6f2018f5b2019b2935bb691d1d_720w.webp)
* 在 `code-runner.executorMap` 中找到 `cpp` 的这一行；
* 在 `$fileNameWithoutExt` 的后面添加 `-std=c++11` 保存后即可食用；

```c++
"cpp": "cd $dir && g++ $fileName -o $fileNameWithoutExt -std=c++11 && $dir$fileNameWithoutExt",
```
