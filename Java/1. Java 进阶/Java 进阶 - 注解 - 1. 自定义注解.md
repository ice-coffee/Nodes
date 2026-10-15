[toc]

## 常见注解
**`Java：`**

* `@Override`：

**`Android：`**

* `@IntDef`：可用于替代枚举类。
* `@LongDef`
* `@StringDef`
* `@IntRange`：声明标识元素取值范围。
* `@FloatRange`
* `@GuardedBy`：标识线程保护条件。Java并不会对这个注解进行特殊处理，它主要是为了辅助代码静态分析工具的工作。
* `@MainThread`：执行线程声明。
* `@UiThread`：
* `@AnyThread`：
* `@BinderThread`：

### @IntDef
由于枚举类在编译后会生成相应内部类，使用时会造成一定的内存消耗，所以 `Android` 提供了 `@IntDef` 注解用于替代枚举类，使用常量比类对象更能节省内存。

```java
public class Main {
    private final static int type1 = 1;
    private final static int type2 = 1<<1;
    private final static int type3 = 1<<2;

    @IntDef(flag = true, value = {type1,type2,type3})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Type {
    }
    
    public static void main(String[] args) {
        Main main = new Main();
        main.doSomthing(type1|type2);
    }

    private void doSomthing(@Type int value) {
    }
}
```

`flag`：设置为 `true` 时可以通过 `|，&` 等操作符同时传递多个常量。

## 自定义注解
**`自定义注解格式如下：`**

```java
public @interface Report {
    int type() default 0;
    String value() default "";
    Class<?> targetClass() default Object.class
}
```

注解的参数类似无参数方法，可以用 `default` 设定一个默认值（强烈推荐）。

**`元注解：`**

声明自定义注解时需要使用元注解进行标记，`Java` 提供的元注解如下：

* `Target`：声明注解可标记的范围，取值为 `ElementType` 枚举类。
* `Retention`：声明注解的生命周期，取值为 `RetentionPolicy` 枚举类。
* `Documented`：声明注解是否包含在用户文档中。
* `Inherited`：声明子类是否可继承作用在父类的注解。且仅针对 `@Target(ElementType.TYPE)` 类型的注解有效，并且仅针对类继承，对接口继承无效。

`ElementType` 取值如下：

| 值 | 说明 |
| --- | --- |
| ElementType.CONSTRUCTOR | 用于描述构造器 |
| ElementType.FIELD | 用于描述域 |
| ElementType.LOCAL_VARIABLE | 用于描述局部变量 |
| ElementType.METHOD | 用于描述方法 |
| ElementType.PACKAGE | 用于描述包 |
| ElementType.PARAMETER | 用于描述参数 |
| ElementType.TYPE | 用于描述类、接口(包括注解类型) 或enum声明 |

`RetentionPolicy` 取值如下：

| 值 | 生命周期 | 举例 |
| --- | --- | --- |
| `RetentionPolicy.SOURCE` | 注解只保留在源文件中，当源文件编译为`class`文件时注解被丢弃 | `APT` 在编译期动态生成代码 |
| `RetentionPolicy.CLASS` | 源文件编译为`class`文件后注解依然存在，当`JVM`加载`class`文件时注解被丢弃 | ***?*** |
| `RetentionPolicy.RUNTIME` | `JVM`加载`class`文件后注解依然存在 | `AOP 切面编程`、`EventBus` 在运行时通过反射获取注解标记的元素信息 |
