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
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
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
    # In 26.05, settings follow the [Section] key structure
    settings = {
      Resolve = {
        DNSOverTLS = "opportunistic";
        DNSSEC = "false";
        # Domains = [ "~." ];
        FallbackDNS = [
          "1.1.1.1#cloudflare-dns.com"
          "9.9.9.9#dns.quad9.net"
        ];
      };
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [
      "network-pre.target"
      "tailscaled.service"
    ];
    wants = [
      "network-pre.target"
      "tailscaled.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";

    # Using a local file for the key to keep your config clean/private
    script = ''
      # Wait for the service to be ready
      sleep 2
      ${pkgs.tailscale}/bin/tailscale up \
        --authkey=$(cat /etc/nixos/.tailscale.key) \
        --accept-dns=true \
        --accept-routes=true
    '';
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
