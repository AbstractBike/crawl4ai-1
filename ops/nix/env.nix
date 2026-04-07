# Non-secret environment variables injected into the systemd service.
# For secrets, use secrets.nix with sops-nix.
{ lib, config, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.env = lib.mkOption {
    type        = lib.types.attrsOf lib.types.str;
    default     = {};
    description = "Non-secret environment variables for the service.";
    example     = { LOG_LEVEL = "info"; TZ = "UTC"; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.crawl4ai.environment = {
      LOG_LEVEL        = "info";
      OTEL_SERVICE_NAME = "crawl4ai";
    } // cfg.env;
  };
}
