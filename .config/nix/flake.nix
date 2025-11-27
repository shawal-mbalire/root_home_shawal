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
    # Shared configuration (platform-agnostic)
    commonConfig = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;
      
      environment.systemPackages = with pkgs; [
        neovim mkalias obsidian kitty tmux fish opencode
        carapace eza
      ];
      
      fonts.packages = [ pkgs.comfortaa ];
      programs.fish.enable = true;
      
      nix.settings.experimental-features = "nix-command flakes";
    };

    # macOS-specific configuration
    darwinConfig = { pkgs, config, ... }: {
      imports = [ commonConfig ];
      
      nixpkgs.hostPlatform = "aarch64-darwin";
      system.primaryUser = "shawalmbalire";
      users.users.shawalmbalire.shell = pkgs.fish;
      
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      
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
    };

    # Linux-specific configuration  
    nixosConfig = { pkgs, config, ... }: {
      imports = [ commonConfig ];
      
      nixpkgs.hostPlatform = "x86_64-linux";
      
      # Add VLC from nixpkgs for Linux
      environment.systemPackages = with pkgs; [ vlc ];
      
      users.users.shawalmbalire = {
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = [ "wheel" ];
      };
      
      system.stateVersion = "23.11";
    };
  in
  {
    darwinConfigurations."macmini" = nix-darwin.lib.darwinSystem {
      modules = [
        darwinConfig 
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "shawalmbalire";
            autoMigrate = true;
          };
        }
      ];
    };
    
    nixosConfigurations."fedora" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ nixosConfig ];
    };
  };
}
