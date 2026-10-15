[toc]
### 参考
[java基础-反射技术浅析](https://mp.weixin.qq.com/s?__biz=MjM5NzE3NjM2OQ==&mid=2247491875&idx=1&sn=4ba14a980e74cc41e3b2265f4b2ddc75&source=41#wechat_redirect)

### 什么是反射
反射 (Reflection) 是 `Java` 的特征之一，它允许运行中的 `Java` 程序获取自身的信息，并且可以操作类或对象的内部属性。

通过反射，我们可以在 `运行时` 获得程序或程序集中每一个类型的成员和成员的信息。程序中一般的对象的类型都是在编译期就确定下来的，而 `Java` 反射机制可以动态地创建对象并调用其属性，这样的对象的类型在编译期是未知的。所以我们可以通过反射机制直接创建对象，即使这个对象的类型在编译期是未知的。

反射的核心是 `JVM` 在运行时才动态加载类或调用方法/访问属性，它不需要事先（写代码的时候或编译期）知道运行对象是谁。

`Java` 反射主要提供以下功能：

- 在运行时构造任意一个类的对象；
- 在运行时判断任意一个对象所属的类；
- 在运行时判断任意一个类所具有的成员变量和方法（通过反射甚至可以调用private方法）；
- 在运行时调用任意一个对象的方法；

> 重点：是运行时而不是编译时。

### 反射机制的相关类

| 类名 | 用途 |
| --- | --- |
| Class | 代表类的实体，在运行的Java应用程序中表示类和接口 |
| Field | 代表类的成员变量（成员变量也称为类的属性） |
| Constructor | 代表类的构造方法 |
| Method | 代表类的方法 |

> 注意：`Field`、`Method`、`Constructor` 中所有的方法有如下规律：
> - 添加 `Declared`：仅对目标 `Class` 自身生效，不包括父类及接口，但可处理包括 `public/private/protected/default` 任一修饰符；
> - 未添加 `Declared`：对目标 `Class` 自身及父类和接口生效，但仅可处理 `public` 修饰符；

> 注意：当访问 `private` 修饰的 `Field`、`Method`、`Constructor` 时必须设置 `isAccessible = true`。为 `true` 则指示反射的对象在使用时应该取消 `Java` 语言访问检查，值为 `false` 则指示反射的对象应该实施 `Java` 语言访问检查。

### Class
可通过如下方式获取 `Class` 实例

1. 通过 `.class`：

``` java
Class class1 = Person.class;
```

2. 通过创建实例对象来获取类对象：

``` java
Person person = new Person();
Class class2 = person.getClass();
```

3. 通过包名，调用 `class` 的 `forName` 方法：

``` java
Class class3 = Class.forName("day07.Person");
```
> `forName` 内部是通过加载器来获取 `Class` 对象的。

4. 通过类加载器

``` java
Class class4 = getClassLoader().loadClass("");
```

可用方法：

* `isPrimitive()`：判定指定的 `Class` 对象是否表示一个 `Java` 的基类型；
* `getSuperclass()`：获取该类的父类 `Class` 对象；
* `getGenericSuperclass()`：获得该类带有泛型的父类 `Class` 对象；

### 获取类对象实例
1. 创建不带参的实例对象：

```java
Class classObject = Class.forName("...");
Object instance = classObject.newInstance();
```

2. 通过构造函数创建带参实例对象：

```java
Class classObject = Class.forName("...");
Constructor constructor = classObject.getConstructor(String.class);
Object object = constructor.newInstance("xxx");
```

### Field

获取 `Field` 对象：
* `Class.getFields()`：~
* `Class.getField(String)`：~
* `Class.getDeclaredFields()`：~
* `Class.getDeclaredField(String)`：~

可用方法：

* `Field.get(Object)`：返回指定 `Object` 对象上这个字段的值。如果该值具有基本类型，则该值将自动包装在对象中。
* `Field.getName(Object)`：获取字段的名字。
* `Field.getInt(Object)`：返回指定 `Object` 对象上这个字段的 `Integer` 值。
* `Field.getFloat(Object)`：返回指定 `Object` 对象上这个字段的 `Float` 值。
...

* `Field.set(Object obj, Object value)`：设置指定 `obj` 对象上这个 `Object` 字段的值。
* `Field.setInt(Object obj, int i)`：设置指定 `obj` 对象上这个 `int` 字段的值。
* `Field.setFloat(Object obj, float f)`：设置指定 `obj` 对象上这个 `float` 字段的值。
...

`Kotlin` 中会通过如下方式设置：

```kotlin
Field[obj] = value
```

### Method

获取 `Method` 对象：

* `Class.getMethods()`：~
* `Class.getMethod(String, Class[])`：~
* `Class.getDeclaredMethods()`：~
* `Class.getDeclaredMethod(String, Class[])`：~

可用方法：

* `getName()：String`：获取方法名；
* `getModifiers()：int`：getModifiers；
* `getReturnType()：Object`：获得返回值类型；
* `getParameterTypes()：Class<?>[]`：获取参数类型；
* `getAnnotations()：Annotation`：获取注解；
* `invoke(Object obj, Object... args)：Object`：反射调用函数。`obj` 指操作的类对象，`args` 指函数传参；

当反射目标 Method 存在基本数据类型参数时，获取 Mehtod 对象时入参应输入如下：

| 基本数据类型 | Class 类型 |
| --- | --- |
| `int` | `int.class` |
| `long` | `long.class` |
| ... | ... |

### Constructor

* `Class.getConstructors()`：~
* `Class.getConstructor(Class[])`：~
* `Class.getDeclaredConstructors()`：~


可用方法：

* `getName()：String`：获取方法名；
* `getReturnType()：Object`：获得返回值类型；
* `getParameterTypes()：Class<?>[]`：获取参数类型；
* `newInstance(Object ... initargs)`：通过带参数的构造函数创建类的实例；

### 反射获取接口

```c++
public class TestClass {
    public static void main(String[] args) {
        try {
            Class mClass = Class.forName("com.mzp.sample.MyLibrary");
            Class mCallBack = Class.forName("com.mzp.sample.MyLibrary$MyCallBack");
            MyHandler myHandler = new MyHandler();
            Object object = Proxy.newProxyInstance(TestClass.class.getClassLoader(), new Class[]{mCallBack}, myHandler);
            Method method = mClass.getDeclaredMethod("mainMethod", mCallBack);
            method.invoke(mClass.newInstance(), object);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

```java
class MyHandler implements InvocationHandler {
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) {
        System.out.println("null");
        return null;
    }
}
```

```java
class MyLibrary {
    public interface MyCallBack {
        void doCallBack();
    }

    public void mainMethod(MyCallBack callBack) {
        System.out.println("call back main");
        callBack.doCallBack();
    }
}
```

### 反射机制的优缺点
优点：
1. 能够运行时动态获取类的实例，提高灵活性；

缺点：

1. 使用反射性能较低，需要解析字节码，将内存中的对象进行解析；
2. 相对不安全，破坏了封装性（因为通过反射可以获得私有方法和属性）；

### 反射性能低的原因
通过查看其它博主的文章，测试结果如下：

通过 `newInstance` 创建类对象的效率比 `new` 没有差很多，但是 `Class.forName()` 方法比较耗时，它实际上调用了一个本地方法，通过这个方法来要求JVM查找并加载指定的类。

通过 `invoke` 调用类方法，效率低。因为 `invoke` 方法会对参数做封装和解封操作：

需要检查方法可见
需要校验参数
反射方法难以内联
JIT 无法优化

### 反射性能优化
创建 `Class`、`Method` 等方法时进行缓存，以减少 `invoke()` 等方法的调用次数。

设置 `setAccessible(true)` 取消安全检查。

> 注意：`setAccessible` 是 `AccessibleObject` 的方法。仅可在 `Field`、`Method`、`Constructor` 内使用。
