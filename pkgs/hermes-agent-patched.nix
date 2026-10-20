# Temporary local rebuild of hermes-agent from a patched Python source tree.
#
# Why this is not a plain `patches` override: the shipped `hermes-agent`
# package is an *assembler* derivation (dontBuild/dontUnpack) that only links a
# prebuilt uv2nix venv, so `patches` never sees a source tree (patchPhase has
# nothing unpacked and fails with "can't find file to patch"). The venv's
# site-packages entries are symlinks into a separate python package derivation
# built from `pythonSrc`. That filtered source is therefore the only supported
# place to patch kernel code.
#
# This file: rebuilds the venv from a patched copy of `pythonSrc`, rewrites the
# assembler's inputs json to point at the new venv, and re-runs the *upstream*
# assembler installPhase against that json. Delete this file (and the one-line
# reference in nixos/orac.nix) when the patch lands upstream.
{ inputs, pkgs, system, patchFile }:
let
  ha = inputs.hermes-agent;
  base = ha.packages.${system}.default;

  # Must match `full` in the upstream nix/packages.nix, otherwise the rebuilt
  # venv is missing optional dependency groups the live install relies on.
  dependencyGroups =
    [
      "all"
      "anthropic"
      "azure-identity"
      "bedrock"
      "daytona"
      "dingtalk"
      "edge-tts"
      "exa"
      "fal"
      "feishu"
      "firecrawl"
      "honcho"
      "messaging"
      "modal"
      "parallel-web"
      "tts-premium"
      "vercel"
      "voice"
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ "matrix" ];

  patchedPythonSrc = pkgs.runCommand "hermes-python-source-patched" {
    nativeBuildInputs = [ pkgs.patch ];
  } ''
    cp -a ${base.hermesNpmLib.pythonSrc}/. $out/
    chmod -R u+w $out
    patch -p1 --directory=$out < ${patchFile}
  '';

  venv =
    (pkgs.callPackage "${ha}/nix/python.nix" {
      inherit (ha.inputs) uv2nix pyproject-nix pyproject-build-systems;
      pythonSrc = patchedPythonSrc;
      dependency-groups = dependencyGroups;
    }).venv;

  # Same json the assembler reads, with every venv path repointed.
  inputsJson = pkgs.runCommand "hermes-agent-inputs-patched.json" { } ''
    sed 's|${toString base.hermesVenv}|${toString venv}|g' ${base.passthru.agentInputsFile} > $out
  '';
in
base.overrideAttrs (old: {
  installPhase = builtins.replaceStrings
    [ (toString base.passthru.agentInputsFile) ]
    [ (toString inputsJson) ]
    old.installPhase;
})
