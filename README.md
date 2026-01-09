# Home Manager Configuration

Cross-platform dotfiles and development environment managed with Nix.

## Quick Start (macOS)

```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Restart your terminal, then apply config
nix run home-manager -- switch --flake ~/.config/home-manager

# 3. Set zsh as default shell
echo ~/.nix-profile/bin/zsh | sudo tee -a /etc/shells
chsh -s ~/.nix-profile/bin/zsh

# 4. Restart terminal - done!
```

## Quick Start (WSL / Linux)

```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Restart your terminal

# 3. Add your hostname to flake.nix
#    Run `hostname` to get it, then edit flake.nix line 74:
#    "root@YOURWSLHOSTNAME" -> "root@actualhostname"

# 4. Apply config
nix run home-manager -- switch --flake ~/.config/home-manager

# 5. Set zsh as default shell
echo ~/.nix-profile/bin/zsh | sudo tee -a /etc/shells
chsh -s ~/.nix-profile/bin/zsh

# 6. Restart terminal - done!
```

## Updating

After changing any `.nix` files:

```bash
home-manager switch --flake ~/.config/home-manager
```

Update all packages to latest versions:

```bash
cd ~/.config/home-manager
nix flake update
home-manager switch --flake .
```

## Rollback

If something breaks:

```bash
home-manager rollback
```

## What's Included

| Category | Tools |
|----------|-------|
| Shell | zsh, starship prompt, fzf, zoxide, eza, bat, ripgrep |
| Editor | neovim |
| Git | git, delta (diffs), lazygit (TUI), gh (GitHub CLI) |
| Go | go, gopls, golangci-lint, delve |
| Node | nodejs, npm, pnpm, typescript |
| K8s | kubectl, kubecolor, kubie, stern, k9s, helm, kustomize |
| Containers | podman, podman-compose, dive, skopeo |
| IaC | opentofu (terraform fork), ansible, sops |

## Adding a New Machine

1. Get the hostname: `hostname`
2. Add to `flake.nix` in `homeConfigurations`:
   ```nix
   "username@hostname" = mkHome <configName>;
   ```
3. Run `home-manager switch --flake .`
