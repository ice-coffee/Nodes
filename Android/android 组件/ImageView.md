## ImageView
### 1. 使用ImageSwitcher实现图片的切换效果
[源码下载](http://pan.baidu.com/s/1bnmJX7L)
只需要以下几个简单步骤：
1. 通 过 findViewById() 方 法 获 取 TextSwitcher 对 象 的 引 用switcher，当然也可以直接在代码中构造该对象。
2. 通过 switcher.setFactory() 方法指定 TextSwitcher 的 View-Factory。
3. 通过 switcher.setInAnimation() 方法设置换入动画效果。
4. 通过 switcher.setOutAnimation() 方法设置换出动画效果

示例代码如下所示:

```
public class ImageActivity extends Activity
{
    private ImageSwitcher mImageSwitcher;
    private int[] icons = {R.drawable.n_guide_1, R.drawable.n_guide_2, R.drawable.n_guide_3};
    private int mImagePosition = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.image_layout);

        /* ImageSwitcher控件初始化 */
        mImageSwitcher = (ImageSwitcher) findViewById(R.id.your_imageview);

        mImageSwitcher.setFactory(new ViewSwitcher.ViewFactory() {
            @Override
            public View makeView()
            {
                ImageView imageView = new ImageView(ImageActivity.this);

                return imageView;
            }
        });

        /* 加载显示动画 */
        mImageSwitcher.setInAnimation(this, R.anim.image_fade_in);
        /* 加载隐藏动画 */
        mImageSwitcher.setOutAnimation(this, R.anim.image_fade_out);

        onSwitchImage(null);
    }

    /**
     * Button 按钮
     * @param v
     */
    public void onSwitchImage(View v)
    {
        mImageSwitcher.setImageResource(icons[mImagePosition]);
        setNextPosition();
    }

    /**
     * 循环获取icons数组的下标
     */
    private void setNextPosition() {
        mImagePosition = (mImagePosition + 1) % icons.length;
    }
}
```
