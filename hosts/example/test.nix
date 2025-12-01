{
  inputs,
  lib,
  pkgs,
  projectConfig,
  hostConfig,
  hostname,
  ...
}:

{
  name = "Test ${hostname} host";
  nodes = {
    machine =
      { pkgs, lib, ... }:
      {
        _module.args = {
          inherit
            inputs
            projectConfig
            hostConfig
            hostname
            ;
        };

        imports = [
          inputs.disko.nixosModules.disko
          inputs.agenix.nixosModules.default
          ./default.nix
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      machine.execute("hostname | grep ${hostname}")

      machine.execute("""
        curl --insecure https://localhost
        | grep 'Hello from NixOS'
      """)
    '';
}
