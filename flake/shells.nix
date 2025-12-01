{ inputs, projectConfig, ... }:

{
  perSystem =
    {
      system,
      config,
      pkgs,
      lib,
      ...
    }:

    let
      packages = [
      ];
      pythonPackages = [
      ];
      pythonEnv = (pkgs.python3.withPackages (p: pythonPackages));
    in
    {
      # Development environment
      devShells.default = pkgs.mkShell {
        packages = packages ++ [ pythonEnv ];
        shellHook =
          let
            inherit (pkgs) lib;
            packagesList = lib.map (p: p.pname) packages;
            pythonPackagesList = lib.map (p: p.pname) pythonPackages;
          in
          ''
            function dev-help {
              echo -e "\n🚀 Development environment"
              echo
              echo "${lib.replaceString "\n" "\ \n" projectConfig.systemBanner}"
              echo "Packages: ${lib.concatStringsSep ", " packagesList}"
              echo "Python packages: ${lib.concatStringsSep ", " pythonPackagesList}"
              echo "Python: ${lib.getExe pythonEnv}"
              echo
              echo "Run 'dev-help' to see this message again."
            }
            dev-help
            echo -e "\nInstalling pre-commit hooks ..."
            ${config.pre-commit.installationScript}
          '';
      };

      # Sysadmin environment
      devShells.admin = pkgs.mkShell {
        packages = [
          # Secrets management
          inputs.agenix.packages.${system}.agenix
          pkgs.rage

          # Deployment
          pkgs.hcloud
          pkgs.opentofu
          inputs.terranix.packages.${system}.default
          inputs.nixos-anywhere.packages.${system}.default
        ];
        shellHook = ''
          echo -e "\n🚀 Admin environment"
          echo
          echo "See README.md file for deployment instructions."
        '';
      };
    };
}
