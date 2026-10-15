### ORMLite

@(android 框架)

#### 下载ORMLite Jar
为了使用ORMLite, 你需要下载相关的jar文件. 您可以从默认仓库[ORMLite release page](http://ormlite.com/releases/)中下载, 也可以从[central maven repository](http://repo1.maven.org/maven2/com/j256/ormlite/)和[Sourceforge](http://sourceforge.net/projects/ormlite/files/)中获取.

准备通过JDBC连接SQL数据库的用户需要下载`ormlite-jdbc-5.0.jar` 和 `ormlite-core-5.0.jar` 这两个文件. 对于在Android应用程序中使用来说, 你需要下载`ormlite-android-5.0.jar` 和 `ormlite-core-5.0.jar`这两个文件. 对于不管是JDBC还是Android来说你都需要拥有ORMLite后台实现的ormlite-core包. 虽然有一些你可能用到的可选包, 但是ORMLite没有提供任何外部依赖. 参见[External Dependencies](http://ormlite.com/javadoc/ormlite-core/doc-files/ormlite_5.html#Dependencies). ORMLite的代码是运行在Java5已经更高的版本上的.

#### 配置Class
下面是一个使用SQLite注解被配置持久化到数据库的示例类. `@DatabaseTable`注解配置Account类持久化到名为accounts的数据库表. `@DatabaseField`注解映射Account类中的字段到数据库中相同名字的字段.
下面示例类中的name字段使用`@DatabaseField(id = true)`注解字段被配置成了数据库表的主键. 另外, 值得注意的是一个无参的构造函数是必须的(可以理解为Java Bean, 但是此构造函数的最低访问权限为包访问权限), 这样就可以通过查询来获取对象了. 欲了解更多信息(JPA注解和其他配置类的方法)请看手册中最新的类设置信息. 参看[Setting Up Your Classes.](http://ormlite.com/javadoc/ormlite-core/doc-files/ormlite_2.html#Class-Setup)

```
@DatabaseTable(tableName = "accounts")
public class Account {
    
    @DatabaseField(id = true)
    private String name;
    @DatabaseField
    private String password;
    
    public Account() {
        // ORMLite needs a no-arg constructor 
    }
    public Account(String name, String password) {
        this.name = name;
        this.password = password;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
}
```

#### 配置DAO
一个典型的隔离数据库操作的Java 模式是使用数据访问对象类(Data Access Objects, 即DAO). 每个DAO提供增, 删, 改等功能类型并专门处理一个单一持久化的类. 一种创建一个DAO的简单方法是使用DaoManager类中的createDao静态方法. 例如, 为上面定义的Account类定义一个DAO你可以这样做:
	
```
Dao<Account, String> accountDao =  DaoManager.createDao(connectionSource, Account.class);
Dao<Order, Integer> orderDao =  DaoManager.createDao(connectionSource, Order.class);
```

更多关于设置DAO的最新可用信息可查看手册, 参看[Setting Up the DAOs.](http://ormlite.com/javadoc/ormlite-core/doc-files/ormlite_2.html#DAO-Setup)

#### ORMLite在Android系统中的使用
##### 1. 下载`ormlite-core.jar` and `ormlite-android.jar`并添加依赖.
##### 2. 通过继承OrmLiteSqliteOpenHeler, 创建数据库helper类, 实现`onCreate(SQLiteDatabase sqliteDatabase, ConnectionSource connectionSource)` 和 `onUpgrade(SQLiteDatabase database, ConnectionSource connectionSource, int oldVersion, int newVersion)`方法, onCreate方法在app第一次安装时被调用创建数据库, 当app版本升级时会调用onUpgrade方法升级数据库.

```
/**
 * DatabaseHelper用于创建和升级数据库, 也通常为其他类提供DAOs
 */
public class DatabaseHelper extends OrmLiteSqliteOpenHelper
{
    //数据库名
    private static final String DATABASE_NAME = "helloAndroid.db";
    // 当前数据库版本号
    private static final int DATABASE_VERSION = 1;

    // 用于操作SimpleData表的DAO
    private Dao<User, Integer> userDao = null;

    public DatabaseHelper(Context context)
    {
        super(context, DATABASE_NAME, null, DATABASE_VERSION, R.raw.ormlite_config);
    }

    /**
     * 数据库第一次创建的时候会调用onCreate(), 在这里调用创建表的语句
     */
    @Override
    public void onCreate(SQLiteDatabase db, ConnectionSource connectionSource)
    {
        try
        {
            //创建SimpleData表
            TableUtils.createTable(connectionSource, User.class);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 数据库更新时调用onUpgrade(), 修改DATABASE_VERSION 字段的值
     */
    @Override
    public void onUpgrade(SQLiteDatabase db, ConnectionSource connectionSource, int oldVersion, int newVersion)
    {
        try
        {
            switch (oldVersion)
            {
                case 1:
                    // 当前版本号大于1时调用以下更新语句

                case 2:
                    // 当前版本号大于2时调用以下更新语句

                    break;
            }
        }catch (SQLException e)
        {
            e.printStackTrace();
        }
    }

    /**
     * 返回数据库SimpleData表的操作对象(DAO)
     */
    public Dao<User, Integer> getDao() throws SQLException {
        if (userDao == null) {
            userDao = getDao(User.class);
        }
        return userDao;
    }

    /**
     * 关闭数据库连接并清理缓存
     */
    @Override
    public void close()
    {
        super.close();
        userDao = null;
    }
}
```
##### 3. 创建数据库表类

```
//标明这是数据库中的一张表, 表名为note
@DatabaseTable(tableName = "User")
public class User
{
    //generatedId 表示id为主键且自动生成
    @DatabaseField(generatedId = true)
    private int id;

    //columnName的值为该字段在数据中的列名
    @DatabaseField(columnName = "name")
    private String name;

    public int getId()
    {
        return id;
    }

    public void setId(int id)
    {
        this.id = id;
    }

    public String getName()
    {
        return name;
    }

    public void setName(String name)
    {
        this.name = name;
    }
}
```

##### 4. 创建User的DAO类

```
/**
 * 数据库的链接和关闭, User表的操作
 */
public class UserDao
{
    private DatabaseHelper databaseHelper;
    private Dao userDao;

    /**
     * 数据库连接, 并创建DAO
     * @param context
     */
    public UserDao(Context context)
    {
        databaseHelper = OpenHelperManager.getHelper(context, DatabaseHelper.class);

        try
        {
            userDao = databaseHelper.getDao();
        } catch (SQLException e)
        {
            e.printStackTrace();
        }

    }

    /**
     * 添加数据到表
     * @param user
     */
    public void addUser(User user)
    {
        try
        {
            userDao.create(user);
        } catch (SQLException e)
        {
            e.printStackTrace();
        }
    }

    /**
     * 查询表中所有数据
     * @return
     */
    public List<User> queryAllUser()
    {
        List<User> userList = null;
        try
        {
            userList = userDao.queryForAll();
        } catch (SQLException e)
        {
            e.printStackTrace();
        }

        return userList;
    }

    /**
     * 根据ID更新内容
     * @param id
     */
    public void updateUserById(int id)
    {
        try
        {
            UpdateBuilder updateBuilder = userDao.updateBuilder();
            updateBuilder.updateColumnValue("name", "haha");
            updateBuilder.where().eq("id", id);
            updateBuilder.update();
        } catch (SQLException e)
        {
            e.printStackTrace();
        }
    }

    /**
     * 根据ID更新内容
     * @param id
     */
    public void deleteUserById(int id)
    {
        try
        {
            DeleteBuilder deleteBuilder = userDao.deleteBuilder();
            deleteBuilder.where().eq("id", id);
            deleteBuilder.delete();
        } catch (SQLException e)
        {
            e.printStackTrace();
        }
    }

    /**
     * 断开数据库连接,并清理缓存
     */
    public void destoryHelper()
    {
        if (databaseHelper != null)
        {
            OpenHelperManager.releaseHelper();
            databaseHelper = null;
        }
    }
}

```

> 使用ORMLite必须在适当的时间调用`OpenHelperManager.getHelper()` and `release()`方法, 可以通过继承`OrmLiteBaseListActivity`, `OrmLiteBaseService`, and `OrmLiteBaseTabActivity`, 这样在Activity的onCreate()和onDestroy()中会通过反射自动分别调用这两个方法, 也可以通过代码实现. 如上, 记得在Activity的onCreate()方法中调用destoryHelper():


##### 5. MainActivity.java

```
public class MainActivity extends Activity
{
    private UserDao userDao;

    private List<User> userList;

    private ListView lv_user;

    private TextView tv_users;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        lv_user = (ListView) findViewById(R.id.lv_user);
        tv_users = (TextView) findViewById(R.id.tv_users);

        userDao = new UserDao(this);
    }

    public void addUser(View view)
    {
        if (null != userDao)
        {
            Random random = new Random();
            int current = random.nextInt(100);

            User user = new User();
            user.setName("name" + current);

            userDao.addUser(user);
        }
    }

    public void queryUser(View view)
    {
        StringBuffer noteStr = new StringBuffer();

        if (null != userDao)
        {
            userList = userDao.queryAllUser();

            for (User user : userList)
            {
                noteStr.append(user.getName());
            }

            tv_users.setText(noteStr);
        }
    }

    public void updateUser(View view)
    {
        if (null != userDao)
        {
            userDao.updateUserById(1);
        }
    }

    public void deleteUser(View view)
    {
        if (null != userDao)
        {
            userDao.deleteUserById(1);
        }
    }

    @Override
    protected void onDestroy()
    {
        super.onDestroy();

        if (null != userDao)
        {
            userDao.destoryHelper();
        }
    }
}
```

##### 6. 使用表配置文件
> 使用表配置文件是由于在Android系统中使用DAO严重影响性能, 使用表配置文件之后性能大概提高20倍, 官网说的我也没测试过.


具体步骤如下:
1. 在res/raw目录下新建`ormlite_config.txt`文件.
2. 定义新类继承OrmLiteConfigUtil, 例如:
	
```
public class DatabaseConfigUtil extends OrmLiteConfigUtil 
{
  public static void main(String[] args) throws Exception 
  {
    writeConfigFile("ormlite_config.txt");
  }
}
```

3. 在Android studio中运行DatabaseConfigUtil 类, 运行之前先进行配置, 如图
![Alt text](<../../attachment/:edit_configuration.png>)
![Alt text](<../../attachment/:edit_configuration_run.png>)
运行完成之后在控制台会打印如下提示:

```
Writing configurations to E:\android\warkspace\study\github\OrmLit\zhy_ormlite\app\src\main\.\res\raw\ormlite_config.txt
Wrote config for class com.zhy.zhy_ormlite.bean.Article
Wrote config for class com.zhy.zhy_ormlite.bean.User
Done.

Process finished with exit code 0
```
ormlite_config.txt文件中的内容为:

```
#
# generated on 2016/09/05 04:25:03
#
# --table-start--
dataClass=com.zhy.zhy_ormlite.bean.User
tableName=User
# --table-fields-start--
# --field-start--
fieldName=id
generatedId=true
# --field-end--
# --field-start--
fieldName=name
columnName=name
# --field-end--
# --table-fields-end--
# --table-end--
#################################

```
