{ config, pkgs, ... }:

{
  users.users.msolinsk = {
    isNormalUser = true;
    description = "Mateusz Soliński";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    shell = pkgs.zsh;
  };

  # This tells NixOS to install Zsh infrastructure system-wide
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.root.shell = pkgs.zsh;

  security.pki.certificateFiles = [ ./rootCA.crt ];
}
