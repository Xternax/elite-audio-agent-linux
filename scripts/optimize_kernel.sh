# Elite Audio Agent - Kernel Optimization Script

set -e
echo "🔧 Optimizing kernel for pro audio..."
if [ "$EUID" -ne 0 ]; then
    echo "❌ Run as root"
    exit 1
fi

if ! grep -q "threadirqs" /proc/cmdline; then
    echo "⚡ Enabling threadirqs in GRUB..."
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="threadirqs /g' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
fi

sysctl vm.swappiness=10
echo "vm.swappiness=10" >> /etc/sysctl.d/99-audio.conf
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance > $cpu
done

cat > /etc/systemd/system/cpu-governor-performance.service <<EOF
[Unit]
Description=Set CPU Governor to Performance

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'

[Install]
WantedBy=multi-user.target
EOF

systemctl enable cpu-governor-performance.service
echo 2048 > /sys/class/rtc/rtc0/max_user_freq
echo "echo 2048 > /sys/class/rtc/rtc0/max_user_freq" >> /etc/rc.local

if ! grep -q "mitigations=off" /proc/cmdline; then
    echo "🚀 Disabling CPU mitigations..."
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="mitigations=off /g' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "✅ Kernel optimization completed!"
