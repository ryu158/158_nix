{
  description = "My Kavita server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      version = "0.8.4";

      # Select the legacy 2.12 package which contains the real liblttng-ust.so.0
      lttng-legacy = pkgs.lttng-ust_2_12;

      runtimeDeps = [
        pkgs.stdenv.cc.cc.lib
        pkgs.zlib
        pkgs.icu
        pkgs.openssl
        pkgs.numactl
        lttng-legacy
      ];
    in
    {
      packages.${system}.kavita = pkgs.stdenv.mkDerivation {
        pname = "kavita";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/Kareadita/Kavita/releases/download/v${version}/kavita-linux-x64.tar.gz";
          hash = "sha256-JNvUeOMFaJjypHBa6mIdgOxoC23l4uhAXaHqhqC/XVQ="; 
        };

        nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
        buildInputs = runtimeDeps; 

        sourceRoot = ".";

        installPhase = ''
          runHook preInstall

          KAVITA_SHARE="$out/share/kavita"
          mkdir -p $out/bin "$KAVITA_SHARE"
          cd Kavita
          cp -r * "$KAVITA_SHARE/"
          chmod +x "$KAVITA_SHARE/Kavita"

          # Create the optimized wrapper script
          cat << 'EOF' > $out/bin/.kavita-wrapped
#!/bin/bash
export KAVITA_DATA_DIR="$HOME/.config/kavita"
TARGET_DIR="$KAVITA_DATA_DIR/config"

# 1. Build out the mutable structure in the user's home directory
mkdir -p "$TARGET_DIR"

if [ ! -f "$TARGET_DIR/appsettings.json" ]; then
   echo "First time setup: Creating appsettings.json layout..."
   echo '{' > "$TARGET_DIR/appsettings.json"
   echo '  "Logging": { "LogLevel": { "Default": "Information", "Microsoft.AspNetCore": "Warning" } },' >> "$TARGET_DIR/appsettings.json"
   echo '  "AllowedHosts": "*",' >> "$TARGET_DIR/appsettings.json"
   echo '  "ConnectionStrings": { "DefaultConnection": "Data Source=kavita.db;Cache=Shared" },' >> "$TARGET_DIR/appsettings.json"
   echo '  "Database": { "Type": "Sqlite" }' >> "$TARGET_DIR/appsettings.json"
   echo '}' >> "$TARGET_DIR/appsettings.json"
fi

# 2. Link the immutable frontend web assets directly into the writable space
# This makes .NET happy without locking up migrations on read-only folders
ln -sfn "KAVITA_SHARE_PATH/wwwroot" "$KAVITA_DATA_DIR/wwwroot"

# 3. Pivot the working execution frame into your home folder context
cd "$KAVITA_DATA_DIR"

# 4. Fire up Kavita pointing directly to the compiled Nix store binary path
exec "KAVITA_SHARE_PATH/Kavita" --data-dir "$KAVITA_DATA_DIR" "$@"
EOF

          # Replace our placeholder string safely with the absolute $out store path
          substituteInPlace $out/bin/.kavita-wrapped \
            --replace "KAVITA_SHARE_PATH" "$KAVITA_SHARE"

          chmod +x $out/bin/.kavita-wrapped

          # Injects the dynamic link paths cleanly
          makeWrapper $out/bin/.kavita-wrapped $out/bin/kavita \
            --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath runtimeDeps}"

          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Fast, feature-rich manga and comic server";
          homepage = "https://www.kavitareader.com/";
          license = licenses.gpl3Only;
          platforms = platforms.linux;
        };
      };

      apps.${system}.kavita = {
        type = "app";
        program = "${self.packages.${system}.kavita}/bin/kavita";
      };

    };
}


# simple start: nix run .#kavita

