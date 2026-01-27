{ config, lib, ... }:
{
  config.eiros.users.lcleveland.mangowc.settings.monitorrule = [
    "eDP-1,normal,1,1920,1080,2560,1600,165"
    "DP-10,normal,1,0,1080,1920,1080,60"
    "DP-11,flipped-180,1,0,0,1920,1080,60"
  ];
}
