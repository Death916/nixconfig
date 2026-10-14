{ config, pkgs, lib, ... }:

let
  # restic has NO cache size limit. Its index+data cache used to live in
  # /var/cache/restic-backups-orac ON THE ROOT FILESYSTEM: 6.3G (3.5G index +
  # 2.9G data) during one run on 2026-10-13, and 12G measured 2026-10-14. It is
  # the single largest thing that has ever swung this 91G root fs and it refills
  # on every run. It now lives on JuiceFS (cacheDir), so root can no longer fill
  # from restic. The pre-flight guard is kept, pointed at the cache's own
  # filesystem: a failed ExecStartPre fails this unit visibly (the health
  # watchdog reports it) instead of silently skipping the backup.
  cacheDir = "/mnt/myjfs/restic-cache";
  minFreeKib = 10 * 1024 * 1024; # 10 GiB, in KiB to match `df -k`
  freeSpaceGuard = pkgs.writeShellScript "restic-free-space-guard" ''
    set -eu
    # FAIL CLOSED if JuiceFS is not mounted. Without this the cache would be
    # written to the bare /mnt/myjfs directory ON ROOT (it exists as a plain
    # dir when the mount is down) - the exact failure this change prevents.
    # grep is already in this unit's PATH; findmnt/mountpoint are not.
    if ! grep -q ' /mnt/myjfs fuse.juicefs ' /proc/mounts; then
      echo "refusing restic run: /mnt/myjfs is not a juicefs mount - the cache would land on root" >&2
      exit 1
    fi
    # NB: df's -P and --output are mutually exclusive; --output=avail is KiB free
    avail=$(df -k --output=avail ${cacheDir} 2>/dev/null | tail -1 || true)
    need=''${RESTIC_MIN_FREE_KIB:-${toString minFreeKib}}
    case "$avail" in
      "" | *[!0-9]*)
        echo "free-space guard: cannot read free space for ${cacheDir} (got '$avail') - refusing to start" >&2
        exit 1
        ;;
    esac
    if [ "$avail" -lt "$need" ]; then
      echo "refusing restic run: $((avail / 1024))M free on ${cacheDir}, need $((need / 1024))M" >&2
      exit 1
    fi
    echo "free-space guard ok: $((avail / 1024))M free on ${cacheDir}"
  '';
in
{

  # Dump JuiceFS PostgreSQL metadata before backup
  systemd.services."juicefs-metadata-dump" = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      EnvironmentFile = "/etc/nixos/secrets/juicefs.env";
    };
    script = ''
      ${pkgs.docker}/bin/docker exec postgres-for-juicefs \
        pg_dump -U death916 juicefs | ${pkgs.gzip}/bin/gzip > /root/juicefs-metadata.sql.gz
    '';
  };

  services.restic.backups.orac = {
    user = "root";
    initialize = true;
    passwordFile = "/etc/nixos/secrets/restic-auth";
    repository = "s3:d8j2.or.idrivee2-38.com/backups";
    environmentFile = "/etc/nixos/secrets/restic.env";
    paths = [
      "/home/"
      "/root"
      "/var/lib/"
      "/var/log/"
      "/etc/"
      "/mnt/myjfs/"
    ];

    exclude = [
      "/mnt/*/.accesslog"
      # Never back up our own cache into the repo it caches.
      cacheDir
      # Cargo target dirs for the fleet's build cards: pure build output,
      # regenerable, and billed per GB on iDrive e2 (standing rule: regenerable
      # data stays out of e2).
      "/mnt/myjfs/build"
    ];

    pruneOpts = [
      "--keep-hourly 48"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 5"
      # restic caches every pack prune touches, so an unbounded repack needs
      # ~11G of local cache on / (measured 2026-10-13, 228-snapshot shared repo).
      # Bound the work per run; prune is idempotent, so it converges over runs.
      "--max-repack-size 2G"
      "--repack-cacheable-only"
    ];
    extraBackupArgs = [
      "--verbose"
      "--exclude-caches"
      "--cleanup-cache"
    ];
    timerConfig = {
      OnCalendar = "00,06,12,18:00:00";
      Persistent = true;
      RandomizedDelaySec = "20m";
    };
  };

  systemd.services."restic-backups-orac" = {
    # The cache now lives on JuiceFS, so that mount must be up first; the guard
    # below fails closed if it is not.
    wants = [ "juicefs-metadata-dump.service" "docker-myjfs-mount-service.service" ];
    after = [ "juicefs-metadata-dump.service" "docker-myjfs-mount-service.service" ];
    # The nixpkgs restic module hardcodes
    # RESTIC_CACHE_DIR=/var/cache/restic-backups-orac (root fs). mkForce
    # re-points it for the backup, the prune AND the generated `restic-orac`
    # wrapper, so a manual run cannot refill root either. The module's
    # CacheDirectory= is left alone - it just leaves an empty /var/cache dir.
    environment.RESTIC_CACHE_DIR = lib.mkForce cacheDir;
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
      ExecStartPre = [ "${freeSpaceGuard}" ];
    };
  };

}
