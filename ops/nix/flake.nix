{
  description = "Crawl4AI — LLM-friendly web crawler";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosModules.default = import ./nixos.nix;

      # uncomment when package.nix is populated
      # packages.${system}.default =
      #   pkgs.callPackage ./package.nix { src = self; };

      checks.${system}.test = import ./tests.nix { inherit pkgs; };
    };
}
