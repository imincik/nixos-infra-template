{
  projectConfig,
  hostConfig,
  hostname,
  ...
}:

{
  # Variables
  variable = {
    ssh_public_key = {
      description = "SSH public key for initial access";
      type = "string";
    };
    server_type = {
      description = "Hetzner server type";
      type = "string";
      default = "cpx22";
    };
    server_location = {
      description = "Hetzner datacenter location";
      type = "string";
      default = "nbg1";
    };
  };

  # Outputs
  output = {
    server_ip = {
      value = "\${hcloud_server.${hostname}.ipv4_address}";
      description = "Server IPv4 address";
    };
    server_id = {
      value = "\${hcloud_server.${hostname}.id}";
      description = "Server ID";
    };
    deployment_cmd = {
      value = "nixos-anywhere --flake .#\${hcloud_server.${hostname}.name} root@\${hcloud_server.${hostname}.ipv4_address}";
      description = "NixOS deployment command";
    };
  };
}
