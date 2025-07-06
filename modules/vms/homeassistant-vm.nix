# modules/vms/homeassistant-vm.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.homeassistant-vm;
in
{
  imports = [
    ./ha-deploy-script.nix
    ./ha-control-script.nix
  ];

  options.services.homeassistant-vm = {
    enable = mkEnableOption "Home Assistant OS Virtual Machine";
    imagePath = mkOption {
      type = types.str;
      default = "/var/lib/libvirt/images/haos.qcow2";
      description = "Path to the HAOS qcow2 image";
    };
    memory = mkOption {
      type = types.int;
      default = 4096;
      description = "Memory in MB";
    };
    vcpus = mkOption {
      type = types.int;
      default = 2;
      description = "Number of CPUs";
    };
    bridge = mkOption {
      type = types.str;
      default = "br0";
      description = "Bridge interface for VM networking";
    };
  };

  config = mkIf cfg.enable { };
}

