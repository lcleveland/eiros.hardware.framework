{ pkgs, ... }:
{
  systemd.services.bluetooth-mtk-rebind = {
    description = "Re-initialize MediaTek MT7922 Bluetooth after Wi-Fi firmware load";
    after = [ "bluetooth.service" ];
    wantedBy = [ "bluetooth.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "bluetooth-mtk-rebind" ''
        sleep 5
        [ -e /sys/class/bluetooth/hci0 ] && exit 0

        for dev in /sys/bus/usb/devices/*/; do
          vid=$(cat "$dev/idVendor" 2>/dev/null)
          pid=$(cat "$dev/idProduct" 2>/dev/null)
          [ "$vid" = "0e8d" ] && [ "$pid" = "e616" ] || continue

          dev_name=$(basename "$dev")

          for intf in /sys/bus/usb/devices/$dev_name:*/; do
            [ -d "$intf" ] || continue
            intf_name=$(basename "$intf")
            [ -e /sys/bus/usb/drivers/btusb/$intf_name ] && \
              echo "$intf_name" > /sys/bus/usb/drivers/btusb/unbind 2>/dev/null
          done

          sleep 1
          udevadm trigger --type=devices --action=add --sysname-match="$dev_name"
          break
        done
      '';
    };
  };
}
