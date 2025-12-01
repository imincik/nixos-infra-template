toplevel@{ inputs, config, ... }:

let
  inherit (inputs.nixpkgs) lib;
in

{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:

    {
      apps =
        let
          # List of all hosts
          allHosts = lib.attrNames toplevel.config.flake.nixosConfigurations;

          # Make NixOS VM
          mkVm = hostname: {
            type = "app";
            program = "${lib.getExe
              toplevel.config.flake.nixosConfigurations.${hostname}.config.system.build.vm
            }";
            meta.description = "Virtual machine";
          };
        in

        # Create VM for all hosts
        lib.mapAttrs' (n: v: lib.nameValuePair (n + "-vm") v) (lib.genAttrs allHosts (h: mkVm h));
    };
}
