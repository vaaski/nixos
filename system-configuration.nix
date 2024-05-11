# system-specific configuration
{ pkgs, ... }:

{
  boot.kernelParams = [ "consoleblank=20" ];
  networking.hostName = "lserver";

  environment.systemPackages = with pkgs; [
    cifs-utils
    caddy
  ];

  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" (builtins.readFile ./Caddyfile);
  };

  # sda -> fat 2tb
  # sdb -> crap 2tb
  # sdc -> trans0-2tb
  # sdd -> trans1-2tb
  fileSystems = {
    "/media/raids" = {
      device = "/dev/md0";
      fsType = "ext4";
    };
    "/media/hserver-static" = {
      device = "//192.168.88.100/static";
      fsType = "cifs";
      options =
        let
          automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

        in
        [ "${automount_opts},credentials=/home/o/nixos/smb-secrets" ];
    };
    "/media/hserver-2TB" = {
      device = "//192.168.88.100/2TB-SPINNINGRUST";
      fsType = "cifs";
      options =
        let
          automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

        in
        [ "${automount_opts},credentials=/home/o/nixos/smb-secrets" ];
    };
    "/media/hserver-1TB-SSD" = {
      device = "//192.168.88.100/1TB-SSD";
      fsType = "cifs";
      options =
        let
          automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

        in
        [ "${automount_opts},credentials=/home/o/nixos/smb-secrets" ];
    };
  };

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.88. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      dfree command = /home/o/nixos/samba-dfree/dfree.sh
      dfree cache time = 60
    '';
    shares = {
      home = {
        path = "/home/o";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "o";
      };
      raids = {
        path = "/media/raids";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "o";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
