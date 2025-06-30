# NixOS Configuration Refactor

This document outlines the new, modular structure of the NixOS configuration and explains how to revert to the previous setup if necessary.

## New Directory Structure

The configuration has been reorganized to be more modular and easier to manage. Here is an overview of the new structure:

```
.
├── flake.nix
├── home-manager/
│   ├── death916-homelab.nix
│   └── home.nix
├── modules/
│   ├── home-manager/
│   │   └── common.nix
│   └── nixos/
│       ├── common/
│       │   ├── base.nix
│       │   └── tailscale.nix
│       ├── homelab/
│       │   ├── networking.nix
│       │   ├── services.nix
│       │   └── user.nix
│       └── laptop/
│           ├── desktop.nix
│           └── user.nix
├── nixos/
│   ├── configuration.nix
│   └── homelab.nix
├── old_config/         # <-- Your previous configuration is backed up here
└── scripts/
    └── nh-push         # <-- New helper script
```

### Key Changes

- **Modularization**: The main `configuration.nix` and `homelab.nix` files have been split into smaller, more focused modules located in the `modules/` directory. This makes the code cleaner and easier to navigate.
- **Shared vs. Specific Config**: Common settings shared between both the laptop and homelab are now in `modules/nixos/common/` and `modules/home-manager/common.nix`. Machine-specific configurations are in their respective `laptop/` and `homelab/` subdirectories.
- **`flake.nix`**: The flake now uses `specialArgs` to pass overlays and other shared values to the modules, reducing redundancy.
- **`nh-push` script**: A new script has been added at `scripts/nh-push`. This script wraps the `nh os switch` command and automatically runs `git push` after a successful build, streamlining the update process.

## How to Revert the Changes

If you encounter any issues with the new configuration, you can easily revert to your previous setup. Your old files are safely archived in the `old_config/` directory.

To revert, follow these steps:

1.  **Delete the new configuration files**:

    ```bash
    rm -rf flake.nix nixos/ modules/ home-manager/ scripts/
    ```

2.  **Restore the old configuration from the backup**:

    ```bash
    mv old_config/* .
    rmdir old_config
    ```

3.  **Rebuild your system**:

    After restoring the files, run your usual NixOS rebuild command, for example:

    ```bash
    sudo nixos-rebuild switch --flake .#homelab
    ```

This will restore your system to the exact state it was in before these changes were made.

## Quick Reference: Where to Find Common Settings

Here is a quick guide to help you locate the most common configuration settings in the new modular structure.

### System-Wide Settings

*   **Settings for BOTH Laptop & Homelab:**
    *   `modules/nixos/common/base.nix`: Base system settings like the bootloader, timezone, and `allowUnfree`.
    *   `modules/nixos/common/tailscale.nix`: Tailscale configuration.

*   **Laptop-Specific System Settings:**
    *   `modules/nixos/laptop/desktop.nix`: Desktop environment, system packages, and other laptop-specific services.
    *   `nixos/hardware-configuration.nix`: Filesystems and hardware settings for the laptop.

*   **Homelab-Specific System Settings:**
    *   `modules/nixos/homelab/services.nix`: All homelab services (Docker, Jellyfin, etc.) and system packages.
    *   `modules/nixos/homelab/networking.nix`: Static IP, firewall, and network settings for the homelab.
    *   `nixos/hardware-homelab.nix`: Filesystems and hardware settings for the homelab.

### User & Home-Manager Settings

*   **Settings for YOUR USER on BOTH Systems:**
    *   `modules/home-manager/common.nix`: Shared user settings like your shell (Bash), Git config, Helix, and default editor.

*   **Laptop-Specific User Settings:**
    *   `home-manager/home.nix`: User-specific packages, shell prompt (`starship`), and aliases for the laptop.

*   **Homelab-Specific User Settings:**
    *   `home-manager/death916-homelab.nix`: User-specific packages and aliases for the homelab.
