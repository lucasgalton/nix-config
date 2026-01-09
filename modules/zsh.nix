{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Modern replacements
      ls = "eza -lah --icons --group-directories-first --git";
      ll = "eza -la --icons --group-directories-first --git";
      la = "eza -a --icons --group-directories-first --git";
      lt = "eza --tree --icons --group-directories-first --git";
      cat = "bat";

      # Git shortcuts
      g = "git";
      gs = "git status";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";

      # Kubernetes shortcuts
      k = "kubectl";
      kx = "kubie ctx";
      kn = "kubie ns";
      kgp = "kubectl get pods";
      kgs = "kubectl get svc";
      kgd = "kubectl get deployments";
      kga = "kubectl get all";
      kgn = "kubectl get namespaces";
      klogs = "kubectl logs -f";
      kdesc = "kubectl describe";
      kexec = "kubectl exec -it";

      # Docker/Podman
      d = "docker";
      dc = "docker compose";
      p = "podman";
      pc = "podman-compose";

      # Misc
      tf = "tofu";
      terraform = "tofu";
      vim = "nvim";
      vi = "nvim";

      # Node version management (fnm aliased as nvm)
      nvm = "fnm";
    };

    # Auto-start tmux in login shells (new terminal windows)
    profileExtra = ''
      if command -v tmux &> /dev/null \
         && [[ ! "$TERM" =~ screen ]] \
         && [[ ! "$TERM" =~ tmux ]] \
         && [[ -z "$TMUX" ]] \
         && [[ -t 0 ]] && [[ -t 1 ]] \
         && [[ "$TERMINAL_EMULATOR" != "JetBrains-JediTerm" ]] \
         && [[ "$TERM_PROGRAM" != "vscode" ]]; then
        exec tmux new-session -A -s main
      fi
    '';

    initContent = ''
      # Enable Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Better history search with arrow keys
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # Edit command in editor
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      # Word navigation
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

      # kubectl completion
      if command -v kubectl &> /dev/null; then
        source <(kubectl completion zsh)
        compdef kubecolor=kubectl
      fi

      # Stern completion
      if command -v stern &> /dev/null; then
        source <(stern --completion=zsh)
      fi

      # Use kubecolor instead of kubectl when available
      if command -v kubecolor &> /dev/null; then
        alias kubectl="kubecolor"
      fi

      # PATH additions
      export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"

      # Go environment
      export GOPATH="$HOME/go"

      # Editor
      export EDITOR="nvim"
      export VISUAL="nvim"

      # fnm (Fast Node Manager) - auto-switch node versions
      if command -v fnm &> /dev/null; then
        eval "$(fnm env --use-on-cd)"
      fi

      # Load Powerlevel10k config
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
      {
        name = "zsh-nix-shell";
        src = pkgs.zsh-nix-shell;
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];
  };

  # Powerlevel10k prompt
  home.file.".p10k.zsh".source = ../config/p10k.zsh;

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  # Zoxide for smart cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
