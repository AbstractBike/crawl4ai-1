# Feature toggles injected as FEATURE_<NAME>=true/false env vars.
{ lib, config, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.featureFlags = lib.mkOption {
    type        = lib.types.attrsOf lib.types.bool;
    default     = {};
    description = "Feature flags injected as FEATURE_<NAME>=true/false environment variables.";
    example     = { new_dashboard = true; legacy_api = false; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.crawl4ai.environment = lib.mapAttrs'
      (name: val: lib.nameValuePair
        "FEATURE_${lib.toUpper (builtins.replaceStrings ["-"] ["_"] name)}"
        (if val then "true" else "false"))
      cfg.featureFlags;
  };
}
