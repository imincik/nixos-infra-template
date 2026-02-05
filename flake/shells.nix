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

      # Deployment environment
      devShells.deployment = pkgs.mkShell {
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
          echo -e "\n🚀 Deployment environment"
          echo
          echo "See README.md file for deployment instructions."

          sshopts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

          function host-ssh {
            user=$(tofu output -raw admin_user)
            ip=$(tofu output -raw $1_server_ip)
            ssh $sshopts $user@$ip
          }

          function host-cmd {
            user=$(tofu output -raw admin_user)
            ip=$(tofu output -raw $1_server_ip)
            ssh $sshopts $user@$ip $2
          }

          function host-upload-key {
            user=$(tofu output -raw admin_user)
            ip=$(tofu output -raw $1_server_ip)
            host-cmd $1 "sudo mkdir -pv /root/.agenix"
            scp $sshopts $2 $user@$ip:/tmp/agenix.key
            host-cmd $1 "sudo mv -v /tmp/agenix.key /root/.agenix/agenix.key"
          }
        '';
      };
    };
}
