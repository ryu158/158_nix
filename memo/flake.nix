{
  description = "Simple nginx hello server for Oracle Linux 9 using Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      devShell.x86_64-linux = pkgs.mkShell {
        packages = [ pkgs.pandoc pkgs.glow ];
      };

    };
}

