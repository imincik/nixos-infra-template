# Host-specific infrastructure for example
{
  # Infrastructure configuration (used by terraform)
  config = {
    server_type = "cx23";
    server_location = "nbg1";
  };

  # Terraform resources (function)
  terraform =
    {
      projectConfig,
      hostname,
      hostConfig,
      ...
    }:
    {
      # HTTPS firewall
      resource.hcloud_firewall."${hostname}-https" = {
        name = "${hostname}-https";
        rule = [
          {
            direction = "in";
            protocol = "tcp";
            port = "443"; # HTTPS
            source_ips = [
              "0.0.0.0/0"
              "::/0"
            ];
            description = "Allow inbound traffic on port 443";
          }
          {
            direction = "in";
            protocol = "tcp";
            port = "80"; # HTTP
            source_ips = [
              "0.0.0.0/0"
              "::/0"
            ];
            description = "Allow inbound traffic on port 80 (needed by ACME)";
          }
        ];
      };

      # Extend server to include both SSH and HTTPS firewalls
      resource.hcloud_server.${hostname} = {
        firewall_ids = [
          "\${hcloud_firewall.${hostname}-ssh.id}"
          "\${hcloud_firewall.${hostname}-https.id}"
        ];
      };
    };
}
