### IllegalStateException : Can not perform this action after onSaveInstanceSate

@(android BUG记录)

[原文](https://www.jianshu.com/p/f6570ce9e413)

> Fragment虽然使用起来确实非常的方便，而且在效率上来看，也比Activity要高。但是也存在各种各样的问题。这里对DialogFragment.show()调用的时候，可能引发的一个Bug解决来看看DialogFragment。

#### 还原现场
既然是Bug，直接上现场，崩溃栈如下：

![enter image description here](https://upload-images.jianshu.io/upload_images/1420036-843c02fe7f36f863.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/933/format/webp)

可以看到是因为调用了DialogFragment.show()，最终导致了IllegalStateException。

> IllegalStateException : Can not perform this action after onSaveInstanceSate

#### 复盘
既然有崩溃栈，那么接下来我们来根据复盘。
直接根据调用栈来看源码，最终崩溃的地方如下。

```
/**
 * Adds an action to the queue of pending actions.
 *
 * @param action the action to add
 * @param allowStateLoss whether to allow loss of state information
 * @throws IllegalStateException if the activity has been destroyed
 */
public void enqueueAction(Runnable action, boolean allowStateLoss) {
    if (!allowStateLoss) {
        checkStateLoss();
    }
    synchronized (this) {
        if (mDestroyed || mHost == null) {
            throw new IllegalStateException("Activity has been destroyed");
        }
        if (mPendingActions == null) {
            mPendingActions = new ArrayList<Runnable>();
        }
        mPendingActions.add(action);
        if (mPendingActions.size() == 1) {
            mHost.getHandler().removeCallbacks(mExecCommit);
            mHost.getHandler().post(mExecCommit);
        }
    }
}

private void checkStateLoss() {
    if (mStateSaved) {
        throw new IllegalStateException(
                "Can not perform this action after onSaveInstanceState");
    }
    if (mNoTransactionsBecause != null) {
        throw new IllegalStateException(
                "Can not perform this action inside of " + mNoTransactionsBecause);
    }
}
```


可以看到在checkStateLoss()的时候，如果mStateSaved已经被置为true，导致直接抛出此异常。那么问题就出在mStateSaved这个变量什么时候会被置为true，通过源码继续找下去发现只有在saveAllState()的时候，才会将它置为true。

```
Parcelable saveAllState() {
    // ...
    if (HONEYCOMB) {
        // As of Honeycomb, we save state after pausing.  Prior to that
        // it is before pausing.  With fragments this is an issue, since
        // there are many things you may do after pausing but before
        // stopping that change the fragment state.  For those older
        // devices, we will not at this point say that we have saved
        // the state, so we will allow them to continue doing fragment
        // transactions.  This retains the same semantics as Honeycomb,
        // though you do have the risk of losing the very most recent state
        // if the process is killed...  we'll live with that.
        mStateSaved = true;
    }
    // ...
}
```

这段注释解释的很清楚了，就不再翻译了。
只有在API level 11+之后，才会用到这个状态，在Fragment所在的依附的Activity被销毁的时候，会调用此方法保存Fragment的状态，体现在代码中，就是在FragmentActivity的onSaveInstanceState()的时候，会去调用FragmentManager.saveAllState()方法去保存当前所有的Fragment的状态，以便下次进行恢复。而在被销毁到恢复期间的时候，去做有关Fragment状态的操作，就会引起IllegalStateException。
而调用的地方在FragmentActivity.java中。

```
/**
 * Save all appropriate fragment state.
 */
@Override
protected void onSaveInstanceState(Bundle outState) {
    super.onSaveInstanceState(outState);
    Parcelable p = mFragments.saveAllState();
    if (p != null) {
        outState.putParcelable(FRAGMENTS_TAG, p);
    }
}
```

当然，onSaveInstanceState会在什么时候调用，有什么地方需要注意，可以自行Google，这个不是本篇的主题。

#### 解决思路
既然已经找到了问题出在哪里，那么如何解决呢。从上面的FragmentManager.enqueueAction()代码可以看出，是有传递一个参数去控制是否允许状态的损失，也就是在状态被保存的时候依然继续执行。

```
/**
 * Adds an action to the queue of pending actions.
 *
 * @param action the action to add
 * @param allowStateLoss whether to allow loss of state information
 * @throws IllegalStateException if the activity has been destroyed
 */
public void enqueueAction(Runnable action, boolean allowStateLoss) {
    if (!allowStateLoss) {
        checkStateLoss();
    }
    // ...
}
```

而allowStateLoss什么时候会传递true呢？继续查看源码会发现FragmentTransaction中出了commit()还提供了一个类似的方法commitAllowingStateLoss()，调用它就会去忽略mStateSaved。

```
/**
 * Schedules a commit of this transaction.  The commit does
 * not happen immediately; it will be scheduled as work on the main thread
 * to be done the next time that thread is ready.
 *
 * <p class="note">A transaction can only be committed with this method
 * prior to its containing activity saving its state.  If the commit is
 * attempted after that point, an exception will be thrown.  This is
 * because the state after the commit can be lost if the activity needs to
 * be restored from its state.  See {@link #commitAllowingStateLoss()} for
 * situations where it may be okay to lose the commit.</p>
 * 
 * @return Returns the identifier of this transaction's back stack entry,
 * if {@link #addToBackStack(String)} had been called.  Otherwise, returns
 * a negative number.
 */
public abstract int commit();

/**
 * Like {@link #commit} but allows the commit to be executed after an
 * activity's state is saved.  This is dangerous because the commit can
 * be lost if the activity needs to later be restored from its state, so
 * this should only be used for cases where it is okay for the UI state
 * to change unexpectedly on the user.
 */
public abstract int commitAllowingStateLoss();
```


这样来看，实际上设计的时候是有考虑过状态的问题的，只需要把commit()替换成commitAllowingStateLoss()即可。但是DialogFragment本身提供的show()方法，会去直接调用commit()。根本没有调用commitAllowingStateLoss()的入口。

```
/**
     * Display the dialog, adding the fragment to the given FragmentManager.  This
     * is a convenience for explicitly creating a transaction, adding the
     * fragment to it with the given tag, and committing it.  This does
     * <em>not</em> add the transaction to the back stack.  When the fragment
     * is dismissed, a new transaction will be executed to remove it from
     * the activity.
     * @param manager The FragmentManager this fragment will be added to.
     * @param tag The tag for this fragment, as per
     * {@link FragmentTransaction#add(Fragment, String) FragmentTransaction.add}.
     */
    public void show(FragmentManager manager, String tag) {
        mDismissed = false;
        mShownByMe = true;
        FragmentTransaction ft = manager.beginTransaction();
        ft.add(this, tag);
        ft.commit();
    }
```

看来Android设计者还是有遗漏的没有考虑到的地方。

#### 解决方案
既然已经找到了问题的症结。那么就有办法解决了。
try.catch住
已经很明朗是因为mStateSaved出现的错误，那么在继承DialogFragment之后，从写show()方法，然后把super.show()用try.catch包裹住即可。这样就可以忽略此Bug了。

@Override
public void show(FragmentManager manager, String tag) {
    try{
        super.show(manager,tag);
    }catch (IllegalStateException ignore){
    }
}

重写DialogFragment
使用try.catch的方式明显不够优雅。那么就可以考虑第二种方案。
既然DialogFragment是继承于Fragment，那么可以把它完整的代码全部拷贝过来，然后重写show()方法，把commit()替换为commitAllowingStateLoss()即可。
不过如果Fragment的继承有包的限制，可以在自己的项目中，新建一个android.support.v4.app的Package，然后在其中新建一个PDialogFragment.java，将DialogFragment的代码全部copy过来，重写对应的方法即可。

public void show(FragmentManager manager, String tag) {
    mDismissed = false;
    mShownByMe = true;
    FragmentTransaction ft = manager.beginTransaction();
    ft.add(this, tag);
    ft.commitAllowingStateLoss();
}

虽然用继承DialogFragment的方式，自己去写show()，不去调用super.show()应该也可以，但是show()中其实是有一些状态的置换的，最好不要用这种方式，用这种方式在调试的时候可能没有问题，但是发布出去可能会导致未知问题。
