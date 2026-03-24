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
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # --- USER PACKAGES --- #
  home.packages = with pkgs; [
    discord
    easyeffects
    gparted-full
    element-desktop
    steam
    appflowy
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
      cls = "clear";
      ls = "eza --icons";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#msolinsk";
      nixupdate = "nix flake update /etc/nixos && rebuild";
      nixconf = "sudo ZED_ALLOW_ROOT=true zeditor /etc/nixos/";

      # --- TAILSCALE ALIASES ---
      tsoff = "sudo tailscale down";
      tson = "sudo tailscale up --accept-routes --exit-node= --exit-node-allow-lan-access=true && tailscale status";
      tsnode = "sudo tailscale up --exit-node=100.110.227.95 --exit-node-allow-lan-access=true --accept-routes && tailscale status";
      tsstat = "tailscale status";
    };
  };
}
