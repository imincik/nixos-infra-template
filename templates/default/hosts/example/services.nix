{
  config,
  lib,
  pkgs,
  projectConfig,
  hostConfig,
  ...
}:

{
  services.nginx = {
    enable = true;
    virtualHosts."example" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
      ];
      locations."/" = {
        return = "200 'Hello from NixOS !'";
        extraConfig = ''
          add_header Content-Type text/plain;
        '';
      };
    };
  };
}
