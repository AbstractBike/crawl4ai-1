# Script that runs when the service fails (forensics, capture state, notify).
# Triggered via systemd OnFailure= — runs in a separate unit.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.hooks.postFailure = {
    script        = lib.mkOption { type = lib.types.lines; default = ""; description = "Shell script to run on service failure"; };
    notifyChannel = lib.mkOption { type = lib.types.str; default = ""; description = "Telegram/Slack channel for failure notification"; };
  };

  config = lib.mkIf (cfg.enable && cfg.hooks.postFailure.script != "") {
    systemd.services.crawl4ai-post-mortem = {
      description = "crawl4ai post-mortem forensics";
      serviceConfig = {
        Type     = "oneshot";
        User     = cfg.user;
        ExecStart = pkgs.writeShellScript "crawl4ai-post-mortem" cfg.hooks.postFailure.script;
      };
    };
    systemd.services.crawl4ai.unitConfig.OnFailure = "crawl4ai-post-mortem.service";
  };
}
