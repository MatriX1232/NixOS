{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Dev
    zed-editor
    nil
    nixpkgs-fmt
    direnv # Essential for "mobile dev" (per-project environments)
    nix-direnv
    git
    gh
    zsh-autosuggestions
    zsh-syntax-highlighting

    # Gaming & Graphics
    protonup-qt # Easy way to install GE-Proton for Steam
    mangohud # Performance overlay
    vulkan-tools
    libva-utils # run 'vainfo' to check acceleration
    mesa-demos

    # System
    asusctl
    supergfxctl
    nvtopPackages.full
    btop

    # Other
    jetbrains-mono
    eza
  ];

  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enable" = true;
      "media.rdd-ffmpeg.enabled" = true;
      "widget.wayland.fractional-scale-enabled" = true; # Smooth scaling on the G16 screen
    };
  };

  programs.rog-control-center.enable = true;

  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
