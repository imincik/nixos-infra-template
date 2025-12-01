{
  inputs,
  config,
  projectConfig,
  ...
}:

let
  inherit (inputs.nixpkgs) lib;
in

{
  flake.nixosConfigurations =
    let
      # Make NixOS server host
      mkHost =
        hostname:
        let
          hostConfig = import ./../hosts/${hostname}/config.nix;
          system = "x86_64-linux";
        in
        lib.nixosSystem {
          inherit system;
          modules = [
            inputs.disko.nixosModules.disko
            inputs.agenix.nixosModules.default
            ./../hosts/${hostname}
          ]
          ++ lib.optional (projectConfig.environmentName == "dev") (
            lib.warn "Using insecure development configuration (profiles/development.nix) !" ../profiles/development.nix
          )
          ++ lib.optional (projectConfig.environmentName == "dev") (
            lib.warn "Using insecure development configuration (hosts/${hostname}/development.nix) !" ./../hosts/${hostname}/development.nix
          );
          specialArgs = {
            inherit projectConfig hostConfig hostname;
          };
        };
    in
    import ../hosts.nix { inherit mkHost; };
}
