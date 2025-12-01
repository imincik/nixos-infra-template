# Only for development. Don't use in production !

{
  config,
  lib,
  pkgs,
  projectConfig,
  ...
}:

lib.throwIfNot (projectConfig.environmentName == "dev")
  ''
    Can't enable insecure development configuration in non-development
    environment !
  ''
  {
    # Add extra packages
    environment.systemPackages = [
      pkgs.htop
      pkgs.jq
      pkgs.tmux
      pkgs.vim
    ];

    # Disable firewall
    networking.firewall.enable = lib.mkForce false;

    # Root user and automatic login
    users.users.root.password = "root";
    services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
    services.openssh.settings.PasswordAuthentication = lib.mkForce true;
    services.getty.autologinUser = "root";

    virtualisation.vmVariant = {
      # Launch VM in console
      virtualisation.graphics = false;

      # Port forwarding
      virtualisation.forwardPorts = [
        # SSH
        {
          from = "host";
          host.port = 10022;
          guest.port = builtins.elemAt config.services.openssh.ports 0;
        }
        # HTTP
        {
          from = "host";
          host.port = 8080;
          guest.port = 80;
        }
        # HTTPS
        {
          from = "host";
          host.port = 8443;
          guest.port = 443;
        }
      ];
    };
  }
