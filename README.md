# smartball-practice

A ROM patching tool for creating a speedrun practice ROM for Jerry Boy / Smart Ball (SNES).

## Overview

This project applies an ASM patch to a Jerry Boy / Smart Ball ROM using the [Asar](https://github.com/RPGHacker/asar) SNES assembler. The resulting patched ROM adds quality-of-life features for speedrun practice, such as instant level reload and level advance via controller input.

The patch hooks into the game's main update loop and injects an `every_frame_patch` routine that runs two checks each frame: `reload_level` (L+R to restart the current level) and `change_level` (Start+Up to advance to the next level).

A watch mode is also included for iterative ASM development — file changes trigger an automatic rebuild and launch the emulator.

## Getting Started

### Prerequisites

- Python 3.12 or later
- [uv](https://github.com/astral-sh/uv) (recommended) or pip
- [Asar](https://github.com/RPGHacker/asar) assembler CLI available on your `PATH` (required for the default build)
- An original, headerless `jerryboy.sfc` ROM placed in the project root
- `libasar.so` (already included in `asar/`) — Asar shared library for Linux (required for watch/debug mode)
- [Mesen](https://www.mesen.ca/) emulator (required only for watch/debug mode)

### Setup

```bash
# Install dependencies with uv
uv sync

# Or with pip
pip install watchfiles
```

### Build

```bash
python build.py
```

This copies `jerryboy.sfc` to `patched/sb_practice.sfc` and applies the ASM patch via the `asar` CLI. The patched ROM is written to `patched/sb_practice.sfc`.

## Development

```bash
# Watch mode: auto-rebuild on .asm/.bin file changes and launch Mesen
python build.py --debug
```

In watch mode, any change to a file under `src/` triggers a full rebuild using the Python `libasar.so` binding directly (no `asar` CLI required). If the build succeeds, the patched ROM is launched in Mesen automatically.

## Patch Features

### Level Reload (L + R)

Pressing **L + R** simultaneously during gameplay reloads the current level from the start.

**Implementation:**
- Checks `!controller_axlr` (`$046B`) against bitmask `$30`
- On match, jumps to `load_level` at `$00840D`

### Level Advance (Start + Up)

Pressing **Start + Up** simultaneously during gameplay advances to the next level by incrementing the level index.

**Implementation:**
- Checks `!controller_byetudlr` (`$046C`) against bitmask `%00011000`
- On match, increments `!level_idx_level2` (`$1E38`)

## Architecture

The build pipeline is driven by `build.py`. In the default build, it invokes the external `asar` CLI. In debug/watch mode, it uses a Python ctypes wrapper (`asar/asar.py`) to call into `asar/libasar.so` directly, enabling richer diagnostics (per-block byte counts, hijack reporting).

The original ROM is copied to `patched/` first, then the ASM patch is assembled and applied in-place.

```
jerryboy.sfc (original ROM)
       │
       ▼
  build.py ──── asar CLI (default)
       │    OR  asar/libasar.so (debug mode)
       │
       │    assembles src/main.asm
       │    (includes defines.asm, labels.asm, code.asm)
       │
       ▼
patched/sb_practice.sfc (practice ROM)
```

**Key files:**

- `build.py` — Build script; handles ROM copy, assembly, watch mode, and emulator launch
- `src/main.asm` — Top-level ASM entry point; includes all sub-files
- `src/defines.asm` — RAM address defines (controller, player position, frame counters, level index)
- `src/labels.asm` — Labels for key game routines (`load_level` at `$00840D`, `update_game` hook at `$0088CC`)
- `src/code.asm` — Patch logic; injects `every_frame_patch` into free ROM space at `$00B330`
- `asar/asar.py` — Python ctypes wrapper for the Asar assembler library
- `asar/libasar.so` — Asar shared library (Linux)
