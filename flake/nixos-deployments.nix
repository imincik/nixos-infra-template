{
  inputs,
  config,
  projectConfig,
  ...
}:

{
  flake.terraformConfigurations =
    let
      # Deploy NixOS server host
      mkDeployment =
        hostname:
        let
          hostConfig = import ./../hosts/${hostname}/config.nix;
          system = "x86_64-linux";
        in
        inputs.terranix.lib.terranixConfiguration {
          inherit system;
          modules = [
            ../infra/variables.nix
            ../infra/hetzner-firewall.nix
            ../infra/hetzner-server.nix
            ./../hosts/${hostname}/infra.nix
          ];
          extraArgs = {
            inherit projectConfig hostConfig hostname;
          };
        };
    in
    import ../deployments.nix { inherit mkDeployment; };
}
