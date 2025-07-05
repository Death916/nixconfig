# /home/death916/nixconfig/modules/vms/home-assistant.nix
{ config, pkgs, ... }:

let
  # The incus-migrate tool is a separate package that we need to reference.
  incus-migrate = pkgs.incus-migrate;

  # The path to your HAOS image, as requested.
  haos-image-path = "/home/death916/incus/haos_ova-15.2.qcow2";

  # This script will run on boot to ensure the VM exists.
  # It uses incus-migrate with a configuration file.
  setupScript = pkgs.writeShellScript "ha-vm-setup.sh" ''
    set -e
    INCUS_CMD="${pkgs.incus}/bin/incus"
    VM_NAME="home-assistant"

    # 1. Check if the VM already exists. If so, do nothing.
    if $INCUS_CMD info "''${VM_NAME}" >/dev/null 2>&1; then
      echo "VM ''${VM_NAME} already exists. Ensuring it is running."
      $INCUS_CMD start "''${VM_NAME}"
      exit 0
    fi

    # 2. If the VM does not exist, create it using incus-migrate.
    echo "Creating HAOS VM (''${VM_NAME}) with incus-migrate..."

    # The configuration for incus-migrate, passed via stdin.
    # This tells the tool what to do non-interactively.
    cat <<EOF | ${incus-migrate}/bin/incus-migrate
      name: ''${VM_NAME}
      source_driver: disk
      source_config:
        path: "${haos-image-path}"
      uefi: true
      config:
        limits.cpu: "2"
        limits.memory: "4GiB"
    EOF

    # 3. Resize the disk after creation.
    # incus-migrate doesn't set the size directly, so we do it here.
    echo "Resizing root disk to 32GiB..."
    $INCUS_CMD config device override "''${VM_NAME}" root size=32GiB

    # 4. Start the VM.
    $INCUS_CMD start "''${VM_NAME}"
  '';
in
{
  # This systemd service runs our setup script.
  systemd.services.setup-ha-vm = {
    description = "Setup Home Assistant Incus VM using incus-migrate";
    after = [ "incus.service" ];
    requires = [ "incus.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${setupScript}";
    };
  };

  # Ensure incus-migrate is available in the system path for the service.
  environment.systemPackages = [ pkgs.incus-migrate ];
}
