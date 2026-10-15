[PackageManagerService类作用分析](https://blog.csdn.net/h55l55/article/details/95619005)

### 功能
- 提供一个能够根据 `intent` 匹配到具体的 `Activity`、`Provider`、`Service`。即可以把 `intent` 转化为可以被 `java` 类加载器识别的 `Component`。
- 进行权限检查。
- 提供安装、删除应用程序的接口。
