
### 什么是内容提供器
内容提供器（`Content Provider`）主要用于在不同的应用程序之间实现数据的共享功能，同时还保证被访问数据的安全性。使用内容提供器是 `android` 目前实现跨程序共享数据的标准方式。

### ContentResolver 访问其它应用中的数据

> 只需要获取到该应用程序的内容 `Uri`，然后借助 `ContentResolver` 进行 `CRUD` 操作就可以了。

`ContentResolver` 提供的操作：

* `insert()`
* `update()`
* `delete()`
* `query()`

`Uri` 组成：

* 协议声明：`content://`，固定格式不可更改；
* 权限：权限是用于对不同的应用程序做区分的，一般为了避免冲突，都会采用`程序包名`的方式来进行命名；
* 路径：路径则是用于对同一应用程序中不同的表做区分的，通常都会添加到权限的后面；
* 
            
例如:
```
content://com.android.contacts/data/phones
```

访问手机联系人信息:

``` java
Uri uri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI;
Cursor cursor = null;
try
{
    cursor = getContentResolver().query(uri, null, null, null, null);
    while (cursor.moveToNext()) {
        // 获取联系人姓名
        String displayName = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
        // 获取联系人手机号
        String number = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
        contentList.add(displayName + "\n" + number);
    }
} catch (Exception e) {
    e.printStackTrace(System.out);
} finally {
    if (null != cursor) {
        cursor.close();
    }
}
```
        
### 监听数据变化
在调用 `insert()、delete()、update()` 方法对数据库进行修改时调用如下代码：

```
//当数据库内容变化的时候 ，通知某一个uri（私密的邮箱） 数据变化了。
getContext().getContentResolver().notifyChange(Uri.parse("content://aaa.bbb.ccc.ddd"), null);
```

这段代码首先获取了一个内容提供器,然后调用了 `notifyChange()` 方法发送一个通知，那么如何获取这个通知呢？

在数据监听类中调用如下代码

```
Uri uri = Uri.parse("content://aaa.bbb.ccc.ddd");
getContentResolver().registerContentObserver(uri, true, new MyObserver(new Handler()));
```

```
private class MyObserver extends ContentObserver{

    public MyObserver(Handler handler) {
        super(handler);
    }

    @Override
    public void onChange(boolean selfChange) {
        System.out.println("哈哈哈，我是大老板，我发现了a应用数据库的内容变化了。");
        super.onChange(selfChange);
    }
}
```

### 创建自己的内容提供器
    
创建自己的内容提供器继承 `ContentProvider` 并实现 `ContentProvider` 中的六个抽象方法：

* `onCreate()`：初始化内容提供器的时候调用。通常会在这里完成对数据库的创建和升级等操作,返回 true 表示内容提供器初始化成功，返回 false 则表示失败。注意，只有当存在ContentResolver 尝试访问我们程序中的数据时，内容提供器才会被初始化。 
* `query()`：从内容提供器中查询数据。使用 uri 参数来确定查询哪张表， projection 参数用于确定查询哪些列， selection 和 selectionArgs 参数用于约束查询哪些行， sortOrder 参数用于对结果进行排序， 查询的结果存放在 Cursor 对象中返回。
* `insert()`：向内容提供器中添加一条数据。使用 uri 参数来确定要添加到的表，待添加的数据保存在 values 参数中。添加完成后，返回一个用于表示这条新记录的 URI。
* `update()`：更新内容提供器中已有的数据。使用 uri 参数来确定更新哪一张表中的数据，新数据保存在 values 参数中， selection 和selectionArgs 参数用于约束更新哪些行， 受影响的行数将作为返回值返回。
* `delete()`：从内容提供器中删除数据。使用 uri 参数来确定删除哪一张表中的数据， selection和 selectionArgs 参数用于约束删除哪些行， 被删除的行数将作为返回值返回。
* `getType()`：根据传入的内容 URI 来返回相应的 MIME 类型。

使用UriMatcher匹配内容Uri
	1. 内容Uri主要有两种格式
		1. `content://com.example.app.provider/table1`
                这就表示调用方期望访问的是 com.example.app 这个应用的 table1 表中的数据。
                除此之外，我们还可以在这个内容 URI 的后面加上一个id，如下所示：
		2. `content://com.example.app.provider/table1/1`
                表示调用方期望访问的是 com.example.app 这个应用的 table1 表中 id 为 1 的数据

	2. 使用通配符的方式来分别匹配这两种格式的内容 URI，规则如下。
		1. *：表示匹配任意长度的任意字符
		2. #：表示匹配任意长度的数字
                所以，一个能够匹配任意表的内容 URI 格式就可以写成：
                `content://com.example.app.provider/*`
                而一个能够匹配 table1 表中任意一行数据的内容 URI 格式就可以写成：
                `content://com.example.app.provider/table1/#`

3. 借助UriMatcher实现匹配Uri的功能
            我们借助 UriMatcher这个类可以轻松地实现匹配内容 URI的功能。UriMatcher中提供了一个 addURI()方法，这个方法接收三个参数，可以                                分别把权限、路径和一个自定义代码传进去。这样，当调用 UriMatcher 的 match()方法时，就可以将一个 Uri 对象传入，返回值是某个能够匹配这个             Uri 对象所对应的自定义代码，利用这个代码，我们就可以判断出调用方期望访问的是哪张表中的数据了

3. getType()方法处理:
        getType()方法。它是所有的内容提供器都必 须提供的一个方法，用于获取 Uri 对象所对应的 MIME 类型。 一个内容 URI 所对应的 MIME字符        串主要由三部分组分， Android 对这三个部分做了如下格式规定。 
        1. 必须以 vnd 开头。
        2. 如果内容 URI 以路径结尾，则后接 android.cursor.dir/，如果内容 URI 以 id 结尾， 则后接 android.cursor.item/。 
        3. 最后接上 vnd.<authority>.<path>。
            所以，对于 content://com.example.app.provider/table1 这个内容 URI，它所对应的 MIME
            类型就可以写成：
            `vnd.android.cursor.dir/vnd.com.example.app.provider.table1`
            对于 content://com.example.app.provider/table1/1 这个内容 URI，它所对应的 MIME 类型
            就可以写成：
            `vnd.android.cursor.item/vnd.com.example.app.provider.table1`
实例

```
package com.example.ContentProviderTest;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.UriMatcher;
import android.database.Cursor;
import android.net.Uri;

/**
 * Created by ice_coffee on 2015/10/19.
 */
public class MyContentProvider extends ContentProvider
{
    public static final String PROVIDER_PACKAGE = "com.example.ContentProviderTest";

    public static final int TABLE1_DIR = 0;
    public static final int TABLE1_ITEM = 1;
    public static final int TABLE2_DIR = 2;
    public static final int TABLE2_ITEM = 3;
    private static UriMatcher uriMatcher;

    static {
        uriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
        uriMatcher.addURI(PROVIDER_PACKAGE, "table1", TABLE1_DIR);
        uriMatcher.addURI(PROVIDER_PACKAGE, "table1/#", TABLE1_ITEM);
        uriMatcher.addURI(PROVIDER_PACKAGE, "table2", TABLE2_ITEM);
        uriMatcher.addURI(PROVIDER_PACKAGE, "table2/#", TABLE2_ITEM);
    }

    @Override
    public boolean onCreate()
    {
        return false;
    }

    @Override
    public String getType(Uri uri)
    {
        switch (uriMatcher.match(uri)) {
            case TABLE1_DIR:
                return "vnd.android.cursor.dir/vnd.com.example.app.provider.table1";
            case TABLE1_ITEM:
                return "vnd.android.cursor.item/vnd.com.example.app.provider.table1";
            case TABLE2_DIR:
                return "vnd.android.cursor.dir/vnd.com.example.app.provider.table2";
            case TABLE2_ITEM:
                return "vnd.android.cursor.item/vnd.com.example.app.provider.table2";
            default:
                break;
        }
        return null;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder)
    {
        switch (uriMatcher.match(uri)) {
            case TABLE1_DIR:
                // 查询table1表中的所有数据
                break;
            case TABLE1_ITEM:
                // 查询table1表中的单条数据
                break;
            case TABLE2_DIR:
                // 查询table2表中的所有数据
                break;
            case TABLE2_ITEM:
                // 查询table2表中的单条数据
                break;
            default:
                break;
        }
        return null;
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs)
    {
        return 0;
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs)
    {
        return 0;
    }

    @Override
    public Uri insert(Uri uri, ContentValues values)
    {
        return null;
    }
}
```
