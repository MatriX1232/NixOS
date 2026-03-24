{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./asus.nix
    ./packages.nix
    ./users.nix
    ./storage.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "kernel.split_lock_mitigate" = 0;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
  };

  services.scx = {
    enable = true;
    scheduler = "scx_bpfland";
    extraArgs = [ "-m all" ];
  };

  services.ananicy.enable = true;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;
  zramSwap.algorithm = "zstd";

  nix.settings = {
    substituters = [
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  # Networking
  networking.hostName = "msolinsk";
  networking.networkmanager.enable = true;

  # Locales
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Desktop Environment
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverridePackages = [ pkgs.mutter ];
    extraGSettingsOverrides = ''
      [org.gnome.mutter]
      experimental-features=['scale-monitor-framebuffer', 'variable-refresh-rate', 'xwayland-native-scaling']
    '';
  };
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  console.keyMap = "pl2";

  # Sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
    ];
    fontconfig = {
      antialias = true;
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      hinting = {
        enable = true;
        style = "slight"; # 'slight' is best for high-DPI screens
      };
    };
  };

  # Modern Nix Features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.11";
}
