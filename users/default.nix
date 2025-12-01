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
    openssh.authorizedKeys.keyFiles = [
      ./imincik.pub # FIXME: replace this whith your own key
    ];
    shell = pkgs.bash;
  };
}
