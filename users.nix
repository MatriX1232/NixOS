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
  };

  # programs.bash.shellAliases = {
  #   zed = "zeditor";
  #   nixconf = "sudo ZED_ALLOW_ROOT=true zeditor /etc/nixos/";
  #   rebuild = "sudo nixos-rebuild switch";
  #   checkgpu = "nvidia-smi";
  # };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
      ];
      theme = "half-life";
    };

    shellAliases = {
      cls = "clear";
      ls = "eza --icons";
      rebuild = "sudo nixos-rebuild switch";
      nixconf = "sudo ZED_ALLOW_ROOT=true zeditor /etc/nixos/";
    };
  };

  users.defaultUserShell = pkgs.zsh;

  security.pki.certificateFiles = [ ./rootCA.crt ];
}
