# TLS certificate management — ACME (Let's Encrypt) or internal PKI.
# certPath/keyPath are consumed by routing.nix for nginx TLS termination.
{ lib, config, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.certs = {
    acme.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Use ACME/Let's Encrypt"; };
    pki.enable  = lib.mkOption { type = lib.types.bool; default = false; description = "Use internal PKI (catalog.pki)"; };
    domain      = lib.mkOption { type = lib.types.str; default = "crawl4ai.pin"; };
    certPath    = lib.mkOption { type = lib.types.str; readOnly = true; description = "Path to TLS certificate (set by this module)"; };
    keyPath     = lib.mkOption { type = lib.types.str; readOnly = true; description = "Path to TLS key (set by this module)"; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.certs.acme.enable {
      security.acme.certs.${cfg.certs.domain}.group = cfg.group;
      pinpkgs.crawl4ai.certs.certPath = "/var/lib/acme/${cfg.certs.domain}/cert.pem";
      pinpkgs.crawl4ai.certs.keyPath  = "/var/lib/acme/${cfg.certs.domain}/key.pem";
    })
  ]);
}
