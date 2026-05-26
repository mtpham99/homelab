{
  description = "mtpham99's homelab flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11-small";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      ...
    }@inputs:
    let
      allSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      pkgsForSystem = system: import nixpkgs { inherit system; };
      forAllSystems = fn: nixpkgs.lib.genAttrs allSystems fn;
      forAllSystemsPkgs = fn: forAllSystems (system: fn (pkgsForSystem system));
    in
    {
      # `nixos-rebuild { build | switch | ... } --flake .#<hostname>`
      nixosConfigurations = { };

      # `nix develop`
      devShells = forAllSystemsPkgs (pkgs: {
        default = import ./nix/devshell.nix { inherit pkgs; };
      });

      # `nix fmt`
      formatter = forAllSystemsPkgs (pkgs: pkgs.treefmt);
    };
}
