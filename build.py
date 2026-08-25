#!/usr/bin/env python3

import os
import sys
import datetime

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'asar'))
import asar
from tools.convert_palette import convert_palette

asar.init(os.path.join(os.path.dirname(__file__), 'asar', 'asar.dll'))

ORIGINAL = "jerryboy.sfc"
OUT_DIR = "patched"
OUT_FILE = "sb_practice.sfc"
OUT_PATH = os.path.join(OUT_DIR, OUT_FILE)
PALETTE_SOURCE = os.path.join("src", "gfx", "font.pal")
PALETTE_OUTPUT = os.path.join(OUT_DIR, "font.snes.pal")
PALETTE_FIRST_COLOR = 0xA0
PALETTE_COLOR_COUNT = 16


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    convert_palette(
        PALETTE_SOURCE,
        PALETTE_OUTPUT,
        PALETTE_FIRST_COLOR,
        PALETTE_COLOR_COUNT,
    )

    with open(ORIGINAL, "rb") as f:
        rom_data = f.read()

    success, patched_data = asar.patch(
        "src/main.asm",
        rom_data,
        override_checksum=True,
        additional_defines={"BUILD_DATE": datetime.datetime.now().isoformat()},
    )

    if not success:
        for err in asar.geterrors():
            print(f"ERROR: {err.filename}:{err.line} - {err.rawerrdata.decode()}")
        sys.exit(1)

    with open(OUT_PATH, "wb") as f:
        f.write(patched_data)

    written = sum(block.numbytes for block in asar.getwrittenblocks())
    print(f"OK: ROM patched to {OUT_PATH} (+{written} bytes)")


if __name__ == "__main__":
    main()
