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

org $00B390
open_stage_select:
    lda !controller_byetudlr
    cmp #!stage_select_buttons
    bne .done
    jsr timer_deactivate
    jmp stage_select_init

.done:
    rts
