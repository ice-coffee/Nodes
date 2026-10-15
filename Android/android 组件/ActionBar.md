## ActionBar

@(android 控件药店)


### 1.showAsAction属性不起作用
> 由于版本更新使用AndroidStudio新建项目后会自动引用V7包,这样的话使用ActionBar时,就会产生一个问题,在menu_bar.xml文件中showAsAction属性所在的命名空间是xmlns:app="http://schemas.android.com/apk/res-auto",这样不管设置成那个值显示按钮的时候都是在Overflow中显示,这样需要把引用的V7包换成V4包,然后使用命名空间为xmlns:android="http://schemas.android.com/apk/res/android"的showAsAction属性设置按钮的显示位置
