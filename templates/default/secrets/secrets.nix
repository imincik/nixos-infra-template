let
  # IDENTITIES

  # Admin users
  projectConfig = import ../config.nix;
  adminUsers = [ projectConfig.adminPublicSSHkey ];

  # NixOS host
  # id_ed25519_nixos.pub
  nixosHost = "TODO";

in
{
  # SECRETS

  # <SECRET-NAME>.age.publicKeys = <LIST-OF-IDENTITIES-ALLOWED-TO-DECRYPT-THE-SECRET>;

  # Permissions: read access to code, commit statuses, and metadata
  "nixosAutoUpgradeToken.age".publicKeys = adminUsers ++ [ nixosHost ];
}
