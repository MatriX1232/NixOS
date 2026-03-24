{
  config,
  pkgs,
  self,
  ...
}:

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
    python314
    dotnetCorePackages.sdk_10_0-bin
    uv
    docker
    clang-tools
    ollama-cuda
    lmstudio
    ghostty

    # CUDA
    cudaPackages.cudnn
    cudaPackages.cuda_nvcc

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
    tailscale

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
    aonsoku
    jellyfin-desktop
    bitwarden-desktop
    sony-headphones-client
  ];

  services.tailscale.enable = true;

  programs.rog-control-center.enable = true;
  programs.gamescope.enable = true;

  programs.gamemode = {
    enable = true;
    settings = {
      custom = {
        start = "${pkgs.asusctl}/bin/asusctl profile -n Performance";
        end = "${pkgs.asusctl}/bin/asusctl profile -n Balanced";
      };
    };
  };

  programs.firefox = {
    enable = true;
    preferences = {
      # Basic VA-API
      "media.ffmpeg.vaapi.enabled" = true;
      "media.rdd-ffmpeg.enabled" = true;

      # FORCE Hardware, Disable Software fallbacks
      "media.hardware-video-decoding.force-enabled" = true;
      "media.ffvpx.enabled" = false;

      # Sandbox fix for Intel 12/13th Gen
      "security.sandbox.content.level" = 2;

      # Wayland Performance
      "widget.dmabuf.force-enabled" = true;
      "widget.wayland.fractional-scale-enabled" = true;
    };
  };

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

    PROTON_ENABLE_NVAPI = "1";
    NV_PRIME_RENDER_OFFLOAD = "1";
  };
}
