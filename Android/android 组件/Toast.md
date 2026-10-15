## Toast
[toc]
### 如改变Toast出现的位置

```
public void setGravity (int gravity, int xOffset, int yOffset)
```

> 函数功能为:设置通知出现在屏幕上的位置

第一个参数里可以设置一个值也可以设置两个值中间用`|`隔开,如:

```
Toast toast = Toast.makeText(this, "Bottom Right!", Toast.LENGTH_SHORT);
toast.setGravity(Gravity.BOTTOM | Gravity.RIGHT, 0, 0);
toast.show();
```
