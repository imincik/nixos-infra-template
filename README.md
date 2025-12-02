# NixOS infrastructure template

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

Then,

* Run `nix develop` to launch local shell environment

* Or run `nix run .#<hostname>-vm` to launch VM


## Shell environment

1. Launch local shell environment

```bash
  nix develop
```


## NixOS system

### New host

1. Add new host to `hosts.nix` file

1. Create host configuration in `hosts/<hostname>` directory and
   **add all files to Git**

1. Include relevant [profiles](profiles/) in `default.nix` file

1. Implement host specific configuration in `services.nix` file.
   See [NixOS options](https://search.nixos.org/options)

1. Optionally, implement host specific development configuration in
   `development.nix` file

1. Test host configuration

```bash
  nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Virtual machine

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

## Tests

1. Run all tests

```bash
  nix flake check
```

## Secrets management

1. Create identities (users and/or systems able to use secrets) and secrets in
   [secrets/secrets.nix](secrets/secrets.nix) file

1. Activate admin shell environment and change directory

```bash
  nix develop .#admin
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
tools are provided by deployment (admin) shell environment.

1. Add host to `deployment.nix` file (do only once)

1. Enter deployment (admin) shell environment
```bash
  nix develop .#admin
```

1. Set environment to `prod`
```bash
  echo prod > environment.txt
```

1. Move to host directory and set some variables
```bash
  cd hosts/<hostname>

  DEPLOY_HOSTNAME=$(basename "$PWD")
  DEPLOY_SSH_OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
```

1. Create `.env` file containing Hetzner API Token (do only once)
```bash
# .env

# Hetzner Cloud API Token
# Get it from: https://console.hetzner.cloud/ → Your Project → Security → API Tokens
export HCLOUD_TOKEN="<TOKEN>"
```

1. Create terraform variables file `terraform.tfvars` (do only once)
```bash
# terraform.tfvars

# SSH public key for server access
# Get it with: cat ~/.ssh/id_rsa.pub
ssh_public_key = ""

# Optional: Override defaults
server_type = "cpx22"
server_location = "nbg1"
```

1. Build terraform configuration
```bash
  source .env
  nix build .#terraformConfigurations.$DEPLOY_HOSTNAME -o config.tf.json
```

1. Initialize terraform environment (run only once)
```bash
  tofu init
```

1. Deploy initial resources (ssh key, firewall, initial server, ...)
```bash
  tofu apply
  DEPLOY_IP_ADDRESS=$(tofu output -raw server_ip)
```

1. Deploy NixOS server
```bash
  nixos-anywhere --flake .#$DEPLOY_HOSTNAME root@$DEPLOY_IP_ADDRESS
```

1. Test connection to NixOS server
```bash
  ssh $DEPLOY_SSH_OPTIONS admin@$DEPLOY_IP_ADDRESS "uname -a"
```

1. Upload secrets decryption key
```bash
  ssh $DEPLOY_SSH_OPTIONS admin@$DEPLOY_IP_ADDRESS "sudo mkdir /root/.agenix"
  scp $DEPLOY_SSH_OPTIONS id_ed25519_admin admin@$DEPLOY_IP_ADDRESS:/tmp/agenix.key
  ssh $DEPLOY_SSH_OPTIONS admin@$DEPLOY_IP_ADDRESS "sudo mv /tmp/agenix.key /root/.agenix/agenix.key"

  ssh $DEPLOY_SSH_OPTIONS admin@$DEPLOY_IP_ADDRESS "sudo restart"
```
