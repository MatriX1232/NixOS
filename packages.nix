{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Dev
    zed-editor
    nil
    nixpkgs-fmt
    direnv
    nix-tree
    nix-direnv
    git
    gh
    zsh-autosuggestions
    zsh-syntax-highlighting

    # Gaming & Graphics
    protonup-qt
    mangohud
    vulkan-tools
    libva-utils
    mesa-demos

    # System
    asusctl
    supergfxctl
    nvtopPackages.full
    btop
    intel-gpu-tools
    ananicy-rules-cachyos
    ananicy-cpp

    # GNOME Extensions
    gnome-extension-manager
    gnomeExtensions.blur-my-shell
    gnomeExtensions.gpu-supergfxctl-switch
    gnomeExtensions.in-picture
    gnomeExtensions.perf-switcher-asusctl
    gnomeExtensions.vitals

    # Other
    eza
    fastfetch
    gparted-full
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

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    # extraArgs = "-forcedesktopscaling 1.25";
  };

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    ZED_WAYLAND = "1";

    # 3. Help with blurriness in some GTK apps
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
}
