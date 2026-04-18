{
  config,
  pkgs,
  inputs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  config_text = builtins.toJSON {
    "show_custom_themes" = true;
    "setting_defaults" = {
      "custom_themes" = [
        {
          "name" = "Dracula";
          "is_dark" = true;
          "colors" = {
            "accent-color" = "#bd93f9";
            "primary-color" = "#bd93f9";
            "warning-color" = "#ff5555";
            "sidebar-color" = "#282a36";
            "roomlist-background-color" = "#282a36";
            "timeline-background-color" = "#282a36";
            "timeline-text-color" = "#f8f8f2";
            "secondary-content-color" = "#6272a4";
            "tertiary-content-color" = "#44475a";
            "focus-bg-color" = "#44475a";
          };
        }
      ];
    };
  };

in
{
  home.username = "msolinsk";
  home.homeDirectory = "/home/msolinsk";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.file.".config/Element/config.json" = {
    text = config_text;
    force = true;
  };

  home.file.".config/Riot/config.json" = {
    text = config_text;
    force = true;
  };

  # --- USER PACKAGES --- #
  home.packages = with pkgs; [
    discord
    easyeffects
    gparted-full
    steam
    appflowy
    element-desktop
    cinny-desktop
  ];

  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      shuffle
    ];
    theme = spicePkgs.themes.bloom;
  };

  # --- ZED EDITOR CONFIGURATION --- #
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "vscodium-theme-pack"
      "C#"
      "Dockerfile"
    ];

    userSettings = {
      theme = "Dracula";
      ui_font_size = 16;
      buffer_font_size = 14;
      buffer_font_family = "JetBrains Mono";
      text_rendering_mode = "grayscale";
      # Optional: Helps with sharpness on 1440p
      buffer_line_height = "comfortable";
      format_on_save = "on";
      languages = {
        Nix = {
          language_servers = [ "nil" ];
          formatter = {
            external = {
              command = "nixpkgs-fmt";
            };
          };
        };
      };
    };
  };

  # --- GHOSTTY CONFIGURATION ---
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Dracula+";
      font-size = 10;
      window-padding-x = 10;
      window-padding-y = 10;
      window-width = 210;
      window-height = 42;
    };
  };

  # --- ZSH CONFIGURATION ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "half-life";
    };

    shellAliases = {
      # --- QOL ALIASES ---
      cls = "clear";
      ls = "eza --icons";

      # --- SYS ALIASES ---
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#msolinsk";
      nixupdate = "nix flake update /etc/nixos && rebuild";
      nixconf = "sudo ZED_ALLOW_ROOT=true zeditor /etc/nixos/";

      # --- TAILSCALE ALIASES ---
      tsoff = "sudo tailscale down";
      tsnode = "sudo tailscale up --accept-dns=true --accept-routes=true --exit-node=100.110.227.95 --exit-node-allow-lan-access=true";
      tson = "sudo tailscale up --accept-dns=true --accept-routes=true --exit-node=";
      tsstat = "tailscale status";
    };
  };
}
