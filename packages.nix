{
  config,
  pkgs,
  self,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # Dev
    vim
    zed-editor
    vscode
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
    gnumake
    mlx42
    llvmPackages.libcxxClang
    ollama-cuda
    lmstudio
    ghostty

    # --- CUDA DEVELOPMENT TOOLS ---
    # cudaPackages.cuda_nvcc # CUDA Compiler
    # cudaPackages.cuda_cudart # CUDA Runtime
    # cudaPackages.libcublas # Basic Linear Algebra (Required by Torch)
    # cudaPackages.libcufft # Fast Fourier Transforms
    # cudaPackages.libcurand # Random Number Generation
    # cudaPackages.libcusolver # Linear Solvers
    # cudaPackages.libcusparse # Sparse Matrices
    # cudaPackages.cudnn # Deep Neural Network Library (Required by Torch/TF)
    # cudaPackages.tensorrt # High-performance Inference

    # Gaming & Graphics
    protonup-qt
    umu-launcher
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
    pciutils
    zenity

    # GNOME Extensions
    gnome-extension-manager
    gnomeExtensions.blur-my-shell
    gnomeExtensions.gpu-supergfxctl-switch
    gnomeExtensions.in-picture
    gnomeExtensions.perf-switcher-asusctl
    gnomeExtensions.vitals
    gnomeExtensions.just-perfection
    # gnomeExtensions.power-off-options

    # Other
    eza
    fastfetch
    gparted-full
    aonsoku
    jellyfin-desktop
    bitwarden-desktop
    sony-headphones-client
    localsend
    heroic
    slack
    prismlauncher
  ];

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

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
      # "widget.dmabuf.force-enabled" = true;
      "widget.wayland.fractional-scale-enabled" = true;
    };
  };

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
    # extraArgs = "-forcedesktopscaling 1.25";
  };

  # programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  #   stdenv.cc.cc
  #   zlib
  #   fuse3
  #   icu
  #   nss
  #   openssl
  #   curl
  #   expat

  #   # CUDA libraries for nix-ld to expose to Python
  #   cudaPackages.cuda_cudart
  #   cudaPackages.libcublas
  #   cudaPackages.libcufft
  #   cudaPackages.libcurand
  #   cudaPackages.libcusolver
  #   cudaPackages.libcusparse
  #   cudaPackages.cudnn
  #   linuxPackages.nvidia_x11
  #   libGL
  #   glib
  # ];

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    ZED_WAYLAND = "1";

    # 3. Help with blurriness in some GTK apps
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";

    GTK_USE_PORTAL = "1";

    PROTON_ENABLE_NVAPI = "1";
    NV_PRIME_RENDER_OFFLOAD = "1";
  };
}
