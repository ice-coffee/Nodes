[Triple Buffer](https://www.androidperformance.com/2019/12/15/Android-Systrace-Triple-Buffer)

[MainThread 和 RenderThread](https://www.androidperformance.com/2019/11/06/Android-Systrace-MainThread-And-RenderThread/)

[SurfaceFlinger](https://www.androidperformance.com/2020/02/14/Android-Systrace-SurfaceFlinger/)

[Android中的Surface和SurfaceView之我见](https://blog.csdn.net/tgww88/article/details/7973476)：`Surface` 定义。

[android图形框架之surfaceflinger分析\(一\)](https://www.huaweicloud.com/articles/cd17cf3ee32f423e022da79ef5a493a8.html)：配有详细类图、流程图。

[Android 5.0\(Lollipop\)中的SurfaceTexture，TextureView, SurfaceView和GLSurfaceView](https://blog.csdn.net/jinzhuojun/article/details/44062175)

[从零开始仿写一个抖音App——Android绘制机制以及Surface家族源码全解析](https://juejin.cn/post/6844903777334460430#heading-4)：详细分析了 `Android` 绘制机制和方法调用路径，以及 `Surface` 家族源码。

#### Surface
简单的说 `Surface` 对应了一块屏幕缓冲区，每个 `window` 对应一个 `Surface`，任何 `View` 都要画在 `Surface` 的 `Canvas` 上（后面有原因解释）。传统的 `view` 共享一块屏幕缓冲区，所有的绘制必须在 `UI` 线程中进行。

在 `SDK` 的文档中，对 `Surface` 的描述是这样的：`“Handle onto a raw buffer that is being managed by the screen compositor”`，翻译成中文就是 “由屏幕显示内容合成器`（screen compositor）`所管理的原始缓冲区的句柄”，这句话包括下面两个意思：

1、通过 `Surface`（因为 `Surface` 是句柄）就可以获得原生缓冲器以及其中的内容。就像在 `C++` 语言中，可以通过一个文件的句柄，就可以获得文件的内容一样。

2、原始缓冲区`（a raw buffer）`是用于保存当前窗口的像素数据的。

引伸地，可以认为 `Android` 中的 `Surface` 就是一个用来画图形`（graphics）`或图像`（image）`的地方。

根据 `Java` 方面的常规知识，我们知道通常画图是在一个 `Canvas` 对象上面进行的，由此，可以推知一个 `Surface` 对象中应该包含有一个 `Canvas`（画布）对象。因此，在前面提及的两个意思的基础上，可以再加上一条：

3、`Surface` 中有一个 `Canvas` 成员，专门用于画图的。

由以上的概括，我们总结如下：`Surface` 中的 `Canvas` 成员，是专门用于供程序员画图的场所，就像黑板一样；其中的原始缓冲区是用来保存数据的地方；`Surface` 本身的作用类似一个句柄，得到了这个句柄就可以得到其中的 `Canvas`、原始缓冲区以及其它方面的内容。

`Surface 是用来管理数据的。（句柄）`

#### SurfaceFlinger
`surfaceflinger` 作用是接受多个来源的图形显示数据，将它们合成，然后发送到显示设备。

#### SurfaceView
#### GLSurfaceView
#### SurfaceTexture
#### TextureView
