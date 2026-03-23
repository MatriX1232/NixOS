{
  config,
  pkgs,
  lib,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------
  # BASE CONFIGURATION: HYBRID MODE (DEFAULT)
  # ---------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # iGPU HW Accel (iHD)
      intel-compute-runtime # OpenCL for Intel
      nvidia-vaapi-driver # dGPU HW Accel for offload
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    # Allows dGPU to sleep
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  environment.variables = {
    # Default to Intel for efficient video decoding in Hybrid
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
    MOZ_ENABLE_WAYLAND = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_SHADER_DISK_CACHE_SIZE = "10000000000";
  };

  # ---------------------------------------------------------
  # SPECIALISATIONS
  # ---------------------------------------------------------
  specialisation = {

    # --- PROFILE 1: INTEGRATED ONLY ---
    integrated-only.configuration = {
      system.nixos.tags = [ "integrated-only" ];

      # 1. Back to CachyOS Kernel (Better E-core management)
      # boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;

      # 2. Use 'scx_rustland' - The most efficient scheduler for Hybrid CPUs
      services.scx = {
        enable = lib.mkForce true;
        scheduler = lib.mkForce "scx_rustland";
      };

      services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
      services.ananicy.enable = lib.mkForce false;
      services.thermald.enable = true;
      powerManagement.powertop.enable = true;

      # 3. Deep Hardware States
      boot.kernelParams = [
        "i915.enable_guc=3"
        "i915.enable_fbc=1"
        "i915.enable_psr=1"
        "i915.enable_dc=4" # Deepest Display Sleep
        "intel_pstate=active" # Hardware-managed EPP
        "pcie_aspm.policy=powersave" # Stable PCIe saving
        "workqueue.power_efficient=Y" # Force power-efficient workqueues
      ];

      # 4. Physically unbind NVIDIA (The "Zero-Leak" Rule)
      # This ensures the kernel isn't even looking at the card.
      services.udev.extraRules = lib.mkForce ''
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{remove}="1"
      '';

      environment.variables = {
        LIBVA_DRIVER_NAME = lib.mkForce "iHD";
        GBM_BACKEND = lib.mkForce null;
        __GLX_VENDOR_LIBRARY_NAME = lib.mkForce null;
      };

      systemd.services.battery-optimizer = {
        description = "Deep Battery Optimization";
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          # 1. Asus Quiet Mode (Hard-caps CPU TDP to ~15-20W)
          ${pkgs.asusctl}/bin/asusctl profile -n Quiet

          # 2. Power Profiles Daemon to Power Saver
          ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver

          # 3. Force Intel Energy Preference to 'power'
          # This tells the CPU to stay on E-cores as much as possible
          echo "power" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference

          # 4. Turn off Bluetooth and Lights
          ${pkgs.bluez}/bin/bluetoothctl power off
          ${pkgs.asusctl}/bin/asusctl -k off
        '';
      };
    };

    # --- PROFILE 2: GAMING MUX (Max Performance) ---
    gaming-mux.configuration = {
      system.nixos.tags = [ "gaming-mux" ];

      hardware.nvidia = {
        # PREVENTS CRASHES when Intel is disconnected
        powerManagement.finegrained = lib.mkForce false;

        # Disable PRIME offloading (DIRECT dGPU)
        prime.offload.enable = lib.mkForce false;
        prime.offload.enableOffloadCmd = lib.mkForce false;
      };

      environment.variables = {
        # Force hardware video acceleration to use NVIDIA NVDEC
        LIBVA_DRIVER_NAME = lib.mkForce "nvidia";
        VDPAU_DRIVER = lib.mkForce "nvidia";
      };
    };

  };
}
