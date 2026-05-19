{ ... }:
{
  # MT7922 BT init race: btusb tries the WMT handshake before mt7921e
  # finishes initializing the chip's shared Wi-Fi/BT firmware, producing
  # "Failed to send wmt func ctrl (-22)" and a wedged hci0 with BD address
  # 00:00:00:00:00:00. softdep forces mt7921e to load first.
  boot.extraModprobeConfig = ''
    softdep btusb pre: mt7921e
    options btusb enable_autosuspend=0
  '';

  boot.kernelParams = [ "btusb.enable_autosuspend=0" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", ATTR{power/control}="on", ATTR{power/autosuspend_delay_ms}="-1"
  '';
}
