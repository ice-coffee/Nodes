### Android 问题集锦 04

@(android BUG记录)


#### 1. bug描述
> Error:com.android.builder.internal.aapt.AaptException: Failed to crunch file E:\android\warkspace\study\github\SimplifyReader\SimplifyReader-master\SimplifyReader-master\library\build\intermediates\exploded-aar\com.android.support\appcompat-v7\23.2.0\res\drawable-xhdpi-v4\abc_textfield_search_default_mtrl_alpha.9.png into E:\android\warkspace\study\github\SimplifyReader\SimplifyReader-master\SimplifyReader-master\library\build\intermediates\res\merged\androidTest\debug\drawable-xhdpi-v4\abc_textfield_search_default_mtrl_alpha.9.png

#### 2. 解决方案
文件路径太深, 把项目路径缩短点就好了.
