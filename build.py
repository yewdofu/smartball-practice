#!/usr/bin/env python3

import argparse
import datetime
import hashlib
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'asar'))
import asar
from tools.convert_palette import convert_palette

asar.init(os.path.join(os.path.dirname(__file__), 'asar', 'asar.dll'))

OUT_DIR = "patched"
PALETTE_SOURCE = os.path.join("src", "gfx", "tiles.pal")
PALETTE_OUTPUT = os.path.join(OUT_DIR, "tiles.snes.pal")
PALETTE_FIRST_COLOR = 0xA0
PALETTE_COLOR_COUNT = 16

REGIONS = {
    "jp": {
        "rom": "jerryboy.sfc",
        "sha1": "9df714226c880ed96b43b2d1cdc0884da26a09b1",
        "number": 0,
        "output": "sb_practice.sfc",
    },
    "us": {
        "rom": "smartball.sfc",
        "sha1": "14fc687b5a8437ec0b3515c4d46aed579a8ef58b",
        "number": 1,
        "output": "sb_practice_us.sfc",
    },
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--region", choices=REGIONS, default="jp")
    parser.add_argument("--rom", help="path to the original ROM")
    args = parser.parse_args()
    region = REGIONS[args.region]
    original = args.rom or region["rom"]
    out_path = os.path.join(OUT_DIR, region["output"])

    os.makedirs(OUT_DIR, exist_ok=True)
    convert_palette(
        PALETTE_SOURCE,
        PALETTE_OUTPUT,
        PALETTE_FIRST_COLOR,
        PALETTE_COLOR_COUNT,
    )

    with open(original, "rb") as f:
        rom_data = f.read()

    actual_sha1 = hashlib.sha1(rom_data).hexdigest()
    if actual_sha1 != region["sha1"]:
        print(f"ERROR: {original} is not the verified {args.region.upper()} ROM")
        print(f"Expected SHA-1: {region['sha1']}")
        print(f"Actual SHA-1:   {actual_sha1}")
        sys.exit(1)

    success, patched_data = asar.patch(
        "src/main.asm",
        rom_data,
        override_checksum=True,
        additional_defines={
            "BUILD_DATE": datetime.datetime.now().isoformat(),
            "REGION": str(region["number"]),
        },
    )

    if not success:
        for err in asar.geterrors():
            print(f"ERROR: {err.filename}:{err.line} - {err.rawerrdata.decode()}")
        sys.exit(1)

    with open(out_path, "wb") as f:
        f.write(patched_data)

    written = sum(block.numbytes for block in asar.getwrittenblocks())
    print(f"OK: {args.region.upper()} ROM patched to {out_path} (+{written} bytes)")


if __name__ == "__main__":
    main()
