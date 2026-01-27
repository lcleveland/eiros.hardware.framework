{ config, lib, ... }:
{
  config.eiros.users.lcleveland.mangowc.settings.monitorrule = [
    "name:eDP-1,rr:0,scale:1,x:1920,y:1080,width:2560,height:1600,refresh:165,vrr:0"
    "name:DP-10,rr:0,scale:1,x:0,y:1080,width:1920,height:1080,refresh:60,vrr:0"
    "name:DP-11,rr:2,scale:1,x:0,y:0,width:1920,height:1080,refresh:60,vrr:0"
  ];
}
