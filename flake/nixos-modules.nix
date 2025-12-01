{ inputs, ... }:

{
  flake.nixosModules = {
    xyz = import ./../modules/xyz.nix;
  };
}
