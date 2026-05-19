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
      patch = builtins.toFile "btmtk-revert-remove-resetting-step.patch" ''
        --- a/drivers/bluetooth/btmtk.c
        +++ b/drivers/bluetooth/btmtk.c
        @@ -1330,6 +1330,13 @@ int btmtk_usb_setup(struct hci_dev *hdev)
         		break;
         	case 0x7922:
         	case 0x7925:
        +		/* Reset the device to ensure it's in the initial state before
        +		 * downloading the firmware to ensure.
        +		 */
        +
        +		if (!test_bit(BTMTK_FIRMWARE_LOADED, &btmtk_data->flags))
        +			btmtk_usb_subsys_reset(hdev, dev_id);
        +		fallthrough;
         	case 0x7961:
         		btmtk_fw_get_filename(fw_bin_name, sizeof(fw_bin_name), dev_id,
         				      fw_version, fw_flavor);
        @@ -1338,9 +1345,12 @@ int btmtk_usb_setup(struct hci_dev *hdev)
         						btmtk_usb_hci_wmt_sync);
         		if (err < 0) {
         			bt_dev_err(hdev, "Failed to set up firmware (%d)", err);
        +			clear_bit(BTMTK_FIRMWARE_LOADED, &btmtk_data->flags);
         			return err;
         		}

        +		set_bit(BTMTK_FIRMWARE_LOADED, &btmtk_data->flags);
        +
         		/* It's Device EndPoint Reset Option Register */
         		err = btmtk_usb_uhw_reg_write(hdev, MTK_EP_RST_OPT,
         					      MTK_EP_RST_IN_OUT_OPT);
      '';
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
