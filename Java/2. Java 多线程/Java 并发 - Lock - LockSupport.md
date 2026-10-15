[toc]

`LockSupport` 类提供了用于线程阻塞和唤醒的静态方法。下面是`LockSupport` 类的一些重要函数说明：

#### park()

```java
public static void park()
```

* 阻塞当前线程，使其暂停执行。
* 如果调用 `unpark()` 方法或线程已经被中断，则 `park()` 方法会立即返回。
* `park()` 方法是可以响应中断的，但不会抛出 `InterruptedException` 异常。

#### park(Object blocker)

```java
public static void park(Object blocker)
```

* 阻塞当前线程，使其暂停执行，并关联一个阻塞对象（blocker）。
* 关联阻塞对象可以在调试和监控工具中用于识别线程被阻塞的原因。
* 其他与 `park()` 方法相同的行为规则适用。

#### parkNanos(long nanos)

```java
public static void parkNanos(long nanos)
```

* 阻塞当前线程，使其暂停执行，最长不超过指定的时间（以纳秒为单位）。
* 如果调用 `unpark()` 方法或线程已经被中断，则 `parkNanos()` 方法会提前返回。

#### parkNanos(Object blocker, long nanos)

```java
public static void parkNanos(Object blocker, long nanos)
```

* 阻塞当前线程，使其暂停执行，并关联一个阻塞对象（blocker），最长不超过指定的时间（以纳秒为单位）。
* 关联阻塞对象可以在调试和监控工具中用于识别线程被阻塞的原因。
* 其他与 `parkNanos()` 方法相同的行为规则适用。

#### parkUntil(long deadline)

```java
public static void parkUntil(long deadline)
```

* 阻塞当前线程，使其暂停执行，直到指定的截止时间（以毫秒为单位）。
* 如果调用 `unpark()` 方法或线程已经被中断，则 `parkUntil()` 方法会提前返回。

#### parkUntil(Object blocker, long deadline)

```java
public static void parkUntil(Object blocker, long deadline)
```

* 阻塞当前线程，使其暂停执行，并关联一个阻塞对象（blocker），直到指定的截止时间（以毫秒为单位）。
* 关联阻塞对象可以在调试和监控工

#### unpark(Thread thread)

```java
public static void unpark(Thread thread)
```

* 唤醒指定的线程，使其继续执行。
* 如果指定的线程先于调用 `unpark()` 方法之前调用了 `park()` 方法，那么它将会立即返回。
* `unpark()` 方法可以提供一个许可证给指定线程，如果线程之前没有获得许可证，它将能够继续执行。
