include

org $00B330
ingame_patch:
    jsr practice_menu_update
    bcs .done
    jsr change_level
    jsr open_stage_select
    jsr reload_level
    jsr reload_room
    jsr state_save
    jsr state_load
.done:
    ldx !frame_counter_t ; original instruction
    rts

warnpc $00B350

org $00B350
unlock_every_levels:
    lda #!all_levels_unlocked
    sta !highest_unlocked_level
    rts

warnpc $00B356

org $00B356
change_level:
    lda !controller_byetudlr
    cmp #!change_level_buttons
    bne .done
    inc !level_idx_level2

.done:
    rts

warnpc $00B361
