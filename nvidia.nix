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
      nv-codec-headers-12
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

      # 2. Most efficient scheduler for Hybrid CPUs
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

      boot.kernelParams = [
        "nvidia-drm.modeset=1"
        # "nvidia-drm.fbdev=1" # MUST be 1 for GNOME HDR
        "nvidia_drm.fbdev=1" # Helps with G-Sync stability and smooth boot
        "NV_REG_ENABLE_USERSPACE_MODESET=1"
        "nvidia_drm.vrr_enabled=1"
      ];

      hardware.nvidia = {
        # PREVENTS CRASHES when Intel is disconnected
        powerManagement.finegrained = lib.mkForce false;

        # for the 100/120W boost
        dynamicBoost.enable = true;

        # Disable PRIME offloading (DIRECT dGPU)
        prime.offload.enable = lib.mkForce false;
        prime.offload.enableOffloadCmd = lib.mkForce false;
      };

      services.power-profiles-daemon.enable = true;

      hardware.graphics.extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libvdpau-va-gl
        nv-codec-headers-12 # Helpful for some video tasks
      ];

      environment.variables = {
        __GL_SYNC_TO_VBLANK = "1";
        __GL_SHADER_DISK_CACHE_SIZE = "10000000000";
        # Force hardware video acceleration to use NVIDIA NVDEC
        LIBVA_DRIVER_NAME = lib.mkForce "nvidia";
        VDPAU_DRIVER = lib.mkForce "nvidia";
        VKD3D_CONFIG = "dxr11,force_vendor_id=0x10de";
      };
    };

    # --- PROFILE 3: WINDOWS VM (VFIO GPU Passthrough) ---
    windows-vm.configuration = {
      system.nixos.tags = [ "VFIO" ];

      # Ensure TPM certificate directory exists with correct permissions
      systemd.tmpfiles.rules = [ "d /var/lib/swtpm-localca 0750 tss tss -" ];

      # 1. Disable standard NVIDIA drivers so VFIO can claim the card
      services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
      hardware.nvidia.open = lib.mkForce false;
      hardware.nvidia.prime.offload.enable = lib.mkForce false;

      # 2. Isolate the GPU via Kernel Parameters
      boot.kernelParams = [
        "intel_iommu=on"
        "iommu=pt"
        # lspci -nn
        "vfio-pci.ids=10de:2860,10de:22bd"

        # --- CPU Isolation for P-Cores ---
        "isolcpus=0-11" # Hide P-Cores from the host scheduler
        "nohz_full=0-11" # Disable the scheduling-clock tick on P-Cores
        "rcu_nocbs=0-11" # Move RCU callbacks to the E-Cores
      ];

      # 3. Load VFIO modules early in the boot process
      boot.initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];

      # 4. Enable Virtualization and Windows 11 Requirements (TPM 2.0 & UEFI)
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true; # Temporary measure to bypass permission loops
          swtpm.enable = true; # Critical for Windows 11
          verbatimConfig = ''
            user = "msolinsk"
            group = "libvirtd"
            cgroup_device_acl = [
              "/dev/null", "/dev/full", "/dev/zero",
              "/dev/random", "/dev/urandom",
              "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
              "/dev/rtc","/dev/hpet",
              "/dev/input/by-path/pci-0000:00:15.0-platform-i2c_designware.0-event-mouse",
              "/dev/input/by-path/platform-i8042-serio-0-event-kbd",
              "/dev/input/by-path/pci-0000:00:14.0-usb-0:2.2:1.0-event-mouse",
              "/dev/input/by-path/pci-0000:00:14.0-usb-0:2.3:1.0-event-kbd"
            ]
          '';
        };
      };

      # 5. Add Virtualization Tools to this profile
      environment.systemPackages = with pkgs; [
        virt-manager
        virtio-win # Windows drivers for the VM
      ];

      # 6. Ensure your user can run the VM
      users.users.msolinsk.extraGroups = [
        "libvirtd"
        "kvm"
      ];
    };

  };
}
