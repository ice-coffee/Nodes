### Android 问题集锦 01

@(android BUG记录)


#### 1. bug描述
> WindowManager$BadTokenException: Unable to add window -- token null is not for an application

#### 2. 产生情景

```
private Context mcontext;   
  
    @Override  
    protected void onCreate(Bundle savedInstanceState) 
    {
	    mcontext = getApplicationContext();   
        System.out.println("mcontext=" + mcontext);   
    }

new AlertDialog.Builder(mcontext)   
            .setIcon(android.R.drawable.ic_dialog_alert)   
            .setTitle("Warnning")   
            .setMessage("You forget to write the message. Do you want to fill out it ??")   
            .setPositiveButton("Yes", positiveListener)
            .setNegativeButton("No", negativeListener)
            .create()
            .show();  
```

#### 3. 原因分析
> 导致报这个错是在于new AlertDialog.Builder(mcontext)，虽然这里的参数是AlertDialog.Builder(Context context)但我们不能使用getApplicationContext()获得的Context,而必须使用Activity,因为只有一个Activity才能添加一个窗体。 

#### 4. 修改方案
> 将new AlertDialog.Builder(Context context)中的参数用Activity.this（Activity是你的Activity的名称）来填充就可以正确的创建一个Dialog了。

```
 new AlertDialog.Builder(MyActivity.this)   
                    .setIcon(android.R.drawable.ic_dialog_alert)   
                    .setTitle("Warnning")   
                    .setMessage("You forget to write the message. Do you want to fill out it ??")   
                    .setPositiveButton("Yes", positiveListener)
                    .setNegativeButton("No", negativeListener)
                    .create()
					.show();  
```
