{ pkgs, lib, ... }:
{
  # MT7922 Bluetooth fails to init on upstream Linux >= 7.0.7 (and >= 6.18.30
  # LTS) with "Failed to send wmt func ctrl (-22)" because mainline commit
  # 33634e2ab7c6 ("Bluetooth: btmtk: Remove the resetting step before
  # downloading the fw") removed the chip subsystem reset that MT7922 needs.
  # Arch shipped a revert in 7.0.8.arch1; NixOS hasn't picked it up yet.
  # We apply the revert here until upstream stable backports it.
  boot.kernelPatches = [
    {
      name = "btmtk-revert-remove-resetting-step";
      patch = ./patches/btmtk-revert-remove-resetting-step.patch;
    }
  ];

  # Keep the load-ordering + autosuspend safety nets from 6e18a5b.
  # softdep verified to work; harmless to keep alongside the patch.
  boot.extraModprobeConfig = ''
    softdep btusb pre: mt7921e
    options btusb enable_autosuspend=0
  '';

  boot.kernelParams = [ "btusb.enable_autosuspend=0" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", ATTR{power/control}="on", ATTR{power/autosuspend_delay_ms}="-1"
  '';
}
