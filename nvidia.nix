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

      # Strip NVIDIA from drivers
      services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
      hardware.nvidia.prime.offload.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce false;

      # Blacklist NVIDIA modules to guarantee absolute 0W power draw
      boot.blacklistedKernelModules = [
        "nouveau"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
      ];

      environment.variables = {
        # HW accel for Intel
        LIBVA_DRIVER_NAME = lib.mkForce "iHD";

        # Unset NVIDIA-specific Wayland variables so Mutter falls back to Intel naturally
        GBM_BACKEND = lib.mkForce null;
        __GLX_VENDOR_LIBRARY_NAME = lib.mkForce null;
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
