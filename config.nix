{
  thisRepository = "github:imincik/nixos-framework";

  adminUser = "admin";
  adminEmail = "admin@example.com";
  adminPublicSSHkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWlDZ4iZZAAxmlJknc55t71QfJRZqszgXraiyS6tVv1 imincik";

  systemBanner = ''
    You are welcome here, so long as you come in a good faith.
  '';

  nixosStateVersion = "25.05";
}
