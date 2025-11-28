{
  description = "Shawal system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, ... }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.neovim
          pkgs.mkalias
          pkgs.gemini-cli
          pkgs.obsidian
          pkgs.kitty
          pkgs.tmux
          pkgs.fish
          pkgs.opencode
          pkgs.carapace
          pkgs.eza
          pkgs.git
          pkgs.zsh
          pkgs.htop
          pkgs.hello
          pkgs.zoxide
        ];

      fonts.packages =  [
        pkgs.comfortaa
      ];

      system.primaryUser = "shawalmbalire";
      homebrew = {
          brews = [
            "mas"
          ];
          enable = true;
          casks = [
            "visual-studio-code@insiders"
            "vlc"
          ];
          masApps = {
            };
          onActivation.cleanup = "zap";
        };
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

       # The platform the configuration will be used on.
       nixpkgs.hostPlatform = "aarch64-darwin";



      users.users.shawalmbalire = {
        home = "/Users/shawalmbalire";
      };

     };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macmini" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration 
        nix-homebrew.darwinModules.nix-homebrew

        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "shawalmbalire";

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
