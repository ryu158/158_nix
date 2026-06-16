{
  description = "My Syncthing server";

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
        packages = [ pkgs.syncthing ];
        shellHook = ''
	  echo "syncthing ready!" 
        '';
      };


      packages.${system}.syncthing_serve = pkgs.writeShellScriptBin "syncthing start" ''
          echo "syncthing ready" 
	  ${pkgs.syncthing}/bin/syncthing serve
      '';


    };
}

# simple start: nix run .#syncthing_serve
# nix develop
# automated start: direnv allow at terminal (unset: direnv deny)

# SBB

# config.xml: <gui enabled="true" tls="false"> ->tls means using https, must be false

# syncthing paths
# Configuration file:
#                                                                                               │        /home/opc/.local/state/syncthing/config.xml
#                                                                                               │
#                                                                                               │Device private key & certificate files:
#                                                                                               │        /home/opc/.local/state/syncthing/key.pem
#                                                                                               │        /home/opc/.local/state/syncthing/cert.pem
#                                                                                               │
#                                                                                               │GUI / API HTTPS private key & certificate files:
#                                                                                               │        /home/opc/.local/state/syncthing/https-key.pem
#                                                                                               │        /home/opc/.local/state/syncthing/https-cert.pem
#                                                                                               │
#                                                                                               │Database location:
#                                                                                               │        /home/opc/.local/state/syncthing/index-v2
#                                                                                               │
#                                                                                               │Log file:
#                                                                                               │        /home/opc/.local/state/syncthing/syncthing.log
#                                                                                               │
#                                                                                               │GUI override directory:
#                                                                                               │        /home/opc/.local/state/syncthing/gui
#                                                                                               │
#                                                                                               │Default sync folder directory:
#                                                                                               │        /home/opc/Sync
