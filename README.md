# GitHub MCP Setup untuk Claude

Setup siap pakai untuk menghubungkan Claude ke GitHub lewat
[GitHub MCP Server resmi](https://github.com/github/github-mcp-server).

## 1. Buat token GitHub

1. GitHub → Settings → Developer settings → Personal access tokens.
2. Buat token baru. Beri izin seperlunya saja (misalnya `repo`, `read:org`, `workflow` bila perlu).
3. Simpan token. **Jangan pernah commit atau kirim token ke chat.**

## 2. Pilih cara pasang

### A. Claude Code (paling mudah, tanpa Docker)

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN=token_anda
./scripts/setup-claude-code.sh
claude mcp list
```

Atau manual:

```bash
claude mcp add-json github --scope user '{"type":"http","url":"https://api.githubcopilot.com/mcp/","headers":{"Authorization":"Bearer TOKEN_ANDA"}}'
```

### B. Claude Desktop (memakai Docker)

Prasyarat: Docker Desktop terpasang dan berjalan.

**macOS (otomatis):**

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN=token_anda
./scripts/setup-claude-desktop-mac.sh
```

**Windows / manual:** buka file konfigurasi, lalu salin isi
`claude_desktop_config.example.json` (ganti tokennya).

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

Jika file sudah punya `mcpServers`, tambahkan blok `github` saja, jangan menimpa yang lain.
Restart Claude Desktop sepenuhnya setelah itu.

### C. Custom connector di claude.ai (chat web)

Settings → Connectors → Add custom connector, lalu isi URL
`https://api.githubcopilot.com/mcp/`. Ketersediaan dan cara login (OAuth/token)
bisa berbeda, cek dokumentasi GitHub dan Claude terbaru.

## 3. Tes

Minta Claude: "Tampilkan daftar repository saya" atau "Buka issue terbuka di repo X".

## Troubleshooting

| Masalah | Solusi |
|---|---|
| 401 Unauthorized | Token kosong/salah/kedaluwarsa, atau header Authorization tidak terkirim |
| `docker: command not found` | Pasang dan jalankan Docker Desktop |
| Tool GitHub tidak muncul | Restart Claude Desktop sepenuhnya; cek JSON tidak rusak |
| Tidak bisa akses repo privat | Beri token izin `repo` |

## Keamanan

- Simpan token di `.env` (sudah masuk `.gitignore`), bukan di repo.
- Pakai token dengan izin minimum dan masa berlaku terbatas.
- Cabut token di GitHub jika pernah bocor.

> Catatan: paket npm `@modelcontextprotocol/server-github` sudah tidak didukung sejak April 2025. Gunakan Docker, binary resmi, atau server remote.
