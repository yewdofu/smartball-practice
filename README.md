# smartball-practice
Speedrun practice hack for Smart Ball (SNES).

## Features
- Level unlock
- Room advance
- Stage select (Start + Select)
- Level reset (A + B + L + R)
- Room reset (L + R)
- In-game timer
- Save state (R + Start)
- Load state (L + Start)
- Pause practice menu (D-pad + A/B)

The pause menu configures the starting level/area, lives, HP, ball count,
player form, and BGM. Select `APPLY` to reload the level with the new settings.

Save states use 256KB of battery-backed SRAM and are available during gameplay.

## Build
For the Japanese version, placed the ROM named `jerryboy.sfc` and run:
```bash
python build.py
```

For the US version, place the ROM named `smartball.sfc` and run:
```bash
python build.py --region us
```

You can specify a differently named ROM with `--rom path/to/rom.sfc`.
The patched ROM is generated in `patched/` as `sb_practice.sfc` (JP) or
`sb_practice_us.sfc` (US).
