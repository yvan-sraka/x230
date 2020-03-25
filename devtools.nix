{ config, pkgs, lib, ... }:

{
  # I like my man.
  documentation.dev.enable = true;
  environment.extraOutputsToInstall = [ "info" "man" "devman" ];

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    promptInit = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
  };

  programs.mosh.enable = true;
  programs.tmux.enable = true;

  # Android
  programs.adb.enable = true;
  users.users.yvan.extraGroups = [ "adbusers" ];
  services.udev.packages = [ pkgs.android-udev-rules ];

  virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      (neovim.override {
        viAlias = true;
        vimAlias = true;
        configure = {
          packages.myPlugins = with pkgs.vimPlugins; {
            start = [ editorconfig-vim vim-airline vim-lastplace vim-nix vim-toml ];
            opt = [ ];
          };
        };
      })

      # C/C++/Rust
      binutils
      clang
      gcc
      gdb
      gnumake
      rustup

      # Git
      gitFull

      # ECMAScript
      nodejs
      yarn

      # Nix
      nixfmt

      # Python3
      python3Full
      python3Packages.virtualenv
      pipenv
    ];

  environment.variables.EDITOR = "nvim";
}
