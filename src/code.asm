include

; enable controller inputs while 
org $0092A4
    db $80, $10

org $008227
    jsr unlock_every_levels

org $00B330
ingame_patch:
    jsr change_level
    jsr open_stage_select
    jsr reload_level
    ldx !frame_counter_t ; original instruction
    rts

org $00B350
unlock_every_levels:
    lda #!all_levels_unlocked
    sta !highest_unlocked_level
    rts

org $00B356
change_level:
    lda !controller_byetudlr
    cmp #!change_level_buttons
    bne .done
    inc !level_idx_level2

.done:
    rts
