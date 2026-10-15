[TOC]
### 关联网址
[Gradle User Guide 中文版](https://doc.yonyoucloud.com/doc/wiki/project/GradleUserGuide-Wiki/index.html)
[Gradle 官网](http://gradle.org/)
[Gradle 参考](https://docs.gradle.org/current/dsl/)
[Gradle API 文档](https://docs.gradle.org/current/javadoc/index.html?overview-summary.html)

### Gradle 环境配置

2. 在[Gradle SDK](http://gradle.org/gradle-download/)下载 Gradle SDK。选择 Complete distribution 和 Binary only distribution 都行。
3. 下载后解压。
4. 配置 Gradle 环境变量。
```
open ~/.bash_profile
```
写入 Gradle bin 目录地址
```
export PATH=$PATH:/Users/****/gradle-6.7-all/bin
```
使配置生效
```
source ~/.bash_profile
```
5. 测试
```
gradle -v
```
输出版本号代表配置成功。

基本与 Groovy 配置步骤一致。

### Gradle 是什么
gradle 是一个开源的自动化构建工具。

### Gradle 使用

#### 在项目中使用 Gradle 
> 与 Android Studio 生成的 Android 项目对比来看，更容易理解。

- 每一个 Project 都必须设置一个 build.gradle 文件。
- 对于 multi-projects build，需要在根目录下也放一个 build.gradle，和一个 settings.gradle。
- 一个 Project 是由若干 tasks 来组成的，当 gradle xxx 的时候，实际上是要求 gradle 执行 xxx 任务。这个任务就能完成具体的工作。

在 Android 中每一个 `Library` 和每一个 `App` 都是单独的 `Project`。

Gradle 通过配置 Multi-Projects Build 很容易可以一次执行 `Project` 中所有的编译文件。它需要：
- 在项目根目录下添加 `build.gradle`：配置其他子 `Project` ,比如为子`Project` 添加一些属性。这个 build.gradle 有没有都无所属。
- 在项目根目录下添加 `settings.gradle`：这个文件很重要，名字必须是  `settings.gradle`。它里边用来告诉 Gradle，这个 multiprojects 包含多少个子 Project。


#### Gradle 工作流程

Gradle 工作包含三个阶段:
- 初始化阶段，这个时候 settings.gradle 会执行。
- 配置阶段，每个 Project 都会被解析，其内部的任务也会被添加到一个有向图里，用于解决执行过程中的依赖关系。
- 然后是执行阶段，你在 gradle xxx 中指定什么任务，gradle 就会将这个 xxx 任务链上的所有任务全部按依赖顺序执行一遍!

### Gradle 介绍
Gradle 基于 Groovy，Groovy 又基于 Java。所以，Gradle 执行的时候和 Groovy 一样， 会把脚本转换成 Java 对象。Gradle 主要有三种对象，这三种对象和三种不同的脚本文件对应，在 gradle 执行的时候，会将脚本转换成对应的对象:
- Gradle 对象:当我们执行 gradle xxx 或者什么的时候，gradle 会从默认的配置 脚本中构造出一个 Gradle 对象。在整个执行过程中，只有这么一个对象。Gradle 对象的数据类型就是 Gradle。我们一般很少去定制这个默认的配置脚本。
- Settings 对象:显然，每一个 settings.gradle 都会转换成一个 Settings 对象。
- Project 对象:每一个 build.gradle 会转换成一个 Project 对象。

每个 `Gradle` 脚本都实现了 `Script` 接口，该接口定义了很多可以在脚本中使用的属性和方法。

#### Gradle
在项目构建开始时会先创建一个也仅有一个的 `Gradle` 对象，这个对象存在于 `Setting` 、 `Project` 对象中，是它们的实例变量。

##### 常用属性

| Property | Description |
| --- | --- |
| gradle | 返回 Gradle 实例。 |
| gradleHomeDir | gradle SDK 的存放目录。 |
| gradleUserHomeDir | `.gradle` 配置文件的存放目录。 |
| rootProject | 项目根目录 `build.gradle` 所属的 `project` 对象。 |

```
// /Users/xxx/Desktop/Tools/Android/gradle/gradle-4.1
println gradle.gradleHomeDir

// /Users/xxx/.gradle
println gradle.gradleUserHomeDir
```

#### Project
在 `Project` 对象中可以访问 `Gradle` 的所有功能。

##### 生命周期
在加载和初始化过程中，Gradle 为每一个参与构建项目的 `build.gradle` 文件生成一个 `Project` 对象。

- 创建 `Setting` 对象；
- `Setting` 对象加载 `Setting.gradle` 中的配置；
- 通过配置好的 `Setting` 对象创建 `Project` 对象的视图层级。

`Gradle` 会执行 Project 中的 `build.gralde` 文件委托给相应 `Project` 对象，所以在 `build.gradle` 文件中可以直接使用 `Project` 接口的任何方法和属性。

```
defaultTasks（'some-task'）   //委托给Project.defaultTasks（） 
reportsDir = file（'reports'）//委托给Project.file（）和Java插件
```

> 建议使用 `project` 进行访问，使代码更清晰。

##### 常用属性

| Property | Description |
| --- | --- |
| gradle | 该项目的 `gradle` 对象 |
| rootDir | 该项目的根目录 |
| rootProject | 项目根目录 `build.gradle` 所属的 `project` 对象。 |
| tasks | 该 Project 的任务集合 |

##### 常用方法
1. `getTasks`

获取 `TaskContainer` 它是 `Task` 对象的集合。在 gradle 文件中可以通过简写 `tasks` 获得。
示例一：
禁止名称中包含 `debug` 的 `Task` 执行。
```
def targetTasks = project.tasks.findAll{task ->
    task.name.contains("Debug") 
}

targetTasks.each{
    println "disable debug task : ${it.name}"
    it.setEnabled false
}
```

2. `apply`

> 这里我理解 `apply` 会加载插件或脚本到响应的 `project` 对象上。通过 `project` 对象可以进行访问，后面有项目示例可以参考。
Project 通过 `apply` 方法加载插件。如下：

```
//加载插件
void apply(Map<String, ?> options)
```

`apply` 方法的选项有三种：
1. `plugin`：加载插件
```
//编译 library
apply plugin: 'com.android.library'
//编译 app
apply plugin: 'com.android.application'
```
2. `from`：加载脚本
```
//conf.gradle 是一个配置脚本
apply from: "conf.gradle"
```
3. `to`：指定委托对象（还没见到如何使用）
当一个 Project apply 一个 gradle 文件的时候，这个 gradle 文件会转换成一个 Script 对象。Script 中有一个 delegate 对象，这个 delegate 默认是加载(即调用 apply)它的 Project 对象。通过 to 参数，你可以把 delegate 对象指定为别的东西。

##### 设置额外属性
Gradle 提供了一种名为 `extra property` 的方法。extra property 是额外属性的意思，在第一次定义该属性的时候需要通过 `ext` 前缀来标示它是一个额外的属性。定义好之后，后面 的存取就不需要 ext 前缀了。ext 属性支持 Project 和 Gradle 对象。即 Project 和 Gradle 对象 都可以设置 ext 属性。

设置属性有两种方式：
1. 通过属性赋值
```
//第一次定义或者设置它的时候需要 ext 前缀
gradle.ext.versionCode = “103”

//再次存取 api 的时候，就不需要 ext 前缀了
println gradle.versionCode
```
> 测试直接使用 ext 属性也可。
2. 通过闭包
```
ext {
    versionCode = "103"
}
```
> 注意：gradle 就是 gradle 对象。它默认是 Settings 和 Project 的成员变量。

> 在 Android 项目中 `ext` 属性可以用于配置信息，也说明了 `from` 的用法，如下：

conf.gradle
```
ext {
    android = [
        compileSdkVersion: 28,
        minSdkVersion    : 21,
        targetSdkVersion : 28,

        versionCode      : 10003,
        versionName      : '1.0.3',
    ]

    dependencies = [
        "appcompat-v7"  : "com.android.support:appcompat-v7:${android["VSupportSdk"]}",
        "support-v4"    : "com.android.support:support-v4:${android["VSupportSdk"]}",
        "design"        : "com.android.support:design:${android["VSupportSdk"]}"
    ]
}
```
build.gradle(Application)
```
apply from: "conf.gradle"
...省略其他...
```
build.gradle(:app)
```
android {
    compileSdkVersion rootProject.ext.android.compileSdkVersion
    ...省略其他...
}
```
其中 `rootProject` 指代项目根目录下的 build.gradle 对象，`rootProject.ext.android.compileSdkVersion` 说明 `apply from: "conf.grale"` 将 `conf.gradle` 加载到了 `rootProject` 对象中。

#### 脚本块

构建脚本由零个或多个语句和脚本块组成。语句可以包括方法调用、属性分配和局部变量定义。脚本块是将闭包作为参数的方法调用。该闭包被视为配置闭包，它在执行时配置一些委托对象。顶级脚本块如下。


| Block | Description |
| --- | --- |
| allprojects { } | 配置该项目及其每个子项目。 |
| artifacts { } | 为该项目配置已发布的工件。 |
| buildscript { } | 为该项目配置构建脚本类路径。 |
| configurations { } | 为该项目配置依赖项配置。 |
| dependencies { } | 配置此项目的依赖项。 |
| repositories { } | 配置此项目的存储库。 |
| sourceSets { } | 配置该项目的源集。 |
| subprojects { } | 配置该项目的子项目。 |
