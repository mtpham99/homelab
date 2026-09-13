{
  description = "mtpham99's homelab flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11-small";

    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      git-hooks,
      treefmt-nix,
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

      treefmtEval = forAllSystemsPkgs (
        pkgs:
        treefmt-nix.lib.evalModule (pkgs) {
          programs.prettier.enable = true;
          programs.nixfmt.enable = true;
          programs.taplo.enable = true;
          programs.terraform = {
            enable = true;
            package = pkgs.opentofu;
          };
        }
      );
    in
    {
      # `nixos-rebuild { build | switch | ... } --flake .#<hostname>`
      nixosConfigurations = { };

      # `nix develop`
      devShells = forAllSystemsPkgs (pkgs: {
        default = import ./nix/shells/devshell.nix { inherit pkgs; };
      });

      # `nix flake check`
      checks = forAllSystemsPkgs (pkgs: {
        git-hooks = git-hooks.lib.${pkgs.system}.run {
          src = ./.;
          hooks = {
            trim-trailing-whitespace.enable = true;
          };
        };
        betterleaks =
          pkgs.runCommand "betterleaks"
            {
              nativeBuildInputs = [ pkgs.betterleaks ];
            }
            ''
              mkdir $out
              cd ${self}
              betterleaks dir ./. --config ./.betterleaks.toml
            '';
        treefmt = treefmtEval.${pkgs.system}.config.build.check self;
      });

      # `nix fmt`
      formatter = forAllSystemsPkgs (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
    };
}
