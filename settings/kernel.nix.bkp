{ pkgs, ... }:
{
  # MT7922 BT init regression: mainline commit 33634e2ab7c6 removed the
  # subsystem reset before fw download. Backported to linux >= 7.0.7,
  # >= 6.18.30, and >= 6.12.x (via 12abefb8c821, 2025-03-15). The 6.6 LTS
  # line on nixos-unstable does not carry this backport. Drop this pin once
  # nixpkgs' linux_7_0 includes the revert (Arch shipped it in 7.0.8.arch1).
  eiros.system.boot.kernel.package = pkgs.linuxPackages_6_6;
}
