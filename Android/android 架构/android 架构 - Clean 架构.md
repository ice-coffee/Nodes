[toc]
### 参考
[Clean架构探讨](https://www.jianshu.com/p/66e749e19f0d)

[The Clean Architecture--一篇很不错的关于架构的文章](https://www.cnblogs.com/wanpengcoder/p/3479322.html)

[Architecting Android...The clean way?](https://fernandocejas.com/blog/engineering/2014-09-03-architecting-android-the-clean-way/)

在 `Uncle Bob` 的文章中总结了架构所应具有的特征：`框架独立`、`可测试性`、`UI独立`、`数据库独立`、`外部机制独立`。
基于以上特点 `Bob` 提出了 `Clean 架构` 思想。

### 架构的一般特征
在 `Uncle Bob` 的文章中总结了架构所应具有的特征：

- `框架独立`：架构不依赖于一些满载功能的软件库。这可以让你像使用工具一样使用这样的框架，而不是把系统塞到他们有限的约束之中。
- `可测试性`：业务规则可以在没有UI，数据库，Web服务器，或者其他外部元素的情况下完成测试。
- `UI独立`：在不改变系统其余部分的情况下完成UI的简易修改。如，Web UI可以在不改变业务规则的基础之上替换成控制台UI。
- `数据库独立`：业务规则不绑定的数据库中，这样你可以更换Oracle or SQL Server, for Mongo, BigTable, CouchDB，或者其他数据库。
- `外部机制独立`：事实上业务规则根本不知道外层的事情。

基于以上特点 `Bob` 提出了 `Clean 架构` 思想。

`Clean` 的核心思想在于面向对象编程，通过分层和依赖倒置原则对项目解耦。

### Clean 架构分层
![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/bob_clean.png)

`Clean` 架构大致可以将一个项目分为四层，如上图中洋葱图所示：

- `Entities`：实体
- `Use Cases`：用例
- `Interface Adapters`：接口适配器
- `Frameworks and Drivers`：框架和驱动

#### entity 实体
实体是可以在 `企业范围` 内多个不同应用间公用的核心对象。实体的具体形式是什么其实并不重要，它可以是包含有方法的对象或者一系列的数据结构和函数。但其内包含的一定是最通用和最高等级的规则。实体层外的任何变动都不能影响到实体。

#### Use Cases 用例
用例包含了 `应用范围` 内的特定业务规则。用例层整合并且实现了应用中需要的所有用例。这些用例协调着来往于实体之间的数据流，并且指引实体使用它们企业范围内的业务规则实现用例的目标。

同样用例层的代码也不应受到其外层变动的影响。比如数据库框架、UI框架或其他通用框架的替换都不应影响用例层代码。

只有在应用的业务逻辑发生变动时才能对用例层的相关代码进行调整。

#### Interface Adapters 接口适配器
本层是通过一系列适配器，将用例层和实体层方便使用的数据格式转换成最外层数据库和Web等框架方便使用的数据格式。

本层相当于分割内层与外层的分界线。本层以里为具体的业务逻辑以及里层所操作的数据结构，本层以外是项目所使用的库、框架等以及外层所操作的数据。这样就将业务逻辑与UI、技术的使用分割开来，再通过适配器的作用使内层和外层互相连接在一起。

接口适配器的存在让项目可以里层外层同时开发。

#### Frameworks and Drivers 框架和驱动
这一层是项目的最外层，一般包括项目中所使用到的框架和工具，如数据库、Web框架等。最外层所用到的所有框架和工具要做到可以用最小的代价随时替换。

#### 跨层调用

按照 `Clean` 架构思想内层是不应该持有外层对象的。外层访问内层可以直接通过内层对象进行访问，那内层如何访问外层呢？这可以通过 `依赖倒置原则` 来解决。依赖倒置简单理解就是依赖于抽象而不依赖于具体。可以将外层某个逻辑抽象出一个接口，内层通过接口调用外层接口的具体实现以达到访问外层的目的。

### Clean 架构在 Android 项目中的应用
介绍完 `Clean` 架构之后，我们来看如何将 `Clean` 架构的思想运用到 `Android` 项目中。
我主要是通过下面两个项目来学习 `Clean` 架构思想是如何应用于 `Android` 项目的。

- [Android-CleanArchitecture](https://github.com/android10/Android-CleanArchitecture)
- [architecture-samples](https://github.com/android/architecture-samples/tree/todo-mvp-clean)

上面两个项目虽然都是 `MVP - Clean` 两种架构结合的开发方式。但其侧重点不同：

- `Android-CleanArchitecture`：此项目是 `Clean` 架构思想在 `Android` 项目中的完整体现。非常适合 `Android` 开发者学习 `Clean` 架构思想。
- `architecture-samples`：此项目展示了如何使用不同架构开发 `Android` 项目。其 `todo-mvp-clean` 分支更多的是使用 `Clean` 架构的用例层思想来对 `P` 层复杂的业务逻辑进行简化。

本篇主要是为了学习 `Clean` 思想那我们主要来介绍 `Android-CleanArchitecture` 项目。但是强烈建议也学习 `architecture-samples` 项目。

#### Android 项目分层
`Android-CleanArchitecture` 项目作者将 `MVP` 架构按 `Clean` 思想绘制成洋葱图如下：

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/clean_architecture.png)

看到这张图你可能会有疑惑 `UI` 和 `Presenters` 层都理解，那 `M` 层去哪了。其实就是本项目中的 `UserModel`，是 `UI` 和 `Presenters` 层操作的数据模型。

#### 项目模块和层级间对应关系
作者将项目划分为了三个模块，如下图：

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/clean_architecture_layers.png)

三个模块各自功能以及分别对应于洋葱图中的哪层，如下：

`Presentation Layer`：表示层，本模块对应于 `UI`、`Presenters` 两层。负责处理与视图相关的所有逻辑。刚才也介绍过了 `M` 是`UI`、`Presenters` 两层处理的数据结构，所以其实 `MVP` 都存在于本模块的。但功能和以往有所不同，`V` 依然表示是视图，`P` 不再处理业务逻辑而是通过适配器连接表示层和用例层进行数据交换，`M` 就是单纯的数据结构，对应于项目中的 `UserModel`。

`Domain Layer`：用例层，本模块对应于 `Use Cases` 层。负责实现项目中所有的业务逻辑用例。并定义了 `UserRepository` 接口供用例调用。

`Data Layer`：数据层，本模块对应于 `Entities`、`UI` 两层。这里可能就有些难以理解了，`Entities` 层好理解，这里有 `UI` 层什么事，代码里没有 `UI`。我们再来回顾一下 `Clean` 架构思想，最外层除了 `UI` 还有什么，是不是还有数据库、工具库等这里的 `UI` 就代指它们。`Data Layer` 中使用 `Repository` 模式处理实体数据，包括线上数据、本地数据的处理，其中线上数据可能会用到 `Retrofit`、`Okhttp` 等具体实现，本地数据可能会用到 `SQLite`、`Room` 等，它们也都应该是在 `Clean` 架构的最外层，可以随时替换掉的。

这也可以理解为什么作者会把 `UserRepository` 接口定义在 `Domain Layer` 中了。

所以可以理解到 `Bob` 大叔的 `Clean` 架构思想是：

* 代码按重要性分层。
* 外层可以直接访问内层，而内层想要访问外层必须通过接口实现。

#### 数据传递
介绍完项目模块的划分以及如此划分的原因，我们最后再来看项目中数据是如何传递的。如下图：

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/clean_architecture_layers_details.png)

可以看到项目中的数据是通过观察者模式传递的。

结合项目本身可以看到作者为每个模块都定义了一个数据结构（`UserEntity、User、UserModel`）并有对应的转换器 `Mapper`。这样做的好处就是各个模块之间可以最大程度的解耦。但是对于一些非常简单的业务项目来说每个模块都定义一个数据模型实在是没有必要的，太繁琐了。事实上对于一些小项目来说项目中某业务中仅存一个数据结构已经是常态了。

个人理解如果将视图开发和业务开发分离的话仅需要 `XxxModel`、`XxxEntity` 两种数据结构就可以了即解耦又减少了些繁琐。在 [Clean架构探讨](https://www.jianshu.com/p/66e749e19f0d) 中作者给出了不同的意见。还是那句话 `只有最合适的架构没有最好的架构`。

感觉有用的话点赞哟 `^_^`。
