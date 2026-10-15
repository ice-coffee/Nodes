## ExpandableListView --- 二级菜单

### 1. 二级菜单的适配器 --- BaseExpandableListAdapter

```
public class ContacterExpandAdapter extends BaseExpandableListAdapter
{
    @Override
    public int getGroupCount()
    {
		return 0;
    }

    @Override
    public long getGroupId(int groupPosition)
    {
        return groupPosition;
    }

    @Override
    public Object getGroup(int groupPosition)
    {
        return groupPosition;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded, View convertView, ViewGroup parent)
    {
        return null;
    }

    @Override
    public Object getChild(int groupPosition, int childPosition)
    {
        return childPosition;
    }

    @Override
    public int getChildrenCount(int groupPosition)
    {
         return groupPosition;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition)
    {
        return childPosition;
    }

    @Override
    public View getChildView(int groupPosition, int childPosition, boolean isLastChild, View convertView, ViewGroup parent)
    {
        return null;
    }

    @Override
    public boolean hasStableIds()
    {
        return true;
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition)
    {
        return true;
    }

}
```

### 2. 二级菜单的长按事件

```
[ExpandableListView]elvAddress.setOnCreateContextMenuListener(onCreateContextMenuListener);

private OnCreateContextMenuListener onCreateContextMenuListener = new OnCreateContextMenuListener()
    {
        @Override
        public void onCreateContextMenu(ContextMenu menu, View v, ContextMenuInfo menuInfo)
        {

            ExpandableListContextMenuInfo info = (ExpandableListContextMenuInfo) menuInfo;

            // 类型，0代表是group类，1代表是child类
            int type = ExpandableListView.getPackedPositionType(info.packedPosition);

            if (type == ExpandableListView.PACKED_POSITION_TYPE_GROUP)
            {
                Log.e("listener", "groupclick");
            }
            else if (type == ExpandableListView.PACKED_POSITION_TYPE_CHILD)
            {
                Log.e("listener", "childclick");
            }
        }

    };
```
