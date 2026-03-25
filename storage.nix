{ config, pkgs, ... }:

{
  # 1. Required tools
  environment.systemPackages = with pkgs; [
    cifs-utils
    ntfs3g
  ];

  # 2. Support for both filesystems
  boot.supportedFilesystems = [
    "ntfs"
    "cifs"
  ];

  # 3. The 710GB Windows Partition
  fileSystems."/mnt/WD_SSD" = {
    device = "/dev/disk/by-uuid/3C00FC4200FC0524";
    fsType = "ntfs3";
    options = [
      "uid=1000,gid=1000,rw,user,exec,umask=000,windows_names,nofail"
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
