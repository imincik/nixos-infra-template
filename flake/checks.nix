toplevel@{
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
          hostConfig = import (rootPath + "/hosts/${hostname}/config.nix");
        in
        pkgs.testers.nixosTest (
          import (rootPath + "/hosts/${hostname}/test.nix") {
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

      allTests = (import (rootPath + "/tests.nix") { inherit mkTest; });
    in
    {
      checks = allTests // {
        inherit (config.packages) all-packages;
      };
    };
}
