{
  flake,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) optional;
in
{
  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        # ignoreUserConfig = true;
        waylandFrontend = true;
        addons = with pkgs; [
          qt6Packages.fcitx5-chinese-addons
          fcitx5-gtk
          fcitx5-rose-pine
        ];
      };
    };
  };

  fonts.fontconfig = {
    useEmbeddedBitmaps = true;
    allowBitmaps = true;
  };

  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  networking = {
    dhcpcd.enable = false;
    nameservers = [
      "223.5.5.5"
      "119.29.29.29"
    ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
    firewall = {
      enable = true;
      checkReversePath = false;
    };
  };

  users = {
    users.${flake.self.hive.user.username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "kvm"
        "audio"
        "video"
      ]
      ++ (optional config.networking.networkmanager.enable "networkmanager")
      ++ (optional config.virtualisation.libvirtd.enable "libvirtd")
      ++ (optional config.services.displayManager.dms-greeter.enable "greeter");
    };
  };
}
