{ config, projectConfig, ... }:

{
  age.secrets = {
    nixosAutoUpgradeToken = {
      file = ../secrets/nixosAutoUpgradeToken.age;
    };
  };

  # Automatic upgrades
  system.autoUpgrade = {
    enable = true;
    dates = "02:30";
    flake = "${projectConfig.thisRepository}/deploy-${projectConfig.environmentName}";
    operation = "switch";
    flags = [
      "--accept-flake-config"
      "--refresh"
      "--option"
      "extra-access-tokens"
      "github.com=$(cat ${config.age.secrets.nixosAutoUpgradeToken.path})"
    ];
    allowReboot = false;
    persistent = false;
    randomizedDelaySec = "10min";
  };

  # Nix garbage collector
  nix.gc = {
    automatic = true;
    persistent = false;
    dates = "03:30";
    options = "--delete-older-than 14d";
  };
}
