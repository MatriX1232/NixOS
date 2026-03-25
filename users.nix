{ config, pkgs, ... }:

{
  users.users.msolinsk = {
    isNormalUser = true;
    description = "Mateusz Soliński";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "input"
      "libvirtd"
      "kvm"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.root.shell = pkgs.zsh;

  security.pki.certificateFiles = [ ./rootCA.crt ];
}
