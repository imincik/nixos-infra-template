{
  inputs,
  lib,
  pkgs,
  projectConfig,
  hostConfig,
  hostname,
  ...
}:

{
  imports = [
    # Hardware configuration
    ./disks.nix
    ./hardware.nix

    # System users
    ../../users/default.nix

    # System configuration (from framework)
    (inputs.nixos-framework + "/profiles/common.nix")
    (inputs.nixos-framework + "/profiles/auto-upgrade.nix")

    # Host specific configuration
    ./services.nix
  ];

  # Networking
  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;

    # Firewall
    firewall = {
      allowedTCPPorts = [
        22 # SSH
      ];
    };
  };

  # Nixpkgs
  nixpkgs = {
    config = { };
  };

  # System
  system.configurationRevision = projectConfig.configRevision;
  system.stateVersion = projectConfig.nixosStateVersion;
  nixpkgs.hostPlatform = "x86_64-linux";
}
