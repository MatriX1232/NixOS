{ config, pkgs, ... }:

{
  # 1. Required tools
  environment.systemPackages = with pkgs; [
    cifs-utils
    btrfs-progs
    compsize # Pozwala sprawdzić realny zysk z kompresji: sudo compsize /mnt/WD_GAMES
  ];

  # 2. Support for both filesystems
  boot.supportedFilesystems = [
    "btrfs"
    "cifs"
  ];

  # 3. Konfiguracja Montowania (Dynamiczne zarządzanie 1TB na SN570)
  fileSystems."/mnt/WD_GAMES" = {
    device = "/dev/disk/by-uuid/f6b0f0e1-48cd-4171-af83-3ca4e3b7d410";
    fsType = "btrfs";
    options = [
      "subvol=@games" # Gry zostają na głównym poziomie, gdzie były wcześniej
      "compress-force=zstd:3" # Wymuszamy kompresję na plikach gier dla max oszczędności
      "noatime" # Drastycznie redukuje ilość zapisów na SSD (pomija czas dostępu)
      "discard=async" # KLUCZOWE: Obsługa TRIM w tle dla dysków bez DRAM (SN570)
      "space_cache=v2" # Nowoczesny i szybki sposób śledzenia wolnego miejsca
      "nofail" # System zabootuje nawet jeśli dysk nie zostanie wykryty
    ];
  };

  fileSystems."/mnt/WD_SSD" = {
    device = "/dev/disk/by-uuid/f6b0f0e1-48cd-4171-af83-3ca4e3b7d410";
    fsType = "btrfs";
    options = [
      "subvol=@data" # Twoje nowe miejsce na normalne pliki
      "compress=zstd:3" # Standardowa heurystyka (wystarczy dla dokumentów/media)
      "noatime"
      "discard=async"
      "space_cache=v2"
      "nofail"
    ];
  };

  # 4. The NAS - Mateusz
  # Uses systemd automount so it doesn't hang boot.
  fileSystems."/mnt/OrangePI_Mateusz" = {
    device = "//192.168.1.154/Mateusz";
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,nofail";
      in
      [
        "${automount_opts},credentials=/home/msolinsk/.smbcredentials,uid=1000,gid=1000,vers=3.1.1,cache=loose,rsize=4194304,wsize=4194304,mfsymlinks,_netdev,soft,retrans=2,echo_interval=60"
      ];
  };
}
