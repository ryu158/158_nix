{
  description = "Automated Flatnotes Installation and Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      # Use "aarch64-linux" if on Oracle ARM (Ampere)
      system = "x86_64-linux"; 
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python312Full
          python312Packages.pip
          nodejs_20
          git
          gcc
        ];

        shellHook = ''
          # 1. Download source from Git if not present
          if [ ! -d "flatnotes_src" ]; then
            echo "📥 Downloading Flatnotes source from GitHub..."
            git clone https://github.com/dullage/flatnotes.git flatnotes_src
          fi
          cd flatnotes_src

          # 2. Setup Python Virtual Env
          VENV=".venv"
          if [ ! -d "$VENV" ]; then
            echo " Creating Python virtual environment..."
            python3 -m venv "$VENV"
          fi
          source "$VENV/bin/activate"

          # 3. Install Backend Dependencies
          echo "📦 Installing Python dependencies..."
          pip install -q --upgrade pip
          pip install -q fastapi uvicorn python-multipart pydantic whoosh tinydb pyyaml flask-compress flask-login

          # 4. Build Frontend (If missing)
          if [ ! -d "client/dist" ]; then
            echo "🏗️ Building frontend (this takes a moment)..."
            cd client && npm install && npm run build && cd ..
          fi

          # 5. Link Frontend to Server
          if [ ! -L "server/client" ]; then
            ln -s ../client server/client
            echo "🔗 Linked frontend to server."
          fi

          # 6. Configuration
          export FLATNOTES_PATH="$HOME/notes"
          export FLATNOTES_PORT=3000
          export FLATNOTES_HOST="127.0.0.1"
          export FLATNOTES_AUTH_TYPE="none"
          mkdir -p "$FLATNOTES_PATH"

          echo "------------------------------------------------"
          echo "✅ Flatnotes is installed and ready!"
          echo "Location: $(pwd)"
          echo "Run: cd server && python3 main.py"
          echo "------------------------------------------------"
        '';
      };
    };
}

# - 1st install
# home/opc/nix/flatnotes/flatnotes_src/server/main.py

# - activation command
# - move to home/opc/nix/flatnotes/flatnotes_src/server
# uvicorn main:app --host 127.0.0.1 --port 3000

# - port check
# netstat -tuln | grep 3000

# - attachment error (small file is ok, but large file fails)
# - nginx tmp folder writing fail -> check error log
# sudo tail -f /var/log/nginx/error.log
# - make nginx own tmp folders and authority setup
# mkdir -p /var/lib/nginx/client_body
# chown -R nginx:nginx /var/lib/nginx/client_body
