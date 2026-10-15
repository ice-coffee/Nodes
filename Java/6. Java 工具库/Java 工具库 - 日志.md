[深入掌握Java日志体系](https://juejin.cn/post/6905026199722917902)：
对 `Java` 体系中日志框架做了整体介绍，并讲解了日志框架中门面模式的使用。

[Logback](https://github.com/qos-ch/logback?tab=readme-ov-file)：
logback github 地址。


### 依赖
```gradle
implementation 'ch.qos.logback:logback-classic:1.5.7'

compileOnly 'org.projectlombok:lombok:1.18.20'
annotationProcessor 'org.projectlombok:lombok:1.18.20'
```

> 推荐使用 `slf4j + logback` 处理项目日志。
