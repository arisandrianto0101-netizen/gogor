"""MCP server sederhana.

Mode jalan:
  - Lokal (default, stdio)  : python server.py
  - Remote (HTTP, untuk deploy): MCP_TRANSPORT=http python server.py
"""
import os
from datetime import datetime
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from mcp.server.fastmcp import FastMCP

TRANSPORT = os.environ.get("MCP_TRANSPORT", "stdio").lower()

if TRANSPORT == "http":
    # Layanan hosting biasanya memberi nomor port lewat variabel PORT.
    mcp = FastMCP(
        "mcp-saya",
        host="0.0.0.0",
        port=int(os.environ.get("PORT", "8000")),
    )
else:
    mcp = FastMCP("mcp-saya")


# ---------- TOOLS: aksi yang bisa dipanggil Claude ----------

@mcp.tool()
def tambah(a: float, b: float) -> float:
    """Menjumlahkan dua angka."""
    return a + b


@mcp.tool()
def kali(a: float, b: float) -> float:
    """Mengalikan dua angka."""
    return a * b


@mcp.tool()
def sapa(nama: str) -> str:
    """Menyapa seseorang dengan ramah."""
    return f"Halo, {nama}! Salam dari mcp-saya."


@mcp.tool()
def waktu_sekarang(zona: str = "Asia/Jakarta") -> str:
    """Memberi tanggal dan jam sekarang di zona waktu tertentu (mis. Asia/Jakarta, UTC)."""
    try:
        now = datetime.now(ZoneInfo(zona))
    except ZoneInfoNotFoundError:
        return f"Zona waktu '{zona}' tidak dikenal."
    return now.strftime("%A, %d %B %Y, %H:%M:%S %Z")


# ---------- RESOURCE: data yang bisa dibaca ----------

@mcp.resource("info://server")
def info_server() -> str:
    """Informasi singkat tentang server ini."""
    return "mcp-saya: server MCP contoh dengan tool tambah, kali, sapa, dan waktu_sekarang."


# ---------- PROMPT: template siap pakai ----------

@mcp.prompt()
def ringkas(teks: str) -> str:
    """Template untuk meringkas teks."""
    return f"Ringkas teks berikut dalam 3 poin singkat:\n\n{teks}"


if __name__ == "__main__":
    if TRANSPORT == "http":
        mcp.run(transport="streamable-http")  # alamat MCP: /mcp
    else:
        mcp.run()  # stdio
