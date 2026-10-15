
[toc]

### 参考
[深入理解Java泛型](https://juejin.cn/post/6844903650788114439)：泛型擦除所产生的问题及解决方案。

[Java泛型中的类型擦除详解](https://zhuanlan.zhihu.com/p/346486993)：泛型擦除详解。

[聊聊Java泛型擦除那些事](https://zhuanlan.zhihu.com/p/64583822)：泛型擦除证明。

### 什么是泛型
泛型是 `Java 1.5` 的新特性，它的本质是参数化类型。也就是说由类型参数（类型形参）替代具体的类型，然后在使用时传入具体的类型（类型实参）。

泛型可以被用于类、接口和方法中，分别被称为泛型类、泛型接口和泛型方法。

> 注意：泛型的参数类型不支持基本数据类型。

泛型的作用：

* 类型安全，提供编译期的类型检查；
* 前后兼容，能和 `Java 5` 之前的版本开发二进制类库进行兼容；
* 代码重复利用；
* 性能较高，用GJ(泛型JAVA)编写的代码可以为java编译器和虚拟机带来更多的类型信息，这些信息对java程序做进一步优化提供条件；

**`示例`**：
```java
// 泛型类
public class GenericClass<T> {
    private T value;

    public GenericClass(T value) {
        this.value = value;
    }

    public T getValue() {
        return value;
    }

    // 泛型方法
    public <U> void printGeneric(U u) {
        System.out.println(u);
    }
}

public class Main {
    public static void main(String[] args) {
        // 使用泛型类
        GenericClass<Integer> integerBox = new GenericClass<>(123);
        System.out.println("Value: " + integerBox.getValue());

        // 使用泛型方法
        integerBox.printGeneric("This is a generic method");
        integerBox.printGeneric(456);
    }
}
```

#### 泛型通配符

* `<?>`：无限定通配符
* `<? extends T>`：上限的通配符
* `<? super T>`：下限的通配符

### 类型擦除
**类型擦除**：是指编译器在 `编译时` 擦除了所有泛型信息，所以在 `运行时` 不存在泛型信息。例如 `List<String>` 在运行时仅用一个 `List<Object>` 来表示。这样做的目的，是确保能和 `Java 5` 之前的版本开发二进制类库进行兼容。你无法在运行时访问到类型参数，因为编译器已经把泛型类型转换成了原始类型。

#### 类型检查
既然 `Java` 在编译时会将类型擦除，那为什么不可以添加数字类型到 `List<String>` 呢，这是因为在编译前会进行类型检查，以防止数据类型出错。

```java
List<String> list1 = new ArrayList();  
list1.add("1"); //编译通过  
list1.add(1); //编译错误 
String str1 = list1.get(0); //返回类型就是String 
```

而且类型检查是针对于引用的：

```java
List list2 = new ArrayList<String>();  
list2.add("1"); //编译通过  
list2.add(1); //编译通过
Object object = list2.get(0); //返回类型就是Object 

new ArrayList<String>().add("11"); //编译通过  
new ArrayList<String>().add(22); //编译错误
```

#### 类型判断
泛型类型不能显式地运用在运行时类型检查的操作当中，例如：转型、`instanceof` 和 `new`。

```java
List<String> list = new ArrayList<>();
// 编译不通过
if (list instanceof List<String>)
// 编译通过
if (list instanceof List)
```

```java
// 编译不通过
T var = new T();
```

```java
// 编译不通过
T[] array = (T) new Object[SIZE];
```

#### 类型擦除与多态的冲突

泛型类：
```java
class Pair<T> {  

    private T value;  

    public T getValue() {  
        return value;  
    }  

    public void setValue(T value) {  
        this.value = value;  
    }  
}
```

子类继承：

```java
class DateInter extends Pair<Date> {  

    @Override  
    public void setValue(Date value) {  
        super.setValue(value);  
    }  

    @Override  
    public Date getValue() {  
        return super.getValue();  
    }  
}
```

父类编译后：

```java
class Pair {  
    private Object value;  

    public Object getValue() {  
        return value;  
    }  

    public void setValue(Object  value) {  
        this.value = value;  
    }  
}  
```

可以看到父类编译后的方法和子类方法看起来更像是重载而不是重写。但我们在使用中可以感受到子类方法是重写了父类的方法的。

这是因为在处理泛型类的继承时编译器会在子类中生成桥方法，桥方法才是父类方法的实际重写方法。当调用子类方法时实际调用的是桥方法，桥方法内部就只是去调用子类重写的方法。

用 `javap -c className` 的方式反编译下 `DateInter` 子类的字节码，如下：

```class
class com.tao.test.DateInter extends com.tao.test.Pair<java.util.Date> {  
  com.tao.test.DateInter();  
    Code:  
       0: aload_0  
       1: invokespecial #8                  // Method com/tao/test/Pair."<init>":()V  
       4: return  

  public void setValue(java.util.Date);  //我们重写的setValue方法  
    Code:  
       0: aload_0  
       1: aload_1  
       2: invokespecial #16                 // Method com/tao/test/Pair.setValue:(Ljava/lang/Object;)V  
       5: return  

  public java.util.Date getValue();    //我们重写的getValue方法  
    Code:  
       0: aload_0  
       1: invokespecial #23                 // Method com/tao/test/Pair.getValue:()Ljava/lang/Object;  
       4: checkcast     #26                 // class java/util/Date  
       7: areturn  

  public java.lang.Object getValue();     //编译时由编译器生成的巧方法  
    Code:  
       0: aload_0  
       1: invokevirtual #28                 // Method getValue:()Ljava/util/Date 去调用我们重写的getValue方法;  
       4: areturn  

  public void setValue(java.lang.Object);   //编译时由编译器生成的巧方法  
    Code:  
       0: aload_0  
       1: aload_1  
       2: checkcast     #26                 // class java/util/Date  
       5: invokevirtual #30                 // Method setValue:(Ljava/util/Date; 去调用我们重写的setValue方法)V  
       8: return  
}
```

### 协变、逆变
网上找的一段协变、逆变比较正式的定义：
> 逆变与协变用来描述类型转换后的继承关系，其定义：如果 `A、B` 表示类型，`f(⋅)` 表示类型转换（例如：`f(A)` 表示 `A` -> `List<A>`），`≦` 表示继承关系（比如，`A≦B` 表示 `A` 是由 `B` 派生出来的子类）：
> 当 `A ≦ B` 时,如果有 `f(A) ≦ f(B)` ,那么 `f` 是协变的；
> 当 `A ≦ B` 时,如果有 `f(B) ≦ f(A)` ,那么 `f` 是逆变的；
> 如果上面两种关系都不成立，即 `f(A)` 与 `f(B)` 相互之间没有继承关系，则叫做不变的。

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
