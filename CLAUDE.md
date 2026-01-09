# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cross-platform Home Manager configuration for managing development environments across:
- macOS (Apple Silicon & Intel)
- Linux (x86_64 & ARM)
- WSL (Ubuntu, running as root)

Target use case: Go developer working with Kubernetes and Ansible.

## Commands

```bash
# Apply configuration (auto-detects user@hostname)
home-manager switch --flake .

# Or explicitly select a config
home-manager switch --flake .#mac          # macOS Apple Silicon
home-manager switch --flake .#mac-intel    # macOS Intel
home-manager switch --flake .#wsl          # WSL (root)
home-manager switch --flake .#linux        # Linux x86_64

# Build without applying
home-manager build --flake .

# Update flake inputs
nix flake update

# Check for errors
nix flake check

# Rollback to previous generation
home-manager rollback
```

## Directory Structure

```
~/.config/home-manager/
├── flake.nix           # Flake definition with all host configs
├── home.nix            # Shared configuration (imports modules)
├── modules/
│   ├── zsh.nix         # Zsh + Starship + fzf + zoxide
│   ├── tmux.nix        # Tmux with Catppuccin theme
│   ├── git.nix         # Git + delta + lazygit + gh
│   ├── dev-tools.nix   # Go, Node, Python, Neovim, OpenTofu, Ansible
│   ├── kubernetes.nix  # kubectl, kubie, stern, k9s, helm, podman
│   └── claude.nix      # Claude Code settings and custom skills
└── hosts/
    ├── darwin.nix      # macOS-specific (clipboard, GNU tools)
    ├── linux.nix       # Linux-specific (clipboard, systemd)
    └── wsl.nix         # WSL-specific (Windows interop, clipboard)
```

## Architecture

**Flake-based** configuration using `mkHome` helper function that:
1. Sets system architecture and user details per host
2. Imports Catppuccin theming module
3. Imports shared `home.nix`
4. Imports host-specific module from `hosts/`

**Module pattern**: Each module in `modules/` is self-contained and configures one domain (shell, editor, git, k8s tools). Host modules in `hosts/` handle platform-specific overrides.

## Key Tools Installed

| Category | Tools |
|----------|-------|
| Shell | zsh, starship, fzf, zoxide, eza, bat, ripgrep, fd |
| Dev | go, gopls, golangci-lint, nodejs, python, neovim |
| K8s | kubectl, kubecolor, kubie, stern, k9s, helm, kustomize |
| Containers | podman, podman-compose, dive, skopeo |
| IaC | opentofu (tf/terraform alias), ansible, ansible-lint, sops |
| Git | git, delta, lazygit, gh |

## Nix Patterns Used

- `lib.mkAfter` - append to existing config in host overrides
- `lib.mkForce` - override parent module values
- `with pkgs;` - bring all packages into scope for cleaner lists
- `xdg.configFile` - manage dotfiles in XDG config directory
- `programs.<name>.enable = true` - use Home Manager program modules

## Adding New Configurations

**New package**: Add to `home.packages` in `home.nix` or appropriate module.

**New program module**: Create `modules/name.nix`, import in `home.nix`.

**Host-specific override**: Use `lib.mkAfter` in host file to append, or `lib.mkForce` to replace.

**New host**: Add entry to `homeConfigurations` in `flake.nix` using `mkHome`.

**New Claude skill**: Add to `modules/claude.nix`:
```nix
home.file.".claude/plugins/repos/nix-managed/skills/my-skill/SKILL.md".text = ''
  ---
  name: my-skill
  description: What this skill does
  ---
  # My Skill
  Instructions...
'';
```

## Common Pitfalls to Avoid

### 1. Paths in Scripts/Configs

**NEVER use `~` or `$HOME` in paths** that will be executed by subprocesses (tmux hooks, scripts run by plugins). These environments don't inherit shell expansion or the user's PATH.

**ALWAYS use Nix interpolation:**
```nix
# Bad
set -g @some-hook '~/.config/script.sh'
set -g @some-hook '$HOME/.config/script.sh'

# Good
set -g @some-hook '${config.home.homeDirectory}/.config/script.sh'
```

### 2. GNU vs BSD Tools in Scripts

Scripts executed by tmux/plugins run in a minimal environment without the Nix profile PATH. They will use macOS BSD tools (`/usr/bin/sed`) instead of GNU tools from Nix.

**ALWAYS use full Nix store paths for tools in scripts:**
```nix
xdg.configFile."script.sh".text = ''
  #!${pkgs.bash}/bin/bash
  ${pkgs.gnused}/bin/sed -i 's/foo/bar/' file
  ${pkgs.gnugrep}/bin/grep pattern file
  ${pkgs.coreutils}/bin/ls -la
'';
```

### 3. GNU sed vs BSD sed Syntax

GNU sed (from Nix) and BSD sed (macOS default) have different syntax:
```bash
# GNU sed - in-place edit without backup
sed -i 's/old/new/' file

# BSD sed - requires suffix (use empty string for no backup)
sed -i '' 's/old/new/' file
```

Since we use GNU sed from Nix, always use `-i` without `''`.

### 4. Process Matching in tmux-resurrect

The `@resurrect-processes` option matches process names from `ps`. Nix-wrapped binaries show full store paths.

```nix
# Use "~pattern" to match partial process names
set -g @resurrect-processes '"~nvim" "~kubectl"'  # Matches /nix/store/.../nvim
```

### 5. Testing Scripts Before Deploying

Always test scripts manually before relying on hooks:
```bash
# Run the script directly to catch errors
~/.config/tmux/my-script.sh

# Check for errors that might be swallowed in hook execution
bash -x ~/.config/tmux/my-script.sh
```
