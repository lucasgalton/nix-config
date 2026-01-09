{ config, pkgs, lib, ... }:

{
  # Claude Code settings
  home.file.".claude/settings.json".text = builtins.toJSON {
    permissions = {
      allow = [
        "Bash(git commit:*)"
      ];
      deny = [];
    };
  };

  # Plugin metadata
  home.file.".claude/plugins/repos/nix-managed/.claude-plugin/plugin.json".text = builtins.toJSON {
    name = "nix-managed";
    displayName = "Nix-Managed Skills";
    description = "Custom skills managed via Home Manager";
    version = "1.0.0";
  };

  # Skills directory - just put .md files in ~/.config/home-manager/skills/
  # Structure: skills/my-skill/SKILL.md
  home.file.".claude/plugins/repos/nix-managed/skills" = {
    source = ../skills;
    recursive = true;
  };

  # Register the plugin
  home.file.".claude/plugins/config.json".text = builtins.toJSON {
    repositories = {
      "nix-managed" = {
        path = "${config.home.homeDirectory}/.claude/plugins/repos/nix-managed";
      };
    };
  };

  # Note: Install Claude Code manually after first activation:
  # npm install -g @anthropic-ai/claude-code
}
