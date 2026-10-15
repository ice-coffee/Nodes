## Android 问题集锦 06

@(android BUG记录)

### 描述
> butterknife插件绑定控件返回null

### 解决方案

```
apply plugin: 'com.android.library'
apply plugin: 'com.jakewharton.butterknife'
classpath 'com.jakewharton:butterknife-gradle-plugin:8.4.0'
```

这三个是使用本地库的时候需要的

```
compile 'com.jakewharton:butterknife:8.4.0'
annotationProcessor 'com.jakewharton:butterknife-compiler:8.4.0'
```

这两个是使用gradle库需要的

分开使用，别一起用

使用第二种方式, 我发现添加以上代码到 app‘s build.gradle 是正确的。
但是添加到library’s build.gradle 就会java.lang.NullPointerException.

### 参考
[java.lang.NullPointerException](https://github.com/JakeWharton/butterknife/issues/801)
