{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Lucas Galton";
        email = "lucas@galton.fr";
      };

      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
        lg = "log --oneline --graph --decorate --all";
        amend = "commit --amend --no-edit";
        undo = "reset --soft HEAD~1";
        wip = "commit -am 'WIP'";
        branches = "branch -a";
        tags = "tag -l";
        remotes = "remote -v";
        stashes = "stash list";
        prune-branches = "!git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
      rerere.enabled = true;

      core = {
        editor = "nvim";
        autocrlf = "input";
        whitespace = "trailing-space,space-before-tab";
      };

      color = {
        ui = true;
        diff = "auto";
        status = "auto";
        branch = "auto";
      };
    };

    ignores = [
      # OS
      ".DS_Store"
      "Thumbs.db"

      # Editors
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "*.sublime-*"

      # Nix
      "result"
      "result-*"

      # Environment
      ".env"
      ".env.local"
      ".envrc"

      # Dependencies
      "node_modules/"
      "vendor/"
      "__pycache__/"
      "*.pyc"
    ];
  };

  # Delta for better diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      line-numbers = true;
      side-by-side = true;
    };
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # Lazygit for TUI git
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
      };
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
      };
    };
  };
}
