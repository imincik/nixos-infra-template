toplevel@{
  inputs,
  config,
  projectConfig,
  ...
}:

{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      # Force prod environment for tests
      prodProjectConfig = projectConfig // {
        environmentName = "prod";
      };

      # Make NixOS test
      mkTest =
        hostname:
        let
          hostConfig = import ./../hosts/${hostname}/config.nix;
        in
        pkgs.testers.nixosTest (
          import ./../hosts/${hostname}/test.nix {
            inherit
              inputs
              lib
              pkgs
              hostConfig
              hostname
              ;
            projectConfig = prodProjectConfig;
          }
        );
    in
    {
      checks = import ../tests.nix { inherit mkTest; };
    };
}
