{ config, pkgs, ... }:

let
  cfg = config.services.homeassistant-vm;
in
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "deploy-haos" ''
      set -e
      IMAGE="${cfg.imagePath}"
      VM_NAME="homeassistant"
      BRIDGE="${cfg.bridge}"
      MEM_MB="${toString cfg.memory}"
      VCPUS="${toString cfg.vcpus}"

      if [ ! -f "$IMAGE" ]; then
        echo "Error: HAOS image not found at $IMAGE"
        exit 1
      fi

      if virsh list --all | grep -q " $VM_NAME "; then
        echo "VM $VM_NAME already exists"
        exit 0
      fi

      virt-install \
        --name "$VM_NAME" \
        --memory "$MEM_MB" \
        --vcpus "$VCPUS" \
        --import \
        --disk path="$IMAGE",format=qcow2,bus=virtio \
        --network bridge="$BRIDGE",model=virtio \
        --os-variant generic \
        --graphics none \
        --noautoconsole \
        --boot uefi

      echo "Home Assistant VM deployed!"
      echo "Get IP with: haos ip"
    '')
  ];
}

