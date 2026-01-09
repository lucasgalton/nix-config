{ config, pkgs, lib, ... }:

{
  imports = [ ./linux.nix ];

  # WSL-specific packages
  home.packages = with pkgs; [
    wslu # WSL utilities
  ];

  # WSL-specific configuration
  programs.zsh.initContent = lib.mkAfter ''
    # WSL-specific settings

    # Use Windows browser for opening URLs
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
      export BROWSER="wslview"
    fi

    # Windows interop
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
      # Access Windows home
      export WINHOME="/mnt/c/Users/$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')"

      # Windows clipboard integration
      alias clip="clip.exe"
      alias paste="powershell.exe Get-Clipboard"
    fi
  '';

  # WSL clipboard for tmux
  programs.tmux.extraConfig = lib.mkAfter ''
    # WSL clipboard
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip.exe"
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "clip.exe"
  '';

  # Disable systemd in WSL if not using systemd
  systemd.user.startServices = lib.mkForce false;
}
