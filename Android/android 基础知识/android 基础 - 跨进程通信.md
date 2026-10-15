[toc]

## 总结
跨进程通信（`IPC`）。

![90b963c9055f6225e26b3edef2f8e865.png](<../../attachment/android_IPC.png>)

## Binder
### AIDL
#### 使用
1、创建 `.aidl` 文件；
2、创建 `Service` 并实现 `aidl` 接口，将 `aidl` 实例通过 `onBind()` 返回给客户端；
3、将相关 `aidl` 文件拷贝到客户端相同目录下；
4、在客户端绑定服务，在 `onServiceConnected()` 中使用 `IBinder` 获取 `aidl` 接口实例；
5、在客户端通过接口实例调用在接口中声明的方法传递参数，服务端即可收到；
6、服务端在 `aidl` 的实现中处理客户端发来的消息。

#### 支持数据类型
`AIDL` 支持下列数据类型：
* `Java` 编程语言中的所有原语类型（如 `int、long、char、boolean` 等）
* `String`
* `CharSequence`
* `List`：`List` 中的所有元素必须是以上列表中支持的数据类型，或者您所声明的由 `AIDL` 生成的其他接口或 `Parcelable` 类型。您可选择将 `List` 用作“泛型”类（例如，`List<String>`）。尽管生成的方法旨在使用 `List` 接口，但另一方实际接收的具体类始终是 `ArrayList`。
* `Map`：`Map` 中的所有元素必须是以上列表中支持的数据类型，或者您所声明的由 `AIDL` 生成的其他接口或 `Parcelable` 类型。不支持泛型 `Map`（如 `Map<String,Integer>` 形式的 `Map`）。尽管生成的方法旨在使用 `Map` 接口，但另一方实际接收的具体类始终是 `HashMap`。

#### 双向传递
##### 传递复杂对象
`aidl` 接口内定义方法时可以带有零个或多个参数，返回值或void。如果参数是非基本数据类型时需要实现 `Parcelable` 并标记数据的走向，标记如下：
* `in`：数据只能由客户端流向服务端，服务端会收到客户端传递对象的完整数据，但服务端对数据对象的修改不会同步到客户端；
* `out`：数据只能由服务端流向客户端，服务端收到客户端传递的对象是未赋值的对象，服务端对对象的修改会同步到客户端；
* `inout`：数据可在服务端与客户端之间双向流通，服务端会收到客户端传递的完整对象数据，并且对对象修改时会同步到客户端。

##### 传递自定义类型
1、在 `java` 目录下创建自定义类型实现 `Parcelable` 接口，并实现 `readFromParcel(Parcel source)` 方法；
2、在 `aidl` 目录内同 `java` 相同的目录下创建自定义类型的 `aidl` 文件，使用 `parcelable` 标识，例如：`parcelable Message；`；
3、在 `aidl` 接口文件中使用自定义类型时，需要手动导入类地址；
4、将新增自定义类型和它的 `aidl` 文件拷贝到客户端相同目录下。

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/service_aidl_directory.png)

**`IAidlInterface.aidl：`**
```java
package com.example.myapplication;
import com.example.myapplication.bean.User;


// Declare any non-default types here with import statements

interface IAidlInterface {
    /**
     * Demonstrates some basic types that you can use as parameters
     * and return values in AIDL.
     */
    void basicTypes(in User data);
}
```

**`User.aidl：`**
```java
package com.example.myapplication;

// Declare any non-default types here with import statements

parcelable User;
```

**`User.java：`**
```java
package com.example.myapplication.bean;

import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

public class User implements Parcelable {
    private String name;
    private int age;

    public User() {
    }

    protected User(Parcel in) {
        name = in.readString();
        age = in.readInt();
    }

    public static final Creator<User> CREATOR = new Creator<User>() {
        @Override
        public User createFromParcel(Parcel in) {
            return new User(in);
        }

        @Override
        public User[] newArray(int size) {
            return new User[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(@NonNull Parcel dest, int flags) {
        dest.writeString(name);
        dest.writeInt(age);
    }

    public void readFromParcel(Parcel source) {
        name = source.readString();
        age = source.readInt();
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }
}
```

#### 异步调用
`aidl` 接口定义的方法默认是同步调用，可以通过 `oneway` 指定接口是否是异步调用：
```java
interface IAidlInterface {
    oneway void post(in Bundle data);//异步
    void get(out Bundle data);// 同步
}
```

#### 遇到的问题
1、高版本 Android studio 无法右键自动创建 aidl 文件：
在 `build.gradle` 中设置：
```gradle
buileFeatures { aidl = true }
```
2、`targetSdkVersion >= 30` 时无法跨进程访问：
Google在 **`API30`** 以后加强了包可见性限制，如果需要跨进程访问某个应用，需要在`AndroidManifest` 中声明要访问的应用。

```xml
<manifest>
    ...
    <queries>
        <package android:name="com.baidu.mapautotest" />
    </queries>
    ...
</manifest>
```

### Messenger
`Messenger` 比 `AIDL` 使用更加简单，它会将接收的消息加入同一线程队列进行处理，而 AIDL处理消息的线程会根据消息来源产生差异（本地进程消息，远程进程消息）。

**`Messenger`**：一个Messenger对应一个 Handler用于发送、处理消息；
**`Message`**：Message是消息主体，replyTo参数表示发送消息的 Messenger；

#### 使用
1、创建 `Service`，并实现一个 `Handler`，用于接收来自客户端的消息；
2、使用 `Handler` 创建 `Messenger` 对象；
3、使用 `Messenger` 创建 `IBinder`，通过 `onBind()` 将其返回给客户端；
4、在客户端绑定服务，在 `onServiceConnected()` 中使用 `IBinder` 将 `Messenger` 实例化，然后就可以通过它将 `Message` 对象发送给服务端；
5、服务端在其 `Handler` 中接收客户端发送的 `Message` 消息。

#### 双向消息传递
1、当客户端收到 `onServiceConnected()` 回调时，可以通过 `Messenger.send(Message)` 方法的向服务发送一个 `Message`，并在其 `replyTo` 参数中加入客户端的 `Messenger`。

**`服务端：`**
```java
public class MessengerService extends Service {

    private static final int REGISTER_CLIENT_MESSAGE = 101;
    private static final int UNREGISTER_CLIENT_MESSAGE = 102;
    private static final int SERVICE_BACK_MESSAGE = 103;
    private static final int SEND_GET_MESSAGE = 1;
    private static final int SEND_POST_MESSAGE = 2;

    /**
     * 服务端
     */
    private Messenger mServer;
    /**
     * 客户端列表
     */
    private final List<Messenger> mClients = new ArrayList<>();

    /**
     * Handler of incoming messages from clients.
     */
    static class IncomingHandler extends Handler {
        private final WeakReference<List<Messenger>> clients;

        IncomingHandler(List<Messenger> clients) {
            super();
            this.clients = new WeakReference<>(clients);
        }

        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case REGISTER_CLIENT_MESSAGE:
                    clients.get().add(msg.replyTo);
                    break;
                case UNREGISTER_CLIENT_MESSAGE:
                    clients.get().remove(msg.replyTo);
                    break;
                case SEND_GET_MESSAGE:
                    List<Messenger> clientList = clients.get();
                    for (Messenger client : clientList) {
                        try {
                            client.send(Message.obtain(null, SERVICE_BACK_MESSAGE, 110, 0));
                        } catch (RemoteException e) {
                            e.printStackTrace();
                        }
                    }
                    break;
                case SEND_POST_MESSAGE:
                    break;
                default:
                    super.handleMessage(msg);
            }
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        Toast.makeText(getApplicationContext(), "binding", Toast.LENGTH_SHORT).show();
        mServer = new Messenger(new IncomingHandler(mClients));
        return mServer.getBinder();
    }
}
```

**`AndroidManifest.xml：`**
```xml
<service
    android:name=".MessengerService"
    android:enabled="true"
    android:exported="true">
    <intent-filter>
        <action android:name="任意字符串" />
    </intent-filter>
</service>
```

**`客户端：`**
```kotlin
class MessengerClient : IClient {
    companion object {
        const val TAG = "messenger_client"
        const val SERVICE_ACTION = "com.baidu.mapautosdk.messenger"
        const val SERVICE_PACKAGE = "com.baidu.mapautotest"
        const val REGISTER_CLIENT_MESSAGE = 0
        const val UNREGISTER_CLIENT_MESSAGE = 1
        const val SEND_GET_MESSAGE = 2
        const val SEND_POST_MESSAGE = 3
        const val SERVICE_BACK_MESSAGE = 4

        class IncomingHandler : Handler() {
            override fun handleMessage(msg: Message) {
                super.handleMessage(msg)
                if (msg.what == SERVICE_BACK_MESSAGE) {
                    Log.e(TAG, "${msg.arg1}")
                }
            }
        }
    }

    private var mService: Messenger? = null
    private val mMessenger = Messenger(IncomingHandler())
    private var isBindSuccess = false
    override fun init(context: Context) {
        if (isBindSuccess) {
            return
        }
        val intent = Intent()
        intent.action = SERVICE_ACTION
        intent.`package` = SERVICE_PACKAGE
        context.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE).also {
            isBindSuccess = it
        }
    }

    override fun destory(context: Context) {
        if (isBindSuccess) {
            context.unbindService(serviceConnection)
            isBindSuccess = false
        }
    }

    override fun get(what: Int, bundle: Bundle) {
        if (null == mService) {
            return
        }
        val msg = Message.obtain(null, SEND_GET_MESSAGE, 0, 0, bundle)
        mService!!.send(msg)
    }

    override fun post(what: Int, bundle: Bundle) {
        if (null == mService) {
            return
        }
        val msg = Message.obtain(null, SEND_POST_MESSAGE, 0, 0, bundle)
        mService!!.send(msg)
    }

    private val serviceConnection: ServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName, service: IBinder) {
            mService = Messenger(service)
            isBindSuccess = true

            val msg = Message.obtain(null, REGISTER_CLIENT_MESSAGE, 0, 0)
            msg.replyTo = mMessenger
            mService!!.send(msg)
        }

        override fun onServiceDisconnected(name: ComponentName) {
            val msg = Message.obtain(null, UNREGISTER_CLIENT_MESSAGE, 0, 0)
            msg.replyTo = mMessenger
            mService!!.send(msg)

            mService = null
            isBindSuccess = false
        }
    }
}
```

### AIDL vs Messenger
虽然 `Messenger` 实现更为简单，但是 `Messenger` 只能在单个线程中处理消息而 `AIDL` 在内部维护了线程池传递消息。

### ContentProvider
[android 基础 - ContentProvider](https://app.yinxiang.com/shard/s58/nl/10744683/854bf59e-1133-423f-ad8c-bf250c7c23ef/)

### Binder 跨进程通信存在问题
1、受限于 `Binder` 传输数据的限制，通过当前方式无法传输超过1M的数据。
解决方案：使用 `ParcelFileDescriptor` 传输。

## 内存共享

## socket
