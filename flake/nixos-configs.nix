{
  inputs,
  config,
  projectConfig,
  nixosFrameworkConfig,
  ...
}:

let
  inherit (inputs.nixpkgs) lib;
  rootPath = nixosFrameworkConfig.rootPath;
in

{
  flake.nixosConfigurations =
    let
      # Make NixOS server host
      mkHost =
        hostname:
        let
          hostConfig = import (rootPath + "/hosts/${hostname}/config.nix");
          system = "x86_64-linux";
        in
        lib.nixosSystem {
          inherit system;
          modules = [
            inputs.disko.nixosModules.disko
            inputs.agenix.nixosModules.default
            {
              _module.args = {
                inherit
                  inputs
                  projectConfig
                  hostConfig
                  hostname
                  ;
              };
            }
            (rootPath + "/hosts/${hostname}")
          ]
          ++ nixosFrameworkConfig.extraModules
          ++ lib.optional (projectConfig.environmentName == "dev") (
            lib.warn "Using insecure development configuration (profiles/development.nix)!" (
              rootPath + "/profiles/development.nix"
            )
          )
          ++ lib.optional (projectConfig.environmentName == "dev") (
            lib.warn "Using insecure development configuration (hosts/${hostname}/development.nix)!" (
              rootPath + "/hosts/${hostname}/development.nix"
            )
          );
          specialArgs = {
            inherit
              inputs
              projectConfig
              hostConfig
              hostname
              ;
          };
        };
    in
    import (rootPath + "/hosts.nix") { inherit mkHost; };
}
