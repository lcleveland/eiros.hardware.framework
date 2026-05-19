{
  description = "Hardware configuration for my Framework 16";
  outputs =
    { nixos_hardware, self, ... }@inputs:
    let
      import_modules = import ./resources/nix/import_modules.nix;
    in
    {
      inputs = inputs;
      nixosModules.default = {
        imports = [
          nixos_hardware.nixosModules.framework-16-7040-amd
          ./hardware-configuration.nix
        ]
        ++ (import_modules ./settings);
      };
    };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos_hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
