# https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs
{
  projectConfig,
  hostConfig,
  hostname,
  ...
}:

{
  resource = {
    # HTTPS firewall rule
    hcloud_firewall."${hostname}-https" = {
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
      ];
    };

    # Extend the server configuration to include HTTPS firewall
    hcloud_server.${hostname} = {
      firewall_ids = [ "\${hcloud_firewall.${hostname}-https.id}" ];
    };
  };
}
