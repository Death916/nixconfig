{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "haos" ''
      VM_NAME="homeassistant"
      case "$1" in
        start)   virsh start "$VM_NAME" ;;
        stop)    virsh shutdown "$VM_NAME" ;;
        status)  virsh list --all | grep "$VM_NAME" ;;
        ip)      virsh domifaddr "$VM_NAME" | awk '/ipv4/ {print $4}' | cut -d/ -f1 ;;
        console) virsh console "$VM_NAME" ;;
        destroy)
          echo "This will permanently delete the VM. Are you sure? (y/N)"
          read -r confirmation
          if [[ "$confirmation" =~ ^[Yy]$ ]]; then
            virsh destroy "$VM_NAME" || true
            virsh undefine "$VM_NAME" --remove-all-storage || true
            echo "VM destroyed."
          else
            echo "Destruction cancelled."
          fi
          ;;
        *)
          echo "Usage: haos {start|stop|status|ip|console|destroy}"
          ;;
      esac
    '')
  ];
}

