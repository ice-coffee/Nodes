[toc]

## 信号和槽
信号和槽（`Signal & Slot`）是 `Qt` 框架的核心机制，用于对象之间的通讯。

在 `C++` 中使用需要继承 `QObject` 类，`QObject` 是 `Qt` 框架中的一个基类，提供了信号和槽机制、对象树管理等功能。并且需要在类中声明 `Q_OBJECT` 宏，这个宏告诉 `Qt` 编译器生成与信号和槽相关的代码，使得这个类可以使用 `Qt` 的信号和槽机制。

**`1. 信号函数`**：

在类中声明的一种特殊的成员函数，表示某个事件已发生。信号使用 `signals` 关键字声明。

```c++
// MyClass.h
class MyClass : public QObject
{
    Q_OBJECT

signals:
    void mySignal();
};
```

**`2. 槽函数`**：

在类中声明的一种特殊的成员函数，用于响应信号。槽使用 `slots` 关键字声明。

```c++
// MyClass.h
class MyClass : public QObject
{
    Q_OBJECT

public slots:
    void mySlot();
};
```

```c++
// MyClass.cpp
MyClass::mySlot() {
    // ...
}
```

**`3. 连接信号和槽`**：

在某个地方（通常在对象的构造函数中）使用 `connect` 函数来建立信号和槽之间的连接。

```c++
MyClass* myObject = new MyClass();
QObject::connect(myObject, SIGNAL(mySignal()), myObject, SLOT(mySlot()));
```

**`4. 发送信号`**：

在类的某个函数中使用 `emit` 关键字来发射信号。

```c++
// MyClass.cpp
void MyClass::someFunction()
{
    // ...

    // 发射信号
    emit mySignal();
}
```

**`5. 断开连接`**：

如果需要，可以使用 `disconnect` 函数来断开信号和槽的连接。

```c++
QObject::disconnect(myObject, SIGNAL(mySignal()), myObject, SLOT(mySlot()));
```

### c++ 和 qml 通信
`c++` 和 `qml` 通信：

1. 在 `c++` 类中定义继承于 `QObject` 的类，声明 `Q_OBJECT` 宏，并定义信号函数。
```c++
// MyClass.h
class MyClass : public QObject
{
    Q_OBJECT

signals:
    void mySignal();
};
```
2. 通过 `qmlRegisterType` 注册类对象到 `qml`。
```c++
// main.cpp: 注册类对象到 `qml`
#include <QQmlApplicationEngine>
#include <QtQml>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    qmlRegisterType<MyClass>("MyClass", 1, 0, "MyClass");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
```

3. 在 `qml` 中通过 `Connections` 元素连接 `c++` 类对象，并监听信号。
```qml
// main.qml: 监听信号
import QtQuick 2.15
import QtQuick.Controls 2.15
import MyClass 1.0

ApplicationWindow {
    visible: true
    width: 400
    height: 200
    title: "Signal Receiver"

    Rectangle {
        width: parent.width
        height: parent.height

        // 创建 MyObject 对象
        MyClass {
            id: myCppObject
        }

        // 和 c++ 信号建立连接
        Connections {
            target: myCppObject
            onMySignal: {
                console.log("Signal received in QML:", value);
            }
        }

        // 通过 c++ 对象发送信号
        Button {
            text: "Emit Signal"
            anchors.centerIn: parent
            onClicked: {
                // Emit signal from C++
                myCppObject.mySignal(42);
            }
        }
    }
}
```
4. 在 `c++` 中通过 `emit` 关键字发送信号。
```c++
// MyClass.cpp
void MyClass::someFunction()
{
    // ...

    // 发射信号
    emit mySignal();
}
```

在 `qml` 中声明信号监听格式：`on<Signal>`，`<Signal>` 是信号函数名首字母大写。

### 示例

#### qml 内置信号
```qml
import QtQuick 2.9
import QtQuick.Window 2.2
 
Window {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
 
    MouseArea {
        anchors.fill: parent
        //按键点击的信号处理程序
        onClicked: {
            console.log("on clicked");
        }
    }    
}
```

#### qml 属性变更信号

```qml
Rectangle {
    id: rec
    color: "#00B000"
    width: 80; height: 80
    rotation: 90

    /*
        color: 是Rectangle的属性
        onColorChanged: {} Rectangle的属性变化信号处理器
    */
    onColorChanged: {
        console.log("Rectangle颜色改变了。")
    }
}
```

## Q_INVOKABLE
`Q_INVOKABLE` 是 `Qt` 中的一个宏，用于标记一个成员函数，使得该函数能够在 `Qt` 的元对象系统中被调用。这个宏的作用是将被标记的函数注册到元对象中，从而可以在运行时通过字符串进行调用。



## 附
[QML中的信号槽](https://blog.csdn.net/gongjianbo1992/article/details/87937804)
