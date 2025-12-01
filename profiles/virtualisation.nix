{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Add more disk and memory space
  virtualisation = {
    diskSize = 20 * 1024;
  };

  virtualisation.vmVariant = {
    virtualisation = {
      diskSize = 20 * 1024;
      memorySize = 4 * 1024;
    };
  };
}
