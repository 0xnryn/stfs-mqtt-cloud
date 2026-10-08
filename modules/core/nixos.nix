# Provides an option for declaring NixOS configurations.
# These configurations end up as flake outputs under `#nixosConfigurations."<name>"`.
# A check for the toplevel derivation of each configuration also ends
# under `#checks.<system>."configurations:nixos:<name>"`.
{ lib, config, inputs, ... }:
{
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = {
          system = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Target system architecture (e.g., aarch64-linux)";
          };

          specialArgs = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Extra arguments passed to lib.nixosSystem";
          };

          module = lib.mkOption {
            type = lib.types.deferredModule;
            description = "NixOS system module";
          };
        };
      }
    );
  };

  config.flake = {
    nixosConfigurations = lib.mapAttrs (
      name: cfg:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; } // cfg.specialArgs;
        modules = [
          cfg.module
        ] ++ lib.optional (cfg.system != null) {
          nixpkgs.hostPlatform = lib.mkDefault cfg.system;
        };
      }
    ) config.configurations.nixos;

    checks = lib.mkMerge (
      lib.mapAttrsToList (
        name: nixos: {
          ${nixos.config.nixpkgs.hostPlatform.system} = {
            "configurations:nixos:${name}" = nixos.config.system.build.toplevel;
          };
        }
      ) config.flake.nixosConfigurations
    );
  };
}