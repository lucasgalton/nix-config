{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/zsh.nix
    ./modules/tmux.nix
    ./modules/git.nix
    ./modules/dev-tools.nix
    ./modules/kubernetes.nix
    ./modules/claude.nix
    ./modules/neovim.nix
  ];

  # Enable catppuccin theming
  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Base packages available on all systems
  home.packages = with pkgs; [
    # Core utilities
    coreutils
    watch
    curl
    wget
    jq
    yq-go
    ripgrep
    fd
    bat
    eza
    tree
    htop
    ncdu
    unzip
    zip

    # Development
    gnumake
    direnv
    mynav
    lazyssh

    # Networking
    httpie
    dnsutils
  ];

  # XDG Base Directory specification
  xdg.enable = true;

  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
