# NixOS Infrastructure

Infrastructure as Code using [nixos-framework](https://github.com/imincik/nixos-framework).

## Quick Start

1. **Update configuration**
   - Edit `config.nix` with your admin user, email, and SSH key
   - Update `hosts/example/config.nix` with your domain
   - Customize `hosts/example/services.nix` with your services
   - Set environment: `echo dev > environment.txt` (or `prod`)

2. **Test locally with VM**
   ```bash
   nix run .#example-vm
   ```

3. **Deploy to cloud (optional)**
   See the [main project documentation](https://github.com/imincik/nixos-framework) for:
   - Infrastructure deployment (Terraform/OpenTofu)
   - Secrets management (agenix)
   - Profiles for code reuse
   - Testing with NixOS tests
   - CI/CD integration

## Project Structure

```
.
├── flake.nix              # Main flake configuration
├── config.nix             # Project-wide settings
├── environment.txt        # Environment (dev/prod)
├── hosts.nix              # List of hosts
├── deployments.nix        # Deployment configurations
├── tests.nix              # Test configurations
├── hosts/
│   └── example/           # Example host configuration
│       ├── default.nix    # Main host config
│       ├── config.nix     # Host metadata
│       ├── disks.nix      # Disk configuration
│       ├── hardware.nix   # Hardware configuration
│       ├── infra.nix      # Infrastructure settings
│       ├── services.nix   # Services configuration
│       ├── test.nix       # Host tests
│       └── development.nix # Development overrides
└── secrets/               # Encrypted secrets (agenix)
```

## Adding More Hosts

1. Create `hosts/<hostname>/` directory with configuration files
2. Add host to `hosts.nix`: `newhostname = mkHost "newhostname";`
3. Add to `deployments.nix` (if deploying to cloud)
4. Add to `tests.nix` (if adding tests)

## Next Steps

- Organize shared configuration into `profiles/` directory
- Set up cloud deployment: create `infra/` directory
- Add encrypted secrets in `secrets/`
- Run tests with `nix flake check`

## Documentation

Full documentation: https://github.com/imincik/nixos-framework
