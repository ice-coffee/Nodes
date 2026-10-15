### MVC 、 MVP 、 MVVM

[原文地址1](http://www.cnblogs.com/JustRun1983/p/3679827.html)
[原文地址2](http://www.cnblogs.com/JustRun1983/p/3727560.html)

#### 1. MVC
> - MVC全名是Model View Controller，是模型(model)－视图(view)－控制器(controller)的缩写
> - MVC的本质 ： Model在MVC架构中起的作用非常重要，它应该是业务逻辑真正的实现层。所以Model的实际上是Business Model（业务模型）。而Controller仅仅起一个“桥梁”作用，它负责把View的请求转发给Model，再负责把Model处理结束的消息通知View。Controller是用来解耦View和Model的，具体一点说，就是为了让UI与逻辑分离（界面与代码分离）。

Model
> 用于封装与应用程序的业务逻辑相关的数据以及对数据的处理方法。
> 模型中数据的变化一般会通过一种刷新机制被公布。为了实现这种机制，那些用于监视此模型的视图必须事先在此模型上注册，从而，视图可以了解在数据模型上发生的改变。

View
> 视图层负责数据的展示。
> 在视图中一般没有程序上的逻辑。为了实现视图上的刷新功能，视图需要访问它监视的数据模型（Model），因此应该事先在被它监视的数据那里订阅Model的事件。

Controller
> 控制器是M和V之间的连接器，用于控制应用程序的流程。它处理事件并作出响应。“事件”包括用户的行为和数据模型上的改变。

1. 主动MVC时序图
![Alt text](<../../attachment/:9G57N8TS4K8-7UTM@FIL.png>)

2. 被动MVC时序图
![Alt text](<../../attachment/:CH@5DZFGO7J63-L11R-4S.png>)

3. 被动MVC与主动MVC的区别
- 模型对视图和控制器一无所知，它仅仅是被它们使用 
- 控制器使用视图，并通知它更新数据显示 
- 视图仅仅是在控制器通知它去模型取数据的时候它才这么做(视图并不会订阅或监视模型的更新) 

4. MVC的使用误区
- 把Model理解成实体类（Entity），在MVC中Model应该包含2部分功能，一部分是处理业务逻辑，一部分是提供View显示的数据
- 把业务逻辑全部放在Controller端
#### 2. MVP
> - MVP中的M代表Model, V是View, P是Presenter
> - 在MVP里，Presenter完全把Model和View进行了分离，主要的程序逻辑在Presenter里实现。而且，Presenter与具体的 View是没有直接关联的，而是通过定义好的接口进行交互，从而使得在变更View时候可以保持Presenter的不变，即重用！ 不仅如此，我们还可以编写测试用的View，模拟用户的各种操作，从而实现对Presenter的测试 —— 而不需要使用自动化的测试工具。 我们甚至可以在Model和View都没有完成时候，就可以通过编写Mock Object（即实现了Model和View的接口，但没有具体的内容的）来测试Presenter的逻辑。

1. 代码结构图
![Alt text](<../../attachment/:H4%608ZVL2T4_X8456QCUTB.png>)

2. 时序图
![Alt text](<../../attachment/:WSPU_463ERW--RJVHN5E6R.png>)

#### 3.MVVM

#### MVP与MVC的区别
在MVC里，View是可以直接访问Model的！从而，View里会包含Model信息，不可避免的还要包括一些业务逻辑。在MVC模型里，更关注的Model的不变，而同时有多个对Model的不同显示，及View。

所以，在MVC模型里，Model不依赖于View，但是View是依赖于Model的。不仅如此，因为有一些业务逻辑在View里实现了，导致要更改View也是比较困难的，至少那些业务逻辑是无法重用的。

在MVP里，Presenter完全把Model和View进行了分离，主要的程序逻辑在 Presenter里实现。而且，Presenter与具体的View是没有直接关联的，而是通过定义好的接口进行交互，从而使得在变更View时候可以 保持Presenter的不变，即重用！

不仅如此，我们还可以编写测试用的View，模拟用户的各种操作，从而实现对Presenter的测试--而不需要使用自动化的测试工具。

我们甚至可以在Model和View都没有完成时候，就可以通过编写Mock Object（即实现了Model和View的接口，但没有具体的内容的）来测试Presenter的逻辑。
