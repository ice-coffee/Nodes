#!/bin/bash
# Android Studio / Gradle 编译期内存采样器
# 用法: ./monitor_as_mem.sh <输出csv> [采样间隔秒] [最长运行秒]
OUT="${1:-./as_build.csv}"
INTERVAL="${2:-20}"
MAXSEC="${3:-7200}"
JCMD="/Users/miaozepeng/Library/Java/jdk-11.0.21.jdk/Contents/Home/bin/jcmd"
PAGE=16384

echo "time,as_rss_mb,as_foot_mb,gradle_pid,gradle_rss_mb,gradle_foot_mb,gradle_heap_used_mb,gradle_heap_total_mb,gradle_cpu_pct,kotlin_pid,kotlin_foot_mb,sys_free_mb,compressor_gb,swap_used_mb,load1" > "$OUT"

fp() { footprint "$1" 2>/dev/null | awk '/phys_footprint:/ {print $2; exit}'; }
rss() { ps -o rss= -p "$1" 2>/dev/null | tr -d ' '; }

end=$((SECONDS + MAXSEC))
while [ $SECONDS -lt $end ]; do
  as_pid=$(pgrep -f "MacOS/studio" | head -1)
  g_pid=$(pgrep -f "org.gradle.launcher.daemon.bootstrap.GradleDaemon" | head -1)
  k_pid=$(pgrep -f "KotlinCompileDaemon" | head -1)

  as_r=$(rss "$as_pid"); as_f=$(fp "$as_pid")
  g_r=$(rss "$g_pid"); g_f=$(fp "$g_pid")
  g_cpu=$(ps -o %cpu= -p "$g_pid" 2>/dev/null | tr -d ' ')
  g_used=""; g_total=""
  if [ -n "$g_pid" ]; then
    read -r g_total g_used <<< "$("$JCMD" "$g_pid" GC.heap_info 2>/dev/null | awk '/garbage-first heap/ {gsub(/K,/,"",$4); gsub(/K,/,"",$6); print int($4/1024), int($6/1024)}')"
  fi
  k_pid_v=$(rss "$k_pid"); k_f=$(fp "$k_pid")

  vm_stat_out=$(vm_stat)
  free_pages=$(echo "$vm_stat_out" | awk '/Pages free/ {gsub(/\./,"",$3); print $3}')
  comp_pages=$(echo "$vm_stat_out" | awk '/occupied by compressor/ {gsub(/\./,"",$5); print $5}')
  swap_used=$(sysctl -n vm.swapusage | sed -E 's/.*used = ([0-9.]+)M.*/\1/')
  load1=$(sysctl -n vm.loadavg | awk '{print $2}')

  awk -v t="$(date +%H:%M:%S)" -v asr="${as_r:-0}" -v asf="${as_f:-0}" \
      -v gp="${g_pid:-NA}" -v gr="${g_r:-0}" -v gf="${g_f:-0}" \
      -v gu="${g_used:-0}" -v gt="${g_total:-0}" -v gc="${g_cpu:-0}" \
      -v kp="${k_pid:-NA}" -v kf="${k_f:-0}" \
      -v fr="${free_pages:-0}" -v cp="${comp_pages:-0}" -v sw="${swap_used:-0}" -v ld="${load1:-0}" \
      -v ps="$PAGE" 'BEGIN{printf "%s,%.0f,%.0f,%s,%.0f,%.0f,%s,%s,%s,%s,%.0f,%.0f,%.2f,%.0f,%s\n", t, asr/1024, asf, gp, gr/1024, gf, gu, gt, gc, kp, kf, fr*ps/1048576, cp*ps/1073741824, sw, ld}' >> "$OUT"

  sleep "$INTERVAL"
done
