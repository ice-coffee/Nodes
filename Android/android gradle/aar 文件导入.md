[Android依赖导入全攻略](https://juejin.im/post/5acd6daaf265da238a30ca73)

和jar包不同，aar包存放的路径声明和依赖引入是分开的：

```
repositories {
    flatDir {
        dir "../${project.name}/libs"
    }
}
dependencies {  
    implementation(name: 'aar名字', ext: 'aar')  
} 
```

复制代码如果aar包有很多，也可以一样象jar包统一添加一个文件夹下的所有包：
   
```
 def dir = new File('app/libs')
    dir.traverse(
            nameFilter: ~/.*\.aar/
    ) { file ->
        def name = file.getName().replace('.aar', '')
        implementation(name: name, ext: 'aar')
    }
```

复制代码当一个library类型的module需要引用aar文件时，也要在所在模块的build.gradle文件中加入上面的话，但是当其他 Module引用此library的module时，也需要在他的build.gradle中加入如下配置，否则会提示找不到文件：

```
repositories {  
    flatDir {  
        dirs 'libs', '../包含aar包的模块名/libs'  
    }  
}  
```

复制代码即如果当前Module需要一个aar包内容，不论aar包是不是在当前Module中，都需要在build.gradle中声明它所在的路径。如果项目中这样的Module比较多，每个都需要声明路径，不便于管理的话，推荐在项目的根build.gradle中统一添加,将所有包含aar包的模块名列出，这样不论是本Module或其他Module都不需要单独配置路径了：

```
allprojects {
    repositories {
        jcenter()
        google()
        flatDir {
             dirs "../moudle-A/libs,../moudle-B/libs,../moudle-C/libs".split(",")
        }
    }
}
```
