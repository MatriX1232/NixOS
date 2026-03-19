{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Dev
    zed-editor
    nil
    nixpkgs-fmt
    direnv # Essential for "mobile dev" (per-project environments)
    nix-tree
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
    intel-gpu-tools

    # Other
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
    # extraArgs = "-forcedesktopscaling 1.25";
  };

  environment.variables = {
    # 1. Force Electron/Chromium apps to use Wayland
    NIXOS_OZONE_WL = "1";

    # 2. Tell Zed to specifically use Wayland
    ZED_WAYLAND = "1";

    # 3. Help with blurriness in some GTK apps
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
}
