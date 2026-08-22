include

org $0088CC
update_game:
    jsr ingame_patch

org $00840D
    jsr prepare_level_load

org $0084BA
    jsr prepare_area_load

org $00856E
    jsr restore_game_checkpoint

org $008578
    jsr finish_room_load

org $00879B
    jsr finish_room_transition

org $009A01
    jsr capture_room_transition

org $009A3C
    jsr clear_instant_transition

; バッテリーバックアップSRAM 256KB をヘッダーに宣言
; FFD5=$20 LoROM / FFD6=$02 ROM+RAM+バッテリ / FFD8=$08 256KB SRAM
org $00FFD5
    db $20
org $00FFD6
    db $02
org $00FFD8
    db $08
