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
    # Defines configuration common to all systems (macOS and Fedora).
    generalConfiguration = { pkgs, config, lib, ... }: {


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
          pkgs.nodejs_24
          pkgs.zoxide
          pkgs.bun
          pkgs.gh
        ];

      fonts.packages =  [
        pkgs.comfortaa
      ];

      system.primaryUser = "shawalmbalire";
      nix.settings.experimental-features = "nix-command flakes";
    };

    # Defines configurations specific to Fedora systems.
    fedoraConfiguration = { pkgs, config, lib, ... }:
      generalConfiguration { inherit pkgs config lib; } // {
        # Fedora-specific settings go here
        nixpkgs.hostPlatform = "x86_64-linux";
        programs.fish.enable = true; # Assuming fish should be enabled on Fedora too
        users.users.shawalmbalire = {
          home = "/home/shawalmbalire"; # Standard Linux home directory
          shell = pkgs.fish;
        };
        # TODO: Add other Fedora-specific configurations here (e.g., boot.loader, networking, services for Linux)
      };
  in
  {
    nixosConfigurations."fedora" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      nixpkgs.config.allowUnfree = true; # Allow unfree packages for this system
      modules = [
        fedoraConfiguration
        # Add other NixOS modules here if needed
      ];
    };

    darwinConfigurations."macmini" = nix-darwin.lib.darwinSystem {
      modules = [
        { nixpkgs.config.allowUnfree = true; } # Allow unfree packages for this system
        ({ pkgs, config, lib, ... }:
          generalConfiguration { inherit pkgs config lib; } // { # Overlay macOS-specific settings
            system.primaryUser = "shawalmbalire";
            homebrew = {
                brews = [
                  "mas"
                ];
                enable = true;
                casks = [
                  "visual-studio-code@insiders"
                  # "gemini-cli"
                  # "opencode"
                  "vlc"
                  "zen"
                  "freecad"
                ];
                masApps = {
                  };
                onActivation.cleanup = "zap";
                onActivation.autoUpdate = true;
                onActivation.upgrade = true;
              };
            programs.fish.enable = true;

            system.defaults = {
              dock = {
                autohide = true;
                orientation = "left";
                persistent-apps = [
                  { app = "/Applications/Visual Studio Code - Insiders.app"; }
                  { app = "/Applications/Zen.app"; }
                ];
              };
              NSGlobalDomain.AppleICUForce24HourTime = true;
              NSGlobalDomain.AppleShowAllExtensions = true;
              loginwindow.GuestEnabled = false;
              finder.FXPreferredViewStyle = "clmv";
              finder.FXRemoveOldTrashItems = true;
            };
            system.keyboard = {
              enableKeyMapping = true;
              remapCapsLockToControl = false;
              remapCapsLockToEscape = true;
            };
            system.configurationRevision = self.rev or self.dirtyRev or null;
            # Backward compatibility state version.
            system.stateVersion = 6;
            # The platform the configuration will be used on.
            nixpkgs.hostPlatform = "aarch64-darwin";
            users.users.shawalmbalire = {
              home = "/Users/shawalmbalire";
              shell = pkgs.fish;
            };

            system.activationScripts.applications.text = let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = [ "/Applications" ];
              };
            in
              pkgs.lib.mkForce ''
              # Set up applications.
              echo "setting up /Applications..." >&2
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
              while read -r src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
                  '';
          }
        )
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true; # Enable Rosetta for Intel Homebrew on Apple Silicon
            user = "shawalmbalire";
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
