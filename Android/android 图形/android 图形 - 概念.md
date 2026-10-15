### OpenGL ES
`OpenGL` 全称：Open Graphics Library，开放图形库。用于渲染2D、3D矢量图形，具有跨语言、跨平台特性。
`OpenGL ES` 全称：OpenGL for Embedded Systems，缩写：GLES。GLES 是 OpenGL 的子集，通俗说就是是阉割版，面向于手机、PDA和游戏主机等嵌入式设备的。

### EGL
因为OpenGL是标准的，但设备是千奇百怪的，要对接就需要一个中间件做协调。也就是说一个设备要支持OpenGL，那么它需要开发一套相对应的EGL来对接。EGL主要负责初始化OpenGL的运行环境和设备间的交互，简单的说就是OpenGL负责绘图EGL负责和设备交互。

### Android GLES EGL 版本
在 Android 中，
`EGL14` 实现的是 EGL 1.4 规范。其相当于 Google 官方对 JAVA 的 EGL10(EGL 1.0 规范)的一次重新设计。通常，我们使用 EGL14 中的函数。
`EGL15` 是 EGL 1.5 规范，其在设计时，仅仅是做了规范的补充，并未重新设计。
通常 EGL14、EGL15 与 GLES20 等一起使用。

`GLES20` 是 OpenGL ES 2.0 规范的实现。
`OpenGL ES 1.x` 规范因为是早期版本，受限于机器性能和架构设计等，基本可以不再使用。
`OpenGL ES 2.x` 规范从 Android 2.3 版本后开始支持，目前市面上的所有手机都支持。相比于 1.0，OpenGL ES 2.0 引入了可编程图形管线，具体的渲染相关使用专门的着色语言来表达。
