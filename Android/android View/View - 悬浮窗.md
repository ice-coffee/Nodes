### 示例代码
添加悬浮窗权限：
```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```
`android 6.0` 之后动态权限申请权限：
```java
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
    if (!Settings.canDrawOverlays(getActivity())) {
        Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
        intent.setData(Uri.parse("package:" + getActivity().getPackageName()));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }
}
```
添加悬浮窗：
```java
public class DragFloatViewHelper implements View.OnTouchListener, View.OnLayoutChangeListener{

    /**
     * view所在位置
     */
    private int mLastX;
    private int mLastY;

    /**
     * 屏幕高宽
     */
    private int mScreenWidth;
    private int mScreenHeight;

    /**
     * view高宽
     */
    private int mWidth;
    private int mHeight;

    /**
     * 是否在拖拽过程中
     */
    private boolean isDrag = false;

    /**
     * 系统最小滑动距离
     */
    private int mTouchSlop = 0;

    private WindowManager.LayoutParams floatLayoutParams;
    private WindowManager mWindowManager;
    private View mView;
    private boolean isShow;

    /**
     * 手指触摸位置
     */
    private float xInScreen;
    private float yInScreen;
    private float xInView;
    public float yInView;

    private DragFloatViewHelper() {
        // nothing
    }

    private static final class Holder {
        private static final DragFloatViewHelper INSTANCE = new DragFloatViewHelper();
    }

    public static DragFloatViewHelper getInstance() {
        return Holder.INSTANCE;
    }

    @Override
    public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
        if (mWidth == 0) {
            // 获取布局高宽
            mWidth = right - left;
            mHeight = bottom - top;
        }
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        int action = event.getAction();
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                mLastX = (int) event.getRawX();
                mLastY = (int) event.getRawY();
                yInView = event.getY();
                xInView = event.getX();
                xInScreen = event.getRawX();
                yInScreen = event.getRawY();
                break;
            case MotionEvent.ACTION_MOVE:
                int dx = (int) event.getRawX() - mLastX;
                int dy = (int) event.getRawY() - mLastY;
                if (Math.abs(dx) > mTouchSlop || Math.abs(dy) > mTouchSlop) {
                    isDrag = true;
                }
                xInScreen = event.getRawX();
                yInScreen = event.getRawY();
                mLastX = (int) event.getRawX();
                mLastY = (int) event.getRawY();
                // 拖拽时调用WindowManager updateViewLayout更新布局位置
                updateFloatPosition(false);
                break;
            case MotionEvent.ACTION_UP:
                if (isDrag) {
                    // 执行贴边
                    startAnim();
                    isDrag = false;
                }
                break;
            default:
                break;
        }
        return true;
    }

    /**
     * 布局显示
     */
    public void show(View view) {
        if (isShow) {
            return;
        }
        this.mView = view;

        Context context = mView.getContext();
        mScreenWidth = context.getResources().getDisplayMetrics().widthPixels;
        mScreenHeight = context.getResources().getDisplayMetrics().heightPixels;
        mTouchSlop = ViewConfiguration.get(context).getScaledTouchSlop();
        mWindowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);

        mView.setOnTouchListener(this);
        mView.addOnLayoutChangeListener(this);

        // Android 8.0 新增 `TYPE_APPLICATION_OVERLAY` 用于替代 `TYPE_PHONE`
        int type = WindowManager.LayoutParams.TYPE_PHONE;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        }

        floatLayoutParams = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT);
        floatLayoutParams.type = type;
        // 设置悬浮窗不接受输入焦点
        floatLayoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        // 设置悬浮窗位图格式
        floatLayoutParams.format =  PixelFormat.RGBA_8888;
        // 设置悬浮窗位置
        floatLayoutParams.gravity = Gravity.START | Gravity.TOP;
        floatLayoutParams.x = 20;
        floatLayoutParams.y = 20;

        if (null != mView && null != mWindowManager) {
            mWindowManager.addView(mView, floatLayoutParams);
            isShow = true;
        }
    }

    public void close() {
        if (null != mView && null != mWindowManager) {
            mWindowManager.removeView(mView);
            mView = null;
            isShow = false;
        }
    }

    public boolean isShow() {
        return isShow;
    }

    /**
     * 更新布局位置
     */
    private void updateFloatPosition(boolean isUp) {
        int x = (int) (xInScreen - xInView);
        int y = (int) (yInScreen - yInView);
        if (isUp) {
            x = isRightFloat() ? mScreenWidth : 0;
        }
        if (x < 0) {
            x = 0;
        }
        if (x > mScreenWidth - mWidth) {
            x = mScreenWidth - mWidth;
        }
        if (y < 0) {
            y = 0;
        }
        if (y > mScreenHeight - mHeight) {
            y = mScreenHeight - mHeight;
        }
        floatLayoutParams.x = x;
        floatLayoutParams.y = y;
        // 更新位置
        mWindowManager.updateViewLayout(mView, floatLayoutParams);
    }

    /**
     * 是否靠右边悬浮
     */
    boolean isRightFloat() {
        return xInScreen > mScreenWidth / 2f;
    }

    /**
     * 执行贴边动画
     */
    private void startAnim(){
        ValueAnimator valueAnimator;
        if (floatLayoutParams.x < mScreenWidth / 2) {
            valueAnimator = ValueAnimator.ofInt(floatLayoutParams.x, 0);
        } else {
            valueAnimator = ValueAnimator.ofInt(floatLayoutParams.x, mScreenWidth - mWidth);
        }
        valueAnimator.setDuration(200);
        valueAnimator.addUpdateListener(animation -> {
            floatLayoutParams.x = (int) animation.getAnimatedValue();
            mWindowManager.updateViewLayout(mView, floatLayoutParams);
        });
        valueAnimator.start();
    }
}
```
