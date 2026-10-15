[toc]

### ListView

#### 示例
```qml
// StudentListDelegate.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    width: ListView.view.width
    height: 80
    color: "lightblue"

    Column {
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: "Name: " + model.name
            font.bold: true
        }

        Text {
            text: "Age: " + model.age
        }

        Text {
            text: "Gender: " + model.gender
        }
    }
}
```

```qml
// StudentList.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

ListView {
    width: parent.width
    height: parent.height

    // 数据模型
    model: ListModel {
        ListElement { name: "Alice"; age: 25; gender: "Female" }
        ListElement { name: "Bob"; age: 22; gender: "Male" }
        ListElement { name: "Charlie"; age: 24; gender: "Male" }
        ListElement { name: "David"; age: 23; gender: "Male" }
        // 添加更多学生...
    }

    // 列表项的委托
    delegate: StudentListDelegate {}
}
```

#### 属性

* `model`：列表项数据。
* `delegate`：列表项布局。

### 自定义 ListModel
首先，创建一个继承自 `QAbstractListModel` 的 `C++` 类。这个类需要实现一些必要的方法，例如 `rowCount` 和 `data`，以提供数据给 `QML`。

```c++
// CustomListModel.h
#ifndef CUSTOMLISTMODEL_H
#define CUSTOMLISTMODEL_H

#include <QAbstractListModel>
#include <QList>

class CustomListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit CustomListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
    QList<QString> m_data;
};

#endif // CUSTOMLISTMODEL_H
```
```c++
// CustomListModel.cpp
#include "CustomListModel.h"

CustomListModel::CustomListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_data << "Alice" << "Bob" << "Charlie" << "David";
}

int CustomListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_data.size();
}

QVariant CustomListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    if (role == Qt::DisplayRole)
        return m_data.at(index.row());

    return QVariant();
}
```

注册：


在 `qml` 中使用：

```qml
// main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import "." // Import the current directory (where qml.qrc is located)

ApplicationWindow {
    visible: true
    width: 400
    height: 600
    title: "Custom List Model Example"

    ListView {
        width: parent.width
        height: parent.height

        model: CustomListModel {}

        delegate: Item {
            width: ListView.view.width
            height: 50
            Rectangle {
                width: parent.width
                height: 50
                color: "lightblue"
                Text {
                    anchors.centerIn: parent
                    text: modelData
                }
            }
        }
    }
}
```
