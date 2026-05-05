{ lib, ... }:
{
  config.eiros.system.nix.sources.hardware.url =
    lib.mkForce "github:lcleveland/eiros.hardware.framework";
}
