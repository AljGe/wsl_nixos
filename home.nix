{ config, pkgs, ... }:

{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "24.05";

  # Packages that should be installed to the user profile
  home.packages = with pkgs; [
    # Dev tools
    vim
    wget
    curl
    gh # GitHub CLI
    jq # JSON processor
    yq # YAML processor
    httpie
    delta
    lazygit
    alejandra # Nix formatter
    home-manager
    nil # Nix LSP
    just # Command runner (like make but simpler)
    difftastic # Better diff tool
    shellcheck # Shell script analyzer
    nodePackages.prettier # Code formatter
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "NerdFontsSymbolsOnly" "Noto" ]; })
    
    # System tools
    btop
    ripgrep
    fd
    tree
    duf
    ncdu
    bottom
    du-dust
    procs
    sd
    choose

    # Shell tools
    fzf
    bat
    eza
    zoxide

    # Utils
    tldr
    neofetch
    p7zip
    unzip
    zip

    # Python development tools
    uv
    ruff
    nh
    vivid

    # Add these useful tools
    comma  # Run programs without installing them
    nix-output-monitor  # Better nix-build output
    nixpkgs-review  # Review nixpkgs pull requests
    statix  # Lint and suggest improvements for Nix code
    
    # Optional but recommended
    devenv  # Development environments
    direnv  # Per-directory environment variables

    # Add these packages for ephemeral package support
    nix-index  # Required for , (comma) to work
    comma
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";  # TODO: Change this
    userEmail = "your.email@example.com";  # TODO: Change this
    delta.enable = true;
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.autocrlf = "input"; # For WSL
       diff.colorMoved = "default";
      merge.conflictStyle = "diff3";
      rebase.autoStash = true;
    };
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    stdlib = ''
      # Enhanced devenv integration
      use_devenv() {
        watch_file devenv.nix
        watch_file devenv.lock
        watch_file devenv.yaml
        watch_file pyproject.toml
        watch_file uv.lock
        
        # Add error handling and timeout
        local max_attempts=3
        local attempt=1
        local timeout=300  # 5 minutes timeout
        
        while [ $attempt -le $max_attempts ]; do
          if timeout $timeout devenv shell --print-bash; then
            eval "$(timeout $timeout devenv shell --print-bash)"
            return 0
          fi
          echo "Attempt $attempt failed, retrying..."
          attempt=$((attempt + 1))
          sleep 5
        done
        
        echo "Failed to initialize devenv after $max_attempts attempts"
        return 1
      }
    '';
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "sudo"
        "history"
        "direnv"
        "colored-man-pages"
        "extract"
        "z"
        "fzf"
        "dirhistory"
        "per-directory-history"
      ];
      theme = "robbyrussell";
    };

    initExtra = ''
      # Create oh-my-zsh cache directory with proper permissions
      export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
      if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
        mkdir -p "$ZSH_CACHE_DIR"
        chmod 755 "$ZSH_CACHE_DIR"
      fi

      if [[ ! -d "$ZSH_CACHE_DIR/completions" ]]; then
        mkdir -p "$ZSH_CACHE_DIR/completions"
        chmod 755 "$ZSH_CACHE_DIR/completions"
      fi

      # Ensure Docker completion file has correct permissions
      if [ -f "$ZSH_CACHE_DIR/completions/_docker" ]; then
        chmod 644 "$ZSH_CACHE_DIR/completions/_docker"
      fi

      # Existing configuration
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      eval "$(zoxide init zsh)"

      # Better integration with Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      # Add SSH agent socket configuration
      export SSH_AUTH_SOCK="/mnt/wsl/ssh-agent.sock"

      # Nix garbage collection and update helper
      nix-cleanup() {
        nix-collect-garbage -d
        nix store optimise
        sudo nix-collect-garbage -d
        sudo nix store optimise
      }

      # Quick flake update
      nix-update() {
        nix flake update
        sudo nixos-rebuild switch --flake .#nixos
      }

      # Configure eza with proper settings for icons
      export EZA_ICONS_AUTO=1
      
      # Remove this line as it might interfere
      # export EZA_ICONS=always
      
      # Instead, use these specific settings
      export EZA_ICON_SPACING=2
      export EZA_ICON_TYPE="nerd"
      
      # Ensure proper locale for UTF-8 support
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      
      # Make sure VSCode terminal uses correct font
      export TERMINAL_FONT="JetBrainsMono Nerd Font Mono"

      # Initialize nix-index database if it doesn't exist
      if [ ! -f ~/.cache/nix-index/files ]; then
        echo "Initializing nix-index database..."
        nix-index
      fi

      # Define ,, and ,s as functions for better argument handling
      function ,,() {
        nix run "nixpkgs#$1" -- "''${@:2}"
      }

      function ,s() {
        nix shell "nixpkgs#$1" -- "''${@:2}"
      }
    '';

    shellAliases = {
      # System management
      # update = "sudo nixos-rebuild switch --flake .#nixos"; # not needed with nh
      
      # Enhanced NH aliases
      nos = "nh os switch . --dry && nh home switch . --dry";     # Safe preview of system changes
      nosa = "nh os switch . && nh home switch .";  # System + Home-manager switch
      ndiff = "nvd diff /run/current-system /nix/var/nix/profiles/system";    # View system differences
      
      nhs = "nh home switch .";         # Home-manager switch
      ngc = "nh clean all --keep-since 7d --keep 10";             # Clean both user and system
      ngcd = "nh clean all --dry --keep-since 7d --keep 10";             # Clean both user and system
      nsc = "nh search";                # Quick package search
      
      # ls aliases...
      ll = "eza -l --icons=always --group-directories-first --git";
      la = "eza -la --icons=always --group-directories-first --git";
      ls = "eza --icons=always --group-directories-first";
      lt = "eza --tree --icons=always --group-directories-first";

      # cat alias...
      cat = "bat";

      # cd alias...nosa
      cd = "z";

      # less ephemeral
      #",," = "nix run nixpkgs#";
      # ",s" = "nix shell nixpkgs#";
    };
  };

  # Basic bash configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      # Add your aliases here
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Use Catppuccin theme (Mocha variant)
      palette = "catppuccin_mocha";

      # Theme color definitions
      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };

      # Modern symbol styling
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };

      # Disable some modules that might slow down the prompt
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = true;

      # Directory configuration
      directory = {
        truncation_length = 5;
        truncate_to_repo = true;
      };

      # Git configuration
      git_branch = {
        symbol = "🌱 ";
        truncation_length = 20;
        truncation_symbol = "...";
      };

      git_status = {
        conflicted = "🏳";
        ahead = "🏎💨";
        behind = "😰";
        diverged = "😵";
        up_to_date = "✓";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "[++\\($count\\)](green)";
        renamed = "👅";
        deleted = "🗑";
      };

      # Nix shell configuration
      nix_shell = {
        symbol = "❄️ ";
        format = "via [$symbol$state( \($name\))]($style) ";
      };
    };
  };


  # Add this section for better XDG compliance
  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # Add nix-index configuration
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;  # Since you're using zsh
  };
}
