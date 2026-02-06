# NixOS Framework

## Quick start

On Non-NixOS system, install Nix
[(learn more about this installer)](https://zero-to-nix.com/start/install)

```bash
  curl --proto '=https' --tlsv1.2 -sSf \
    -L https://install.determinate.systems/nix \
    | sh -s -- install
```

On NixOS system, add following configuration and rebuild your system.

```nix
  nix.settings = {
    trusted-users = [ "root" "@wheel" "@trusted" ];
    experimental-features = [ "flakes" "nix-command" ];
  };
```

Then, run example host in a VM

```bash
  nix run .#example-vm
```

and deploy example host to Hetzner

```bash
  nix develop .#deployment

  echo "export HCLOUD_TOKEN=<HETZNER-TOKEN>" > .env
  source .env

  nix build .#terraformConfigurations.all -o config.tf.json

  tofu init
  tofu apply

  export DEPLOY_HOSTNAME=example
  nixos-anywhere --flake .#$DEPLOY_HOSTNAME root@$(tofu output -raw ${DEPLOY_HOSTNAME}_server_ip)
```


## NixOS system

### Adding new host

1. Add new host to `hosts.nix` file

1. Create host configuration in `hosts/<hostname>` directory and
   **add all files to Git**

1. Create `hosts/<hostname>/config.nix` with domain
```nix
{
  domain = "hostname.example.com";
}
```

1. Include relevant [profiles](profiles/) in `default.nix` file

1. Implement host specific configuration in `services.nix` file.
   See [NixOS options](https://search.nixos.org/options)

1. Optionally, implement host specific development configuration in
   `development.nix` file

1. Test host configuration

```bash
  nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Launching host in virtual machine

1. Run host in local VM

```bash
  nix run .#<hostname>-vm
```

### Development configuration (optional)

For convenience, VM development configuration can be activated by setting
environment type to `dev`:

```bash
  echo dev > environment.txt
```

### Adding tests for host

1. Add new host to `tests.nix` file

1. Implement test in `hosts/<hostname>/test.nix` file

1. Run all tests

```bash
  nix flake check
```

### Secrets management

1. Create identities (users and/or systems able to use secrets) and secrets in
   [secrets/secrets.nix](secrets/secrets.nix) file

1. Activate deployment shell environment and change directory

```bash
  nix develop .#deployment
  cd secrets
```

1. Create a encrypted file for each secret

```bash
  agenix --identity $HOME/.ssh/id_ed25519_nixos --edit <SECRET-FILE>
```

1. Re-key secrets

```bash
  agenix --identity $HOME/.ssh/id_ed25519_nixos --rekey
```

1. Test decryption

```bash
  agenix --identity <ADMIN-USER-SSH-KEY> --decrypt <SECRET-FILE>
```

Check out
[Agenix tutorial](https://github.com/ryantm/agenix/tree/main?tab=readme-ov-file#tutorial)
for information how to use secrets in configuration.


## Deployment

NixOS server deployment process is based on [OpenTofu](https://opentofu.org/)
and [NixOS Anywhere](https://github.com/nix-community/nixos-anywhere). Both
tools are provided by deployment shell environment.

All infrastructure (SSH key, firewalls, servers) is managed from a single
unified Terraform deployment in the project root directory.

### Infrastructure deployment

1. Add new hosts to `deployments.nix` file

1. Configure per-host infrastructure settings in `hosts/<hostname>/infra.nix`
```nix
{
  # Infrastructure configuration
  config = {
    server_type = "cx23";        # Hetzner server type
    server_location = "nbg1";    # Hetzner datacenter location
  };

  # Terraform resources (function)
  terraform = { projectConfig, hostname, hostConfig, ... }: {
    # Optional: Add host-specific firewalls, etc.
  };
}
```

1. Set environment to `prod`
```bash
  echo prod > environment.txt
```

1. Launch deployment shell environment
```bash
  nix develop .#deployment
```

1. Create `.env` file in project root containing Hetzner API Token (do only once)
```bash
# .env

# Hetzner Cloud API Token
# Get it from: https://console.hetzner.cloud/ → Your Project → Security → API Tokens
export HCLOUD_TOKEN="<TOKEN>"
```
```
  source .env
```

1. Build unified terraform configuration
```bash
  nix build .#terraformConfigurations.all -o config.tf.json
```

   **Note:** After modifying `deployments.nix` or host infrastructure settings
   in `infra.nix`, you must rebuild the configuration with this command before
   running `tofu apply`.

1. Initialize terraform environment (run only once)
```bash
  tofu init
```

1. Deploy all infrastructure (SSH key, firewalls, servers for all hosts)
```bash
  tofu apply
```

### Removing a host

1. Comment out or remove the host from `deployments.nix`

1. Rebuild terraform configuration
```bash
  nix build .#terraformConfigurations.all -o config.tf.json
```

1. Apply changes (Terraform will destroy the removed host)
```bash
  tofu apply
```

### NixOS installation (per host)

After infrastructure is deployed, install NixOS on each server:

1. Deploy NixOS to a specific host
```bash
  export DEPLOY_HOSTNAME=<hostname>
  nixos-anywhere --flake .#$DEPLOY_HOSTNAME root@$(tofu output -raw ${DEPLOY_HOSTNAME}_server_ip)
```

1. Deploy secrets decryption key
```bash
  export DEPLOY_SECRETS_DECRYPTION_KEY=~/.ssh/id_ed25519_secrets

  host-upload-key $DEPLOY_HOSTNAME $DEPLOY_SECRETS_DECRYPTION_KEY
  host-cmd $DEPLOY_HOSTNAME "sudo reboot"
```

Repeat for each host.


## Commercial support

Considering [Nix/NixOS](https://nixos.org/) or already using it and need expert
help? Get in touch with [me](https://www.imincik.com).
