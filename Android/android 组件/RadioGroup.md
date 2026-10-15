## RadioGroup
[toc]
### 1. setOnCheckChangeListener多次调用问题

```
RadioGroup bottomMenuBar = (RadioGroup) findViewById(R.id.bottomMenuBar);  
bottomMenuBar.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
	@Override
	public void onCheckedChanged(RadioGroup group, int checkedId)
	{
		Log.e("MainActivity", "onCheckedChanged invoked");
	}
});
bottomMenuBar.check(R.id.tab_new);  
```
使用RadioGroup时如果是以上写法那么控制台上将收到两条打印信息:

```
MainActivity		onCheckedChanged invoked
MainActivity		onCheckedChanged invoked
```

解决办法:
> 使用setChecked()方法替换check()方法
```
		RadioGroup main_radio = (RadioGroup) findViewById(R.id.main_radio);
        RadioButton radio_invest = (RadioButton) findViewById(R.id.rb_invest);
        main_radio.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener()
        {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId)
            {
                changeFragment(checkedId);
            }
        });

        ((RadioButton) main_radio.findViewById(R.id.rb_bjb)).setChecked(true);
```
