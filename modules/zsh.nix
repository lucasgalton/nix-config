{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    # autosuggestion loaded manually via plugins to control order
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

      # Modern replacements (simple command swaps stay as aliases)
      ls = "eza -lah --icons --group-directories-first --git";
      ll = "eza -la --icons --group-directories-first --git";
      la = "eza -a --icons --group-directories-first --git";
      lt = "eza --tree --icons --group-directories-first --git";
      cat = "bat";

      # Simple single-letter shortcuts stay as aliases
      g = "git";
      k = "kubectl";
      d = "docker";
      p = "podman";

      # Misc simple replacements
      tf = "tofu";
      terraform = "tofu";
      vim = "nvim";
      vi = "nvim";
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

      # Autosuggestions strategy (abbreviations plugin loaded via plugins list)
      ZSH_AUTOSUGGEST_STRATEGY=(abbreviations history completion)
    '';

    plugins = [
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
      {
        name = "zsh-abbr";
        src = pkgs.zsh-abbr;
        file = "share/zsh/zsh-abbr/zsh-abbr.zsh";
      }
      {
        name = "zsh-autosuggestions-abbreviations-strategy";
        src = pkgs.zsh-autosuggestions-abbreviations-strategy;
        file = "share/zsh/site-functions/zsh-autosuggestions-abbreviations-strategy.plugin.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
    ];

  };

  # zsh-abbr abbreviations (expanded inline as you type, unlike aliases)
  xdg.configFile."zsh/abbreviations".text = ''
    # Git commands (expanded so you see full command before running)
    abbr gs="git status"
    abbr gd="git diff"
    abbr ga="git add"
    abbr gc="git commit"
    abbr gp="git push"
    abbr gl="git pull"
    abbr gco="git checkout"
    abbr gb="git branch"
    abbr glog="git log --oneline --graph --decorate"

    # Kubernetes (complex commands benefit from expansion)
    abbr kx="kubie ctx"
    abbr kn="kubie ns"
    abbr kgp="kubectl get pods"
    abbr kgs="kubectl get svc"
    abbr kgd="kubectl get deployments"
    abbr kga="kubectl get all"
    abbr kgn="kubectl get namespaces"
    abbr klogs="kubectl logs -f"
    abbr kdesc="kubectl describe"
    abbr kexec="kubectl exec -it"
    abbr kep="kubectl edit pod"
    abbr ked="kubectl edit deployment"
    abbr kes="kubectl edit svc"
    abbr kaf="kubectl apply -f"
    abbr kdf="kubectl delete -f"
    abbr krr="kubectl rollout restart"

    # Docker/Podman
    abbr dc="docker compose"
    abbr pc="podman-compose"
    abbr dps="docker ps"
    abbr dpa="docker ps -a"
    abbr di="docker images"
    abbr drm="docker rm"
    abbr drmi="docker rmi"
  '';

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

  # Starship prompt - single line, minimal left, info on right
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Single line prompt format
      format = lib.concatStrings [
        "$directory"
        "$character"
      ];

      # Right side with git and kubernetes info
      right_format = lib.concatStrings [
        "$git_branch"
        "$git_status"
        "$kubernetes"
        "$cmd_duration"
      ];

      # Minimal directory display
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
        format = "[$path]($style) ";
      };

      # Clean character prompt
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
        vimcmd_symbol = "[](bold green)";
      };

      # Git branch
      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };

      # Git status with symbols
      git_status = {
        style = "bold yellow";
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = "=";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        untracked = "?$count";
        stashed = "*$count";
        modified = "!$count";
        staged = "+$count";
        renamed = "»$count";
        deleted = "✘$count";
      };

      # Kubernetes context (uses kubie)
      kubernetes = {
        disabled = false;
        symbol = "⎈ ";
        style = "bold blue";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
        # Only show when in a k8s-related directory or context is set
        detect_files = ["Dockerfile" "docker-compose.yml" "docker-compose.yaml" "helmfile.yaml" "Chart.yaml" "kustomization.yaml" "Tiltfile"];
        detect_folders = ["charts" "kustomize" "k8s" "kubernetes" "manifests"];
        detect_extensions = [];
      };

      # Command duration (only show if > 2 seconds)
      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
        format = "[$duration]($style) ";
      };

      # Disable modules we don't need for cleaner prompt
      aws.disabled = true;
      azure.disabled = true;
      gcloud.disabled = true;
      package.disabled = true;
      nodejs.disabled = true;
      python.disabled = true;
      golang.disabled = true;
      rust.disabled = true;
      java.disabled = true;
      php.disabled = true;
      ruby.disabled = true;
      terraform.disabled = true;
      docker_context.disabled = true;
    };
  };
}
