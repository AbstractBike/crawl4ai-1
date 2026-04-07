# Network namespace, VPN membership, bind address.
{ lib, config, ... }:
let cfg = config.pinpkgs.crawl4ai; in {
  options.pinpkgs.crawl4ai.network = {
    bindAddress = lib.mkOption { type = lib.types.str; default = "0.0.0.0"; description = "Address to bind the service to"; };
    vpn.enable  = lib.mkOption { type = lib.types.bool; default = false; description = "Route service traffic through VPN"; };
    vpn.interface = lib.mkOption { type = lib.types.str; default = "wg0"; description = "VPN interface name"; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.crawl4ai.environment.BIND_ADDRESS = cfg.network.bindAddress;
    # vpn wiring: add to WireGuard peers in catalog/networking/wireguard.nix
  };
}
