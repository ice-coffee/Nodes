`monkey` 是 `Android` 提供的一个命令行工具，用于对应用程序进行压力测试和调试。它生成伪随机的用户事件，以模拟用户与设备或应用程序的交互。以下是 `monkey` 命令中各个参数的详细解释：

1. -p ALLOWED_PACKAGE: 指定 Monkey 工具应该针对的包名。如果指定多个 -p 选项，工具将考虑所有指定的包。
2. -c MAIN_CATEGORY: 指定 Monkey 工具应该针对的主要活动类别。如果指定多个 -c 选项，工具将考虑所有指定的活动类别。
3. --ignore-crashes: 忽略应用程序崩溃，继续执行 Monkey 测试。
4. --ignore-timeouts: 忽略超时，继续执行 Monkey 测试。
5. --ignore-security-exceptions: 忽略安全异常，继续执行 Monkey 测试。
6. --monitor-native-crashes: 监视并报告本机代码崩溃。
7. --ignore-native-crashes: 忽略本机代码崩溃，继续执行 Monkey 测试。
8. --kill-process-after-error: 在发生错误后终止相关进程。
9. --hprof: 生成 HPROF 文件，用于分析堆内存使用情况。
10. --match-description TEXT: 通过包含指定文本的活动描述来限制 Monkey 事件。
11. --pct-touch PERCENT: 触摸事件的百分比。
12. --pct-motion PERCENT: 移动手势事件的百分比。
13. --pct-trackball PERCENT: 轨迹球事件的百分比。
14. --pct-syskeys PERCENT: 系统按键事件的百分比。
15. --pct-nav PERCENT: 导航事件的百分比。
16. --pct-majornav PERCENT: 主要导航事件的百分比。
17. --pct-appswitch PERCENT: 应用程序切换事件的百分比。
18. --pct-flip PERCENT: 翻转事件的百分比。
19. --pct-anyevent PERCENT: 任意事件的百分比。
20. --pct-pinchzoom PERCENT: 缩放事件的百分比。
21. --pct-permission PERCENT: 权限操作事件的百分比。
22. --pkg-blacklist-file PACKAGE_BLACKLIST_FILE: 指定包名黑名单文件。
23. --pkg-whitelist-file PACKAGE_WHITELIST_FILE: 指定包名白名单文件。
24. --wait-dbg: 在调试器附加时等待。
25. --dbg-no-events: 不生成调试事件。
26. --setup scriptfile: 指定初始化脚本文件。
27. -f scriptfile: 指定执行脚本文件，可以指定多个。
28. --port port: 指定与 Monkey Agent 通信的端口号。
29. -s SEED: 指定随机数生成器的种子。
30. -v: 增加详细程度，可以多次使用增加详细级别。
31. --throttle MILLISEC: 设置事件之间的延迟时间（毫秒）。
32. --randomize-throttle: 随机化事件之间的延迟时间。
33. --profile-wait MILLISEC: 设置开始 Monkey 之前的等待时间（毫秒）。
34. --device-sleep-time MILLISEC: 设置设备休眠时间（毫秒）。
35. --randomize-script: 随机化脚本执行顺序。
36. --script-log: 将脚本执行输出记录到日志文件。
37. --bugreport: 在测试结束时生成 bug 报告。
38. --periodic-bugreport: 定期生成 bug 报告。
39. --permission-target-system: 将权限事件目标定为系统应用。
40. COUNT: 指定执行 Monkey 事件的总数。

`-p` 和 `--pkg-whitelist-file` 的功能很相似

`Monkey` 示例：
```shell
#!/bin/bash
adb shell am force-stop <包名>
adb shell kill -9 `adb shell pidof com.android.commands.monkey`
sleep 1
echo "<包名>" > whitelist.txt
adb push whitelist.txt /sdcard/
rm -f whitelist.txt
freq=$1
if [ "$freq" == "" ]; then
	freq=200
fi
echo "monkey freq=${freq}"

adb shell monkey -v -v -v -s 1000 --pkg-whitelist-file /sdcard/whitelist.txt --ignore-timeouts --ignore-security-exceptions --kill-process-after-error --pct-touch 100 --pct-trackball 0 --pct-nav 0 --pct-anyevent 0 --pct-motion 0 --pct-flip 0 --pct-pinchzoom 0 --pct-syskeys 0 --throttle ${freq} 1000000000
```

关闭 monkey
adb shell ps | grep monkey
adb shell kill 34567
