{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # i7-13620H iGPU
      nvidia-vaapi-driver # dGPU acceleration
      intel-compute-runtime # OpenCL for Intel
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Essential environment variables for Nvidia + Wayland + VA-API
  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD"; # Default to Intel for efficiency
    VDPAU_DRIVER = "va_gl";
    MOZ_ENABLE_WAYLAND = "1";
    # Force Nvidia to use Wayland-friendly buffers
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_SHADER_DISK_CACHE_SIZE = "10000000000";
  };
}
