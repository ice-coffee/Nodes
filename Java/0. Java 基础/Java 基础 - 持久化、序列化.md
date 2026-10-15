[toc]

### 参考
[Serializable 都这么牛逼了，Parcelable，我还要你何用？](https://juejin.cn/post/6844903518826921991)

### 持久化
**`说明：`**
持久化是指将数据保存在存储设备中，以保证数据不会因为设备重启而丢失。

**`常见持久化方式：`**

* **文件存储**
* **数据库**
* **云存储**

### 序列化
**`说明：`**
序列化是指将数据结构或对象转化为字节流或其他格式的过程。以便持久化存储或进行传输（网络传输、内存传输）。更通俗的将序列化是将数据转换为一种便于存储和传输的形式，常见的序列化格式包括 **`JSON`**、**`XML`**、**`二进制`** 等。

**`使用场景：`**：

* 跨进程传递对象；
* 网络传输；
* 类似游戏建档保存游戏进度；

#### 常见序列化工具

**`二进制`**：

* `Serializable`
* `Parcelable`
* `kryo`
* `Protobuf`

**`JSON`**：

* `fastjson`
* `gson`

#### 序列化漏洞
[深入剖析 Java 反序列化漏洞](https://cloud.tencent.com/developer/article/2185239)

### Parcelable vs Serializable
两者最大的区别在于 **`存储媒介`** 的不同，`Serializable` 使用 I/O 读写存储在硬盘上，而 `Parcelable` 是直接 在内存中读写。很明显，内存的读写速度通常大于 `IO` 读写，所以在 `Android` 中传递数据优先选择 `Parcelable`。
`Serializable` 会使用反射，序列化和反序列化过程需要大量 `I/O` 操作， `Parcelable` 自已实现封装和解封（marshalled &unmarshalled）操作不需要用反射，数据也存放在 `Native` 内存中，效率要快很多。

**使用选择**：
* `Parcelable` 的性能比 `Serializable` 好，在内存开销方面较小，所以在内存间数据传输时推荐使用 `Parcelable`，如 `activity` 间传输数据。
* `Serializable` 可将数据持久化方便保存，所以在需要保存或网络传输数据时选择 `Serializable`，而因为 `android` 不同版本 `Parcelable` 可能不同，所以不推荐使用 `Parcelable` 进行数据持久化。

示例：
```java
public class User implements Serializable {
    /**
     * Serialization version.
     */
    private static final long serialVersionUID = 1L;
    
    public String name;
    
    public User(String name) {
        this.name = name;
    }
}
```

```java
// 序列化文件地址
private String savePath = "sdcard/user.ser";
// 可序列化类
private User mUser = new User("大宝");

/**
 * 序列化
 */
public void saveParcel() {
    FileOutputStream fos = null;
    ObjectOutputStream oos = null;

    try {
        fos = new FileOutputStream(savePath);
        oos = new ObjectOutputStream(fos);
        oos.writeObject(mUser);
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (null != oos) {
                oos.flush();
                oos.close();
            }
            if (null != fos) {
                fos.flush();
                fos.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

/**
 * 反序列化
 */
public void loadParcel() {
    FileInputStream fis = null;
    ObjectInputStream ois = null;

    try {
        fis = new FileInputStream(savePath);
        ois = new ObjectInputStream(fis);
        User obj = (User) ois.readObject();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (null != ois) {
                ois.close();
            }
            if (null != fis) {
                fis.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

> **`文件后缀说明`**：`Java` 提供的默认序列化工具，常用文件后缀 `.ser`、`.object`。当然也可以使用其他文件后缀名，只要你在序列化和反序列化时使用正确的方法，并且注意数据格式或编码方式的选择，以避免数据损坏或无法读取的问题。

#### serialVersionID
`serialVersionID` 在 `Java` 序列化机制中起到版本控制的作用，确保序列化和反序列化过程中的类版本一致性。每个可序列化类都有一个对应的 `serialVersionID`，如果不显示指定，那在序列化过程过会根据类名、属性名等生成ID为其赋值。

这就导致，如果类发生变化，比如增加字段，会导致 `serialVersionID` 的值发生变化，进而导致反序列化失败。

推荐在可序列化类中显示定义 `serialVersionID`，仅在不兼容旧版本类时修改它的值，并做好旧数据处理。

#### transient 关键字
`transient` 关键字，用来表示一个成员变量不是该对象序列化的一部分。当一个对象被序列化的时候，`transient` 型变量的值不包括在序列化的结果中，而非 `transient` 型的变量是被包括进去的。

> **`注意`**：`static` 修饰的静态变量天然就是不可序列化的。

### ProtoBuf
[ProtoBuf 在Android的使用与原理解析](https://blog.csdn.net/lixiong0713/article/details/107934792)

`ProtoBuf` 支持多种编程语言（Java、C++、Python、Go 等），适用于跨平台数据交换。


### kryo
[Kryo序列化](https://juejin.cn/post/6993647089431347237)

`Kryo` 是一个高性能的 Java 序列化库，适用于需要快速序列化和反序列化的应用场景。主要用于 `Java`（`kotlin` 等） 生态系统，跨语言支持较弱。
