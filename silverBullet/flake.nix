{
  description = "My SilverBullet server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [ pkgs.silverbullet ];
        shellHook = ''
	  echo "silverbullet ready!" 
        '';
      };


      packages.${system}.sb_start = pkgs.writeShellScriptBin "silverbullet start" ''
          echo "SB_MAX_DOCUMENT_SIZE=2048 SB_MAX_ATTACHMENT_SIZE=2048 silverbullet --port 3000 -L127.0.0.1 ./vault" 
          SB_USER="SB1:SBB" ${pkgs.silverbullet}/bin/silverbullet --port 3000 -L127.0.0.1 ./vault

      '';


    };
}

# packages.${system}.default = pkgs.silverbullet;

# simple start: nix run .#sb_start
# automated start: direnv allow at terminal (unset: direnv deny)

# path for systemd service:  /etc/systemd/user/silverbullet.service
#
# [Unit]
# Description=SilverBullet Service
# After=network.target
#
# [Service]
# WorkingDirectory=%h/nix/silverBullet
# # We point directly to the flake package to ensure it stays pinned
# ExecStart=/nix/store/${nix path}/bin/nix run %h/nix/silverBullet --port 3000 -L127.0.0.1 %h/nix/silverBullet/vault
# Restart=always
#
# [Install]
# WantedBy=default.target
#
# systemctl --user daemon-reload
# systemctl --user enable --now silverbullet.service
# systemctl --user stop silverbullet

# after running... wait until the loading finish msg, do not ctrl_c
# systemctl status | grep silverbullet
# sudo pkill -f silverbullet
# ps aux | grep silverbullet
# silverbullet --port 3000 -L127.0.0.1 ./vault &
#
# SB_USER="SB1:SBB" silverbullet --port 3000 -L127.0.0.1 ./vault -> Login authentication start
# silverbullet --port 3000 -L127.0.0.1 ./vault -> normal start (no login)


