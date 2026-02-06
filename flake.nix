{
  description = "NixOS Framework";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      # Must use latest version due to
      # https://github.com/ryantm/agenix/commit/58c554469cf7bbb27b02f7378c6058ea0ffa59b3
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.disko.follows = "disko";
    };

    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:

    let
      # Project config
      projectConfig = {
        configRevision = if self ? rev then self.rev else "dirty";
        environmentName = builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile ./environment.txt);
      }
      // (import ./config.nix);

    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Enable debug to enable flake-parts debug outputs.
      # https://flake.parts/options/flake-parts.html?highlight=debug#opt-debug
      debug = false;

      systems = [
        "x86_64-linux"
        # "aarch64-linux"
        # "aarch64-darwin"
        # "x86_64-darwin"
      ];

      _module.args = {
        modulesPath = "${inputs.nixpkgs}/nixos/modules";
        inherit inputs projectConfig;
      };

      imports = [
        inputs.git-hooks.flakeModule

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
    };
}
