### jcenter vs maven
@(android gradle)

记录以下两者的区别

```
google()
---or---
maven {
            url 'https://maven.google.com/'
            name 'Google'
        }
```

google() 是如下的简写形式

```
maven {
            url 'https://dl.google.com/dl/android/maven2//'
            name 'Google'
        }
```

但是如果访问如果尝试访问`https://dl.google.com/dl/android/maven2/`, 则会显示404. Google maven存储库的正确网址为：
`https://dl.google.com/dl/android/maven2/index.html` 或`https://maven.google.com`

#### 为什么要
因为jcenter（）存储库已删除`android.arch.core`的目录，因此我们必须
使用 google() 或者 maven 来获取.
#### 扩展
##### jcenter()是什么
jcenter 和 maven 一样声明的是一个远程仓库
Android的项目依赖有一种远程库依赖
比如app需要依赖下面这个远程库，

```
dependencies {
compile 'com.etsy.android.grid:library:1.0.5'
}
```

这样定义了， 去哪里拿到库工程的代码和资源文件呢，肯定是要从某个源去获取。
jcenter是一个声明仓库的源，之前版本则是mavenCentral(), jcenter可以理解成是一个新的中央远程仓库，兼容maven中心仓库，而且性能更优。
