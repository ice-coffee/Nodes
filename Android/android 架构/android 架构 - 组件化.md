[“终于懂了” 系列：Android组件化，全面掌握！](https://mp.weixin.qq.com/s/WSzpJXXocajJjmWgYem3fA)：本篇讲解很详细且容易理解

[组件化场景下 module 依赖实践方案](https://mp.weixin.qq.com/s/i2xeAIei9N8oHTqV88IeNQ)：如标题

[toc]

### 组件化
组件化相对于模块粒度更细，这种细指的是业务的划分，在项目中模块或组件都是 `module`。在组件化项目中分为：

* 壳工程
* 业务组件
* 功能组件
* 基础组件

> 业务组件叫做业务模块也没什么问题
> 组件化相当于模块化的升级优化版本

#### 单独调试
一般采取 `Gradle` 配置的方式替换插件、applicationId、AndroidManifast.xml：

```
if (rootProject.ext.isMusicApplication) {
    apply plugin: 'com.android.application'
} else {
    apply plugin: 'com.android.library'
}

android {
   
    sourceSets {
        main {
            if (rootProject.ext.isMusicApplication) {
                manifest.srcFile 'src/main/module/AndroidManifest.xml'
            } else {
                manifest.srcFile 'src/main/AndroidManifest.xml'
            }
            jniLibs.srcDirs = ['libs']
        }
    }
}
```

#### 组件跳转
`ARouter`

#### 组件间数据访问
根据 `依赖倒置` 原则，使用专门组件定义暴露出去的业务接口，由功能提供方和使用方分别集成此组件。由功能提供方实现业务接口的具体逻辑，而使用方通过组件进行业务访问。

#### 获取 Fragment
可以有两种方式：

- `ARouter`
- 将 `Fragment` 暴露出去，让需要的业务模块通过接口访问

> 其实就是上面两种方式

#### Application 动态配置
两种方式：

- 注册监听接口：创建组件定义生命周期接口，监听主 `Application` 声明周期并分发，缺点无法保证初始化顺序。
- 反射：通过反射获取所有 `Application` 在主 `Application` 做初始化。

> 还有一种注解的方式：[Android组件化开发实践（九）：自定义Gradle插件](https://www.jianshu.com/p/3ec8e9574aaf)

#### 代码隔离
代码隔离：在 `Gradle` 中使用 `runtimeOnly` 使依赖项仅在运行时依赖，在编译期依赖项对于其是完全隔离的。
资源隔离：在 `Gradle` 中使用 `resourcePrefix` 配置来固定组件中资源的前缀。不过 `resourcePrefix` 配置只能限定 `res` 中 `xml` 文件中定义的资源，并不能限定图片资源，所以我们在往组件中添加图片资源时要手动限制资源前缀。并将多个组件中都会用到的资源放入基础组件中。这样我们就可以在最大限度上实现组件间资源的隔离。
