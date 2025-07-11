
# /home/death916/nixconfig/modules/vms/haos-vm.nix
#
# Declarative Home Assistant VM configuration using NixVirt.
# This is the permanent, declarative solution to managing your VM.
#
# To use this, you must:
# 1. Add NixVirt to your flake.nix inputs.
#    inputs.nixvirt = {
#      url = "github:NixOS/nixvirt";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
# 2. Import this file and the nixvirt module in your main NixOS configuration:
#    imports = [
#      ./modules/vms/haos-vm.nix
#      inputs.nixvirt.nixosModules.default # Provides the options below
#    ];
# 3. Remove the old `services.homeassistant-vm` block from your configuration.
# 4. Ensure `virtualisation.libvirtd.qemu.ovmf.enable = true;` is set.

{ config, pkgs, lib, ... }:

let
  # Parameters for your VM, taken from your existing configuration.
  haosImagePath = "/var/lib/libvirt/images/haos.qcow2";
  haosMemory = 6096; # In MiB, from your services.nix
  haosVcpus = 4;    # From your services.nix
  haosBridge = "br0";
in
{
  # This defines the Libvirt domain (VM) using NixVirt's options.
  # It assumes you are using the default libvirt connection.
  virtualisation.libvirt.connections.default.domains = {
    homeassistant = {
      autostart = true;
      # The domain configuration, which maps closely to Libvirt's XML structure.
      domain = {
        type = "kvm"; # Use KVM for hardware acceleration
        name = "homeassistant";
        memory = {
          value = haosMemory;
          unit = "MiB";
        };
        vcpu = {
          placement = "static";
          value = haosVcpus;
        };

        # OS boot configuration
        os = {
          type = {
            arch = "x86_64";
            machine = "pc-q35-8.0"; # Modern machine type, good default
            value = "hvm";
          };
          # This ensures the VM boots with UEFI.
          # The path is managed by NixOS when `ovmf.enable = true` is set.
          loader = {
            readonly = "yes";
            type = "pflash";
            path = "${pkgs.OVMF.fd}/FV/OVMF.fd";
          };
          # NVRAM storage for UEFI settings.
          nvram.template = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
          boot.dev = "hd";
        };

        # CPU configuration
        cpu.mode = "host-passthrough";

        # Devices configuration
        devices = {
          emulator = "${pkgs.qemu_kvm}/bin/qemu-system-x86_64";
          disks = [{
            type = "file";
            device = "disk";
            driver = {
              name = "qemu";
              type = "qcow2";
            };
            source.file = haosImagePath;
            target = {
              dev = "vda";
              bus = "virtio";
            };
          }];
          interfaces = [{
            type = "bridge";
            source.bridge = haosBridge;
            model.type = "virtio";
          }];
          # Headless setup
          consoles = [{ type = "pty"; }];
          graphics = [{ type = "none"; }];
          # Virtio balloon for memory management
          memballoon.model = "virtio";
        };
      };
    };
  };
}
