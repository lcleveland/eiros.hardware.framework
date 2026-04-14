{ config, lib, ... }:
{
  config = {
    eiros.system.hardware.fingerprint_scanner.enable = lib.mkDefault true;
  };
}
