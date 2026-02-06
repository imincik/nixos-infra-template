let
  # IDENTITIES

  # Admin user
  projectConfig = import ../config.nix;

  adminUsersFile = import ../users/default.nix {
    config = { };
    pkgs = { };
    projectConfig = projectConfig;
  };
  adminUser = adminUsersFile.users.users.${projectConfig.adminUser}.openssh.authorizedKeys.keys;

  # NixOS host
  nixosHost = "TODO";

in
{
  # SECRETS
  # <SECRET-NAME>.age.publicKeys = <LIST-OF-IDENTITIES-ALLOWED-TO-DECRYPT-THE-SECRET>;

  # Permissions: read access to code, commit statuses, and metadata
  "nixosAutoUpgradeToken.age".publicKeys = adminUser ++ [ nixosHost ];
}
