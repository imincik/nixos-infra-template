{ inputs, modulesPath, ... }:

{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      packages = {
        all-packages = pkgs.symlinkJoin {
          name = "all-packages";
          paths = lib.attrValues (lib.filterAttrs (n: v: n != "all-packages") config.packages);
        };
      };
    };
}
