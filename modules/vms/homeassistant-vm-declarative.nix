{ config, pkgs, lib, ... }:

let
  # You would define these variables based on your actual configuration
  # or pass them in from the homeassistant-vm.nix module if you keep it
  haosImagePath = "/var/lib/libvirt/images/haos.qcow2";
  haosMemory = 4096; # MB
  haosVcpus = 2;
  haosBridge = "br0";
in
{
  services = {
    libvirtd = {
      enable = true;
      qemu = {
        enable = true;
        swtpm.enable = true;
      };
    };
  };

  virtualisation = {
    libvirt = {
      qemu = {
        # This enables the QEMU driver for Libvirt
        enable = true;

        # Define your Home Assistant VM here
        machines.homeassistant = {
          # Enable autostart for this VM
          autostart = true;

          # Memory in MiB
          memory = haosMemory;

          # Number of virtual CPUs
          vcpu = haosVcpus;

          # Disk configuration
          disks = [
            {
              file = haosImagePath;
              format = "qcow2";
              # Use virtio for better performance
              driver = "qemu"; # Or "raw" if not qcow2
              device = "disk"; # Or "cdrom" for ISO
              bus = "virtio";
            }
          ];

          # Network configuration
          networks = [
            {
              type = "bridge";
              source = haosBridge;
              model = "virtio"; # Use virtio for better performance
            }
          ];

          # OS type and variant (generic is often fine for appliances)
          os = {
            type = "hvm"; # Hardware Virtual Machine
            variant = "generic";
          };

          # No graphical output (headless VM)
          graphics = {
            type = "none";
          };

          # Boot from UEFI
          boot = {
            uefi = true;
          };

          # Optional: Console for debugging
          console = {
            type = "pty";
            targetType = "serial";
            targetPort = 0;
          };
        };
      };
    };
  };
}