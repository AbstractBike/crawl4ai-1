# Script that runs before service start (migrations, config validation, cache warm-up).
# Runs as ExecStartPre — service start is blocked until this completes.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.hooks.pre = {
    script  = lib.mkOption { type = lib.types.lines; default = ""; description = "Shell script to run before service start"; };
    timeout = lib.mkOption { type = lib.types.str; default = "30s"; };
  };

  config = lib.mkIf (cfg.enable && cfg.hooks.pre.script != "") {
    systemd.services.crawl4ai.serviceConfig = {
      ExecStartPre  = pkgs.writeShellScript "crawl4ai-pre-hook" cfg.hooks.pre.script;
      TimeoutStartSec = cfg.hooks.pre.timeout;
    };
  };
}
