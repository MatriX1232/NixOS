{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ---------------------------------------------------------
  # 1. HARDWARE SECURITY (TPM2 & MICROCODE)
  # ---------------------------------------------------------
  hardware.cpu.intel.updateMicrocode = true;

  # Enable TPM2 support
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;

  # PREP FOR FRESH INSTALL:
  boot.initrd.systemd.enable = true;
  boot.initrd.kernelModules = [ "tpm_tis" ];
  boot.initrd.luks.devices."luks-788ea0fc-dc0b-435f-a061-0d4e725e07d5" = {
    device = "/dev/disk/by-uuid/788ea0fc-dc0b-435f-a061-0d4e725e07d5";
    preLVM = true;
    allowDiscards = true;
    # Needed for SSD TRIM performance
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  # ---------------------------------------------------------
  # 2. KERNEL HARDENING (Gaming Optimized)
  # ---------------------------------------------------------
  boot.kernelParams = [
    "slab_nomerge"
    "page_alloc.shuffle=1"
    "vsyscall=none"
  ];

  # Prevent unprivileged users from viewing the kernel log (dmesg)
  boot.kernel.sysctl."kernel.dmesg_restrict" = 1;
  # Hide kernel pointers from /proc/kallsyms
  boot.kernel.sysctl."kernel.kptr_restrict" = 1;

  # ---------------------------------------------------------
  # 3. NETWORK SECURITY (Firewall & Privacy)
  # ---------------------------------------------------------
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [
      # "tailscale0"
      "wg0"
    ];
    checkReversePath = "loose";
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPorts = [
      27036
      41641
      53317
      5500 # VSCode Live Webpage
    ];
    allowedTCPPorts = [
      53317
      5500 # VSCode Live Webpage
    ];
  };

  services.resolved = {
    enable = true;
    # W nowszych wersjach NixOS lepiej używać dedykowanych atrybutów zamiast surowego settings.
    # Używamy domen "~.", aby wymusić najwyższy priorytet routingu DNS.
    domains = [ "~." ];

    settings = {
      Resolve = {
        # WYŁĄCZAMY DoT. Lokalny AdGuard nie ma certyfikatu dla surowego IP.
        DNSOverTLS = "no";
        DNSSEC = "false";
      };
    };
  };

  # Ensure NetworkManager uses systemd-resolved
  networking.networkmanager.dns = "systemd-resolved";

  # ---------------------------------------------------------
  # 4. SYSTEM POLICIES
  # ---------------------------------------------------------
  security.apparmor.enable = true;
  security.auditd.enable = true;
  security.audit.enable = true;

  # Protect the kernel image from being modified at runtime
  security.protectKernelImage = true;

  # Sudo security
  security.sudo.execWheelOnly = true; # Only 'wheel' group can use sudo
  security.sudo.extraConfig = ''
    Defaults passwd_timeout=0
  '';
}
