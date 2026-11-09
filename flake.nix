{
  description = "mtpham99's homelab flake";

  inputs = {
    nixpkgs-hci.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-hci-ceph.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-hcitest.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-hcitest-ceph.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-tools.url = "github:NixOS/nixpkgs/nixos-unstable";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs-tools";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs-tools";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-tools";

    sops.url = "github:Mic92/sops-nix";
    sops.inputs.nixpkgs.follows = "nixpkgs-tools";
  };

  outputs =
    {
      self,
      nixpkgs-hci,
      nixpkgs-hci-ceph,
      nixpkgs-hcitest,
      nixpkgs-hcitest-ceph,
      nixpkgs-tools,
      git-hooks,
      treefmt-nix,
      disko,
      sops,
      ...
    }@inputs:
    let
      # pure nix implementation of nixpkgs.lib.genAttrs
      # see: https://noogle.dev/f/lib/genAttrs/#implementation
      genAttrs =
        names: fn:
        builtins.listToAttrs (
          builtins.map (name: {
            inherit name;
            value = fn name;
          }) names
        );

      allSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = fn: genAttrs allSystems fn;
      forAllSystemsPkgs =
        input-nixpkgs: fn: forAllSystems (system: fn (input-nixpkgs.legacyPackages.${system}));

      treefmtEval = forAllSystemsPkgs nixpkgs-tools (
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
      # `nixos-rebuild < build | switch | ... > --flake .#<hostname>`
      nixosConfigurations =
        let
          mkHciHostConfig =
            let
              system = "x86_64-linux";
            in
            hostname:
            channels@{ os-nixpkgs, ceph-nixpkgs, ... }:
            os-nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                flake-inputs = inputs;
              };
              modules = [
                disko.nixosModules.disko
                sops.nixosModules.sops
                ./nix/hosts/${hostname}
                { networking.hostName = hostname; }
                { hci.ceph.package = ceph-nixpkgs.legacyPackages.${system}.ceph; }
              ];
            };

          hci-channels = {
            os-nixpkgs = nixpkgs-hci;
            ceph-nixpkgs = nixpkgs-hci-ceph;
          };
          hcitest-channels = {
            os-nixpkgs = nixpkgs-hcitest;
            ceph-nixpkgs = nixpkgs-hcitest-ceph;
          };
        in
        {
          hci01 = mkHciHostConfig "hci01" hci-channels;
          hci02 = mkHciHostConfig "hci02" hci-channels;
          hci03 = mkHciHostConfig "hci03" hci-channels;

          hcitest01 = mkHciHostConfig "hcitest01" hcitest-channels;
          hcitest02 = mkHciHostConfig "hcitest02" hcitest-channels;
          hcitest03 = mkHciHostConfig "hcitest03" hcitest-channels;
        };

      # `nix develop`
      devShells = forAllSystemsPkgs nixpkgs-tools (pkgs: {
        default = import ./nix/shells/devshell.nix { inherit pkgs; };
      });

      # `nix flake check`
      checks = forAllSystemsPkgs nixpkgs-tools (pkgs: {
        git-hooks = git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
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
              export HOME=$(mktemp -d)
              mkdir $out
              cd ${self}
              betterleaks dir ./. --config ./.betterleaks.toml
            '';
        treefmt = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });

      # `nix fmt`
      formatter = forAllSystemsPkgs nixpkgs-tools (
        pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper
      );
    };
}
