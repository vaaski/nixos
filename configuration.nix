{ pkgs, ... }:

let
  fetchPackage = { name, url, sha256 }:
    (pkgs.stdenv.mkDerivation {
      name = name;
      src = pkgs.fetchurl {
        name = name;
        url = url;
        sha256 = sha256;
      };
      phases = [ "installPhase" ];
      installPhase = ''
        install -D $src $out/bin/$name
      '';
    });
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./system-configuration.nix # system-specific configuration, e.g. hostname
    ];

  environment.systemPackages = with pkgs; [
    btop
    docker
    ffmpeg
    git
    gnupg
    go
    goreleaser
    neofetch
    nil
    nixpkgs-fmt
    nodejs_20
    nodePackages."@antfu/ni"
    pinentry
    starship
    wget
    (fetchPackage {
      name = "pnpm";
      url = "https://github.com/pnpm/pnpm/releases/download/v8.15.4/pnpm-linuxstatic-x64";
      sha256 = "sha256:7d26cc57186850a2d71ab77da7cf52ff0eeabf680ac446c8da2324aa63808aac";
    })
    (fetchPackage {
      name = "go-yt-dlp";
      url = "https://github.com/vaaski/go-yt-dlp/releases/download/0.1.2/go-yt-dlp-linux-amd64";
      sha256 = "sha256:cb57ada7b1aa3db6cd46c200a16f19a59de646f7ecc205d4b54255edf5b01a56";
    })
    (fetchPackage {
      name = "yt-dlp";
      url = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux";
      sha256 = "sha256:b188523119e0a4368f53e11ad0f223c7ed44a8a28663e4b6c205122da037f47b";
    })
  ];

  programs.bash.shellAliases = {
    r = "sudo nixos-rebuild switch";
    ll = "ls -lhFG";
    la = "ll -A";
    localip = "ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d'/' -f1";
    publicip = "curl -4 -s ifconfig.co";
  };

  virtualisation.docker.enable = true; # needed for docker
  programs.nix-ld.enable = true; # needed for vscode server
  security.sudo.wheelNeedsPassword = false; # passwordless sudo
  networking.firewall.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;

  users.users.o = {
    isNormalUser = true;
    description = "o";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    # packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      # mac air
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDTGEUYjt3nIw+ay+UjPfhuzn6dBTjBPT6bgVZZS7FzmwFGjait2H6hQYkJf2ibGD6Z7JWgKqE1EfDB6kVav/LciKzfG3sTtXsKyIfijL+ktje3hYUe6q109k1F6tW52B99YsN40gUDIXeLEb2Um4odXp68X6PbejJbKSroA4NJt6qgyWKRu9Sm55AlUcxlZ+Xw0p2RNk90cS37pG+QK1+XjmqKTdwgnu8eu+jL5Oa06nojGc5Cg6AYp8Sp1hfo0vl+OsBfx47V5qzHy6Kqt6limOjzYELS5C/PRrr1E/JpQFHCEwrM9PI6869kNUMgLZ6+n8FfHkvNi+c7QghDuQ7q+vwNGkLS62vymvJDvQT6503kfucEHYg87LZv0iSh95/Pu0gCO4ycMJuN5M+I08L1clF4SZD8qpbtmVgEh02/3Rw//+cG7S91b3FbBEMwApD42KPCky96Db7aKbVChIclb0yEPGKJJj/yr1zoz/AYxQNkLwZ2YC+Ux0Yr0rUMqGk="
      # windows
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCn75kBDz7/E92HNrgITF1rGQvoKIL9kZfECCEgNKaCtoTxr10L/TO1Uvq8LZMdxL3HIYO6PGJKzuYIsfEvN7Bx/PG0FXU7QWge0H0j3jCjgWx5p7RPwH76omIIryz0V7Vt+xPFJeGykiW0qmuHl8zK/uxVtHN/cVW+ukmpQ6ztmnRJ9HrGiYIOuOfNgnVr7J6i7lYv8kL+0l7gmBABnMIQk+7cIntgd54jroAdvcPQpja8pO6uki5Eh9XJrAmo/nW9KTjRSx+DtxuQny5lh7jZlwmKZtkIyV6MgoeWopDDWl69BmCzbRDh8GpnkHlCP09WGi6XMFQSGgmOIOhokE+D"
      # iphone
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYlfzHsYEWnzrrdM4t8GC9uA8SIIvjtieZEmIbw/yNn"
      # work mac
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKoiophA8kvDCGunKUiRX91opLWPoNUi+LIsVv+bCmz2"
    ];
  };

  programs.starship.enable = true;
  programs.starship.settings = {
    format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$python$character";
    directory = {
      style = "blue";
    };
    character = {
      success_symbol = "[❯](purple)";
      error_symbol = "[❯](red)";
      vimcmd_symbol = "[❮](green)";
    };
    git_branch = {
      format = "[$branch]($style)";
      style = "bright-black";
    };
    git_status = {
      format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
      style = "cyan";
      conflicted = "​";
      untracked = "​";
      modified = "​";
      staged = "​";
      renamed = "​";
      deleted = "​";
      stashed = "≡";
    };
    git_state = {
      format = "\([$state( $progress_current/$progress_total)]($style)\) ";
      style = "bright-black";
    };
    cmd_duration = {
      format = "[$duration]($style) ";
      style = "yellow";
    };
    python = {
      format = "[$virtualenv]($style) ";
      style = "bright-black";
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console.keyMap = "de";
  services.xserver = {
    layout = "de";
    xkbVariant = "";
  };

  # don't change
  system.stateVersion = "23.11";

}
