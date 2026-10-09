{ ... }:
{
  flake.nixosModules.configuration = { inputs, pkgs, config, ... }:
  {
    nixpkgs.config.allowUnfree = true;
    # Disable NixOS management of Docker-managed /etc files
    environment.etc."hosts".enable = false;
    environment.etc."hostname".enable = false;
    environment.systemPackages = with pkgs;
    [
      tree
      wget
      curl
      git
      nano
      htop
      mosquitto
      cloudflared
    ];

    services = {
      openssh.enable = true;
      mosquitto = 
      {
        enable = true;
        listeners = [
          {
            port = 3001;
            address = "127.0.0.1";
            settings = {
              protocol = "websockets";
            };
            
            # Users MUST be placed inside the listener they apply to
            users = {
              datalogger = {
                acl = [ 
                  "readwrite /datalogger/#"
                  "read /datalogger_admin/#"
                ];
                hashedPasswordFile = config.sops.secrets."datalogger_passwd".path; 
              };
              
              datalogger_admin = {
                acl = [
                  "readwrite /datalogger_admin/#"
                  "readwrite /datalogger/#"
                ];
                hashedPasswordFile = config.sops.secrets."datalogger_admin_passwd".path; 
              };
            };
          }
        ];
      };
      cloudflared = {
        enable = true;
        tunnels = {
          "76e3b76c-19ef-4d3f-beef-f441ee3ace61" = {
            credentialsFile = config.sops.secrets."cloudflare".path;
            ingress = {
              "mqtt.eltros.in" = "http://localhost:3001";        
            };
            default = "http_status:404";
          };
        };
      };
    };
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";
  };
}