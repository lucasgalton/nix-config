{ config, pkgs, lib, ... }:

{
  # Linux-specific packages
  home.packages = with pkgs; [
    # Clipboard tools for Linux
    xclip
    xsel
    wl-clipboard # for Wayland

    # Linux-specific utilities
    pciutils
    usbutils
    lsof
    strace
  ];

  # Linux-specific tmux clipboard
  programs.tmux.extraConfig = lib.mkAfter ''
    # Linux clipboard (X11)
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
    bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
  '';

  # Linux-specific systemd user services
  systemd.user.startServices = "sd-switch";
}
