[toc]

### 参考
[拥抱 Java 8 并行流吧，速度飞起！ ](https://www.cnblogs.com/javastack/p/13370682.html)

### 流

![](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/java_stream_api.png)

#### 概述
`Stream API` 是 `Java 8` 引入的一个强大的工具，用于处理集合数据时提供流式处理操作。它支持声明性的数据处理，可以大大简化代码，提升代码的可读性和可维护性。

#### 核心概念
1. `Stream`：表示数据流，可以是有序或无序的。流不会存储数据，只是按需计算数据。
2. `中间操作`：对流进行转换，返回新的流。中间操作是惰性求值的，只有在终端操作执行时才会真正处理数据。常见的中间操作包括：`map()、 filter()、distinct()、sorted()、limit()、skip()`。
3. `终端操作`：对流进行最终处理，触发流的执行。终端操作包括：`forEach()、collect()、reduce()、count()、anyMatch()、allMatch()、noneMatch()、findFirst()、findAny()`。

#### 方法说明

创建流：

* 集合父类 `Collection` 提供创建流的方法 `stream`、`parallelStream`：

```java
List<String> list = Arrays.asList("a", "b", "c");
Stream<String> stream = list.stream();
```

* 从数组创建流：

```java
String[] array = {"a", "b", "c"};
Stream<String> stream = Arrays.stream(array);
```

* 使用Stream类中的静态方法：

```java
// public static<T> Stream<T> of(T t)
Stream<String> stream = Stream.of("a", "b", "c");
```

* 创建无限流：

```java
Stream<Integer> stream = Stream.iterate(0, n -> n + 1);
Stream<Double> stream = Stream.generate(Math::random);
```

中间操作：这些操作返回一个新的流（Stream），是惰性求值的，只有在执行终端操作时才会处理数据。

* `filter(Predicate<? super T> predicate)`：筛选出满足给定条件的元素。
* `map(Function<? super T, ? extends R> mapper)`：对流中的每个元素应用函数，并将结果收集到一个新的流中。
* `flatMap(Function<? super T, ? extends Stream<? extends R>> mapper)`：将流中的每个元素替换为一个新的流，然后将所有流连接成一个流。
* `distinct()`：返回一个由流中不同元素组成的流（去重）。
* `sorted()`：返回一个按自然顺序排序的流。
* `sorted(Comparator<? super T> comparator)`：返回一个按给定比较器排序的流。
* `peek(Consumer<? super T> action)`：生成一个包含原流所有元素的新流，同时对每个元素执行提供的动作。
* `limit(long maxSize)`：返回一个不超过给定长度的流，也用于对流进行截断。
* `skip(long n)`：返回一个扔掉了前n个元素的流。

终端操作：终端操作会触发流的处理，并返回一个非流的结果，如数值、对象、集合等。

* `forEach(Consumer<? super T> action)`：对流的每个元素执行给定的操作。
* `forEachOrdered(Consumer<? super T> action)`：按流的顺序对每个元素执行给定的操作。
* `toArray()`：将流中的元素存储到一个数组中。
* `reduce(BinaryOperator<T> accumulator)`：通过反复结合流的元素来归约流。
* `reduce(T identity, BinaryOperator<T> accumulator)`：将流的元素归约为一个值，并提供一个起始值。
* `collect(Collector<? super T, A, R> collector)`：将流的元素收集到一个结果容器中，如列表、集合、映射等。
* `min(Comparator<? super T> comparator)`：返回流的最小元素。
* `max(Comparator<? super T> comparator)`：返回流的最大元素。
* `count()`：返回流中的元素个数。
* `anyMatch(Predicate<? super T> predicate)`：检查是否至少有一个元素匹配给定的谓词。
* `allMatch(Predicate<? super T> predicate)`：检查是否所有元素都匹配给定的谓词。
* `noneMatch(Predicate<? super T> predicate)`：检查是否没有元素匹配给定的谓词。
* `findFirst()`：返回流中的第一个元素。
* `findAny()`：返回流中的任意一个元素（通常用于并行流）。

串行流转换并行流：

`S parallel()`：将串行流转换为并行流；
`boolean isParallel()`：判断是否为并行流；

### 并行流
并行流就是将一个流的内容分成多个数据块，并用不同的线程分别处理每个不同数据块的流。

并行流内部使用了默认的 `ForkJoinPool` 线程池。

在并行流的使用上有下面几点需要注意：

1. 尽量使用 `LongStream、IntStream、DoubleStream` 等原始数据流代替 `Stream` 来处理数字，以避免频繁拆装箱带来的额外开销。
2. 要考虑流的操作流水线的总计算成本，假设 N 是要操作的任务总数，Q 是每次操作的时间。N * Q 就是操作的总时间，Q 值越大就意味着使用并行流带来收益的可能性越大。

例如：前端传来几种类型的资源，需要存储到数据库。每种资源对应不同的表。我们可以视作类型数为 N，存储数据库的网络耗时 + 插入操作耗时为 Q。一般情况下网络耗时都是比较大的。因此该操作就比较适合并行处理。当然当类型数目大于核心数时，该操作的性能提升就会打一定的折扣了。更好的优化方法在日后的博客会为大家奉上。

3. 对于较少的数据量，不建议使用并行流。
4. 容易拆分成块的流数据，建议使用并行流。

以下是一些常见的集合框架对应流的可拆分性能表：

| 源 | 可拆分性 |
| --- | --- |
| ArrayList | 极佳 |
| LinkedList | 差 |
| IntStream.range | 极佳 |
| Stream.iterate | 差 |
| HashSet | 好 |
| TreeSet | 好 |
