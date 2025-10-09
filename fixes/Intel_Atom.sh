#!/usr/bin/bash env

echo "options rtl8723bs 11n_disable=1"  | tee /etc/modprobe.d/fix-wifi-Intel-Atom.conf
echo "blacklist snd_hdmi_lpe_audio"     | tee /etc/modprobe.d/fix-lpe-Intel-Atom.conf
echo "options snd_sof sof_debug=1"      | tee /etc/modprobe.d/fix-audio-Intel-Atom.conf

grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf || {
  (
    echo "net.ipv6.conf.all.disable_ipv6 = 1"
    echo "net.ipv6.conf.default.disable_ipv6 = 1"
    echo "net.ipv6.conf.lo.disable_ipv6 = 1"
    echo "net.ipv6.conf.tun0.disable_ipv6 = 1" 
  ) | tee -a /etc/sysctl.conf
}

echo 'amixer controls | grep "DMIC.*Enable"                    \
                      | cut -d= -f2                            \
                      | cut -d, -f1                            \
                      | sed "s|^|amixer cset numid=|;s|$| on|" \
                      | sh' | tee /etc/profile.d/fix-microphone-Intel-Atom.sh

chmod +x /etc/profile.d/fix-microphone-Intel-Atom.sh

echo '
[Unit]
Description=Fixes Alsa not working after suspend
After=suspend.target

[Service]
Type=oneshot
ExecStart=/sbin/alsa reload
StandardOutput=journal

[Install]
WantedBy=suspend.target
WantedBy=hibernate.target
WantedBy=sleep.target
' | tee /etc/systemd/system/fix-alsa-suspend.service
systemctl daemon-reload
systemctl enable fix-alsa-suspend.service

echo '
[Unit]
Description=Fixes Alsa not working at boot
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/sbin/alsa reload
StandardOutput=journal

[Install]
WantedBy=multi-user.target
' | tee /etc/systemd/system/fix-alsa-init.service
systemctl daemon-reload
systemctl enable fix-alsa-init.service



