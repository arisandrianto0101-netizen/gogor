#!/usr/bin/env bash
# Menambahkan GitHub MCP Server (remote) ke Claude Code.
# Pemakaian:  export GITHUB_PERSONAL_ACCESS_TOKEN=xxxx && ./scripts/setup-claude-code.sh
set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "Claude Code belum terpasang (perintah 'claude' tidak ditemukan)." >&2
  exit 1
fi
if [ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
  echo "Set dulu: export GITHUB_PERSONAL_ACCESS_TOKEN=token_anda" >&2
  exit 1
fi

claude mcp add-json github --scope user \
  "{\"type\":\"http\",\"url\":\"https://api.githubcopilot.com/mcp/\",\"headers\":{\"Authorization\":\"Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}\"}}"

echo "Selesai. Cek dengan: claude mcp list"
