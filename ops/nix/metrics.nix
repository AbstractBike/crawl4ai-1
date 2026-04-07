# Prometheus scrape config — consumed by otelcol/nixos.nix extraScrapeConfigs.
{ lib, config, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.metrics = {
    path     = lib.mkOption { type = lib.types.str; default = "/metrics"; };
    port     = lib.mkOption { type = lib.types.port; description = "Metrics scrape port"; };
    interval = lib.mkOption { type = lib.types.str; default = "15s"; };
    labels   = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = { service = "crawl4ai"; }; };
  };

  config = lib.mkIf cfg.enable {
    pinpkgs.crawl4ai.metrics.port = lib.mkDefault cfg.ports.metrics;

    # Adds this service to otelcol's scrape list
    # services.otelcol-obs.extraScrapeConfigs = [{
    #   job_name       = "crawl4ai";
    #   scrape_interval = cfg.metrics.interval;
    #   static_configs  = [{ targets = [ "127.0.0.1:${toString cfg.metrics.port}" ]; labels = cfg.metrics.labels; }];
    #   metrics_path    = cfg.metrics.path;
    # }];
  };
}
