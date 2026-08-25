include

org $0088CC
update_game:
    jsr ingame_patch

org $0086FF
    jsr practice_menu_should_resume
    bcc pause_loop_continue
    lda #!pause_resume_sound
    jsr draw_oam_table_entry
    jsr practice_menu_resume
    bra gameplay_loop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

org $0086F9
    jsr practice_menu_pause_oam_guard

org $0086E3
    jsr practice_menu_pause_oam_guard

org $008D48
    jsr practice_menu_game_oam_guard

org $008715
    jsr practice_menu_should_pause
    bcs pause_loop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

org $018A98
    jml practice_menu_oam_dma_guard
    nop

org $00842F
    jsr play_level_bgm

org $00853F
    jsr queue_bgm

org $00AFB7
    jsr queue_bgm

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
