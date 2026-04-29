#!/system/bin/sh
if [ "$API" -lt 26 ]; then
    abort "Android 8.0 or higher required!"
fi
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "WSAudioFix"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print ""
ui_print "- Device: $(getprop ro.product.model)"
ui_print "- Android: $(getprop ro.build.version.release)"
ui_print "- Module path: $MODPATH"
ui_print ""
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
ui_print "- Initialization completed!"
ui_print ""
sed -i '/description/d' $MODPATH/module.prop
echo "description=Status: Installed ✅\\\\nPrevents audio bridge standby to eliminate 500 ms session lag on resume." >> $MODPATH/module.prop
