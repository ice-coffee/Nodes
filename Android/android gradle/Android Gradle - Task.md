[toc]
> 推荐阅读 `Gradle` 官方文档掌握最全信息。

`Task` 是 Gradle 中的一种数据类型，它代表构建过程中的某项基本工作。每一个 `Task` 都需要和一个 `Project` 关联。

### 关联地址
[Developing Custom Gradle Task Types](https://docs.gradle.org/current/userguide/custom_tasks.html)

[Gradle 使用指南 -- Gradle Task](https://www.heqiangfly.com/2016/03/13/development-tool-gradle-task/)

[Gradle插件从入门到进阶](https://juejin.im/post/6844903838290296846#heading-50)

### 相关命令
> 在 `Android Studio` 中可以直接使用 `gradlew` 脚本运行 `Gradle` 命令。
> 如果想通过 `gradle` 运行命令需要配置 `Gradle` 环境变量。

查看项目中的 `Task`：
```
./gradlew :tasks
```

```
--all           查看项目中所有的 `Task`：
-m,--dry-run    在禁用所有依赖 `Task` 的情况下运行 `Task`
-q              仅输出错误日志
```

### 创建 Task
创建 `Task` 主要有两种方式，
* 一种是通过 `Project` 接口提供的 `task()` 方法。
* 另一种方式是通过 `TaskContainer` 的 `create()` 方法。

```
Task task(String name)
Task task(String name, Closure configureClosure)
Task task(String name, Action<? super Task> configureAction)
Task task(Map<String, ?> args, String name)
Task task(Map<String, ?> args, String name, Closure configureClosure)
```
```
Task create(String name)
Task create(String name, Closure configureClosure)
T create(String name, Class<T> type)
T create(String name, Class<T> type, Object... constructorArgs)
T create(String name, Class<T> type, Action<? super T> configuration)
T create(String name, Action<? super T> configureAction)
Task create(Map<String, ?> options)
Task create(Map<String, ?> options, Closure configureClosure)
```

参数说明：
* name：`Task` 名称。
* configureClosure：在编译期间配置生成的 `Task`。
* configureAction：配置到 `Task` 中要执行的动作。
* args：`Task` 配置项映射。

配置项 `args` 可选如下：

| 选项 | 描述 | 默认值 |
| --- | --- | --- |
| type | 要创建的 `Task` 类型 | DefaultTask |
| overwrite | 是否替换已存在的 `Task`? | false |
| dependsOn | 依赖的 `Task` 或一组 `Task` 的名称 | [] |
| action | 添加到 `Task` 中的 闭包 或 `Action` | null |
| description | 关于 `Task` 的描述 | null |
| group | `Task` 所属的分组 | null |

示例：
```
task hello {
    doFirst {
        println 'task hello doFirst'
    }
    doLast {
        println 'task hello doLast'
    }
    println 'config task hello'
}

task hello2 (type: Copy){
    from 'src/main/AndroidManifest.xml'
    into 'build/test'
}

task hello3(group: "myTest", description:"This is test task paras", dependsOn: ["A", "B"]){
    println 'task hello3'
}

task("hello4", group: "myTest", description:"This is test task para name"){
    println 'task hello4'
}

tasks.create("hello5") {
    group = 'Welcome'
    description = 'Produces a greeting'
    doLast {
        println 'Hello, World'
    }
}
```
执行`./gradlew :tasks`，输出如下：
```
MyTest tasks
------------
hello3 - This is test task paras
hello4 - This is test task para name

Welcome tasks
-------------
hello5 - Produces a greeting
```

可以看到在创建 `hello5 Task` 时，`group`、`description` 包括下文即将提到的 `doFirst` 和 `doLask` 都可以配置在闭包中，这是由于闭包会在构建文件编译时对所生成的 `Task` 进行配置，所以这样写也是可以的。

每个 `Task` 都拥有一个名称和一个完全限定路径。该路径在所有项目和所有任务中都是唯一的。该路径由所属项目的路径和 `Task` 名称组成，由 `:` 分割。例如：
```
app:assemble
```

#### Task Action
一个 `Task` 是由一系列 `Action` 对象组成。可以通过调用 `Task.doFirst(Action)` 或 `Task.doLast(Action)` 添加需要最先执行的 `Action` 或需要最后执行的 `Action`。也可以在声明 `Task` 时通过闭包参数添加 `Action`。
`doFirst` 和 `doLast` 可以添加在闭包内，也可以添加在闭包外，执行结果如下：
```
task myTask {
    doFirst {
        println 'inner first'
    }
    doLast {
        println 'inner last'
    }
}

testBoth.doFirst {
    println 'out first'
}
testBoth.doLast {
    println 'out last'
}
```
运行 `task`：
```
./gradlew myTask
```
输出结果如下：
```
out first
inner first
inner last
out last
```
可以看到声明在闭包外的 `Action` 的生命周期要比闭包内的要长一些。

### Task 依赖和执行顺序
一个 `Task` 可能依赖于其他 `Task` 或者必须在某 `Task` 后运行。`Gradle` 会严格执行 `Task` 的依赖关系，以便 `Task` 能被正确的执行。

指定 `Task` 间的依赖和执行顺序可以使用以下方法：
* Task.dependsOn(java.lang.Object[]) 或 Task.setDependsOn(java.lang.Iterable)
* Task.mustRunAfter(java.lang.Object[]) 或 Task.setMustRunAfter(java.lang.Iterable)
* Task.shouldRunAfter(java.lang.Object[]) 或 Task.setShouldRunAfter(java.lang.Iterable)

以上方法可接收以下任何类型的对象：
* `Task` 的相对路径
* `Task` 对象
* `TaskDependency` 对象
* `TaskReference` 对象
* `Buildable` 对象
* `ARegularFileProperty` 或 `DirectoryProperty`
* `Provider` 对象。包含以上列出的任何类型。
* `Iterable`、`Collection`、`Map` 或 `array`。可能包含此处列出的任何类型。
* 回调函数。该回调可返回此处列出的任何类型。
* `Groovy 闭包` 或 `Kotlin` 函数。闭包或函数可以返回此处列出的任何类型。它的返回值递归转换为任务。若返回值为 `null` 视为空集。
* 其他类型都不支持。

#### Task 依赖
```
task A {
    doLast {
        println 'Hello from A'
    }
}
task B {
    doLast {
        println 'Hello from B'
    }
}
B.dependsOn A
```

执行 `./gradlew -q B` 的同时会先去执行任务 `A`：
```
> Task :A
Hello from A

> Task :B
Hello from B
```

插入依赖
也可以在已经存在的 task 依赖中插入我们的 task 。
比如前面的A和B已经存在了依赖关系，我们想在中间插入任务B1，可以通过下面的代码实现：

```
B1.dependsOn A
B.dependsOn B1
```
输出结果：
```
Hello from A
Hello from B1
Hello from B
```

#### Task 排序
`mustRunAfter` 与 `shouldRunAfter` 在某些情况下，我们希望能控制任务的的执行顺序，这种控制并不是向上面那样去显示地加入依赖关系。我们可以通过 `mustRunAfter` 和 `shouldRunAfter` 来实现。
使用 `mustRunAfter` 意味着 `taskB` 必须总是在 `taskA` 之后运行，`shouldRunAfter` 和 `mustRunAfter` 很像，只是没有这么严格。

```
A.mustRunAfter B
```
执行 `./gradlew -q A B`，结果：
```
Hello from B
Hello from A
```
如果换成 `shouldRunAfter`，结果也是一样的。
虽然我们将两个任务进行了排序，但是他们仍然是可以单独执行的，任务排序不影响任务执行。排序规则只有当两个任务同时执行时才会被应用。
比如执行 
```
./gradlew -q A
```
会输出：
```
Hello from A
```
另外，`shouldRunAfter` 不影响任务之间的执行依赖。但如果 `mustRunAfter` 和任务依赖之间发生了冲突，那么执行时将会报错。

#### finalizedBy
假如出现了这样一种使用场景，执行完任务 A 之后必须要执行一下任务 B，那么上面的方法是无法解决这个问题的，这时 `finalizedBy` 就派上用场了。
```
A.finalizedBy B
```
执行 `./gradlew -q A`，结果：
```
Hello from A
Hello from B
```

### Task Type
除了前面我们介绍的 `Task` 定义方式以外，`Gradle` 本身还提供了一些已有的 `Task` 供我们使用，比如 `Copy`、`Delete`、`Sync` 等。因此我们定义 `Task` 的时候是可以继承已有的 `Task`。

#### Copy
[Gradle基础进阶 拷贝任务](https://blog.hacktons.cn/2016/07/30/gradle-beyond-the-basics-chapter1-copy-task/)
[Gradle基础进阶 过滤与修改文件](https://blog.hacktons.cn/2016/07/31/filtering-and-transfering-files/)

```
task hello2 (type: Copy){
    from 'src/main/AndroidManifest.xml'  // 调用 from 方法
    into 'build/test'  // 调用 into 方法
    // 调用 rename 方法
    rename {String fileName ->
        fileName = "AndroidManifestCopy.xml"
    }
}
```

### 自定义 Task Type

实现自定义 `Task` 需要继承 `DefaultTask`：
```
class GreetingTask extends DefaultTask {
    @Input
    String greeting = 'hello from GreetingTask'
    
    @TaskAction
    def greet() {
        println greeting
    }
}

// Use the default greeting
task hello(type: GreetingTask)

// Customize the greeting
task greeting(type: GreetingTask) {
    greeting = 'greetings from GreetingTask'
}
```
当 `Gradle` 执行 `Task` 时会调用 `TaskAction` 修饰的方法。
执行 `gradle -q hello`，输出如下：
```
>  gradle -q hello greeting
hello from GreetingTask
greetings from GreetingTask
```
> 向自定义 `Task` 中添加属性，可以不声明注解 `@Input`。在文档中 `Input` 一类的注解有很多，表示当属性的值发生改变，则此 `Task` 过期。（不太懂啥意思 `^_^!`）

自定义 `Task` 的打包方式有如下三种：
* build script
* buildSrc project
* Standalone project

#### build script
> 将 `Task` 类直接放在在构建脚本中。

将 `Task` 类放在构建脚本中将自动编译并包含在构建脚本的类路径中，而无需执行任何操作。但是 `Task` 类在构建脚本之外不可见，因此无法在定义该任务的构建脚本之外重用该 `Task`。

#### buildSrc project
> 将 `Task` 类放在 `rootProjectDir/buildSrc/src/main/groovy` 目录中（`rootProjectDir/buildSrc/src/main/java` 或 `rootProjectDir/buildSrc/src/main/kotlin` 看你使用那种语言了）。

创建 `buildSrc/src/main/groovy` 使用 `Gradle` 编译项目，使 `Task` 类可以引用到 `gradle.api `。

#### Standalone project
> 创建独立的项目，打包发布到远程仓库，可以供其他项目使用。
