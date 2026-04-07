# NixOS VM integration tests via pkgs.testers.runNixOSTest.
# Exposed as flake.checks.${system}.test — run with: nix flake check
{ pkgs, ... }:
pkgs.testers.runNixOSTest {
  name = "crawl4ai-test";

  nodes.machine = { ... }: {
    imports = [ ./nixos.nix ];
    pinpkgs.crawl4ai.enable = true;
    # override options for testing:
    # pinpkgs.crawl4ai.storage.stateDir = "/tmp/crawl4ai-test";
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("crawl4ai.service")
    machine.wait_for_open_port(8080)
    machine.succeed("curl -sf http://localhost:8080/healthz")
    # add service-specific functional tests here
  '';
}
