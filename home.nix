{
  config,
  pkgs,
  ...
}: {
  home = {
    # Specify packages not explicitly configured below
    packages = with pkgs; [
      colima
      docker
      entr
      fd
      httpie
      hyperfine
      imagemagick
      jq
      nodejs
      pandoc
      ripgrep
      tree
      tree-sitter
    ];
    sessionVariables = {
      EDITOR = "hx";
    };
  };

  programs = {
    bat = {
      enable = true;
      config = {
        theme = "GitHub";
        italic-text = "always";
      };
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };

    eza = {
      enable = true;
      enableAliases = true;
    };

    fish = {
      enable = true;
      plugins = [
        {
          name = "iterm2-shell-integration";
          src = ./config/fish/iterm2_shell_integration;
        }
        {
          name = "fzf";
          src = pkgs.fetchFromGitHub {
            owner = "PatrickF1";
            repo = "fzf.fish";
            rev = "6d8e962f3ed84e42583cec1ec4861d4f0e6c4eb3";
            sha256 = "sha256-0rnd8oJzLw8x/U7OLqoOMQpK81gRc7DTxZRSHxN9YlM";
          };
        }
        # Need this when using Fish as a default macOS shell in order to pick
        # up ~/.nix-profile/bin
        {
          name = "nix-env";
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "00c6cc762427efe08ac0bd0d1b1d12048d3ca727";
            sha256 = "1hrl22dd0aaszdanhvddvqz3aq40jp9zi2zn0v1hjnf7fx4bgpma";
          };
        }
      ];
      shellInit = ''
        # Set syntax highlighting colours; var names defined here:
        # http://fishshell.com/docs/current/index.html#variables-color
        set fish_color_normal normal
        set fish_color_command white
        set fish_color_quote brgreen
        set fish_color_redirection brblue
        set fish_color_end white
        set fish_color_error -o brred
        set fish_color_param brpurple
        set fish_color_comment --italics brblack
        set fish_color_match cyan
        set fish_color_search_match --background=brblack
        set fish_color_operator cyan
        set fish_color_escape white
        set fish_color_autosuggestion brblack
      '';
      interactiveShellInit = ''
        # Activate the iTerm 2 shell integration
        iterm2_shell_integration

        # Pick up conda installation
        if test -x ~/.mambaforge/bin/conda
          eval ~/.mambaforge/bin/conda "shell.fish" "hook" $argv | source
        end
      '';
      shellAliases = {
        ipython = "ipython --no-banner";
        rm = "rm -i";
        cp = "cp -i";
        mv = "mv -i";
        mkdir = "mkdir -p";
        du = "du -hs";
      };
      # Abbreviate commonly used functions
      # An abbreviation will expand after <space> or <Enter> is hit
      shellAbbrs = {
        b = "bat";
        ip = "ipython";
        g = "git";
        ga = "git add";
        gap = "git add -p";
        gb = "git branch";
        gc = "git commit";
        gca = "git commit --amend";
        gcan = "git commit --amend --no-edit";
        gcm = "git commit -m";
        gcl = "git clone";
        gd = "git diff";
        gds = "git diff --staged";
        gl = "git prettylog";
        gp = "git push";
        gpf = "git push --force-with-lease";
        gpl = "git pull";
        gplp = "git pull --prune";
        gr = "git restore";
        grb = "git rebase";
        grba = "git rebase --abort";
        grbc = "git rebase --continue";
        grbi = "git rebase -i";
        gs = "git status -s -b";
        gst = "git stash";
        gstp = "git stash pop";
        gsts = "git stash show -p";
        gstx = "git stash drop";
        gsw = "git switch";
        gswc = "git switch -c";
        gswm = "git switch main";
        h = "http";
        hme = "home-manager --flake ~/.config/nixpkgs edit";
        hms = "home-manager --flake ~/.config/nixpkgs switch";
        m = "make";
        o = "open";
        p = "python3";
      };
      functions = {
        ctrlp = {
          description = "Launch Helix file finder from the shell";
          argumentNames = "hidden";
          body = ''
            if test -n "$hidden"
              # TODO can't find a way to toggle hidden files in Helix yet
              echo 'Hidden searching not yet supported.'
              exit 1
            else
              hx .
            end
          '';
        };
        fish_greeting = {
          description = "Greeting to show when starting a fish shell";
          body = "";
        };
        fish_user_key_bindings = {
          description = "Set custom key bindings";
          body = ''
            bind \cp ctrlp
            bind \cl 'ctrlp --hidden'
          '';
        };
        mkdcd = {
          description = "Make a directory tree and enter it";
          body = "mkdir -p $argv[1]; and cd $argv[1]";
        };
      };
    };

    fzf = {
      enable = true;
      enableFishIntegration = false;
    };

    gh = {
      enable = true;
      settings = {
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
        git_protocol = "ssh";
      };
    };

    git = {
      enable = true;
      userName = "Alex Pearwin";
      userEmail = "alex@pearwin.com";
      aliases = {
        prettylog = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          syntax-theme = "GitHub";
        };
      };
      extraConfig = {
        core = {
          # If git uses `ssh` from Nix the macOS-specific configuration in
          # `~/.ssh/config` won't be seen as valid
          # https://github.com/NixOS/nixpkgs/issues/15686#issuecomment-865928923
          sshCommand = "/usr/bin/ssh";
        };
        color = {
          ui = true;
        };
        diff = {
          colorMoved = "default";
        };
        merge = {
          conflictstyle = "zdiff3";
        };
        push = {
          default = "current";
        };
        pull = {
          ff = "only";
        };
        init = {
          defaultBranch = "main";
        };
        # Clone git repos with URLs like "gh:alexpearce/dotfiles"
        url."git@github.com:" = {
          insteadOf = "gh:";
          pushInsteadOf = "gh:";
        };
      };
      ignores = [
        ".*.swp"
        ".bundle"
        "vendor/bundle"
        ".DS_Store"
        "Icon"
        "*.pyc"
        ".envrc"
        "environment.yaml"
        ".direnv"
      ];
      includes = [
        {
          contents = {
            commit = {
              gpgsign = true;
            };
            gpg = {
              format = "ssh";
            };
            user = {
              email = "alex.pearwin@multiverse.io";
              signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINDfqmONBNsg0/E8VBzLiIpf5aP+pQIl++DAHtPYY2Dz";
            };
          };
          condition = "gitdir:~/Multiverse/";
        }
      ];
    };

    helix = {
      enable = true;
      settings = {
        theme = "onelight";
        editor = {
          bufferline = "multiple";
          color-modes = true;
          lsp.display-messages = true;
        };
        keys.normal = {
          space.w = ":w";
          space.q = ":q";
          space.x = ":x";
        };
      };
    };

    home-manager.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;
      };
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';
}
