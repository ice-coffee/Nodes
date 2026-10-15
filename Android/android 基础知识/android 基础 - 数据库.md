[toc]

### `SQLite` 数据库存储
`SQLite` 是一款轻量级的关系型数据库，它的运算速度非常快，占用资源很少，通常只需要几百 `K` 的内存就足够了，因而特别适合在移动设备上使用适用于那些数据量大结构复杂的数据。

#### 创建数据库
创建类继承 `SQLiteOpenHelper`，重写 `onCreate()` 和 `onUpgrade()`，然后分别在这两个方法中去实现创建、升级数据库的逻辑。

``` java
class NewTest extends SQLiteOpenHelper {

    public NewTest(@Nullable Context context, @Nullable String name, @Nullable SQLiteDatabase.CursorFactory factory, int version) {
        super(context, name, factory, version);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }
}
```

构建出 `SQLiteOpenHelper` 的实例之后，再调用它的 `getReadableDatabase()` 或 `getWritableDatabase()` 方法就能够创建数据库了。
构造函数参数介绍：

* `context`：上下文对象；
* `name`：数据库名；
* `factory`：允许我们在查询数据的时候返回一个自定义的 `Cursor`，传入 `null` 会返回默认对象；
* `version`：当前数据库的版本号,可用于对数据库进行升级操作；
* `errorHandler`：数据库损毁时调用；

> 注意：
> 1. `version` 必须大于 `0`；
> 2. `version` 只能升不能降；

#### 创建表
声明表创建语句：

``` java
public static final String CREATE_BOOK = 
        "create table Book "
        + "("
        + "id integer primary key autoincrement, "
        + "author text, "
        + "price real, "
        + "pages integer, "
        + "name text, "
        + "category_id integer"
        + ")";
```

重写 `onCreate()`：

``` java
@Override
public void onCreate(SQLiteDatabase db) {
    db.execSQL(CREATE_BOOK);
}
```

#### 数据库升级
在创建 `SQLiteOpenHelper` 实例时传递的版本号参数修改比之前大，那么 `onUpgrade()` 方法就会被调用.

创建新的数据库表，首先声明数据库升级语句：

``` java
public static final String CREATE_CATEGORY = 
        "create table Category "
        + "("
        + "id integer primary key autoincrement, "
        + "category_name text, "
        + "category_code integer"
        + ")";
```

重写 `onUpgrade`，并更新 `onCreate`：

```
@Override
public void onCreate(SQLiteDatabase db) {
    db.execSQL(CREATE_BOOK);
    db.execSQL(CREATE_CATEGORY);
}

@Override
public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
    switch (oldVersion) {
        case 1:
            db.execSQL(CREATE_CATEGORY);
        default:
    }
}
```

#### 数据库操作
有两种方式可以对数据库进行增删改查操作：

1. 使用 `SQLiteDatabase` 内置的方法进行操作：
    - insert：增
    - update：改
    - delete：删
    - query： 查

2. 使用 `SQL` 语句来操作数据库：
    - db.execSQL(String sql)：可用于增\删\改操作
    - db.rawQuery(String sql)：可用于查询操作

#### 使用事务
1. 首先调用 `SQLiteDatabase` 的 `beginTransaction()` 方法来开启一个事务，
2. 然后在一个异常捕获的代码块中去执行具体的数据库操作，
3. 当所有的操作都完成之后，调用 `setTransactionSuccessful()` 表示事务已经执行成功了，
4. 最后在 `finally` 代码块中调用 `endTransaction()` 来结束事务。

``` java
db.beginTransaction();
try {
    ...
    db.setTransactionSuccessful();
} finally {
    db.endTransaction();
}
```

``` java
public class MyDatabaseHelper extends SQLiteOpenHelper {

    /**
     * 初始创建语句中没有 `category_id`
     */
    public static final String CREATE_BOOK =
            "create table Book "
            + "("
            + "id integer primary key autoincrement, "
            + "author text, "
            + "price real, "
            + "pages integer, "
            + "name text, "
            + "category_id integer"
            + ")";

    public static final String CREATE_CATEGORY =
            "create table Category "
            + "("
            + "id integer primary key autoincrement, "
            + "category_name text, "
            + "category_code integer"
            + ")";

    public MyDatabaseHelper(Context context, String name, SQLiteDatabase.CursorFactory factory, int version) {
        super(context, name, factory, version);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(CREATE_BOOK);
        db.execSQL(CREATE_CATEGORY);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        switch (oldVersion) {
            case 1:
                db.execSQL(CREATE_CATEGORY);
            case 2:
                db.execSQL("alter table Book add column category_id integer");
            default:
        }
    }
}
```

#### `getReadableDatabase() vs getWritableDatabase()`

`getReadableDatabase()` 和 `getWritableDatabase()` 的区别。这两个方法都可以创建或打开一个现有的数据库（如果数据库已存在则直接打开，否则创建一个新的数据库,并返回一个可对数据库进行读写操作的对象.不同的是,当数据库不可写入的时候（如磁盘已满） `getReadableDatabase()` 方法返回的对象将以只读的方式去打开数据库，而 `getWritableDatabase()` 方法则将出现异常。

#### SQLite 多线程
[Android SQLite3多线程操作问题研究总结](https://juejin.im/post/5c330e84f265da616d5458d9)

- 事务
