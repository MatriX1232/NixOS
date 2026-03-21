{
  config,
  pkgs,
  inputs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  home.username = "msolinsk";
  home.homeDirectory = "/home/msolinsk";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # --- USER PACKAGES --- #
  home.packages = with pkgs; [
    discord
    easyeffects
    gparted-full
    element-desktop
    steam
  ];

  programs.spicetify = {
    enable = true;
    # spotifyPackage =
    #   (pkgs.symlinkJoin {
    #     name = "spotify";
    #     paths = [ pkgs.spotify ];
    #     nativeBuildInputs = [ pkgs.makeWrapper ];
    #     postBuild = ''
    #       wrapProgram $out/bin/spotify \
    #         --add-flags "--ozone-platform-hint=auto" \
    #         --add-flags "--enable-features=WaylandWindowDecorations"
    #     '';
    #   })
    #   // {
    #     # Inherit metadata from the original package to satisfy spicetify-nix
    #     inherit (pkgs.spotify) pname version;
    #   };
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
    autosuggestion.enable = true;
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
      nixconf = "sudo ZED_ALLOW_ROOT=true zeditor /etc/nixos/";
    };
  };
}
