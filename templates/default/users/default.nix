{
  config,
  pkgs,
  projectConfig,
  ...
}:

let
  extraGroups = [ "wheel" ];

in
{
  users.users.${projectConfig.adminUser} = {
    description = "Admin User";
    isNormalUser = true;
    home = "/home/${projectConfig.adminUser}";
    extraGroups = extraGroups;
    openssh.authorizedKeys.keys = [
      projectConfig.adminPublicSSHkey
    ];
    shell = pkgs.bash;
  };
}
