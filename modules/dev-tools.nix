{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Go
    go
    gopls
    golangci-lint
    delve
    go-tools # staticcheck, etc.
    gomodifytags
    gotests
    impl

    # Node.js version management
    fnm # Fast Node Manager (nvm alternative)
    nodePackages.npm
    nodePackages.pnpm
    nodePackages.typescript
    nodePackages.typescript-language-server

    # Python (for Ansible and scripting)
    python312
    python312Packages.pip
    python312Packages.virtualenv
    uv # Fast Python package manager

    # Infrastructure / DevOps
    opentofu # open-source terraform fork (aliased as 'tofu')
    ansible
    ansible-lint
    sops
    age

    # Rust
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    # Misc dev tools
    shellcheck
    shfmt
    yamllint
    pre-commit
    just
  ];
}
