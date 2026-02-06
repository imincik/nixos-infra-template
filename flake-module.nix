{
  inputs,
  lib,
  config,
  ...
}:

let
  cfg = config.nixosFramework;
in

{
  options.nixosFramework = {
    enable = lib.mkEnableOption "NixOS infrastructure framework";

    projectConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      description = ''
        Project-wide configuration including:
        - configRevision: Git revision or "dirty"
        - environmentName: Environment name (prod/dev)
        - thisRepository: GitHub repository URL
        - adminUser: Admin username
        - adminEmail: Admin email address
        - adminPublicSSHkey: Admin SSH public key
        - systemBanner: System login banner
        - nixosStateVersion: NixOS state version
      '';
      example = {
        configRevision = "abc123";
        environmentName = "prod";
        thisRepository = "github:org/repo";
        adminUser = "admin";
        adminEmail = "admin@example.com";
        adminPublicSSHkey = "ssh-ed25519 AAAA...";
        systemBanner = "Welcome!";
        nixosStateVersion = "25.05";
      };
    };

    rootPath = lib.mkOption {
      type = lib.types.path;
      default = ./.;
      description = "Root path of the project (used to resolve relative paths)";
    };

    extraModules = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
      description = "Extra NixOS modules to include in all host configurations";
    };

    extraDeploymentPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages to include in deployment shell";
    };

    extraDevPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages to include in development shell";
    };
  };

  config = lib.mkIf cfg.enable {
    _module.args = {
      modulesPath = "${inputs.nixpkgs}/nixos/modules";
      projectConfig = cfg.projectConfig;
      nixosFrameworkConfig = cfg;
    };
  };

  imports = [
    ./flake/apps.nix
    ./flake/checks.nix
    ./flake/shells.nix
    ./flake/formatter.nix
    ./flake/hooks.nix
    ./flake/nixos-configs.nix
    ./flake/nixos-deployments.nix
    ./flake/nixos-modules.nix
    ./flake/packages.nix
  ];
}
