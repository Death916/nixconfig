# ~/nixconfig/nixos/acpi-override.nix
{ pkgs, ... }:
let
  acpi-override = pkgs.stdenv.mkDerivation {
    name = "acpi-override";
    src = ./.;
    nativeBuildInputs = [ pkgs.acpica-tools pkgs.cpio ];
    buildCommand = ''
      # Compile the patched DSL back to AML
      iasl -sa $src/ssdt_patch.dsl
      
      # Prepare the directory structure the kernel expects
      mkdir -p kernel/firmware/acpi
      cp ssdt_patch.aml kernel/firmware/acpi/SSDT10.aml
      
      # Create the CPIO archive
      mkdir -p $out
      find kernel | cpio -H newc --create > $out/acpi_override.cpio
    '';
  };
in
{
  boot.initrd.prepend = [
    "${acpi-override}/acpi_override.cpio"
  ];
}
