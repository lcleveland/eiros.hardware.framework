{ ... }:
{
  # MT7922 BT kernel-side fix lives in ./kernel.nix (pins to a kernel line
  # without the btmtk regression). The settings below are independent
  # load-ordering and autosuspend safety nets (commits 6e18a5b, ebaf5e8).
  boot.extraModprobeConfig = ''
    softdep btusb pre: mt7921e
    options btusb enable_autosuspend=0
  '';

  boot.kernelParams = [ "btusb.enable_autosuspend=0" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", ATTR{power/control}="on", ATTR{power/autosuspend_delay_ms}="-1"
  '';
}
