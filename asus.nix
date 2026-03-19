{ config, pkgs, ... }:

{
  services.asusd.enable = true;
  services.supergfxd.enable = true;

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
