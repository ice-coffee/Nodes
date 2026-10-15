```
TypedArray a = mContext.obtainStyledAttributes(R.styleable.AppCompatTheme);
```
`Context` 和 `Theme` 间的关系。

- `backgroundDimEnabled` ：设置背景亮度，默认 `0.6`；可以通过 `getWindow().setDimAmount();` 函数调节亮度；
- `windowNoTitle`：不加标题栏；
- `windowFullscreen`：窗口全屏。隐藏所有装饰栏（状态栏）；
- `windowIsTranslucent`：透明背景；
- `windowBackground`：窗口背景位图；
- `windowContentOverlay`：窗口。。。。。
- `windowFrame`：窗口边框。通常为 `@null`；
- `windowCloseOnTouchOutside`：
