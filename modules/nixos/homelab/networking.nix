# ~/nixconfig/modules.new/nixos/homelab/networking.nix
{
  config,
  pkgs,
  ...
}:

{
  networking.hostName = "homelab";

  boot.initrd.kernelModules = [
    "dm_mod"
    "dm_thin_pool"
  ];
  boot.initrd.availableKernelModules = [
    "ext4"
    "xfs"
  ];

  services.lvm.enable = true;
  services.lvm.boot.thin.enable = true;

  fileSystems."/media" = {
    device = "/dev/media/vm-101-disk-0";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  fileSystems."/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" "nofail" ];
  };

  networking.nftables.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    53
    8096
  ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  networking.bridges.br0.interfaces = [ "enp41s0" ];

  networking.interfaces.br0 = {
    ipv4.addresses = [
      {
        address = "192.168.0.116";
        prefixLength = 24;
      }
    ];
  };

  networking.defaultGateway = "192.168.0.1";

  # Explicitly configure NetworkManager to use systemd-resolved for DNS handling.
  networking.networkmanager.dns = "systemd-resolved"; 
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNS=192.168.0.1
      Cache=yes
      DNSStubListener=yes
    '';
  };

  networking.interfaces.enp41s0.useDHCP = false;

  networking.firewall.trustedInterfaces = [
    "tailscale0"
    "docker0"
    "br0"
  ];

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # systemd.services.lvm-activate = {
  #   description = "Activate LVM volume groups";
  #   wantedBy = [ "local-fs.target" ];
  #   before = [ "local-fs.target" ];
  #   path = [ pkgs.lvm2 ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${pkgs.lvm2}/bin/vgchange -ay";
  #   };
  # };
}
