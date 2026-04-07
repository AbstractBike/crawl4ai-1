# Script that runs after the service starts successfully.
# Use for smoke tests, cache invalidation, Temporal workflow signals.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.hooks.postSuccess = {
    script  = lib.mkOption { type = lib.types.lines; default = ""; description = "Shell script to run after successful start"; };
    timeout = lib.mkOption { type = lib.types.str; default = "10s"; };
  };

  config = lib.mkIf (cfg.enable && cfg.hooks.postSuccess.script != "") {
    systemd.services.crawl4ai.serviceConfig.ExecStartPost =
      pkgs.writeShellScript "crawl4ai-success-hook" cfg.hooks.postSuccess.script;
  };
}
