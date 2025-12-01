{
  projectConfig,
  ...
}:

{
  # Secrets
  age.identityPaths = [ "/root/.agenix/agenix.key" ];

  # System banner
  services.getty.greetingLine = projectConfig.systemBanner;

  # Security
  security.sudo = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  # SSH
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Nix
  nix.settings.trusted-users = [ "@wheel" ];

  # Nix Flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Other
  documentation.nixos.enable = false;
}
