#!/system/bin/sh
# Kill the keepalive process
pkill -f AudioKeepalive 2>/dev/null
echo "WSAudioFix: module uninstalled, audio keepalive stopped" >> /dev/kmsg
