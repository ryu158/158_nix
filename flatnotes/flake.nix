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
	  # 1. Configuration & Paths
	  PROJECT_DIR="flatnotes_src"
	  VENV="$PROJECT_DIR/.venv"
	  export FLATNOTES_PATH="/home/opc/notes"
	  export FLATNOTES_PORT=3000
	  export FLATNOTES_HOST="127.0.0.1"
	  export FLATNOTES_AUTH_TYPE="none"
	  mkdir -p "$FLATNOTES_PATH"

	  # 2. Check if already installed
	  if [ -d "$PROJECT_DIR" ] && [ -f "$VENV/bin/uvicorn" ]; then
	    echo "⚡ Flatnotes is already installed. Skipping setup..."
	    cd "$PROJECT_DIR"
	    source ".venv/bin/activate"
	  else
	    # 3. Download source from Git if missing
	    if [ ! -d "$PROJECT_DIR" ]; then
	      echo "📥 Downloading Flatnotes source from GitHub..."
	      git clone https://github.com/dullage/flatnotes.git "$PROJECT_DIR"
	    fi
	    
	    cd "$PROJECT_DIR"

	    # 4. Setup Python Virtual Env
	    if [ ! -d ".venv" ]; then
	      echo "🐍 Creating Python virtual environment..."
	      python3 -m venv .venv
	    fi
	    source ".venv/bin/activate"

	    # 5. Install Backend Dependencies
	    echo "📦 Installing/Updating Python dependencies..."
	    pip install -q --upgrade pip
	    pip install -q fastapi uvicorn python-multipart pydantic whoosh tinydb pyyaml flask-compress flask-login

	    # 6. Build Frontend (If missing)
	    if [ ! -d "client/dist" ]; then
	      echo "🏗️ Building frontend (this takes a moment)..."
	      cd client && npm install && npm run build && cd ..
	    fi

	    # 7. Link Frontend to Server
	    if [ ! -L "server/client" ]; then
	      ln -s ../client server/client
	      echo "🔗 Linked frontend to server."
	    fi
	  fi

	  echo "------------------------------------------------"
	  echo "✅ Flatnotes Environment Ready!"
	  echo "Location: $(pwd)"
	  echo "Run: cd server && python3 uvicorn main:app --host 127.0.0.1 --port 3000"
	  echo "------------------------------------------------"

	  cd server
	  uvicorn main:app --host 127.0.0.1 --port 3000 
	'';
      };
    };
}

# simple start -> nix develop
# automated start: direnv allow (unset: direnv deny)

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

# export FLATNOTES_PATH="$HOME/opc/nix/silverBullet_0_7/vault"

