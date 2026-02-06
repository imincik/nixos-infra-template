{
  inputs,
  config,
  projectConfig,
  nixosFrameworkConfig,
  ...
}:

let
  rootPath = nixosFrameworkConfig.rootPath;
in

{
  flake.terraformConfigurations =
    let
      system = "x86_64-linux";

      # Import deployments.nix with mkDeployment function that merges config.nix and infra.nix
      hosts = import (rootPath + "/deployments.nix") {
        mkDeployment =
          hostname:
          let
            configNix = import (rootPath + "/hosts/${hostname}/config.nix");
            infraNix = import (rootPath + "/hosts/${hostname}/infra.nix");
          in
          configNix // { infra = infraNix.config; };
      };

      # Single unified deployment for all infrastructure
      all = inputs.terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          (rootPath + "/infra/variables.nix")
          (rootPath + "/infra/providers/hetzner/ssh-key.nix")
          (rootPath + "/infra/providers/hetzner/hosts.nix")
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
