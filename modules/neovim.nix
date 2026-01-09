{ config, pkgs, lib, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Extra plugins not in nixvim
    extraPlugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      vim-obsession  # Continuous session tracking for tmux-resurrect
    ];

    extraConfigLuaPre = ''
      require("catppuccin").setup({
        flavour = "mocha",
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          which_key = true,
          telescope = { enabled = true },
          native_lsp = { enabled = true },
          indent_blankline = { enabled = true },
        },
      })
      vim.cmd.colorscheme "catppuccin"
    '';

    # General options (lazyvim-like)
    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      smartindent = true;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      clipboard = "unnamedplus";
      mouse = "a";
      updatetime = 300;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      sidescrolloff = 8;
      wrap = false;
      undofile = true;
      splitbelow = true;
      splitright = true;
      showmode = false;
      cmdheight = 1;
      laststatus = 3;
      pumheight = 10;
      timeoutlen = 300;
    };

    # Global variables
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Keymaps (lazyvim-style)
    keymaps = [
      # Better window navigation
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Go to left window"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Go to lower window"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Go to upper window"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Go to right window"; }

      # Resize windows
      { mode = "n"; key = "<C-Up>"; action = "<cmd>resize +2<cr>"; options.desc = "Increase window height"; }
      { mode = "n"; key = "<C-Down>"; action = "<cmd>resize -2<cr>"; options.desc = "Decrease window height"; }
      { mode = "n"; key = "<C-Left>"; action = "<cmd>vertical resize -2<cr>"; options.desc = "Decrease window width"; }
      { mode = "n"; key = "<C-Right>"; action = "<cmd>vertical resize +2<cr>"; options.desc = "Increase window width"; }

      # Move lines
      { mode = "n"; key = "<A-j>"; action = "<cmd>m .+1<cr>=="; options.desc = "Move line down"; }
      { mode = "n"; key = "<A-k>"; action = "<cmd>m .-2<cr>=="; options.desc = "Move line up"; }
      { mode = "v"; key = "<A-j>"; action = ":m '>+1<cr>gv=gv"; options.desc = "Move selection down"; }
      { mode = "v"; key = "<A-k>"; action = ":m '<-2<cr>gv=gv"; options.desc = "Move selection up"; }

      # Buffers
      { mode = "n"; key = "<S-h>"; action = "<cmd>bprevious<cr>"; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<S-l>"; action = "<cmd>bnext<cr>"; options.desc = "Next buffer"; }
      { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<cr>"; options.desc = "Delete buffer"; }

      # Clear search
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<cr>"; options.desc = "Clear search highlighting"; }

      # Save
      { mode = "n"; key = "<leader>w"; action = "<cmd>w<cr>"; options.desc = "Save file"; }
      { mode = "n"; key = "<leader>q"; action = "<cmd>q<cr>"; options.desc = "Quit"; }

      # File explorer
      { mode = "n"; key = "<leader>e"; action = "<cmd>NvimTreeToggle<cr>"; options.desc = "Toggle file explorer"; }

      # Telescope
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Live grep"; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<cr>"; options.desc = "Find buffers"; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<cr>"; options.desc = "Help tags"; }
      { mode = "n"; key = "<leader>fr"; action = "<cmd>Telescope oldfiles<cr>"; options.desc = "Recent files"; }
      { mode = "n"; key = "<leader><space>"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
      { mode = "n"; key = "<leader>/"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Grep"; }

      # LSP
      { mode = "n"; key = "gd"; action = "<cmd>Telescope lsp_definitions<cr>"; options.desc = "Go to definition"; }
      { mode = "n"; key = "gr"; action = "<cmd>Telescope lsp_references<cr>"; options.desc = "Go to references"; }
      { mode = "n"; key = "gI"; action = "<cmd>Telescope lsp_implementations<cr>"; options.desc = "Go to implementation"; }
      { mode = "n"; key = "gy"; action = "<cmd>Telescope lsp_type_definitions<cr>"; options.desc = "Go to type definition"; }
      { mode = "n"; key = "K"; action = "<cmd>lua vim.lsp.buf.hover()<cr>"; options.desc = "Hover"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<cr>"; options.desc = "Code action"; }
      { mode = "n"; key = "<leader>cr"; action = "<cmd>lua vim.lsp.buf.rename()<cr>"; options.desc = "Rename"; }
      { mode = "n"; key = "<leader>cf"; action = "<cmd>lua vim.lsp.buf.format()<cr>"; options.desc = "Format"; }
      { mode = "n"; key = "<leader>cd"; action = "<cmd>lua vim.diagnostic.open_float()<cr>"; options.desc = "Line diagnostics"; }
      { mode = "n"; key = "[d"; action = "<cmd>lua vim.diagnostic.goto_prev()<cr>"; options.desc = "Previous diagnostic"; }
      { mode = "n"; key = "]d"; action = "<cmd>lua vim.diagnostic.goto_next()<cr>"; options.desc = "Next diagnostic"; }

      # Git
      { mode = "n"; key = "<leader>gg"; action = "<cmd>LazyGit<cr>"; options.desc = "LazyGit"; }
      { mode = "n"; key = "<leader>gd"; action = "<cmd>DiffviewOpen<cr>"; options.desc = "Diff view"; }
      { mode = "n"; key = "<leader>gc"; action = "<cmd>DiffviewClose<cr>"; options.desc = "Close diff view"; }
      { mode = "n"; key = "<leader>gh"; action = "<cmd>DiffviewFileHistory %<cr>"; options.desc = "File history"; }

      # Debug
      { mode = "n"; key = "<leader>db"; action = "<cmd>lua require('dap').toggle_breakpoint()<cr>"; options.desc = "Toggle breakpoint"; }
      { mode = "n"; key = "<leader>dc"; action = "<cmd>lua require('dap').continue()<cr>"; options.desc = "Continue"; }
      { mode = "n"; key = "<leader>di"; action = "<cmd>lua require('dap').step_into()<cr>"; options.desc = "Step into"; }
      { mode = "n"; key = "<leader>do"; action = "<cmd>lua require('dap').step_over()<cr>"; options.desc = "Step over"; }
      { mode = "n"; key = "<leader>dO"; action = "<cmd>lua require('dap').step_out()<cr>"; options.desc = "Step out"; }
      { mode = "n"; key = "<leader>dr"; action = "<cmd>lua require('dap').repl.open()<cr>"; options.desc = "Open REPL"; }
      { mode = "n"; key = "<leader>du"; action = "<cmd>lua require('dapui').toggle()<cr>"; options.desc = "Toggle DAP UI"; }

      # Which-key hints
      { mode = "n"; key = "<leader>?"; action = "<cmd>WhichKey<cr>"; options.desc = "Which key"; }

      # Session (vim-obsession)
      { mode = "n"; key = "<leader>ss"; action = "<cmd>Obsession<cr>"; options.desc = "Toggle session tracking"; }
    ];

    # Plugins
    plugins = {
      # UI
      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "catppuccin";
            globalstatus = true;
            component_separators = { left = ""; right = ""; };
            section_separators = { left = ""; right = ""; };
          };
        };
      };

      bufferline = {
        enable = true;
        settings.options = {
          diagnostics = "nvim_lsp";
          always_show_bufferline = false;
          offsets = [
            {
              filetype = "NvimTree";
              text = "File Explorer";
              highlight = "Directory";
              separator = true;
            }
          ];
        };
      };

      nvim-tree = {
        enable = true;
        settings = {
          filters.dotfiles = false;
          view.width = 35;
          renderer = {
            group_empty = true;
            highlight_git = true;
            icons.show = {
              git = true;
              folder = true;
              file = true;
            };
          };
        };
      };

      which-key = {
        enable = true;
        settings.spec = [
          { __unkeyed-1 = "<leader>b"; group = "buffer"; }
          { __unkeyed-1 = "<leader>c"; group = "code"; }
          { __unkeyed-1 = "<leader>d"; group = "debug"; }
          { __unkeyed-1 = "<leader>f"; group = "file/find"; }
          { __unkeyed-1 = "<leader>g"; group = "git"; }
          { __unkeyed-1 = "<leader>s"; group = "search"; }
        ];
      };

      indent-blankline = {
        enable = true;
        settings.scope.enabled = true;
      };

      noice = {
        enable = true;
        settings = {
          lsp.override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
          presets = {
            bottom_search = true;
            command_palette = true;
            long_message_to_split = true;
          };
        };
      };

      notify = {
        enable = true;
        settings = {
          background_colour = "#000000";
          stages = "fade";
          timeout = 3000;
        };
      };

      web-devicons.enable = true;

      # Treesitter
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          ensure_installed = [
            "go" "gomod" "gosum" "gowork"
            "python"
            "lua"
            "nix"
            "yaml" "json" "toml"
            "bash"
            "markdown" "markdown_inline"
            "dockerfile"
            "terraform" "hcl"
            "vim" "vimdoc"
            "regex"
            "gitcommit" "gitignore"
          ];
        };
      };

      treesitter-context.enable = true;

      # Telescope
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
        };
        settings.defaults = {
          layout_strategy = "horizontal";
          layout_config.prompt_position = "top";
          sorting_strategy = "ascending";
        };
      };

      # Completion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          snippet.expand = ''function(args) require('luasnip').lsp_expand(args.body) end'';
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
          };
          sources = [
            { name = "nvim_lsp"; priority = 1000; }
            { name = "luasnip"; priority = 750; }
            { name = "buffer"; priority = 500; }
            { name = "path"; priority = 250; }
          ];
          window = {
            completion.border = "rounded";
            documentation.border = "rounded";
          };
        };
      };

      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      luasnip.enable = true;
      friendly-snippets.enable = true;

      # LSP
      lsp = {
        enable = true;
        servers = {
          # Go
          gopls = {
            enable = true;
            settings = {
              gopls = {
                analyses = {
                  unusedparams = true;
                  shadow = true;
                };
                staticcheck = true;
                gofumpt = true;
                usePlaceholders = true;
                hints = {
                  assignVariableTypes = true;
                  compositeLiteralFields = true;
                  compositeLiteralTypes = true;
                  constantValues = true;
                  functionTypeParameters = true;
                  parameterNames = true;
                  rangeVariableTypes = true;
                };
              };
            };
          };

          # Python
          pyright.enable = true;
          ruff.enable = true;

          # YAML with Kubernetes schemas
          yamlls = {
            enable = true;
            settings.yaml = {
              schemas = {
                "https://json.schemastore.org/github-workflow.json" = "/.github/workflows/*";
                "https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json" = ["/*.k8s.yaml" "/*.k8s.yml"];
                kubernetes = ["/*.yaml" "/*.yml"];
              };
              schemaStore.enable = true;
            };
          };

          # Nix
          nil_ls = {
            enable = true;
            settings.nil.formatting.command = ["nixpkgs-fmt"];
          };

          # Bash
          bashls.enable = true;

          # JSON
          jsonls.enable = true;

          # Lua
          lua_ls = {
            enable = true;
            settings.Lua = {
              diagnostics.globals = ["vim"];
              workspace.checkThirdParty = false;
            };
          };

          # Terraform/OpenTofu
          terraformls.enable = true;

          # Docker
          dockerls.enable = true;
          docker_compose_language_service.enable = true;

          # Helm
          helm_ls.enable = true;
        };
      };

      lsp-format.enable = true;
      fidget.enable = true;

      # Formatting
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            go = ["gofumpt" "goimports"];
            python = ["ruff_format"];
            nix = ["nixpkgs-fmt"];
            yaml = ["yamlfmt"];
            json = ["jq"];
            markdown = ["prettier"];
            lua = ["stylua"];
            sh = ["shfmt"];
            bash = ["shfmt"];
            "_" = ["trim_whitespace"];
          };
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
        };
      };

      # Git
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "▎";
            change.text = "▎";
            delete.text = "";
            topdelete.text = "";
            changedelete.text = "▎";
          };
          current_line_blame = true;
          current_line_blame_opts.delay = 500;
        };
      };

      diffview.enable = true;
      lazygit.enable = true;
      neogit = {
        enable = true;
        settings.integrations.diffview = true;
      };

      # Debug
      dap.enable = true;
      dap-ui.enable = true;
      dap-virtual-text.enable = true;
      dap-go.enable = true;
      dap-python.enable = true;

      # Tmux integration
      tmux-navigator.enable = true;

      # Extra features
      todo-comments.enable = true;
      trouble.enable = true;
      flash.enable = true;
      nvim-surround.enable = true;
      autopairs.enable = true;
      comment.enable = true;
      illuminate.enable = true;

      # Mini plugins
      mini = {
        enable = true;
        modules = {
          ai = {};
          bufremove = {};
        };
      };

    };

    # Auto-start vim-obsession for session tracking (tmux-resurrect integration)
    autoCmd = [
      {
        event = [ "VimEnter" ];
        pattern = [ "*" ];
        nested = true;
        callback.__raw = ''
          function()
            local tmux = vim.fn.getenv("TMUX")
            if tmux == vim.NIL or tmux == "" then
              return -- Not in tmux, skip session tracking
            end

            -- Get window and pane index (preserved by tmux-resurrect)
            local win_idx = vim.fn.system("tmux display-message -p '#{window_index}'"):gsub("%s+", "")
            local pane_idx = vim.fn.system("tmux display-message -p '#{pane_index}'"):gsub("%s+", "")

            -- Session file: .session-w1p0.vim (window 1, pane 0)
            local cwd = vim.fn.getcwd()
            local session_file = cwd .. "/.session-w" .. win_idx .. "p" .. pane_idx .. ".vim"

            if vim.fn.filereadable(session_file) == 1 then
              vim.cmd("silent! source " .. session_file)
            end
            vim.cmd("Obsession " .. session_file)
          end
        '';
      }
    ];

    # Extra packages
    extraPackages = with pkgs; [
      # Formatters
      gofumpt
      gotools  # goimports
      ruff
      nixpkgs-fmt
      yamlfmt
      jq
      nodePackages.prettier
      stylua
      shfmt

      # LSP dependencies
      gopls
      pyright
      nil
      lua-language-server
      nodePackages.yaml-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-json-languageserver
      terraform-ls
      dockerfile-language-server-nodejs
      docker-compose-language-service
      helm-ls

      # Debug
      delve

      # Misc
      ripgrep
      fd
    ];
  };
}
