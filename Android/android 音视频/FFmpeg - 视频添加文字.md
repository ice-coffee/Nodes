[文档](http://ffmpeg.org/ffmpeg.html#SEC4)

### 查看FFmpeg支持性

- 可用的bit流：ffmpeg –bsfs
- 可用的编解码器：ffmpeg –codecs
- 可用的解码器：ffmpeg –decoders
- 可用的编码器：ffmpeg –encoders
- 可用的过滤器：ffmpeg –filters
- 可用的视频格式：ffmpeg –formats
- 可用的声道布局：ffmpeg –layouts
- 可用的license：ffmpeg –L
- 可用的像素格式：ffmpeg –pix_fmts
- 可用的协议：ffmpeg -protocols

### 部分语法

```
between(x, min, max)
Return 1 if x is greater than or equal to min and lesser than or equal to max, 0 otherwise.
如果x大于等于min小于等于max，则返回1，否则返回0。

gt(x, y)
Return 1 if x is greater than y, 0 otherwise.
如果x大于y，返回1，否则返回0。

gte(x, y)
Return 1 if x is greater than or equal to y, 0 otherwise.
如果x大于等于y，返回1，否则返回0。

if(x, y)
Evaluate x, and if the result is non-zero return the result of the evaluation of y, return 0 otherwise.
求x的值，如果结果是非0的，则返回y的值，否则返回0。

if(x, y, z)
Evaluate x, and if the result is non-zero return the evaluation result of y, otherwise the evaluation result of z.
求x的值，如果结果是非0的，则返回y的值，否则返回z的值。

lt(x, y)
Return 1 if x is lesser than y, 0 otherwise.
如果x小于y，返回1，否则返回0。

lte(x, y)
Return 1 if x is lesser than or equal to y, 0 otherwise.
如果x小于等于y，返回1，否则返回0。

mod(x, y)
Compute the remainder of division of x by y.
计算x除以y的余数。
```

### 部分FFmpeg命令

前5秒(包括)加文字
```
ffmpeg -i bunny.mp4 -vf drawtext=fontcolor=white:fontsize=40:fontfile=msyh.ttf:line_spacing=7:text='test':x=50:y=50:enable='lte(t\,5)'   -y out.mp4
```

从5秒(包括)之后加文字
```
ffmpeg -i bunny.mp4 -vf ...:enable='gte(t\,5)' -y out.mp4
```

第10秒到20秒加文字
```
ffmpeg -i bunny.mp4 -vf ...:enable='between(t\,10\,20)' -y out.mp4
```

显示5秒 然后5秒不显示 然后再显示5秒 然后5秒不显示； 依次。。。
```
ffmpeg -i bunny.mp4 -vf ...:enable='lte(mod(t\,10)\,5)' -y out.mp4
```

类似字幕显示，可设置开始时间，间隔时间
```
ffmpeg -i bunny.mp4 -vf ...:enable='between(t\,1\,3)',...:enable='between(t\,3\,5)' -y out.mp4
```

文字从左向右移动 每帧移动2个像素
```
ffmpeg -i bunny.mp4 -vf ...:x=50+n*2:y=50  -y out.mp4
```

打印real time
```
ffmpeg -i bunny.mp4 -vf ...:text='%{localtime}' -vframes 600 -y out.mp4
```

设置多段文字淡入淡出 - 时间太长

```
String ffmpegStr = "-i /storage/emulated/0/DCIM/Camera/input.mp4 -filter_complex color=black@0:100x100,format=yuva444p[c];[c][0]scale2ref[ct][mv0];" +
                "[ct]setsar=1,split=" +
                "4" +
                "[t1][t2][t3][t4];" +
                "[t1]drawtext=fontfile=/storage/emulated/0/f2/font/font_black_zk.ttf:shadowcolor=0x500000:shadowx=0:shadowy=1:x=(w-tw)/2:y=3*(h-th)/4:text='\\$30,000.0':fontsize=40:fontcolor=white,fade=t=in:st=1:d=1:alpha=1,fade=t=out:st=3:d=1:alpha=1[txta1];" +
                "[t2]drawtext=fontfile=/storage/emulated/0/f2/font/font_black_zk.ttf:shadowcolor=0x500000:shadowx=0:shadowy=1:x=(w-tw)/2:y=3*(h-th)/4:text='\\$30,000.0':fontsize=40:fontcolor=white,fade=t=in:st=5:d=1:alpha=1,fade=t=out:st=7:d=1:alpha=1[txta2];" +
                "[t3]drawtext=fontfile=/storage/emulated/0/f2/font/font_black_zk.ttf:shadowcolor=0x500000:shadowx=0:shadowy=1:x=(w-tw)/2:y=3*(h-th)/4:text='\\$30,000.0':fontsize=40:fontcolor=white,fade=t=in:st=9:d=1:alpha=1,fade=t=out:st=11:d=1:alpha=1[txta3];" +
                "[t4]drawtext=fontfile=/storage/emulated/0/f2/font/font_black_zk.ttf:shadowcolor=0x500000:shadowx=0:shadowy=1:x=(w-tw)/2:y=3*(h-th)/4:text='\\$30,000.0':fontsize=40:fontcolor=white,fade=t=in:st=13:d=1:alpha=1,fade=t=out:st=14:d=1:alpha=1[txta4];" +
                "[mv0][txta1]overlay=shortest=1[mv1];" +
                "[mv1][txta2]overlay=shortest=1[mv2];" +
                "[mv2][txta3]overlay=shortest=1[mv3];" +
                "[mv3][txta4]overlay=shortest=1" +
                " -y /storage/emulated/0/DCIM/Camera/output.mp4";
```
