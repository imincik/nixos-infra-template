{
  inputs,
  config,
  projectConfig,
  ...
}:

{
  flake.terraformConfigurations =
    let
      system = "x86_64-linux";

      # Import deployments.nix with mkDeployment function that merges config.nix and infra.nix
      hosts = import ../deployments.nix {
        mkDeployment =
          hostname:
          let
            configNix = import ../hosts/${hostname}/config.nix;
            infraNix = import ../hosts/${hostname}/infra.nix;
          in
          configNix // { infra = infraNix.config; };
      };

      # Single unified deployment for all infrastructure
      all = inputs.terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          ../infra/variables.nix
          ../infra/providers/hetzner/ssh-key.nix
          ../infra/providers/hetzner/hosts.nix
        ];
        extraArgs = {
          inherit projectConfig hosts;
        };
      };
    in
    {
      inherit all;
    };
}
