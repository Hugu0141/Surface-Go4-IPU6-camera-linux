#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/00-preflight"
mkdir -p "${OUT_DIR}"

run() {
    local name="$1"
    shift
    {
        echo "# command"
        printf '%q ' "$@"
        echo
        echo
        "$@"
        local rc=$?
        echo
        echo "# exit_code=${rc}"
        return ${rc}
    } >"${OUT_DIR}/${name}.txt" 2>&1 || true
}

run_shell() {
    local name="$1"
    local cmd="$2"
    {
        echo "# command"
        echo "$cmd"
        echo
        bash -lc "$cmd"
        local rc=$?
        echo
        echo "# exit_code=${rc}"
        return ${rc}
    } >"${OUT_DIR}/${name}.txt" 2>&1 || true
}

{
    echo "collected_at=$(date --iso-8601=seconds 2>/dev/null || date)"
    echo "hostname=$(hostname 2>/dev/null || true)"
    echo "user=$(id -un 2>/dev/null || true)"
    echo "uid=$(id -u 2>/dev/null || true)"
} >"${OUT_DIR}/00-metadata.txt"

run "01-uname" uname -a
run_shell "02-os-release" 'cat /etc/os-release 2>/dev/null || true'
run_shell "03-kernel-cmdline" 'cat /proc/cmdline 2>/dev/null || true'
run_shell "04-secure-boot" 'command -v mokutil >/dev/null && mokutil --sb-state || echo "mokutil not installed"'
run_shell "05-lspci-ipu" 'lspci -nnk | grep -iA6 -B3 -E "(Imaging|IPU6|8086:462e)" || true'
run_shell "06-lsmod-camera" 'lsmod | grep -E "^(ov5693|ipu_bridge|intel_ipu6|intel_ipu6_isys)" || true'

for mod in ov5693 ipu_bridge intel_ipu6 intel_ipu6_isys; do
    run_shell "07-modinfo-${mod}" "modinfo ${mod} 2>&1 || true"
done

run_shell "08-v4l2-devices" 'command -v v4l2-ctl >/dev/null && v4l2-ctl --list-devices || echo "v4l2-ctl not installed"'
run_shell "09-media-devices" 'ls -l /dev/media* /dev/video* /dev/v4l-subdev* 2>/dev/null || true'
run_shell "10-media-topology" 'if command -v media-ctl >/dev/null; then for d in /dev/media*; do [ -e "$d" ] || continue; echo "===== $d ====="; media-ctl -d "$d" -p 2>&1; echo; done; else echo "media-ctl not installed"; fi'
run_shell "11-cam-list" 'command -v cam >/dev/null && cam -l || echo "cam not installed"'
run_shell "12-subdev-list" 'for d in /dev/v4l-subdev*; do [ -e "$d" ] || continue; echo "===== $d ====="; v4l2-ctl -d "$d" --all 2>&1 | head -n 120; echo; done'
run_shell "13-acpi-camera-paths" 'find /sys/bus/acpi/devices -maxdepth 2 -type f \( -name hid -o -name path \) -print0 2>/dev/null | xargs -0 -r grep -H -E "INT33BE|OV5693|CAMF" 2>/dev/null || true'
run_shell "14-i2c-camera" 'find /sys/bus/i2c/devices -maxdepth 2 -type f \( -name name -o -name modalias \) -print0 2>/dev/null | xargs -0 -r grep -H -i -E "ov5693|INT33BE" 2>/dev/null || true'

if [ "$(id -u)" -eq 0 ]; then
    run_shell "15-dmesg-camera" 'dmesg --color=never | grep -i -E "ov5693|ipu6|ipu-bridge|INT33BE|frame sync|fifo overflow" || true'
else
    run_shell "15-dmesg-camera" 'dmesg --color=never 2>&1 | grep -i -E "ov5693|ipu6|ipu-bridge|INT33BE|frame sync|fifo overflow" || true'
fi

run_shell "16-tool-versions" 'for c in cam libcamera-hello v4l2-ctl media-ctl git gcc make; do if command -v "$c" >/dev/null; then echo "===== $c ====="; "$c" --version 2>&1 | head -n 5 || true; fi; done'

cat >"${OUT_DIR}/README.txt" <<'EOF'
Preflight snapshot for the Surface Go 4 OV5693 2x2-binning / ADL-N test.

Run this collector before modifying the currently working camera stack.
For the most complete dmesg output, run it with sudo:

  sudo ./collect-preflight.sh

Review files before committing in case the local environment contains information you do not want to publish.
EOF

echo "Preflight evidence written to: ${OUT_DIR}"
echo "Review the files before committing them."
