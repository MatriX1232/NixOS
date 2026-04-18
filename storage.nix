{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cifs-utils
    btrfs-progs
    compsize # Pozwala sprawdzić realny zysk z kompresji: sudo compsize /mnt/WD_GAMES
  ];

  boot.supportedFilesystems = [
    "btrfs"
    "cifs"
  ];

  fileSystems."/mnt/WD_GAMES" = {
    device = "/dev/disk/by-uuid/f6b0f0e1-48cd-4171-af83-3ca4e3b7d410";
    fsType = "btrfs";
    options = [
      "subvol=@games"
      "compress-force=zstd:3"
      "noatime"
      "discard=async"
      "space_cache=v2"
      "nofail"
    ];
  };

  fileSystems."/mnt/WD_SSD" = {
    device = "/dev/disk/by-uuid/f6b0f0e1-48cd-4171-af83-3ca4e3b7d410";
    fsType = "btrfs";
    options = [
      "subvol=@data"
      "compress=zstd:3"
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
