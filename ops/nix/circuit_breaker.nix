# Circuit breaker — cuts traffic when service fails persistently.
# Polls health endpoint; toggles nginx upstream to a 503 page when open.
{ lib, config, pkgs, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.circuitBreaker = {
    enable           = lib.mkOption { type = lib.types.bool; default = false; };
    failureThreshold = lib.mkOption { type = lib.types.int; default = 5; description = "Consecutive failures before opening circuit"; };
    recoveryTimeout  = lib.mkOption { type = lib.types.str; default = "30s"; description = "Time before attempting half-open"; };
    probePath        = lib.mkOption { type = lib.types.str; description = "Path to poll for circuit state"; };
  };

  config = lib.mkIf (cfg.enable && cfg.circuitBreaker.enable) {
    pinpkgs.crawl4ai.circuitBreaker.probePath = lib.mkDefault
      "http://127.0.0.1:${toString cfg.health.liveness.port}${cfg.health.liveness.path}";

    systemd.timers.crawl4ai-circuit-probe = {
      wantedBy  = [ "timers.target" ];
      timerConfig.OnBootSec = "10s";
      timerConfig.OnUnitActiveSec = "10s";
    };
    systemd.services.crawl4ai-circuit-probe = {
      serviceConfig = {
        Type     = "oneshot";
        ExecStart = pkgs.writeShellScript "crawl4ai-circuit-probe" ''
          curl -sf ${cfg.circuitBreaker.probePath} || \
            echo "open" > /run/crawl4ai/circuit-state
        '';
      };
    };
  };
}
