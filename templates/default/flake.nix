{
  description = "NixOS Framework";

  inputs = {
    nixos-framework.url = "github:imincik/nixos-framework";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    agenix = {
      url = "github:ryantm/agenix";
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

    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        # "aarch64-linux"
      ];

      imports = [
        inputs.git-hooks.flakeModule
        inputs.nixos-framework.flakeModules.default
      ];

      nixosFramework = {
        enable = true;
        rootPath = ./.;
        projectConfig = {
          configRevision = if self ? rev then self.rev else "dirty";
          environmentName = builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile ./environment.txt);
        }
        // (import ./config.nix);
      };
    };
}
