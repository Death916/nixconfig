{ config, pkgs, ... }:

let
  dbUser = "death916";
  dbPass = "";
  dbName = "juicefs";

  mountPoint = "/mnt/myjfs";
  cacheDir = "/var/jfsCache";
  cacheSizeMiB = 20480;

  metaURL = "postgres://${dbUser}:${dbPass}@localhost:5432/${dbName}?sslmode=disable";
in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    dataDir = "/var/lib/postgresql/data";
    initialScript = pkgs.writeText "init-juicefs.sql" ''
      CREATE USER ${dbUser} WITH PASSWORD '${dbPass}';
      CREATE DATABASE ${dbName} OWNER ${dbUser};
    '';
  };

  environment.systemPackages = [ pkgs.juicefs ];

  systemd.tmpfiles.rules = [
    "d ${mountPoint} 0777 root users -"
    "d ${cacheDir}   0755 root root -"
  ];

  fileSystems."${mountPoint}" = {
    device = metaURL;
    fsType = "juicefs";
    options = [
      "_netdev"
      "allow_other"
      "cache-dir=${cacheDir}"
      "cache-size=${toString cacheSizeMiB}"
    ];
  };
}
