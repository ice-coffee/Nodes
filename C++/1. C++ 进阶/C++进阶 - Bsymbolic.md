---
id: 20260730-001
tags: [C++, 链接器, 动态库, 符号解析, ELF]
aliases: [-Bsymbolic, Bsymbolic, -Wl,-Bsymbolic, DF_SYMBOLIC, -Bsymbolic-functions]
created: 2026-07-30
updated: 2026-07-30
source: ""
status: draft
---

# -Bsymbolic

## 一句话定义
`-Bsymbolic` 是链接动态库（`.so`）时使用的链接器选项，让库内部对全局符号的引用**在链接期就绑定到本库自己的定义**，不再走运行时全局符号表解析，从而避免被外部同名符号劫持。

## 核心理解
- **是什么**：ld 的一个 shared library 链接选项，语义是“库内引用优先用库内定义”。通过编译器传递：`-Wl,-Bsymbolic`。
- **为什么需要它**：ELF 默认允许**符号插入（symbol interposition）**——库里调用 `foo()` 时，实际调用的是全局符号表里**第一个**被加载的 `foo`，可能来自主程序或其他库。
- **它解决了什么问题**：多份同名依赖共存时的符号劫持（典型场景：进程里存在两个不同版本的 protobuf / OpenSSL / zlib，B 库想用自己那份，结果绑到了 A 库的实现，ABI 不匹配直接崩）。副作用收益是减少动态重定位、加快加载。

## 详细解释

### 默认的符号解析行为
动态库中一个非 hidden 的全局函数调用，编译出来是走 PLT/GOT 的：地址在运行时由 `ld.so` 按**全局作用域顺序**（主程序 → `LD_PRELOAD` → 依赖库按加载顺序 → `RTLD_GLOBAL` 的 `dlopen` 库）查找填入。参见 [[C++进阶 - 全局符号表]]。

也就是说：即使 `libB.so` 内部定义了 `foo`，只要 `libA.so` 先把 `foo` 放进全局表，`libB.so` 内部的 `foo()` 调用也会打到 `libA::foo`。

### 加上 -Bsymbolic 后发生了什么
链接 `libB.so` 时，ld 发现被引用的 `foo` 在本库内已有定义，就**直接把引用绑到本库定义**：
- 函数调用不再需要 `R_X86_64_JUMP_SLOT`（PLT 条目），变为库内相对跳转；
- 数据引用的 `GLOB_DAT` 重定位也大幅减少，改为相对重定位；
- 同时在 `.dynamic` 中设置 `DF_SYMBOLIC` 标志（旧格式为 `DT_SYMBOLIC`）。

关键点：**真正起作用的是链接期的绑定动作**，`DF_SYMBOLIC` 标志本身在现代 glibc 上更多是遗留/信息性的。

### 一个常被忽略的事实：它不隐藏符号
`-Bsymbolic` 只改变“库内部怎么找符号”，**不改变符号是否导出**。`libB.so` 的 `foo` 依然出现在 `nm -D` 的导出列表里，外部依然能链接到它，也依然会进全局符号表影响别人。要真正隐藏，得用 visibility 或 version script。

### 选项家族
- `-Bsymbolic`：所有全局符号（函数 + 数据，含弱符号）都内部绑定。
- `-Bsymbolic-functions`：只对**函数**内部绑定，数据符号仍可被插入。折中方案，风险小很多。
- `-Bsymbolic-non-weak` / `-Bsymbolic-non-weak-functions`（binutils 2.37+）：跳过弱符号，保留弱符号的可插入性。
- `-Bno-symbolic`：取消前面的 `-Bsymbolic`（命令行后出现者生效）。
- `--dynamic-list=file`：在 `-Bsymbolic` 基础上开白名单，列出的符号仍保持可插入。

## 常用用法

### 基础用法：编译动态库时开启
```bash
gcc -shared -fPIC -Wl,-Bsymbolic -o libfoo.so a.o b.o
```

### CMake 中使用
```cmake
target_link_options(foo PRIVATE "-Wl,-Bsymbolic")
# 或旧写法
set_target_properties(foo PROPERTIES LINK_FLAGS "-Wl,-Bsymbolic")
```
注意加在**动态库 target** 上，加在可执行文件上无意义。

### 更安全的折中：只绑定函数
```bash
gcc -shared -fPIC -Wl,-Bsymbolic-functions -o libfoo.so *.o
```
适用于“怕函数被劫持，但库里有需要全局唯一的数据符号”的情况。

### 配合白名单，留出可插入的符号
```bash
# exports.list：这些符号仍允许被外部覆盖
{ my_plugin_hook; my_allocator; };
```
```bash
gcc -shared -Wl,-Bsymbolic -Wl,--dynamic-list=exports.list -o libfoo.so *.o
```

### 验证是否生效
```bash
readelf -d libfoo.so | grep -i symbolic     # 看 FLAGS 是否含 SYMBOLIC
readelf -r libfoo.so | grep JUMP_SLOT       # PLT 重定位应显著减少
LD_DEBUG=bindings ./app 2>&1 | grep foo     # 运行时确认 foo 绑到了哪个库
```

## 关键要点
- 它管的是“**库内引用往哪绑**”，不管“符号是否导出”。
- 绑定发生在**链接期**，不是运行时行为开关。
- 它会一并干掉合法的符号插入能力（`LD_PRELOAD` hook、`malloc` 替换、弱符号覆盖）。
- 数据符号被内部绑定后，可能出现主程序和库各持一份**不同的对象**，状态不一致。
- 隔离符号的正确首选是 `-fvisibility=hidden` + version script；`-Bsymbolic` 是补充手段，不是替代品。

## 例子与边界

### 正例：避免第三方库版本劫持
```
app ──> libA.so (静态打包了 protobuf 3.6，且导出了 protobuf 符号)
    ──> libB.so (静态打包了 protobuf 3.21)
```
`libB.so` 内部的 protobuf 调用会绑到 `libA` 的 3.6 实现 → 结构体布局不同 → 崩溃或数据错乱。
给 `libB.so` 加 `-Wl,-Bsymbolic`（或更彻底：`-Wl,--exclude-libs,ALL` + hidden visibility）后，`libB` 内部调用固定使用自带的 3.21。

### 反例 1：破坏 operator new/delete 替换
```cpp
// libfoo.so 内部大量 new/delete
// 主程序里全局替换了 operator new 做内存统计
void* operator new(std::size_t n) { /* 统计 */ }
```
`libfoo.so` 若用 `-Bsymbolic` 链接且自身带有 `operator new` 定义（如静态链接了某个分配器），库内 `new` 不再走主程序的替换版本 → 统计漏掉，甚至出现“A 处 new、B 处 delete”跨堆释放。

### 反例 2：单例/全局变量变成两份
```cpp
// 主程序和 libfoo.so 都包含 Registry::instance() 的定义（同一份头文件 + 静态库）
```
`-Bsymbolic` 下库内引用绑本库那份，主程序用自己那份 → 两个 `Registry`，注册在库里的东西主程序查不到。这类 bug 表现极隐蔽。

### 边界情况
- 只对**动态库**有意义；链接可执行文件时该选项无效果。
- 弱符号：`-Bsymbolic` 会把弱符号也绑死，破坏“弱符号供外部覆盖”的设计意图，这正是 `-Bsymbolic-non-weak` 存在的原因。
- C++ 跨库异常与 RTTI：若同一类型的 `typeinfo` 在两边各有一份且被内部绑定，某些实现下 `dynamic_cast` / `catch` 匹配可能失败（glibc 上通常按名字字符串比较，风险较低；非 glibc 平台需实测）。
- Windows DLL 无此问题——DLL 本身就是链接期绑定语义，不存在默认插入。

## 关系与连接
- **前置知识**：ELF、动态链接、PLT/GOT、重定位、全局符号表、符号可见性、弱符号
- **关联概念**：`-fvisibility=hidden`、`--version-script`、`--exclude-libs`、`--dynamic-list`、`RTLD_DEEPBIND`、`LD_PRELOAD`、`DF_SYMBOLIC`
- **容易混淆**：`-Bsymbolic`（隐藏不了符号，只改内部绑定）vs `-fvisibility=hidden`（真正不导出）
- **上位/下位知识**：上位是“动态库符号隔离与冲突治理”；下位是各具体选项与验证手段

### 与相近方案对比
- `-fvisibility=hidden` + `__attribute__((visibility("default")))`：**首选**。编译期决定导出面，既不被劫持也不劫持别人；需要能改源码/构建。
- `--version-script`：链接期精确控制导出符号列表，效果同上且能做符号版本化；不改源码即可用。
- `--exclude-libs,ALL`：阻止静态库（`.a`）符号从 `.so` 导出，专治“静态打包第三方库导致符号泄漏”。
- `-Bsymbolic`：只解决“我不被别人劫持”，不解决“我劫持别人”。
- `RTLD_DEEPBIND`（`dlopen` 标志）：运行时、更激进——本库及其依赖的整个查找作用域都优先自身。副作用比 `-Bsymbolic` 更大，且是调用方决定而非库作者决定。

推荐组合：`-fvisibility=hidden` + `--version-script` 为主，`-Bsymbolic-functions` 作为补强。

## 常见误区
- 以为加了 `-Bsymbolic` 符号就不导出了 —— 不会，仍在 `nm -D` 里。
- 以为它是运行时开关 —— 绑定在链接期已经完成，改环境变量无法回退。
- 以为“隔离越彻底越好”就无脑全开 —— 会静默破坏内存分配器替换、插桩 hook、单例唯一性这类依赖插入语义的机制。
- 以为它能解决“同一符号两份实现”的根因 —— 根因是同一依赖被打包了多份，`-Bsymbolic` 只是让崩溃点挪开。

## 应用场景
- **适合用在**：静态打包了第三方库的插件 / SDK `.so`；同一进程内必须共存多版本依赖；对加载时间敏感、想减少动态重定位的大型库。
- **不适合用在**：需要被 `LD_PRELOAD` 插桩或替换 `malloc`/`operator new` 的库；与主程序共享单例或全局状态的库；本可以直接用 hidden visibility 干净解决的项目。

## 参考来源
- GNU ld 手册：`-Bsymbolic`、`-Bsymbolic-functions`、`--dynamic-list`
- ELF 规范：`DT_FLAGS` / `DF_SYMBOLIC`
- [[C++进阶 - 全局符号表]]

## 我的理解
可以把默认动态链接想成“打电话先查公司总台通讯录”——总台上谁先登记 `foo` 就转给谁。`-Bsymbolic` 相当于告诉本部门：“内部事务直接拨内线，别问总台。” 好处是不会被别的部门冒名接走；代价是总台想统一转接（插桩、替换分配器）也转不动了，而且部门内线名单和总台名单可能各记一份，导致“同一个人两个号码”。

判断口诀：**怕被劫持用 `-Bsymbolic`，怕劫持别人用 hidden/version-script**；两个担心都有，就两个都上。
