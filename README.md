# smartball-practice

A ROM patching tool for creating a speedrun practice ROM for Jerry Boy / Smart Ball (SNES).

## Overview

This project applies an ASM patch to a Jerry Boy / Smart Ball ROM using the [Asar](https://github.com/RPGHacker/asar) SNES assembler. The resulting patched ROM adds quality-of-life features for speedrun practice, such as instant level reload via controller input.

The patch currently hooks into the game's main update loop and injects a `reload_level` routine: pressing **L + R** simultaneously reloads the current level from the beginning, allowing runners to quickly retry sections without navigating menus.

A watch mode is also included for iterative ASM development — file changes trigger an automatic rebuild and launch the emulator.

## Getting Started

### Prerequisites

- Python 3.12 or later
- [uv](https://github.com/astral-sh/uv) (recommended) or pip
- An original, headerless `jellyboy.sfc` ROM placed in the project root
- `libasar.so` (already included in `asar/`) — Asar shared library for Linux
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

This copies `jellyboy.sfc` to `patched/sb_practice.sfc` and applies the ASM patch. The patched ROM is written to `patched/sb_practice.sfc`.

## Development

```bash
# Watch mode: auto-rebuild on .asm/.bin file changes and launch Mesen
python build.py --debug
```

In watch mode, any change to a file under `src/` triggers a full rebuild. If the build succeeds, the patched ROM is launched in Mesen automatically.

## Patch Features

### Level Reload (L + R)

Pressing **L + R** simultaneously during gameplay reloads the current level from the start. This is the primary feature for speedrun practice.

**Implementation:**
- A `reload_level` routine is injected at `$00B330` (free space in the ROM)
- The game's `update_game` routine at `$0088CC` is hijacked to call `reload_level` each frame
- On L+R input (controller bitmask `$30`), execution jumps to `load_level` at `$AFA1`

## Architecture

The build pipeline is driven by `build.py`, which uses a Python binding (`asar/asar.py`) to call into `asar/libasar.so` — the Asar SNES assembler shared library. The original ROM is loaded into memory, the ASM patch is assembled and applied in-place, and the result is written to `patched/sb_practice.sfc`.

```
jellyboy.sfc (original ROM)
       │
       ▼
  build.py ──── asar/libasar.so
       │               │
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
- `src/labels.asm` — Labels for key game routines (`load_level`, `update_game`)
- `src/code.asm` — Patch logic; injects the `reload_level` routine into free ROM space
- `asar/asar.py` — Python ctypes wrapper for the Asar assembler library
- `asar/libasar.so` — Asar shared library (Linux)
