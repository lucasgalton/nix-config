{ config, pkgs, lib, ... }:

{
  # macOS-specific packages
  home.packages = with pkgs; [
    # macOS clipboard integration (already built-in but useful)
    pngpaste

    # macOS specific tools
    mas # Mac App Store CLI

    # GNU tools to replace BSD defaults
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    gnutar

    # JavaScript/TypeScript (macOS only)
    bun

    # Flutter (includes Dart) - macOS only
    flutter
  ];

  # macOS-specific shell configuration
  programs.zsh.initContent = lib.mkAfter ''
    # Homebrew (if installed alongside nix) - load first, then Nix takes priority
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Ensure Nix paths come BEFORE Homebrew
    export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

    # JetBrains Toolbox scripts
    if [[ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
      export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    fi
  '';

  # tmux clipboard configuration for macOS
  programs.tmux.extraConfig = lib.mkAfter ''
    # macOS clipboard
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
  '';
}
