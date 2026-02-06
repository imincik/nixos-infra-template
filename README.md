# NixOS Framework

## Quick Start

On Non-NixOS system, install Nix [(learn more)](https://zero-to-nix.com/start/install):

```bash
curl --proto '=https' --tlsv1.2 -sSf \
  -L https://install.determinate.systems/nix \
  | sh -s -- install
```

On NixOS system, enable flakes in your configuration:

```nix
nix.settings = {
  trusted-users = [ "root" "@wheel" ];
  experimental-features = [ "flakes" "nix-command" ];
};
```

### Create a New Project

Initialize a new NixOS infrastructure project:

```bash
nix flake init -t github:imincik/nixos-framework
```

### Test Locally

Run the example host in a VM:

```bash
nix run .#example-vm
```


## Usage in Your Project

Import the framework in your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-framework.url = "github:imincik/nixos-framework";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.nixos-framework.flakeModules.default ];

      nixosFramework = {
        enable = true;
        rootPath = ./.;
        projectConfig = {
          configRevision = if self ? rev then self.rev else "dirty";
          environmentName = "dev";  # or "prod"
          # ... your project config
        };
      };
    };
}
```


## Commercial support

Considering [Nix/NixOS](https://nixos.org/) or already using it and need expert
help? Get in touch with [me](https://www.imincik.com).
