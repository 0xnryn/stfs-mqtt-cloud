# Provides an option for declaring Home Manager configurations.
# These configurations end up as flake outputs under `#homeConfigurations."<name>"`.
# A check for the activation package of each configuration also ends up
# under `#checks.<system>."configurations:home:<name>"`.
{ lib, config, inputs, ... }:
{
  options.configurations.home = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = {
          system = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Target system architecture (e.g., aarch64-linux, x86_64-linux)";
          };

          pkgs = lib.mkOption {
            type = lib.types.nullOr lib.types.raw;
            default = null;
            description = "Explicit nixpkgs package set (optional if 'system' is provided)";
          };

          extraSpecialArgs = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Extra arguments passed to homeManagerConfiguration";
          };

          module = lib.mkOption {
            type = lib.types.deferredModule;
            description = "Home Manager configuration module";
          };
        };
      }
    );
  };

  config.flake = {
    homeConfigurations = lib.mapAttrs (
      name: cfg:
      let
        pkgs =
          if cfg.pkgs != null then
            cfg.pkgs
          else if cfg.system != null then
            inputs.nixpkgs.legacyPackages.${cfg.system}
          else
            throw "configurations.home.\"${name}\": either 'system' or 'pkgs' must be specified.";
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; } // cfg.extraSpecialArgs;
        modules = [
          cfg.module
        ];
      }
    ) config.configurations.home;

    checks = lib.mkMerge (
      lib.mapAttrsToList (
        name: hm: {
          ${hm.pkgs.stdenv.hostPlatform.system} = {
            "configurations:home:${name}" = hm.activationPackage;
          };
        }
      ) config.flake.homeConfigurations
    );
  };
}