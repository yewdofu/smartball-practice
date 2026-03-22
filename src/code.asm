include

!Empty = $00B330

org !Empty
reload_level:
    lda !controller_axlr
    cmp #$30
    bne .done
    jmp $afa1

.done:
    ldx $1E3E
    rts
