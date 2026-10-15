[toc]

### 协变、逆变

网上找的一段协变、逆变比较正式的定义：
> 逆变与协变用来描述类型转换后的继承关系，其定义：如果 `A、B` 表示类型，`f(⋅)` 表示类型转换（例如：`f(A)` 表示 `A` -> `List<A>`），`≦` 表示继承关系（比如，`A≦B` 表示 `A` 是由 `B` 派生出来的子类）：
> 当 `A ≦ B` 时,如果有 `f(A) ≦ f(B)` ,那么 `f` 是协变的；
> 当 `A ≦ B` 时,如果有 `f(B) ≦ f(A)` ,那么 `f` 是逆变的；
> 如果上面两种关系都不成立，即 `(A)` 与 `f(B)` 相互之间没有继承关系，则叫做不变的。

`java` 中可以通过如下泛型通配符以支持协变和逆变：

- `? extends` 来使泛型支持协变。修饰的泛型集合只能读取不能修改，这里的修改仅指对泛型集合添加元素，如果是 `remove(int index)` 以及 `clear` 当然是可以的。
- `? super` 来使泛型支持逆变。修饰的泛型集合只能修改不能读取，这里说的不能读取是指不能按照泛型类型读取，你如果按照 `Object` 读出来再强转当然也是可以的。

以动物举例，看代码。

``` java
abstract class Animal {
    void eat() {
        System.out.println("我是" + myName() + ", 我最喜欢吃" + myFavoriteFood());
    }

    abstract String myName();

    abstract String myFavoriteFood();
}

class Fish extends Animal {

    @Override
    String myName() {
        return "鱼";
    }

    @Override
    String myFavoriteFood() {
        return "虾米";
    }
}

class Cat extends Animal {

    @Override
    String myName() {
        return "猫";
    }

    @Override
    String myFavoriteFood() {
        return "小鱼干";
    }
}

public static void extendsFun() {
    List<Fish> fishList = new ArrayList<>();
    fishList.add(new Fish());
    List<Cat> catList = new ArrayList<>();
    catList.add(new Cat());
    List<? extends Animal> animals1 = fishList;
    List<? extends Animal> animals2 = catList;

    animals2.add(new Fish()); // 报错
    Animal animal1 = animals1.get(0);
    Animal animal2 = animals2.get(0);
    animal1.eat();
    animal2.eat();
}

//输出结果：
我是鱼, 我最喜欢吃虾米
我是猫, 我最喜欢吃小鱼干
```

协变就好比有多个集合，每个集合存储的是某中特定动物（`extends Animal`），但是不告诉你那个集合里存储的是鱼，哪个是猫。所以你虽然可以从任意一个集合中读取一个动物信息，没有问题，但是你没办法将一条鱼的信息存储到鱼的集合里，因为仅从变量 `animals1、animals2` 的类型声明上来看你不知道哪个集合里存储的是鱼，哪个集合里是猫。
假如报错的代码不报错了，那不就说明把一条鱼塞进了一堆猫里，这属于给猫加菜啊，所以肯定是不行的。`? extends` 类型通配符所表达的协变就是这个意思。

那逆变是什么意思呢？还是以上面的动物举例：

``` java
public static void superFun() {
    List<Fish> fishList = new ArrayList<>();
    fishList.add(new Fish());
    List<Animal> animalList = new ArrayList<>();
    animalList.add(new Cat());
    animalList.add(new Fish());
    List<? super Fish> fish1 = fishList;
    List<? super Fish> fish2 = animalList;

    fish1.add(new Fish());
    Fish fish = fish2.get(0); //报错
}
```

从变量 `fish1、fish2` 的类型声明上只能知道里面存储的都是鱼的父类，如果这里也不报错的话可就从 `fish2` 的集合里拿出一只猫赋值给一条鱼了，这属于谋杀亲鱼。所以肯定也是不行。`? super` 类型通配符所表达的逆变就是这个意思。

`kotlin` 中对于协变和逆变也提供了两个修饰符：

- `out`：声明协变；
- `in`：声明逆变。

它们有两种使用方式：

- 第一种：和 `java` 一样在使用处声明；
- 第二种：在类或接口的定义处声明。

当和 `java` 一样在使用处声明时，将上面 `java` 示例转换为 `kotlin`：

``` kotlin
fun extendsFun() {
    val fishList: MutableList<Fish> = ArrayList()
    fishList.add(Fish())
    val catList: MutableList<Cat> = ArrayList()
    catList.add(Cat())
    val animals1: MutableList<out Animal> = fishList
    val animals2: MutableList<out Animal> = catList
    animals2.add(Fish()) // 报错
    val animal1 = animals1[0]
    val animal2 = animals2[0]
    animal1.eat()
    animal2.eat()
}

fun superFun() {
    val fishList: MutableList<Fish> = ArrayList()
    fishList.add(Fish())
    val animalList: MutableList<Animal> = ArrayList()
    animalList.add(Cat())
    animalList.add(Fish())
    val fish1: MutableList<in Fish> = fishList
    val fish2: MutableList<in Fish> = animalList
    fish1.add(Fish())
    val fish: Fish = fish2[0] //报错
}
```

可以看到在 `kotlin` 代码中除了将 `? extends` 替换为了 `out`，将 `? super` 替换为了 `in`，其他地方并没有发生变化，而产生的结果是一样的。那在类或接口的定义处声明 `in、out` 的作用是什么呢。

假设有一个泛型接口 `Source<T>`，该接口中不存在任何以 `T` 作为参数的方法，只是方法返回 `T` 类型值：

``` java
// Java
interface Source<T> {
  T nextT();
}
```

那么，在 `Source <Object>` 类型的变量中存储 `Source <String>` 实例的引用是极为安全的——没有消费者-方法可以调用。但是 `Java` 并不知道这一点，并且仍然禁止这样操作：

``` java
// Java
void demo(Source<String> strs) {
  Source<Object> objects = strs; // ！！！在 Java 中不允许
  // ……
}
```

为了修正这一点，我们必须声明对象的类型为 `Source<? extends Object>`，但这样的方式很复杂。而在 `kotlin` 中有一种简单的方式向编译器解释这种情况。我们可以标注 `Source` 的类型参数 `T` 来确保它仅从 `Source<T>` 成员中返回（生产），并从不被消费。为此我们使用 `out` 修饰符修饰泛型 `T`：

``` kotlin
interface Source<out T> {
    fun nextT(): T
}

fun demo(strs: Source<String>) {
    val objects: Source<Any> = strs // 这个没问题，因为 T 是一个 out-参数
    // ……
}
```

还记得开篇协变的定义吗？
> 当 `A ≦ B` 时,如果有 `f(A) ≦ f(B)` ,那么 `f` 是协变的；
> 当 `A ≦ B` 时,如果有 `f(B) ≦ f(A)` ,那么 `f` 是逆变的；

也就是说：
> 当一个类 `C` 的类型参数 `T` 被声明为 `out` 时，那么就意味着类 `C` 在参数 `T` 上是协变的；参数 `T` 只能出现在类 `C` 的输出位置，不能出现在类 `C` 的输入位置。

同样的，对于 `in` 修饰符来说
> 当一个类 `C` 的类型参数 `T` 被声明为 `in` 时，那么就意味着类 `C` 在参数 `T` 上是逆变的；参数 `T` 只能出现在类 `C` 的输如位置，不能出现在类 `C` 的输出位置。

``` kotlin
interface Comparable<in T> {
    operator fun compareTo(other: T): Int
}

fun demo(x: Comparable<Number>) {
    x.compareTo(1.0) // 1.0 拥有类型 Double，它是 Number 的子类型
    // 因此，我们可以将 x 赋给类型为 Comparable <Double> 的变量
    val y: Comparable<Double> = x // OK！
}
```

总结如下表：

![image](https://mzp-blog.oss-cn-beijing.aliyuncs.com/img/kotlin_in_or_out.jpg)

大家有其他看法的可以留言一起交流学习！

### 使用处型变：类型投影

`使用处型变` 描述了 `类型投影` 的使用场景，及在使用时通过型变注解约束行为。比如 `out` 声明代表仅可以使用 `get` 一类的方法。

```kotlin
fun copy(from: Array<out Any>, to: Array<Any>){
    for (i in from.indices){
        to[i] = from[i]
    }
}

val ints: Array<Int> = arrayOf(1, 2, 3)
val any = Array<Any>(3) { "" } 
copy(ints, any)
```
