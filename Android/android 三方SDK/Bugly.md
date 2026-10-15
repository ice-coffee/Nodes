### Bugly

@(android 工具)

#### 版本更新UI自定义

[自定义UI](https://bugly.qq.com/docs/user-guide/advance-features-android-beta/#ui)

> 实例:

Application，onCreate（）
```
Beta.upgradeDialogLayoutId = R.layout.dialog_version_upgrade;
Beta.upgradeDialogLifecycleListener = new UILifecycleListener<UpgradeInfo>(){

    @Override
    public void onCreate(final Context context, final View view, UpgradeInfo upgradeInfo) {
        TextView upgradeFeature = view.findViewById(R.id.tv_dialog_feature);
        upgradeFeature.setMovementMethod(ScrollingMovementMethod.getInstance());

        ImageView ivClose = view.findViewById(R.id.iv_dialog_close);
        //升级策略 1建议 2强制 3手工
        if (upgradeInfo.upgradeType != 2) {
            ivClose.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onStart(Context context, View view, UpgradeInfo upgradeInfo) {

    }

    @Override
    public void onResume(Context context, View view, UpgradeInfo upgradeInfo) {

    }

    @Override
    public void onPause(Context context, View view, UpgradeInfo upgradeInfo) {

    }

    @Override
    public void onStop(Context context, View view, UpgradeInfo upgradeInfo) {

    }

    @Override
    public void onDestroy(Context context, View view, UpgradeInfo upgradeInfo) {

    }
};
Bugly.init(getApplicationContext(), BUGLY_APPID, true);
```

dialog_version_upgrade.xml
```
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:ignore="SpUsage">

    <RelativeLayout
        android:layout_width="263dp"
        android:layout_height="376dp"
        android:layout_centerInParent="true"
        android:background="@mipmap/bg_version_update">

        <ImageView
            android:id="@+id/iv_dialog_close"
            android:visibility="gone"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_alignParentEnd="true"
            android:layout_marginTop="30dp"
            android:layout_marginEnd="10dp"
            android:padding="10dp"
            android:src="@mipmap/ic_close_white"/>

        <TextView
            android:tag="beta_cancel_button"
            android:layout_width="40dp"
            android:layout_height="40dp"
            android:layout_alignParentEnd="true"
            android:layout_marginTop="30dp"
            android:layout_marginEnd="10dp"
            android:padding="10dp"
            android:textSize="0dp"/>

        <TextView
            android:id="@+id/bt_update_now"
            android:tag="beta_confirm_button"
            android:layout_width="match_parent"
            android:layout_height="42dp"
            android:gravity="center"
            android:layout_alignParentBottom="true"
            android:layout_marginBottom="20dp"
            android:layout_marginStart="40dp"
            android:layout_marginEnd="40dp"
            android:background="@drawable/selector_rect_red_rad5"
            android:text="@string/update_now"
            android:textColor="@color/white"
            android:textSize="14dp"/>

        <TextView
            android:id="@+id/tv_dialog_feature"
            android:tag="beta_upgrade_feature"
            android:layout_above="@id/bt_update_now"
            android:layout_width="match_parent"
            android:layout_height="120dp"
            android:layout_marginStart="20dp"
            android:layout_marginEnd="20dp"
            android:layout_marginBottom="20dp"
            android:scrollbars="vertical"
            android:fadeScrollbars="true"
            android:scrollbarThumbVertical="@drawable/shape_rect_red_rad5"
            android:scrollbarSize="3dp"
            android:textColor="#333333"
            android:textSize="12dp" />

        <TextView
            android:tag="beta_upgrade_feature"
            android:layout_above="@id/tv_dialog_feature"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginStart="20dp"
            android:layout_marginEnd="20dp"
            android:layout_marginBottom="10dp"
            android:text="@string/update_title"
            android:textStyle="bold"
            android:textColor="#333333"
            android:textSize="12dp" />

    </RelativeLayout>

    <TextView
        android:tag="beta_title"
        android:layout_width="0dp"
        android:layout_height="0dp" />
    <TextView
        android:tag="beta_upgrade_info"
        android:layout_width="0dp"
        android:layout_height="0dp" />

</RelativeLayout>
```

#### 注意
> 自定义布局中, bugly写了5个需要对应标注的tag, 但是并没有说其实这五个tag都必须出现在布局中, 否则将显示不出更新的信息
> - "beta_upgrade_info";
> - "beta_upgrade_feature";
> - "beta_cancel_button";
> - "beta_confirm_button";
> - "beta_tip_message";

![enter image description here](https://bugly.qq.com/docs/img/beta/advance/1467275423177.png?v=20181014122344)

> -----------------------------------------------

> //升级策略 1建议 2强制 3手工，当升级策略为强制升级时，tag为"beta_cancel_button"的View会被隐藏
