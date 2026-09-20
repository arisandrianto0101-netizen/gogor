#!/usr/bin/env bash
# Setup sekali jalan untuk VPS Linux (Ubuntu/Debian): Claude Code + tmux + GitHub MCP.
# Pemakaian:  bash scripts/setup-vps.sh
set -euo pipefail

echo "==> Cek sistem"
if [ "$(id -u)" -eq 0 ]; then
  echo "PERINGATAN: Anda menjalankan sebagai root. Disarankan pakai user biasa." >&2
  read -r -p "Lanjut tetap? (y/N) " a; [ "${a:-N}" = "y" ] || exit 1
fi
MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
if [ "$MEM_KB" -lt 3500000 ]; then
  echo "PERINGATAN: RAM kurang dari 4 GB. Claude Code mungkin berjalan lambat/gagal." >&2
fi

echo "==> Pasang paket dasar (curl, git, tmux)"
if command -v apt-get >/dev/null 2>&1; then
  SUDO=""; [ "$(id -u)" -eq 0 ] || SUDO="sudo"
  $SUDO apt-get update -y
  $SUDO apt-get install -y curl git tmux
else
  echo "apt tidak ditemukan. Pasang curl, git, tmux secara manual lalu jalankan ulang." >&2
fi

echo "==> Pasang Claude Code"
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
export PATH="$HOME/.local/bin:$PATH"
if ! grep -q '.local/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi
command -v claude >/dev/null 2>&1 || { echo "Instalasi Claude Code gagal." >&2; exit 1; }

echo "==> Token GitHub"
if [ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
  read -r -s -p "Tempel GitHub Personal Access Token (tidak akan tampil): " GITHUB_PERSONAL_ACCESS_TOKEN
  echo
fi
[ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ] || { echo "Token kosong." >&2; exit 1; }

echo "==> Tambahkan GitHub MCP ke Claude Code"
claude mcp remove github --scope user >/dev/null 2>&1 || true
claude mcp add-json github --scope user \
  "{\"type\":\"http\",\"url\":\"https://api.githubcopilot.com/mcp/\",\"headers\":{\"Authorization\":\"Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}\"}}"
unset GITHUB_PERSONAL_ACCESS_TOKEN

[ -f "$HOME/.claude.json" ] && chmod 600 "$HOME/.claude.json"

echo
echo "SELESAI. Langkah terakhir (manual):"
echo "  1) source ~/.bashrc"
echo "  2) tmux new -s claude"
echo "  3) claude        # login pertama kali, ikuti link yang muncul"
echo "  4) Di dalam Claude, ketik /mcp untuk cek GitHub sudah terhubung"
echo "Lepas sesi tmux: Ctrl+B lalu D. Sambung lagi: tmux attach -t claude"
