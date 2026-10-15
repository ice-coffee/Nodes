### 关于Android studio

@(android studio)

[TOC]

#### 1. 项目替换包名
在项目目录下直接修改包名`Refactor` --> `Rename`
![Alt text](<../../attachment/:1.png>)
点击`Rename package`
有时可能会出现无法修改完整包名的问题,如下:
![Alt text](<../../attachment/:TDRM33DB~6MMN3N0SF-SM~3.png>)
这时需要点击齿轮图标修改包结构,然后就可以随便修改包的名字了
![Alt text](<../../attachment/:8~@S%60P0@DJ~X7MEF~G4I-L.png>)

#### 2. 解决引用类库时类库中包和本程序包冲突问题

    complite (project(':PG_Edit_SDK'))
    {
	    exclude module:'universal-image-loader'
    }

解释一下 , 上方代码的意思就是, 添加Library: PG_Edit_SDK中除image-loader外所以的包, 
exclude : 排除

#### 3. TODO
[Android Studio 必备技巧：TODO 用法及自定义 TODO](http://blog.csdn.net/my_truelove/article/details/72857949)

#### 4. TODO
[Android Studio 必备技巧：TODO 用法及自定义 TODO](http://blog.csdn.net/my_truelove/article/details/72857949)

#### 5. Android Studio 完全卸载
[原文](https://blog.csdn.net/qq_21996633/article/details/51079380)

1／执行这些命令在命令行

```
rm -Rf /Applications/Android\ Studio.app
rm -Rf ~/Library/Preferences/AndroidStudio*
rm ~/Library/Preferences/com.google.android.studio.plist
rm -Rf ~/Library/Application\ Support/AndroidStudio*
rm -Rf ~/Library/Logs/AndroidStudio*
rm -Rf ~/Library/Caches/AndroidStudio*
```

2／如果你想删除全部项目

```
rm -Rf ~/AndroidStudioProjects
```

3／删除gradle关联文件 (caches & wrapper)

```
rm -Rf ~/.gradle
```

4／删除模拟器

```
rm -Rf ~/.android
```

5／删除android 工具

```
rm -Rf ~/Library/Android*
```

如果你想要完全清除的话，除了4，全部敲一下。

#### 6. layout design 不显示问题

关键词: design editor
解决方法：
File -> sync project with gradle file
重启Android Studio
