include

!Empty = $00B330

; enable controller inputs while 
org $0092A4
    db $80, $10

org $008227
    jsr unlock_every_levels

org $00B350
unlock_every_levels:
    lda #$0F
    sta $1E33
    rts

org !Empty
every_frame_patch:
    ldx !frame_counter_t
    jsr advance_level
    jsr reload_level
    rts

advance_level:
    lda !controller_byetudlr
    cmp #%00011000
    bne .done
    inc !level_idx_level2
    jmp load_level

.done:
    rts

reload_level:
    lda !controller_axlr
    cmp #$30
    bne .done
    jmp load_level

.done:
    rts
