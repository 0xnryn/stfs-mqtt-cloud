{ inputs, ... }:
{
  configurations.nixos = {
    "stfs-mqtt-cloud" = {
      system = "x86_64-linux";
      module = { modulesPath, ... }:
      let
        hostName = "stfs-mqtt-cloud";
      in
      {
        imports = [
          "${modulesPath}/virtualisation/docker-image.nix"
          inputs.home-manager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          inputs.self.nixosModules.configuration
        ];
        boot.isContainer = true;
        system.stateVersion = "26.05";
        nixpkgs.hostPlatform = "x86_64-linux";
        time.timeZone = "Asia/Kolkata";
        i18n.defaultLocale = "en_US.UTF-8";
        networking = {
          networkmanager.enable = true;
          inherit hostName;
        };
        users.users.sudha = {
          isNormalUser = true;
          extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        };
        sops = {
          age.keyFile = "/var/lib/sops-nix/key.txt";
          defaultSopsFile = ../secrets/${hostName}.yaml; # Relative path to your encrypted sops file
          defaultSopsFormat = "yaml";
          secrets = {
            "datalogger_passwd" = {
              owner = "mosquitto"; # Mosquitto daemon must own this file
            };
            "datalogger_admin_passwd" = {
              owner = "mosquitto"; # Mosquitto daemon must own this file
            };
            "cloudflare" = {
              owner = "cloudflared";
              group = "cloudflared"; # Explicitly setting group prevents sops-nix auto-lookup error
            };
          };
        };
      };
    };
  };
}