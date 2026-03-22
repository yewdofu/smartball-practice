#!/usr/bin/env python3

import os
import sys
import shutil
import subprocess
import datetime
from argparse import ArgumentParser
from watchfiles import Change, DefaultFilter, watch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'asar'))
import asar

asar.init(os.path.join(os.path.dirname(__file__), 'asar', 'libasar.so'))

c = subprocess.call

EMULATOR = "mesen-s"

ORIGINAL = "jerryboy.sfc"
OUT_DIR = "patched"

OUT_FILE = "sb_practice.sfc"

OUT_PATH = os.path.join(OUT_DIR, OUT_FILE)

BANK_SOURCES = {
    0x910000: ("overworld.asm", 0x118000),
    0x920000: ("menu.asm", 0x128000),
    0x930000: ("level.asm", 0x138000),
}

ACTIONS = {
    1: "ADDED",
    2: "MODIFIED",
    3: "DELETED",
}


class extensionFilter(DefaultFilter):
    allowed_extensions = ".asm", ".bin"

    def __call__(self, change: Change, path: str) -> bool:
        return super().__call__(change, path) and path.endswith(self.allowed_extensions)


def create_directory():
    if os.path.exists(OUT_DIR):
        shutil.rmtree(OUT_DIR)
    os.mkdir(OUT_DIR)


def copy_original_rom():
    shutil.copy(ORIGINAL, OUT_PATH)


def get_source_for_block(snes_addr):
    if 0x910000 <= snes_addr < 0x940000:
        bank_start = (snes_addr // 0x10000) * 0x10000
        if bank_start in BANK_SOURCES:
            return BANK_SOURCES[bank_start][0]
    return None


def assemble2():
    with open (ORIGINAL, "rb") as f:
        rom_data = f.read()

    success, patched_data = asar.patch(
        "src/main.asm",
        rom_data,
        override_checksum=True,
        additional_defines={"BUILD_DATE": datetime.datetime.now().isoformat()}
    )
    
    if not success:
        for err in asar.geterrors():
            print(f"❌ {err.filename}:{err.line} - {err.rawerrdata.decode()}")

    with open(OUT_PATH, "wb") as f:
        f.write(patched_data)

    print(f"✓ ROM patched: {OUT_PATH}")
    blocks = asar.getwrittenblocks()

    banked = {}
    hijacks = []

    for block in blocks:
        source = get_source_for_block(block.snesoffset)
        if source:
            if source not in banked:
                banked[source] = []
            banked[source].append(block)
        else:
            hijacks.append(block)

    for source in sorted(banked.keys()):
        total_bytes = sum(b.numbytes for b in banked[source])
        print(f"  [{source}] {total_bytes} bytes")
        for block in banked[source]:
            print(f"    ${block.snesoffset:06x}: {block.numbytes} bytes")

    if hijacks:
        print(f"  [hijacks.asm / edits.asm] {len(hijacks)} hooks")
        for block in hijacks:
            print(f"    ${block.snesoffset:06x}: {block.numbytes} bytes")

    return True


def assemble():
    c(f"asar src/main.asm {OUT_PATH}".split())
    print(f"Assembling finished. File: {OUT_PATH}")


def debug():
    for changes in watch("src", watch_filter=extensionFilter()):
        for action, path in changes:
            time = datetime.datetime.now().strftime("%H:%M:%S")
            if action == 3:
                continue
            action_text = f"{time} | {ACTIONS.get(action)}:"
            print(action_text, path)
            create_directory()
            copy_original_rom()
            is_patched = assemble2()
            if is_patched:
                subprocess.Popen(f"mesen {OUT_PATH}".split())


def main():
    create_directory()
    copy_original_rom()
    assemble()


parser = ArgumentParser()
parser.add_argument(
    "-d",
    "--debug",
    action="store_true",
    help="option for debugging or development purpose.",
)
args = parser.parse_args()

if args.debug == True:
    debug()
else:
    main()
sys.exit()
