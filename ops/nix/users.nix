# System user and group for the service process.
{ lib, config, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai = {
    user  = lib.mkOption { type = lib.types.str; default = "crawl4ai"; description = "System user for the service"; };
    group = lib.mkOption { type = lib.types.str; default = "crawl4ai"; description = "System group for the service"; };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group        = cfg.group;
      description  = "crawl4ai service user";
    };
    users.groups.${cfg.group} = {};
  };
}
