{ inputs, ... }:

{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:

    {
      pre-commit.settings.hooks = {
        nixfmt-rfc-style.enable = true;
      };
    };
}
