include

org $00B370
reload_level:
    lda !controller_axlr
    cmp #!reload_level_buttons
    bne .done
    jsr timer_deactivate
    jmp load_level

.done:
    rts
