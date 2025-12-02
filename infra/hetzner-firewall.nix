# https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs
{
  projectConfig,
  hostConfig,
  hostname,
  ...
}:

{
  resource = {
    hcloud_firewall."${hostname}-ssh" = {
      name = "${hostname}-ssh";
      rule = [
        {
          direction = "in";
          protocol = "tcp";
          port = "22"; # SSH
          source_ips = [
            "0.0.0.0/0"
            "::/0"
          ];
          description = "Allow inbound traffic on port 22";
        }
      ];
    };
  };
}
