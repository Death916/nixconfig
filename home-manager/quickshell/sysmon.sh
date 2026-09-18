#!/usr/bin/env bash
# Omadeck system monitor metrics source.
#
# Prints one space separated line per second (consumed by SysMonitor.qml):
#   cpuPercent memPercent gpuPercent cpuTempC gpuTempC load1 memUsedGiB memTotalGiB
#
# Missing sensors are reported as -1 so the field count never shifts.
# hwmon numbering is not stable across boots, so sensors are resolved by driver
# name instead of a hardcoded hwmon index.

set -u

# Resolve a hwmon directory by its driver name (k10temp, amdgpu, ...).
hwmon_dir() {
  local driver=$1 dir
  for dir in /sys/class/hwmon/hwmon*; do
    [ -r "$dir/name" ] || continue
    if [ "$(cat "$dir/name" 2>/dev/null)" = "$driver" ]; then
      printf '%s' "$dir"
      return 0
    fi
  done
  return 1
}

# First temperature of a driver, in whole degrees celsius.
temp_of() {
  local dir file
  dir=$(hwmon_dir "$1") || return 1
  for file in "$dir"/temp*_input; do
    [ -r "$file" ] || continue
    printf '%d' $(( $(cat "$file" 2>/dev/null) / 1000 ))
    return 0
  done
  return 1
}

# amdgpu load; only the amdgpu DRM node exposes this attribute.
gpu_busy_file=""
for f in /sys/class/drm/card*/device/gpu_busy_percent; do
  if [ -r "$f" ]; then
    gpu_busy_file=$f
    break
  fi
done

# "total idle" jiffies of the aggregate cpu line.
cpu_sample() {
  awk '/^cpu /{ total = 0; for (i = 2; i <= NF; i++) total += $i; print total, $5 + $6 }' /proc/stat
}

# "usedGiB totalGiB percent"
mem_sample() {
  awk '
    /^MemTotal:/     { total = $2 }
    /^MemAvailable:/ { avail = $2 }
    END {
      if (total > 0) {
        printf "%.1f %.1f %d", (total - avail) / 1048576, total / 1048576, 100 * (total - avail) / total
      } else {
        printf "0 0 0"
      }
    }' /proc/meminfo
}

prev=$(cpu_sample)
while :; do
  sleep 1
  cur=$(cpu_sample)
  read -r p_total p_idle <<<"$prev"
  read -r c_total c_idle <<<"$cur"

  total_delta=$((c_total - p_total))
  idle_delta=$((c_idle - p_idle))
  if [ "$total_delta" -gt 0 ]; then
    cpu=$(( (1000 * (total_delta - idle_delta) / total_delta + 5) / 10 ))
  else
    cpu=0
  fi
  prev=$cur

  read -r mem_used mem_total mem_pct <<<"$(mem_sample)"

  if [ -n "$gpu_busy_file" ]; then
    gpu=$(cat "$gpu_busy_file" 2>/dev/null)
  fi
  case "${gpu:-}" in
    ''|*[!0-9]*) gpu=-1 ;;
  esac

  cpu_temp=$(temp_of k10temp) || cpu_temp=-1
  gpu_temp=$(temp_of amdgpu) || gpu_temp=-1
  load=$(cut -d' ' -f1 /proc/loadavg)

  echo "$cpu $mem_pct $gpu $cpu_temp $gpu_temp $load $mem_used $mem_total"
done
