### WindowManager.LayoutParams

[WindowManager.LayoutParams和Token以及其他窗口Dialog，Toast](https://www.jianshu.com/p/bac61386d9bf)


| 渲染场景 | 纯软件绘制 | 硬件加速 | 加速效果分析 |
|---|---|---|---|---| 
| 页面初始化 | 绘制所有View | 创建所有DisplayList | GPU分担了复杂计算任务 | 
| 在一个复杂页面调用背景透明TextView的setText()，且调用后其尺寸位置不变 | 重绘脏区所有View | TextView及每一级父View重建DisplayList | 重叠的兄弟节点不需CPU重绘，GPU会自行处理 | 
| TextView逐帧播放Alpha / Translation / Scale动画 | 每帧都要重绘脏区所有View | 除第一帧同场景2，之后每帧只更新TextView对应RenderNode的属性 | 刷新一帧性能极大提高，动画流畅度提高 |
| 修改TextView透明度 | 重绘脏区所有View | 直接调用RenderNode.setAlpha()更新 | 加速前需全页面遍历，并重绘很多View；加速后只触发DecorView.updateDisplayListIfDirty，不再往下遍历，CPU执行时间可忽略不计 |

#### 窗口类型
`WindowManager.LayoutParams` 里定义了三种窗口类型：

* **应用窗口**：取值范围在 `1~99`，它往往对应着一个Activity；
* **子窗口**：取值范围在 `1000~1999`，子窗口是指该窗口必须要有一个父窗口，例如：Dialog。
* **系统窗口**：取值范围在 `2000~2999`，它往往需要声明权限才能创建，例如Toast、状态栏、悬浮窗都是系统窗口。

> 值越大代表窗口所在的层级越高。
