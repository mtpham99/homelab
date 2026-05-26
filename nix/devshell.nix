{
  pkgs ? import <nixpkgs> { },
  useOpenTofu ? true,
  ...
}:

pkgs.mkShell {
  name = "homelab-devshell";

  packages = [
    pkgs.git
    pkgs.ansible
    pkgs.ansible-lint
    (if useOpenTofu then pkgs.opentofu else pkgs.terraform)

    pkgs.gnupg
    pkgs.pinentry-curses
    pkgs.sops
    pkgs.age

    pkgs.neovim

    pkgs.pre-commit
    pkgs.treefmt
    pkgs.prettier
    pkgs.nixfmt
    pkgs.taplo

    pkgs.jq
    pkgs.yq
  ];

  shellHook = ''
    # editor
    export EDITOR='${pkgs.neovim}/bin/nvim'
    export VISUAL='${pkgs.neovim}/bin/nvim'
    alias vi='${pkgs.neovim}/bin/nvim'
    alias vim='${pkgs.neovim}/bin/nvim'
    alias view='${pkgs.neovim}/bin/nvim -R'

    # enable flakes
    alias nix="nix --experimental-features 'nix-command flakes'"
  '';
}
