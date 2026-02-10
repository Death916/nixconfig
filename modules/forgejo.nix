{ config, pkgs, ... }:

{
  services.forgejo = {
    enable = true;
    database = {
      type = "postgres";
      user = "forgejo";
      name = "forgejo";
      socket = "/run/postgresql";
    };
    
    settings = {
      server = {
        DOMAIN = "git.death916.xyz";
        HTTP_PORT = 3050;
        ROOT_URL = "https://git.death916.xyz/";
        PROTOCOL = "http";
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3050 ];
}