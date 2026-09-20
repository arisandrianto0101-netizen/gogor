#!/usr/bin/env bash
# Menambahkan GitHub MCP Server (Docker) ke Claude Desktop di macOS.
# Pemakaian:  export GITHUB_PERSONAL_ACCESS_TOKEN=xxxx && ./scripts/setup-claude-desktop-mac.sh
set -euo pipefail

CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

command -v docker >/dev/null 2>&1 || { echo "Docker belum terpasang / belum berjalan." >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "python3 dibutuhkan." >&2; exit 1; }
[ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ] || { echo "Set dulu GITHUB_PERSONAL_ACCESS_TOKEN." >&2; exit 1; }

docker pull ghcr.io/github/github-mcp-server

mkdir -p "$(dirname "$CONFIG")"
[ -f "$CONFIG" ] && cp "$CONFIG" "$CONFIG.bak"

python3 - "$CONFIG" <<'PY'
import json, os, sys
path = sys.argv[1]
cfg = {}
if os.path.exists(path) and os.path.getsize(path) > 0:
    with open(path) as f:
        cfg = json.load(f)
cfg.setdefault("mcpServers", {})["github"] = {
    "command": "docker",
    "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
             "ghcr.io/github/github-mcp-server"],
    "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": os.environ["GITHUB_PERSONAL_ACCESS_TOKEN"]},
}
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
print("Config ditulis ke", path)
PY

echo "Selesai. Restart Claude Desktop sepenuhnya."
