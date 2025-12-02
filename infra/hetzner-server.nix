# https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs
{
  projectConfig,
  hostConfig,
  hostname,
  ...
}:

let
  prodProtection = if projectConfig.environmentName == "prod" then "true" else "false";
in
{
  # Terraform settings
  terraform.required_providers.hcloud = {
    source = "hetznercloud/hcloud";
    version = "~> 1.45";
  };

  # Provider
  provider.hcloud.token = "\${var.hcloud_token}";

  # SSH Key
  resource.hcloud_ssh_key."${hostname}" = {
    name = "${hostname}";
    public_key = "\${var.ssh_public_key}";
  };

  # Server - Start with rescue system for nixos-anywhere
  resource.hcloud_server.${hostname} = {
    name = "${hostname}";
    server_type = "\${var.server_type}";
    image = "ubuntu-24.04"; # Will be replaced by NixOS
    location = "\${var.server_location}";
    ssh_keys = [ "\${hcloud_ssh_key.${hostname}.id}" ];
    firewall_ids = [ "\${hcloud_firewall.${hostname}-ssh.id}" ];
    delete_protection = prodProtection;
    rebuild_protection = prodProtection;

    # Boot into rescue mode for nixos-anywhere
    lifecycle = {
      ignore_changes = [
        "image"
        "ssh_keys"
      ];
    };
  };
}
