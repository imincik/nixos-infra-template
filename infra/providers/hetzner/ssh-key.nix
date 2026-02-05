# SSH Key - shared across all hosts
{ projectConfig, ... }:

{
  resource.hcloud_ssh_key.admin = {
    name = "admin";
    public_key = projectConfig.adminPublicSSHkey;
  };
}
