{ inputs, ... }:

{
  perSystem =
    { system, lib, ... }:
    {
      # Configure ONE nixpkgs instance for all perSystem modules
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg:
          lib.elem (lib.getName pkg) [
            "terraform"
          ];
      };
    };
}
