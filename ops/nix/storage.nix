# Persistent state directories + impermanence declarations.
# backup.nix uses stateDirs as restic include paths.
{ lib, config, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.storage = {
    stateDir = lib.mkOption {
      type        = lib.types.str;
      default     = "/var/lib/crawl4ai";
      description = "Primary data directory for the service.";
    };
    stateDirs = lib.mkOption {
      type        = lib.types.listOf lib.types.str;
      description = "All directories to persist across reboots.";
    };
  };

  config = lib.mkIf cfg.enable {
    pinpkgs.crawl4ai.storage.stateDirs = lib.mkDefault [ cfg.storage.stateDir ];

    systemd.tmpfiles.rules = [
      "d ${cfg.storage.stateDir} 0750 ${cfg.user} ${cfg.group} -"
    ];

    # impermanence — uncomment if host uses catalog.impermanence
    # environment.persistence."/persist".directories =
    #   map (d: { directory = d; user = cfg.user; group = cfg.group; }) cfg.storage.stateDirs;
  };
}
