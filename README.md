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
Run following:
```bash
python build.py
```

It will generate `sb_practice.sfc` in `patched/` directory.
