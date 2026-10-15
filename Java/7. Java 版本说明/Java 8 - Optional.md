[Optional用法与争议点](https://juejin.cn/post/7162882431932956680#heading-5)

[Java8的Optional是不是鸡肋？](https://blog.csdn.net/g6U8W7p06dCO99fQ3/article/details/118282653)

### 概述
`Optional` 用于简化空指针判断。

简化示例：

```java
Order order = getOrderById(orderId);
String userCode = "";
if(order != null){
    if(order.getUser() != null){
        if(order.getUser().getUserCode() != null){
            userCode = order.getUser().getUserCode().toUpperCase();
        }
    }
}
```

```java
Order order = getOrderById(orderId);
String userCode = Optional.ofNullable(order)
    .map(Order::getUser)
    .map(User::getUserCode)
    .map(String::toUpperCase)
    .orElse("")
```

### 创建Optional
`ofNullable()`：创建一个Optional，传入的值可以是null或不是null。
`of()`：得到一个Optional，明确知道传入的值不是null时用这个，如果传null会报错NullPointerExcepiton。
其实值不为null一般是没必要使用Optional的，这个应该是用于特殊场景，比如方法返回值必须是一个Optional。
`empty()`：得到一个空的Optional，一般也用于返回值必须是Optional的场景。

### 判空
`ifPresent()`：判断是否有值，注意，这个方法虽然看起来挺好用的，但它不太应该是使用Optional时第一个使用的方法。

### 取值
`get()`：获取Optional的值，当没有值时会抛出一个NoSuchElementException异常。

```java
public T get() {
    if (value == null) {
        throw new NoSuchElementException("No value present");
    }
    return value;
}
```

同样的，它也不太应该是使用Optional时的第一个使用的方法，因为抛NoSuchElementException与抛NullPointerException并没有太大区别。

`orElse()`：没有值时会返回指定的值。

```java
String name = nameOpt.orElse("");
```

`orElseGet()`：同上，不过参数变成了一个提供默认值的lambda函数，这用在取指定值需要一定代价的场景，如下：

```java
BigDecimal amount = amountOpt.orElseGet(() -&gt; calcDefaultAmount());
```

`orElseThrow()`：没有值时抛出一个指定的异常，如下：

```java
Optional&lt;User&gt; userOpt = getUser(userId);
User user = userOpt.orElseThrow(() -&gt; new NullPointerException("userId:" + userId));
```

可能会有人疑问，你还是抛出了一个NPE异常，和不使用Optional有啥区别？区别是这个NPE异常会告诉你哪个userId查不到数据，方便定位问题，而jvm抛出的NPE是没有这个信息的。
