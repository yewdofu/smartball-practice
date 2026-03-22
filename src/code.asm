include

!Empty = $00B330

org !Empty
every_frame_patch:
    ldx !frame_counter_t
    jsr change_level
    jsr reload_level
    rts

change_level:
    lda !controller_byetudlr
    cmp #%00011000
    bne .done
    inc !level_idx_level2

.done:
    rts

reload_level:
    lda !controller_axlr
    cmp #$30
    bne .done
    jmp load_level

.done:
    rts