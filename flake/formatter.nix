{ inputs, ... }:

{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:

    {
      formatter = pkgs.nixfmt-tree;
    };
}
