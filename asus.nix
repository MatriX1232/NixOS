{ config, pkgs, ... }:

{
  services.asusd.enable = true;
  services.supergfxd.enable = true;

  # Battery Health: Limit charge to 80% (save battery life at home)
  # You can change this to 60 or 100 using asusctl anytime
  systemd.services.asusd-battery-limit = {
    description = "Set Asus battery charge limit";
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.asusctl}/bin/asusctl -c 80";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Power Management: GNOME works best with power-profiles-daemon
  services.power-profiles-daemon.enable = true;
}
