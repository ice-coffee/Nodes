[toc]

### 接入方式选择

Android 项目引入 `protobuf` 有两种主流做法，先选定再往下走：

| 方式   | 做法                                                                                          | 适用场景                              |
| ---- | ------------------------------------------------------------------------------------------- | --------------------------------- |
| 产物入库 | 本地执行 `protoc` 生成 Java，把 `.java` 提交到仓库，Gradle 只当普通源码编译                                       | 构建机不想装 protoc；proto 由外部团队维护、变更不频繁 |
| 插件生成 | 引入 [protobuf-gradle-plugin](https://github.com/google/protobuf-gradle-plugin)，编译期自动跑 protoc | proto 在本仓维护、改动频繁，要求自动同步           |

> 两种方式的差异只在「谁来生成 Java」，第 4 步之后的使用方式完全一致。

### 步骤 1：准备 `.proto` 文件与目录

`.proto` 的存放目录必须**镜像 proto 的 package 路径**，因为 `import` 写的是相对 `-I` 根目录的完整路径，目录对不上 protoc 会直接报找不到依赖。

```
app/
└── proto/                                  # -I 根目录
    └── demo/packet/v1/packet.proto         # package demo.packet.v1;
```

Android 侧必须补上两个 Java 选项，否则生成的包名和类名不可控：

```proto
syntax = "proto3";
package demo.packet.v1;

option java_package = "com.example.proto.packet";   // 生成 Java 的包名
option java_outer_classname = "PacketProto";        // 外层容器类名

message Envelope {
  repeated Frame frames = 1;
}

message Frame {
  string topic = 1;
  bytes value = 2;
}

message Payload {
  oneof body {
    RouteStart route_start = 10;
    CommandAck ack = 11;
  }
}
```

**`注意：`** 所有 `message` 都会作为静态内部类挂在 `java_outer_classname` 指定的类下，即 `PacketProto.Envelope`。**文件名和外层类名不必同名**，代码里找不到类时先看这个 option，不要按文件名猜。

### 步骤 2：生成 Java 代码

**`方式一：手动执行 protoc`**

Android 用 `lite` 版生成，产物体积和方法数远小于完整版：

```bash
protoc --java_out=lite:app/generated-java \
       -I=app/proto \
       $(find app/proto -name '*.proto')
```

生成结果：

```
app/generated-java/com/example/proto/packet/PacketProto.java
```

建议把这条命令固化成脚本并**写死 protoc 版本**，避免不同机器生成物漂移。

**`方式二：protobuf-gradle-plugin`**

```groovy
plugins {
    id "com.google.protobuf" version "0.9.4"
}

protobuf {
    protoc { artifact = "com.google.protobuf:protoc:3.18.3" }
    generateProtoTasks {
        all().each { task ->
            task.builtins {
                java { option "lite" }      // 关键：生成 lite 代码
            }
        }
    }
}

android {
    sourceSets {
        main { proto.srcDirs = ["app/proto"] }   // .proto 位置
    }
}
```

产物落在 `build/generated/source/proto/...`，由插件自动加入编译，不需要手动配 `java.srcDirs`。

---

### 步骤 3：把生成产物挂进 sourceSets

仅「产物入库」方式需要这一步：

```groovy
android {
    sourceSets {
        main {
            java.srcDirs = ["src/main/java", "app/generated-java"]
        }
    }
}
```

**`注意：`** `sourceSets` 才是「产物到底从哪来」的事实来源。README 和注释里写的生成脚本可能早已删除或改名，排查「改了 proto 却没生效」时先核对这里。

---

### 步骤 4：添加运行时依赖

生成代码只是壳，还要有运行时库；且**生成方式必须和运行时版本配套**：

```groovy
dependencies {
    // 与 --java_out=lite / option "lite" 配套
    implementation "com.google.protobuf:protobuf-javalite:3.18.3"

    // 若用 --java_out（完整版）生成，则依赖这个，二者不能混用
    // implementation "com.google.protobuf:protobuf-java:3.18.3"
}
```

| 依赖 | 配套生成参数 | 说明 |
| --- | --- | --- |
| `protobuf-javalite` | `--java_out=lite:DIR` | Android 首选，无反射、无 descriptor，包体小 |
| `protobuf-java` | `--java_out=DIR` | 功能全，支持 `JsonFormat`、`TextFormat`、动态消息 |

**`注意：`** lite 版**没有** `JsonFormat`，不能把消息转成 JSON 打日志，也不能按字段名动态取值。若强依赖这些能力，只能换完整版。

---

### 步骤 5：混淆配置与验证

**`混淆：`** javalite 不依赖反射，一般无需额外规则；若使用完整版或通过反射访问消息，需保留：

```proguard
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }
-keepclassmembers class * extends com.google.protobuf.GeneratedMessageLite {
    <fields>;
}
```

**`验证：`** 用同一份生成代码「组包再解包」做一次 round-trip 自测，是成本最低的验证方式——编解码共用一份生成代码，能保证信封层级没写错。

```kotlin
val bytes = buildEnvelope().toByteArray()
val back = PacketProto.Envelope.parseFrom(bytes)
assertEquals(TOPIC_DOWN, back.getFrames(0).topic)
```

调试期把线上抓到的 pb 数据落盘回放时，必须按**二进制**读写（`file.readBytes()`）。经过 `String(bytes)`、日志复制粘贴、塞进 JSON 字符串字段的搬运都会破坏数据。

### 注意事项

* 字段号（tag）是 wire 协议的唯一身份，字段名只影响生成代码：**改名兼容，换号不兼容**；已发布的 tag 不复用、不改类型。
* proto3 标量字段无法区分「值为 0/空串」和「没传」，不要用 `0`、`""` 当业务哨兵值，必要时用 `optional` 或包一层 message。
* 判断 `oneof` 收到的是哪个分支要用 `getBodyCase()`，直接取值时未设置的分支会返回默认实例，导致静默走错逻辑。
* 生成文件头写着 `DO NOT EDIT`，手改会在下次生成时丢失。
* 若同一份 proto 还要给 native 层用，另跑一次 `--cpp_out` 由 CMake 编进 so；C++ 侧通常链接完整 `libprotobuf`，与 Java 侧选 lite 互不影响。
