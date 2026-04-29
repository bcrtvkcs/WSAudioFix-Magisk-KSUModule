#!/system/bin/sh
MODDIR="/data/adb/modules/WSAudioFix"

update_status() {
    local status_text="$1"
    local status_emoji="$2"
    local new_description="description=Status: $status_text $status_emoji\\\\nPrevents audio bridge standby to eliminate 500 ms session lag on resume."
    sed -i "s|^description=.*|$new_description|" "$MODDIR/module.prop"
    echo "WSAudioFix: $status_text" >> /dev/kmsg
}

update_status "Starting" "⏳"

echo "WSAudioFix: waiting for boot completion" >> /dev/kmsg
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 1
done
echo "WSAudioFix: boot completed" >> /dev/kmsg

sleep 5

update_status "Running" "⏳"

while true; do
    /system/bin/app_process \
        -Djava.class.path="$MODDIR/audio_keepalive.dex" \
        /system/bin \
        AudioKeepalive
    echo "WSAudioFix: process exited, restarting in 3s" >> /dev/kmsg
    sleep 3
done &

PID=$!
echo "WSAudioFix: keepalive started (pid $PID)" >> /dev/kmsg

sleep 5

if kill -0 $PID 2>/dev/null; then
    update_status "Active" "✅"
    echo "WSAudioFix: keepalive confirmed running" >> /dev/kmsg
else
    update_status "Failed" "❌"
    echo "WSAudioFix: keepalive failed to start" >> /dev/kmsg
fi
