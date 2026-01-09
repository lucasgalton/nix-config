{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    baseIndex = 1;
    escapeTime = 10;
    keyMode = "vi";
    mouse = true;

    plugins = with pkgs.tmuxPlugins; [
      yank
      tmux-fzf
      {
        plugin = resurrect;
        extraConfig = ''
          # Session strategies for editors
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'

          # Capture and restore pane contents
          set -g @resurrect-capture-pane-contents 'on'

          # Additional programs to restore (nvim/claude commands cleaned by post-save hook)
          # Use "~nvim" pattern to match /nix/store/.../nvim
          set -g @resurrect-processes '"~nvim" claude ssh psql mysql sqlite3 "~kubectl" k9s "~stern" "~watch" htop btop lazygit "~npm run" "~go run" "~python"'

          # Save and restore shell history (experimental)
          set -g @resurrect-save-shell-history 'on'

          # Post-save hook to fix nvim and claude commands for proper restoration
          set -g @resurrect-hook-post-save-all '${config.home.homeDirectory}/.config/tmux/resurrect-post-save.sh'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '1'
        '';
      }
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_window_status_style 'rounded'
          set -g @catppuccin_window_number_position 'left'
          set -g @catppuccin_window_text ' #W'
          set -g @catppuccin_window_current_text ' #W'
          set -g @catppuccin_date_time_text '%d-%m %H:%M'
        '';
      }
    ];

    extraConfig = ''
      # Force zsh as login shell (fixes resurrect restoring wrong shell)
      set -g default-command "${pkgs.zsh}/bin/zsh -l"

      # Sensible defaults
      set -s escape-time 0
      set -g display-time 4000
      set -g status-interval 5
      set -g focus-events on
      bind-key C-p previous-window
      bind-key C-n next-window

      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Start panes at 1
      setw -g pane-base-index 1

      # Use emacs keybindings in the status line
      set-option -g status-keys emacs

      # Vi copy mode
      unbind-key -T copy-mode-vi v
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle

      # Better splits (use current path)
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Vim-like pane navigation (with prefix)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Smart pane switching with awareness of Vim splits
      # See: https://github.com/christoomey/vim-tmux-navigator
      vim_pattern='(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +$vim_pattern'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
      bind-key -n 'C-\' if-shell "$is_vim" 'send-keys C-\\' 'select-pane -l'
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l

      # Resize panes with Shift+Arrow
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Quick reload config
      bind r source-file ${config.home.homeDirectory}/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Session management
      bind S choose-session
      bind N new-session

      # Clear screen and history
      bind C-l send-keys 'C-l' \; clear-history
    '';
  };

  # Post-save script for tmux-resurrect to fix nvim and claude commands
  xdg.configFile."tmux/resurrect-post-save.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash

      # Use GNU sed from Nix (BSD sed doesn't support -E with capture groups properly)
      SED="${pkgs.gnused}/bin/sed"

      RESURRECT_FILE=$(readlink -f ${config.home.homeDirectory}/.tmux/resurrect/last)

      # Fix nixvim wrapper command (strip --cmd args, keep filename)
      $SED -i -E \
        's|:/nix/store/[^ ]*nvim --cmd .*/nix/store/[^ ]*$|:nvim|; s|:/nix/store/[^ ]*nvim --cmd .* ([^ ]+)$|:nvim \1|' \
        "$RESURRECT_FILE"

      # Fix claude command to include --resume with session ID
      while IFS= read -r line; do
        if echo "$line" | ${pkgs.gnugrep}/bin/grep -q $'\t:claude$'; then
          # Extract working directory from the pane line (field 8)
          dir=$(echo "$line" | cut -f8 | $SED 's/^://')

          if [ -n "$dir" ] && [ -d "$dir" ]; then
            # Convert directory to claude project path format (/ and . become -)
            project_path=$(echo "$dir" | $SED 's|[/.]|-|g')
            claude_project_dir="$HOME/.claude/projects/$project_path"

            if [ -d "$claude_project_dir" ]; then
              # Find most recent session file
              session_file=$(ls -t "$claude_project_dir"/*.jsonl 2>/dev/null | head -1)
              if [ -n "$session_file" ]; then
                session_id=$(basename "$session_file" .jsonl)
                # Replace :claude with :claude --resume <session-id>
                $SED -i "s|:claude$|:claude --resume $session_id|" "$RESURRECT_FILE"
              fi
            fi
          fi
        fi
      done < "$RESURRECT_FILE"
    '';
  };
}
