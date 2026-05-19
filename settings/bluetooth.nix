{ pkgs, ... }:
let
  rebindScript = pkgs.writeShellScript "bluetooth-mtk-rebind" ''
    for i in $(seq 1 30); do
      [ -e /sys/class/bluetooth/hci0 ] && exit 0
      sleep 1
    done

    for dev in /sys/bus/usb/devices/*/; do
      vid=$(cat "$dev/idVendor" 2>/dev/null)
      [ "$vid" = "0e8d" ] || continue

      pid=$(cat "$dev/idProduct" 2>/dev/null)
      dev_name=$(basename "$dev")

      for intf in /sys/bus/usb/devices/$dev_name:*/; do
        [ -d "$intf" ] || continue
        intf_name=$(basename "$intf")
        [ -e /sys/bus/usb/drivers/btusb/$intf_name ] && \
          echo "$intf_name" > /sys/bus/usb/drivers/btusb/unbind 2>/dev/null
      done

      sleep 1
      echo "0e8d $pid" > /sys/bus/usb/drivers/btusb/new_id 2>/dev/null || true
      udevadm trigger --type=devices --action=add --sysname-match="$dev_name"
      sleep 2
      systemctl restart bluetooth
      break
    done
  '';
in
{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", ATTR{power/control}="on"
  '';

  systemd.services.bluetooth-mtk-rebind = {
    description = "Re-initialize MediaTek MT7922 Bluetooth after Wi-Fi firmware load";
    after = [ "bluetooth.service" ];
    wantedBy = [ "bluetooth.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = rebindScript;
    };
  };

  systemd.services.bluetooth-mtk-rebind-resume = {
    description = "Re-initialize MediaTek MT7922 Bluetooth after resume";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = rebindScript;
    };
  };
}
