include

; enable controller inputs while paused
org JP_US($0092A4, $00925B)
    db $80, $10

org JP_US($008227, $0080F9)
    jsr unlock_every_levels

org JP_US($0088CC, $00887F)
update_game:
    jsr ingame_patch

org JP_US($0086FF, $0086B2)
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

org JP_US($0086F9, $0086AC)
    jsr practice_menu_pause_oam_guard

org JP_US($0086E3, $008696)
    jsr practice_menu_pause_oam_guard

org JP_US($008D48, $008CFB)
    jsr practice_menu_game_oam_guard

org JP_US($008715, $0086C8)
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

org JP_US($00842F, $0083D5)
    jsr play_level_bgm

org JP_US($00853F, $0084E5)
    jsr queue_bgm

org JP_US($00AFB7, $00AF6E)
    jsr queue_bgm

org JP_US($00840D, $0083B3)
    jsr prepare_level_load

org JP_US($0084BA, $008460)
    jsr prepare_area_load

org JP_US($00856E, $008514)
    jsr restore_game_checkpoint

org JP_US($008578, $00851E)
    jsr finish_room_load

org JP_US($00879B, $00874E)
    jsr finish_room_transition

org JP_US($009A01, $0099B8)
    jsr capture_room_transition

org JP_US($009A3C, $0099F3)
    jsr clear_instant_transition

org JP_US($0085B7, $00855D)
    jsr timer_prepare
    nop
    nop

org JP_US($009283, $00923A)
    jsr timer_frame_hook

; バッテリーバックアップSRAM 256KB をヘッダーに宣言
; FFD5=$20 LoROM / FFD6=$02 ROM+RAM+バッテリ / FFD8=$08 256KB SRAM
org $00FFD5
    db $20
org $00FFD6
    db $02
org $00FFD8
    db $08
