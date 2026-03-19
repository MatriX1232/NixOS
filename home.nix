{ config, pkgs, ... }:

{
  home.username = "msolinsk";
  home.homeDirectory = "/home/msolinsk";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # --- USER PACKAGES --- #
  # Non-System apps (Spotify, etc.)
  home.packages = with pkgs; [
    spotify
    discord
    easyeffects
    gparted-full
  ];

  # --- ZED EDITOR CONFIGURATION --- #
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "vscodium-theme-pack"
      "catppuccin"
    ];

    userSettings = {
      theme = "Ayu Dark";
      ui_font_size = 16;
      buffer_font_size = 14;
      buffer_font_family = "JetBrains Mono";
      # Auto-format Nix files using the tools we installed earlier
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

  # --- ZSH CONFIGURATION ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "half-life";
    };

    shellAliases = {
      cls = "clear";
      ls = "eza --icons";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#msolinsk";
      nixupdate = "nix flake update /etc/nixos && rebuild";
      nixconf = "zeditor /etc/nixos/";
    };
  };
}
