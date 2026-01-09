{
  description = "Home Manager configuration for Lucas Galton";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, catppuccin, nixvim, ... }:
    let
      # Overlay to skip nodejs tests (they timeout on macOS)
      nodejsFixOverlay = final: prev: {
        nodejs = prev.nodejs.overrideAttrs (old: { doCheck = false; });
        nodejs-slim = prev.nodejs-slim.overrideAttrs (old: { doCheck = false; });
        nodejs_22 = prev.nodejs_22.overrideAttrs (old: { doCheck = false; });
        nodejs_20 = prev.nodejs_20.overrideAttrs (old: { doCheck = false; });
      };

      # Custom packages overlay
      customPackagesOverlay = final: prev: {
        mynav = final.buildGoModule rec {
          pname = "mynav";
          version = "2.2.0";

          src = final.fetchFromGitHub {
            owner = "GianlucaP106";
            repo = "mynav";
            rev = "v${version}";
            hash = "sha256-FaCFLfYjn6RKmh3Pnz/dniKGZAOMEICoLuzVLks9TB4=";
          };

          vendorHash = "sha256-EtPGBSW0deqRXO5iQjdgcySbvLSHa1gs25OBlImWWSM=";

          meta = with final.lib; {
            description = "Terminal-based workspace navigator and session manager";
            homepage = "https://github.com/GianlucaP106/mynav";
            license = licenses.mit;
            mainProgram = "mynav";
          };
        };

        lazyssh = final.buildGoModule rec {
          pname = "lazyssh";
          version = "0.3.0";

          src = final.fetchFromGitHub {
            owner = "Adembc";
            repo = "lazyssh";
            rev = "v${version}";
            hash = "sha256-6halWoLu9Vp6XU57wAQXaWBwKzqpnyoxJORzCbyeU5Q=";
          };

          vendorHash = "sha256-OMlpqe7FJDqgppxt4t8lJ1KnXICOh6MXVXoKkYJ74Ks=";

          postInstall = ''
            mv $out/bin/cmd $out/bin/lazyssh
          '';

          meta = with final.lib; {
            description = "Terminal-based SSH manager";
            homepage = "https://github.com/Adembc/lazyssh";
            license = licenses.mit;
            mainProgram = "lazyssh";
          };
        };
      };

      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ nodejsFixOverlay customPackagesOverlay ];
      };

      # Helper function to create a home-manager configuration
      mkHome = { system, username, homeDirectory, extraModules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          modules = [
            catppuccin.homeModules.catppuccin
            nixvim.homeModules.nixvim
            ./home.nix
            {
              home = {
                inherit username homeDirectory;
                stateVersion = "24.11";
              };
            }
          ] ++ extraModules;
        };

      # macOS config (Apple Silicon)
      darwinConfig = {
        system = "aarch64-darwin";
        username = "lucasgalton";
        homeDirectory = "/Users/lucasgalton";
        extraModules = [ ./hosts/darwin.nix ];
      };

      # macOS config (Intel)
      darwinIntelConfig = {
        system = "x86_64-darwin";
        username = "lucasgalton";
        homeDirectory = "/Users/lucasgalton";
        extraModules = [ ./hosts/darwin.nix ];
      };

      # WSL config (root user)
      wslConfig = {
        system = "x86_64-linux";
        username = "root";
        homeDirectory = "/root";
        extraModules = [ ./hosts/wsl.nix ];
      };

      # Linux config (standard user)
      linuxConfig = {
        system = "x86_64-linux";
        username = "lucasgalton";
        homeDirectory = "/home/lucasgalton";
        extraModules = [ ./hosts/linux.nix ];
      };
    in
    {
      homeConfigurations = {
        # ============================================
        # Auto-detected configs (username@hostname)
        # Run: home-manager switch --flake .
        # ============================================

        # This Mac (Apple Silicon)
        "lucasgalton@mac-1.home" = mkHome darwinConfig;

        # WSL - update "YOURWSLHOSTNAME" after running `hostname` in WSL
        "root@YOURWSLHOSTNAME" = mkHome wslConfig;

        # ============================================
        # Manual configs (for explicit selection)
        # Run: home-manager switch --flake .#configname
        # ============================================

        # Fallback/manual selection
        "mac" = mkHome darwinConfig;
        "mac-intel" = mkHome darwinIntelConfig;
        "wsl" = mkHome wslConfig;
        "linux" = mkHome linuxConfig;
      };
    };
}
