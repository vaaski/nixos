# system-specific configuration
{ pkgs, config, ... }:

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

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  };
  hardware.nvidia.prime = {
    sync.enable = true;

    # Make sure to use the correct Bus ID values for your system!
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  nixpkgs.config.nvidia.acceptLicense = true;

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
