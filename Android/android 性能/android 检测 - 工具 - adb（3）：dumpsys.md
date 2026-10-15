[toc]

[Android 命令行工具：dumpsys](https://developer.android.com/tools/dumpsys?hl=zh-cn)

## meminfo
### 内存名词

* **`USS`**（Unique Set Size）：物理内存，进程独占的内存。

* **`PSS`**（Proportional Set Size）：物理内存，`PSS` = `USS` + 按比例分摊的共享库占用内存。比如一个应用有两个进程都用到了同一共享 `so` 库，那么每个进程会承担 `50%` 的 `so` 库的内存占用。`PSS` 是我们使用最频繁的一个指标，`App` 线上的内存数据统计一般都取这个指标。但是 `PSS` 也有一个问题，如果 `A` 进程与 `B` 进程都会使用一个共享 `So` 库，但是 `A` 是在 `B` 之后启动的，那么对于 `B` 的 `PSS` 曲线而言，在 `A` 启动的那一刻，即使 `B` 没有做任何事情，也会出现一个比较大的阶梯状下滑，这会给用曲线图分析软件内存的行为造成致命的麻烦。

* **`RSS`**（Resident Set Size）：物理内存，`RSS` = `USS` + 共享库占用内存。`PSS` 中的共享库会按比例分担，但是 `RSS` 不会，它会完全算进当前进程，所以把所有进程的 RSS 加总后得出来的内存会比实际高。按比例计算内存占用会有一定的消耗，因此当想要高性能的获取内存数据时便可以使用 `RSS`，`Android` 的 `LowMemoryKiller` 机制就是根据每个进程的 `RSS` 来计算进程优先级的。

* **`VSS`**（Virtual Set Size）：虚拟内存，`VSS` = `RSS` + 未分配实际物理内存。

> `USS <= PSS <= RSS <= VSS`。

#### 物理内存、虚拟内存
~

### meminfo

```
adb shell dumpsys meminfo 「pName/pId」
```

> 验证使用 `adb shell dumpsys meminfo pName` 是否会触发 `GC`。

输出如下：

![416fa4593faf196d0e26b9ce2a74f75e.png](<../../attachment/3B008BE1-D73D-4469-B83E-1C5479B28226.png>)

第`1`部分：
**横坐标：**
`Pss Total`：
`Private Dirty`：

* 进程独占 + 已被修改
* 不能被回收
* 被杀进程才能释放

`Private Clean`：

* 进程独占，但未修改
* 可被系统直接回收

`SwapPss Dirty`：

`Heap Size / Alloc / Free`：

* **Size**：堆最大可用容量
* **Alloc**：已使用
* **Free**：未使用但已预留

**纵坐标：**
* `Native Heap`：进程通过 native 分配器（`malloc / new / mmap`）申请的堆内存，不受 ART GC 管理，主要来自 NDK、JNI 和 native SDK。
* `Dalvik Heap`：ART/Dalvik 为 Java/Kotlin 对象分配的堆内存，由垃圾回收器管理。
* `Dalvik Other`：ART 运行时除 Java 对象堆外的内存，如类元数据、Dex cache、JIT 相关结构。
* `Stack`：进程中各线程的调用栈内存，随线程创建分配，通常不可回收。
* `Ashmem`：Android 匿名共享内存，用于进程间共享数据（如 Binder、Bitmap、共享缓冲区）。
* `Gfx dev`：显示设备相关的显存或帧缓冲映射，用于最终屏幕显示。
* `Other dev`：除图形设备外的其他设备文件映射占用的内存。
* `.so mmap`：动态链接库（`.so`）通过 mmap 映射到进程地址空间的内存页，通常为多进程共享。
* `.jar mmap`：Java `.jar` 文件被 ClassLoader 映射到内存中的只读页。
* `.apk mmap`：APK 中的资源与代码被 mmap 映射到内存中的页。
* `.ttf mmap`：字体文件（TrueType Font）通过 mmap 映射的内存。
* `.dex mmap`：DEX 字节码文件通过 mmap 映射到内存的部分。
* `.oat mmap`：ART 编译生成的 OAT 文件（优化后的本地代码）映射到内存的部分。
* `.art mmap`：ART 运行时的 image space（boot image）映射到内存的只读共享区域。
* `Other mmap`：无法归类到已知类型的其他 mmap 映射内存，通常来自 native 代码。
* `EGL mtrack`：EGL 相关的图形缓冲区和 GPU 资源占用的内存（Surface、GraphicBuffer 等）。
* `GL mtrack`：OpenGL 使用的 GPU 资源内存，如纹理、VBO、FBO 等。


第`2`部分：**`App Summary`**

* `Java Heap`：Dalvik Heap + Dalvik Other
* `Native Heap`：Native Heap 汇总
* `Code`：so / apk / dex / oat
* `Stack`：所有线程栈
* `Graphics`：EGL + GL + Gfx dev
* `Private Other`：Ashmem + Unknown + Others
* `System`：系统相关共享内存

第`3`部分：**`Objects`**
`Objects` 统计的是“`Framework` 明确感知并管理的系统级对象”，而不是 `JVM` 内部的普通 `Java` 对象；`Java` 对象的数量与生命周期属于 `GC` 领域，因此刻意不出现在 `meminfo` 中。

所以 `Objects` 不能直接用于判断是否内存泄漏，它只能表现 `Framework` 层生命周期是否正常，系统资源是否未释放。

| 字段               | 含义          |
| ---------------- | ----------- |
| `Views`            | View 对象数    |
| `ViewRootImpl`     | Window 数    |
| `AppContexts`      | Context 数   |
| `Activities`       | Activity 实例 |
| `Assets`           | Asset 实例    |
| `AssetManagers`    | 资源管理器       |
| `Local Binders`    | 本地 Binder   |
| `Proxy Binders`    | 远程 Binder   |
| `Parcel memory`    | Parcel 占用   |
| `Parcel count`     | Parcel 数量   |
| `Death Recipients` | Binder 回调   |
| `WebViews`         | WebView 数   |

### 参考资料
[Android 内存泄露详解](https://juejin.cn/post/6844903750180536334)

[内存优化：掌握 APP 运行时的内存模型](https://juejin.cn/post/7175438290324029498#heading-6)

## activity
