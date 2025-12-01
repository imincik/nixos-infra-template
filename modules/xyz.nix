{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.mymodule;
in
{
  options = {
    enable = lib.mkEnableOption "My module";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.warn "This module is not implemented !" [ pkgs.cowsay ];
  };
}
