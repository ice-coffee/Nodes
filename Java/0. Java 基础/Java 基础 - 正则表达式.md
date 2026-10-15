[toc]
### 正则表达式

#### 小括号、中括号、大括号
在正则表达式中，`()`, `[]`, 和 `{}` 是用来定义分组和字符类、重复次数的特殊符号。它们的作用如下：

* **`() - 分组`**： 圆括号 () 用于将正则表达式中的一部分内容分组，这样你可以对该组内的内容应用操作符，比如重复次数操作符。分组还可以用于提取匹配的部分文本，以便后续的处理。例如，(ab)+ 匹配一个或多个连续的"ab"序列。
* **`[] - 字符类`**： 方括号 [] 用于定义一个字符类，它匹配方括号内的任意一个字符。例如，[aeiou] 匹配任何一个元音字母。你还可以使用连字符（-）来定义字符范围，比如 [a-z] 匹配所有小写字母。字符类也可以包含多个字符，例如 [aeiouAEIOU] 匹配任何一个大小写字母。
* **`{} - 重复次数`**： 花括号 {} 用于指定前面的模式重复出现的次数。例如，a{3} 匹配恰好三个连续的字母"a"。你还可以使用逗号来指定一个范围，比如a{2,4} 匹配2到4个连续的字母"a"。

### Pattern
`Pattern.split(CharSequence input)`：用于分隔字符串,并返回一个 `String[]`。

```java
Pattern p = Pattern.compile("\\d+"); 
String[] str = p.split("我的QQ是:456456我的电话是:0532214我的邮箱是:aaa@aaa.com"); 

输出：str[0]="我的QQ是:" str[1]="我的电话是:" str[2]="我的邮箱是:aaa@aaa.com" 
```

### Matcher
`Matcher` 类提供三个匹配操作方法：

| 方法 | 说明 |
| --- | --- |
| `matches()` | 对整个字符串进行匹配,只有整个字符串都匹配了才返回true  |
| `lookingAt()` | 对前面的字符串进行匹配,只有匹配到的字符串在最前面才返回true  |
| `find()` | 对字符串进行匹配,匹配到的字符串可以在任何位置  |

获取匹配详情信息：

| 方法 | 说明 |
| --- | --- |
| `start()` | 返回匹配到的子字符串在字符串中的索引位置 |
| `end()` | 返回匹配到的子字符串的最后一个字符在字符串中的索引位置 |
| `group()` | 返回匹配到的子字符串 |
| `groupCount()` | 返回匹配到多少组，第一组是整个字符串 |

正则表达式的分组使用：

```java
Pattern p = Pattern.compile("([a-z]+)(\\d+)"); 
Matcher m = p.matcher("aaa2223bb"); 
m.find();   //匹配aaa2223 
m.groupCount();   //返回2,因为有2组 
m.start(1);   //返回0 返回第一组匹配到的子字符串在字符串中的索引号 
m.start(2);   //返回3 
m.end(1);   //返回3 返回第一组匹配到的子字符串的最后一个字符在字符串中的索引位置. 
m.end(2);   //返回7 
m.group(1);   //返回aaa,返回第一组匹配到的子字符串 
m.group(2);   //返回2223,返回第二组匹配到的子字符串 
```

### 示例

以 .java 为结尾的文件的正则表达式：

```
".*\.java"
```

```java
/**
 * 用户名注册格式
 * 1.用户名不能以数字开头
 * 2.不能包含除"_"和"-"外的其他特殊字符
 * 3."\u4e00-\u9fa5"可包含汉字
 * 4.长度要求为2到25位
 *
 * @param name
 *
 * @return
 */
public static boolean isLoginUserName(String name)
{
    Pattern p = Pattern.compile("(?!^\\d[A-Za-z0-9_-]*$)^[A-Za-z0-9\u4e00-\u9fa5_-]{2,25}$");
    Matcher m = p.matcher(name);
    return m.matches();
}
```
```java
/**
 * 是否由数字组成
 */
public static boolean isNumber(String num)
{
    Pattern p = Pattern.compile("^[0-9]+(.[0-9]+)?$");
    Matcher m = p.matcher(num);
    return m.matches();
}
```
```java
/**
 * 密码格式要求
 * 1.以字母/数字/特殊字符(^$.+*_@!#%&~=-)组成
 * 2.长度限制为6到32位
 *
 * @param pwd
 *
 * @return
 */
public static boolean isPassword(String pwd)
{
    Pattern p = Pattern.compile("^[A-Za-z0-9\\^\\$\\.\\+\\*_@!#%&~=-]{6,32}$");
    Matcher m = p.matcher(pwd);
    return m.matches();
}
```
```java
/**
 * 注册名格式要求:
 * 1.不能以数字开头
 * 2.只包含字母.数字._.-
 * 3.长度限制为5到20位
 *
 * @param pwd
 *
 * @return
 */
public static boolean isRegisterUserName(String pwd)
{
    Pattern p = Pattern.compile("(?!^\\d[A-Za-z0-9_-]*$)^[A-Za-z0-9_-]{5,20}$");
    Matcher m = p.matcher(pwd);

    return m.matches();
}
```
```java
/**
 * 电话号码格式要求
 * 1.密码开头为13/15/17/18
 * 2.剩下9位为任意数字
 *
 * @param phoneNum
 *
 * @return
 */
public static boolean isPhoneNumber(String phoneNum)
{
    if (!TextUtils.isEmpty(phoneNum) && phoneNum.length() == 11)
    {
        Pattern p = Pattern.compile("^((13[0-9])|(15[0-9])|(17[0-9])|(18[0-9]))\\d{8}$");
        Matcher m = p.matcher(phoneNum);
        return m.matches();
    }
    else
    {
        return false;
    }
}
```
```java
/**
 * 身份证号格式要求
 * 1.15位或18位，如果是15位，必需全是数字。
 * 2.如果是18位，最后一位可以是数字或字母Xx，其余必需是数字。
 */
public static boolean isIDCard(String cardNumber)
{
    Pattern p = Pattern.compile("^(\\d{15}$|^\\d{18}$|^\\d{17}(\\d|X|x))$");
    Matcher m = p.matcher(cardNumber);

    return m.matches();
}
```
