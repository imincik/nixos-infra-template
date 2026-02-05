# Unified infrastructure for all hosts
# Generates servers, firewalls, and outputs for all hosts defined in the hosts attribute
{
  projectConfig,
  hosts,
  lib,
  ...
}:

let
  prodProtection = projectConfig.environmentName == "prod";

  # Generate resources for a single host
  mkHostResources = hostname: hostConfig: {
    # SSH firewall (base firewall for all hosts)
    resource.hcloud_firewall."${hostname}-ssh" = {
      name = "${hostname}-ssh";
      rule = [
        {
          direction = "in";
          protocol = "tcp";
          port = "22";
          source_ips = [
            "0.0.0.0/0"
            "::/0"
          ];
          description = "Allow inbound traffic on port 22";
        }
      ];
    };

    # Server
    resource.hcloud_server.${hostname} = {
      name = "${hostname}";
      server_type = hostConfig.infra.server_type or "cx23";
      image = "ubuntu-24.04"; # Will be replaced by NixOS
      location = hostConfig.infra.server_location or "fsn1";
      ssh_keys = [ "\${hcloud_ssh_key.admin.id}" ];
      # Base firewall - can be extended by host-specific configs
      firewall_ids = lib.mkDefault [ "\${hcloud_firewall.${hostname}-ssh.id}" ];
      backups = prodProtection;
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

    # Output server IP
    output."${hostname}_server_ip" = {
      value = "\${hcloud_server.${hostname}.ipv4_address}";
    };
  };

  # Import host-specific extensions (firewalls, etc.)
  mkHostExtensions =
    hostname: hostConfig:
    let
      infraModule = import ../../../hosts/${hostname}/infra.nix;
    in
    infraModule.terraform { inherit projectConfig hostname hostConfig; };
in
lib.mkMerge [
  # Terraform provider settings
  {
    terraform.required_providers.hcloud = {
      source = "hetznercloud/hcloud";
      version = "~> 1.45";
    };
    provider.hcloud = { };
  }

  # All host base resources (servers, SSH firewalls, outputs)
  (lib.mkMerge (lib.mapAttrsToList mkHostResources hosts))

  # All host-specific extensions
  (lib.mkMerge (lib.mapAttrsToList mkHostExtensions hosts))
]
