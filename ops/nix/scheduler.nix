# Systemd timers for periodic jobs of the service.
# Each timer generates a systemd.timers + systemd.services pair.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.scheduler.timers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        onCalendar     = lib.mkOption { type = lib.types.str; description = "systemd OnCalendar expression"; };
        command        = lib.mkOption { type = lib.types.str; description = "Command to run"; };
        persistent     = lib.mkOption { type = lib.types.bool; default = true; description = "Run on next boot if missed"; };
        randomizedDelay = lib.mkOption { type = lib.types.str; default = "5m"; description = "Randomize start by up to this amount"; };
      };
    });
    default     = {};
    description = "Named periodic jobs for this service.";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge (lib.mapAttrsToList (name: timer: {
    systemd.timers."crawl4ai-${name}" = {
      wantedBy  = [ "timers.target" ];
      timerConfig = {
        OnCalendar        = timer.onCalendar;
        Persistent        = timer.persistent;
        RandomizedDelaySec = timer.randomizedDelay;
      };
    };
    systemd.services."crawl4ai-${name}" = {
      description = "crawl4ai scheduled job: ${name}";
      serviceConfig = {
        Type     = "oneshot";
        User     = cfg.user;
        ExecStart = pkgs.writeShellScript "crawl4ai-${name}" timer.command;
      };
    };
  }) cfg.scheduler.timers));
}
