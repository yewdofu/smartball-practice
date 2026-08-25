include

; Practice menu alphabet (A-Z), mapped to OBJ tiles $A0-$B9.
org $10F400
    incbin "gfx/font.bin":$0200..$053F

org $00BCC0
practice_menu_resume:
    jsr pause_setup
    jsr deactivate_practice_menu
    jsr wait_vblank_end
    jsl restore_practice_menu_oam
    rts

practice_menu_should_pause:
    lda !menu_resume_after_load
    beq .button
    stz !menu_resume_after_load
    clc
    rts
.button:
    jsr practice_menu_pause_button_edge
    bcc .stay_active
    jsr practice_menu_pause_enter
    sec
    rts
.stay_active:
    clc
    rts

practice_menu_should_resume:
    jsr practice_menu_update
    lda !menu_draw_pending
    beq .request
    jsr wait_vblank_end
    lda !menu_draw_pending
    cmp #!menu_draw_cursor
    beq .draw_cursor
    cmp #!menu_draw_value
    beq .draw_value
    jsr draw_practice_menu
    bra .draw_done
.draw_cursor:
    jsr draw_menu_cursor
    bra .draw_done
.draw_value:
    jsl draw_practice_menu_value_update
.draw_done:
    stz !menu_draw_pending
.request:
    lda !menu_cancel_requested
    beq .button
    stz !menu_cancel_requested
    sec
    rts
.button:
    jmp practice_menu_pause_button_edge

practice_menu_pause_enter:
    lda #!menu_active_value
    sta !menu_active
    stz !menu_draw_pending
    stz !menu_cursor
    stz !menu_cancel_requested
    stz !menu_draw_initialized
    lda !level_idx_world
    sta !menu_level
    lda !level_idx_level
    sta !menu_area
    lda !continue_count
    sta !menu_lives
    lda !player_hp
    sta !menu_hp
    lda !ball_count
    sta !menu_balls
    jsl open_practice_menu_display
    rts

practice_menu_pause_oam_guard:
    pha
    lda !menu_active
    bne .skip
    pla
    jmp draw_oam_table_entry
.skip:
    pla
    rts

practice_menu_oam_dma_guard:
    lda !menu_active
    bne .skip
    lda #!zero_data_bank
    sta !dma_control
    jml oam_dma_continue
.skip:
    jml oam_dma_return

practice_menu_update:
    lda !menu_active
    bne .active
    jmp .inactive
.active:
    lda !controller_byetudlr_prev
    eor #!controller_invert_mask
    and !controller_byetudlr
    sta !menu_input_edge
    and #!menu_b_button
    bne .cancel
    lda !menu_input_edge
    and #!menu_up_button
    bne .up
    lda !menu_input_edge
    and #!menu_down_button
    bne .down
    lda !menu_input_edge
    and #!menu_left_button
    bne .decrement
    lda !menu_input_edge
    and #!menu_right_button
    bne .increment
    lda !controller_axlr_prev
    eor #!controller_invert_mask
    and !controller_axlr
    and #!menu_a_button
    bne .a_pressed
    jmp .consumed
.a_pressed:
    lda !menu_cursor
    cmp #!menu_apply_item
    bne +
    jmp .apply
+:
    bra .increment
.cancel:
    lda #!menu_request_value
    sta !menu_cancel_requested
    jmp .consumed
.up:
    lda !menu_cursor
    bne +
    lda #!menu_item_count
+:
    dec
    sta !menu_cursor
    bra .redraw_cursor
.down:
    inc !menu_cursor
    lda !menu_cursor
    cmp #!menu_item_count
    bcc .redraw_cursor
    stz !menu_cursor
    bra .redraw_cursor
.increment:
    lda #!zero_data_bank
    xba
    lda !menu_cursor
    tax
    cpx.w #!menu_apply_item
    beq .consumed
    lda !menu_level,x
    inc
    cmp.l menu_max_values,x
    bcc +
    beq +
    lda.l menu_min_values,x
+:
    sta !menu_level,x
    bra .redraw_value
.decrement:
    lda #!zero_data_bank
    xba
    lda !menu_cursor
    tax
    cpx.w #!menu_apply_item
    beq .consumed
    lda !menu_level,x
    cmp.l menu_min_values,x
    bne .decrement_value
    lda.l menu_max_values,x
    bra .store_decrement
.decrement_value:
    dec
.store_decrement:
    sta !menu_level,x
    bra .redraw_value
.redraw_cursor:
    lda #!menu_draw_cursor
    sta !menu_draw_pending
    bra .consumed
.redraw_value:
    lda !menu_cursor
    cmp #!menu_bgm_item
    bne +
    jsr save_bgm_setting
+:
    lda #!menu_draw_value
    sta !menu_draw_pending
    bra .consumed
.apply:
    lda #!menu_request_value
    sta !menu_apply_pending
    sta !menu_resume_after_load
    jsr deactivate_practice_menu
    lda !menu_level
    sta !level_idx_world2
    lda !menu_area
    sta !level_idx_level2
    jsr timer_deactivate
    stz !room_timer_restore_pending
    rep #!status_index_16bit
    ldx.w #!stack_initial
    txs
    jmp load_level
.consumed:
    sec
    rts
.inactive:
    clc
    rts

apply_practice_settings:
    lda !menu_apply_pending
    beq .done
    stz !menu_apply_pending
    lda !menu_lives
    sta !continue_count
    lda !menu_hp
    sta !player_hp
    sta !player_max_hp
    lda !menu_balls
    sta !ball_count
.done:
    rts

play_level_bgm:
    lda !menu_bgm_disabled
    bne .muted
    jmp apu_write_command
.muted:
    rts

queue_bgm:
    pha
    lda !menu_bgm_disabled
    beq .enabled
    pla
    lda #!bgm_silent_command
    bra .store
.enabled:
    pla
.store:
    sta !apu_command
    rts

load_bgm_setting:
    lda.l !sram_bgm_disabled
    cmp #!menu_bgm_value_count
    bcc .valid
    lda #!menu_bgm_min
    sta.l !sram_bgm_disabled
.valid:
    sta !menu_bgm_disabled
    rts

save_bgm_setting:
    lda !menu_bgm_disabled
    sta.l !sram_bgm_disabled
    rts

draw_practice_menu:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    lda !menu_active
    beq .inactive
    jmp .active
.inactive:
    plp
    rts
.active:
    lda !menu_draw_initialized
    bne .draw_low_oam
    lda #!inidisp_forced_blank_full
    sta !inidisp
.draw_low_oam:
    lda #!menu_oam_base_address
    sta !oam_address_low
    stz !oam_address_high
    jsr draw_menu_cursor
    stz !menu_draw_row
    ldx.w #!menu_first_item
.row:
    stz !menu_draw_col
.column:
    lda.l menu_text,x
    cmp #!menu_hidden_tile
    beq .next
    pha
    lda !menu_draw_col
    asl
    asl
    asl
    clc
    adc #!menu_label_x
    sta !oam_data
    lda !menu_draw_row
    asl
    asl
    asl
    asl
    clc
    adc #!menu_y
    sta !oam_data
    pla
    sta !oam_data
    lda #!menu_oam_attributes
    sta !oam_data
.next:
    inx
    inc !menu_draw_col
    lda !menu_draw_col
    cmp #!menu_text_columns
    bcc .column
    inc !menu_draw_row
    lda !menu_draw_row
    cmp #!menu_item_count
    bcc .row

    ldx.w #!menu_first_item
.value:
    txa
    sta !menu_draw_row
    lda !menu_level,x
    clc
    adc #!menu_font_digit_base
    jsr draw_menu_value
    inx
    cpx.w #!menu_bgm_item
    bcc .value

    lda #!menu_bgm_item
    sta !menu_draw_row
    ldx.w #!menu_first_item
    lda !menu_bgm_disabled
    beq .bgm_on
    ldx.w #!menu_bgm_text_length
.bgm_on:
    ldy.w #!menu_first_item
.bgm:
    lda.l menu_bgm_text,x
    jsr draw_menu_value
    inx
    iny
    cpy.w #!menu_bgm_text_length
    bcc .bgm

    lda !menu_draw_initialized
    bne .done
    jsr hide_unused_menu_oam
    lda #!menu_oam_high_address
    sta !oam_address_low
    lda #!oam_high_table_select
    sta !oam_address_high
    ldx.w #!menu_oam_high_bytes
.high:
    stz !oam_data
    dex
    bne .high
    lda #!inidisp_display_full
    sta !inidisp
    lda #!menu_active_value
    sta !menu_draw_initialized
.done:
    plp
    rts

hide_unused_menu_oam:
    lda #!menu_oam_tail_base_address
    ldx.w #!menu_oam_tail_count
    bra hide_oam_entries

hide_oam_entries:
    sta !oam_address_low
    stz !oam_address_high
.entry:
    lda #!menu_oam_hidden_y
    sta !oam_data
    sta !oam_data
    sta !oam_data
    sta !oam_data
    dex
    bne .entry
    rts

draw_menu_value:
    cmp #!menu_hidden_tile
    bne .visible
    pha
    stz !oam_data
    lda #!menu_oam_hidden_y
    sta !oam_data
    pla
    bra .tile
.visible:
    pha
    lda #!menu_value_x
    sta !oam_data
    lda !menu_draw_row
    asl
    asl
    asl
    asl
    clc
    adc #!menu_y
    sta !oam_data
    pla
.tile:
    sta !oam_data
    lda #!menu_oam_attributes
    sta !oam_data
    rts

menu_text:
    db $AB,$A4,$B5,$A4,$AB,$FF
    db $A0,$B1,$A4,$A0,$FF,$FF
    db $AB,$A8,$B5,$A4,$B2,$FF
    db $A7,$AF,$FF,$FF,$FF,$FF
    db $A1,$A0,$AB,$AB,$B2,$FF
    db $A1,$A6,$AC,$FF,$FF,$FF
    db $A0,$AF,$AF,$AB,$B8,$FF

warnpc $00C000

pushpc
org $00B361
menu_min_values:
    db 1,1,0,1,0,0
menu_max_values:
    db 8,2,9,8,8,1
menu_bgm_text:
    db $AE,$AD,$FF,$AE,$A5,$A5
deactivate_practice_menu:
    stz !menu_active
    rts
practice_menu_pause_button_edge:
    lda !controller_byetudlr_prev
    eor #!controller_invert_mask
    and !controller_byetudlr
    and #!pause_button
    beq .not_pressed
    sec
    rts
.not_pressed:
    clc
    rts
warnpc $00B390
pullpc

pushpc
org $00B3C0
practice_menu_game_oam_guard:
    lda !menu_active
    bne .skip
    jmp pause_gfx_prepare
.skip:
    rts

draw_menu_cursor:
    lda #!menu_oam_base_address
    sta !oam_address_low
    stz !oam_address_high
    lda #!menu_cursor_x
    sta !oam_data
    lda !menu_cursor
    asl
    asl
    asl
    asl
    clc
    adc #!menu_y
    sta !oam_data
    lda #!menu_font_digit_base
    sta !oam_data
    lda #!menu_oam_selected_attributes
    sta !oam_data
    rts
warnpc $00B400
pullpc

pushpc
org $1FF000
capture_practice_menu_oam:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    stz !oam_address_low
    stz !oam_address_high
    lda #!dma_mode0_ppu_to_cpu
    sta !dma1_control
    lda #!dma_bbus_oam_read
    sta !dma1_bbus_address
    ldx.w #!menu_oam_backup_address
    stx !dma1_source_address
    lda #!menu_oam_sram_bank
    sta !dma1_source_bank
    ldx.w #!state_oam_size
    stx !dma1_transfer_size
    lda #!dma_channel1_enable
    sta !dma_enable
    stz !oam_address_low
    lda #!oam_high_table_select
    sta !oam_address_high
    ldx.w #!menu_oam_backup_high_address
    stx !dma1_source_address
    ldx.w #!state_oam_high_size
    stx !dma1_transfer_size
    lda #!dma_channel1_enable
    sta !dma_enable
    plp
    rtl

restore_practice_menu_oam:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    stz !oam_address_low
    stz !oam_address_high
    lda #!dma_mode0_cpu_to_ppu
    sta !dma1_control
    lda #!dma_bbus_oam_write
    sta !dma1_bbus_address
    ldx.w #!menu_oam_backup_address
    stx !dma1_source_address
    lda #!menu_oam_sram_bank
    sta !dma1_source_bank
    ldx.w #!state_oam_size
    stx !dma1_transfer_size
    lda #!dma_channel1_enable
    sta !dma_enable
    stz !oam_address_low
    lda #!oam_high_table_select
    sta !oam_address_high
    ldx.w #!menu_oam_backup_high_address
    stx !dma1_source_address
    ldx.w #!state_oam_high_size
    stx !dma1_transfer_size
    lda #!dma_channel1_enable
    sta !dma_enable
    plp
    rtl

transfer_practice_menu_oam:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    stz !oam_address_low
    stz !oam_address_high
    lda #!dma_mode0_cpu_to_ppu
    sta !dma1_control
    lda #!dma_bbus_oam_write
    sta !dma1_bbus_address
    ldx.w #!menu_oam_buffer_address
    stx !dma1_source_address
    lda #!menu_oam_sram_bank
    sta !dma1_source_bank
    ldx.w #!menu_oam_low_size
    stx !dma1_transfer_size
    lda #!dma_channel1_enable
    sta !dma_enable
    stz !oam_address_low
    lda #!oam_high_table_select
    sta !oam_address_high
    ldx.w #!menu_oam_buffer_high_address
    stx !dma1_source_address
    ldx.w #!menu_oam_high_bytes
    stx !dma1_transfer_size
    lda #!dma_channel1_enable
    sta !dma_enable
    plp
    rtl

draw_practice_menu_value_update:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    lda !menu_cursor
    cmp #!menu_bgm_item
    bcs .bgm
    asl
    clc
    adc #!menu_numeric_value_oam_base_address
    sta !oam_address_low
    stz !oam_address_high
    lda #!menu_value_x
    sta !oam_data
    lda !menu_cursor
    asl
    asl
    asl
    asl
    clc
    adc #!menu_y
    sta !oam_data
    lda #!zero_data_bank
    xba
    lda !menu_cursor
    tax
    lda !menu_level,x
    clc
    adc #!menu_font_digit_base
    sta !oam_data
    lda #!menu_oam_attributes
    sta !oam_data
    plp
    rtl
.bgm:
    lda #!menu_bgm_oam_base_address
    sta !oam_address_low
    stz !oam_address_high
    ldx.w #!menu_first_item
    lda !menu_bgm_disabled
    beq +
    ldx.w #!menu_bgm_text_length
+:
    ldy.w #!menu_first_item
.bgm_char:
    lda.l menu_bgm_text,x
    pha
    cmp #!menu_hidden_tile
    beq .bgm_hidden
    tya
    asl
    asl
    asl
    clc
    adc #!menu_value_x
    sta !oam_data
    lda #!menu_y+(!menu_bgm_item*!menu_row_spacing)
    sta !oam_data
    pla
    bra .bgm_tile
.bgm_hidden:
    stz !oam_data
    lda #!menu_oam_hidden_y
    sta !oam_data
    pla
.bgm_tile:
    sta !oam_data
    lda #!menu_oam_attributes
    sta !oam_data
    inx
    iny
    cpy.w #!menu_bgm_text_length
    bcc .bgm_char
    plp
    rtl

open_practice_menu_display:
    jsl build_practice_menu_oam
.vblank:
    lda !hvbjoy
    bpl .vblank
    jsl capture_practice_menu_oam
    jsl transfer_practice_menu_oam
    lda #!menu_active_value
    sta !menu_draw_initialized
    rtl

build_practice_menu_oam:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    ldx.w #!state_transfer_index_start
    ldy.w #!menu_oam_count
    lda #!menu_oam_hidden_y
.hide_low:
    sta.l !menu_oam_buffer,x
    inx
    sta.l !menu_oam_buffer,x
    inx
    sta.l !menu_oam_buffer,x
    inx
    sta.l !menu_oam_buffer,x
    inx
    dey
    bne .hide_low
    ldx.w #!state_transfer_index_start
    ldy.w #!menu_oam_high_bytes
    lda #!zero_data_bank
.hide_high:
    sta.l !menu_oam_buffer_high,x
    inx
    dey
    bne .hide_high

    ldx.w #!state_transfer_index_start
    lda #!menu_cursor_x
    sta.l !menu_oam_buffer,x
    inx
    lda !menu_cursor
    asl
    asl
    asl
    asl
    clc
    adc #!menu_y
    sta.l !menu_oam_buffer,x
    inx
    lda #!menu_font_digit_base
    sta.l !menu_oam_buffer,x
    inx
    lda #!menu_oam_selected_attributes
    sta.l !menu_oam_buffer,x
    inx

    stz !menu_draw_row
    ldy.w #!menu_first_item
.row:
    stz !menu_draw_col
.column:
    phx
    tyx
    lda.l menu_text,x
    plx
    cmp #!menu_hidden_tile
    beq .next
    pha
    lda !menu_draw_col
    asl
    asl
    asl
    clc
    adc #!menu_label_x
    sta.l !menu_oam_buffer,x
    inx
    lda !menu_draw_row
    asl
    asl
    asl
    asl
    clc
    adc #!menu_y
    sta.l !menu_oam_buffer,x
    inx
    pla
    sta.l !menu_oam_buffer,x
    inx
    lda #!menu_oam_attributes
    sta.l !menu_oam_buffer,x
    inx
.next:
    iny
    inc !menu_draw_col
    lda !menu_draw_col
    cmp #!menu_text_columns
    bcc .column
    inc !menu_draw_row
    lda !menu_draw_row
    cmp #!menu_item_count
    bcc .row

    ldy.w #!menu_first_item
.value:
    lda #!menu_value_x
    sta.l !menu_oam_buffer,x
    inx
    tya
    asl
    asl
    asl
    asl
    clc
    adc #!menu_y
    sta.l !menu_oam_buffer,x
    inx
    lda !menu_level,y
    clc
    adc #!menu_font_digit_base
    sta.l !menu_oam_buffer,x
    inx
    lda #!menu_oam_attributes
    sta.l !menu_oam_buffer,x
    inx
    iny
    cpy.w #!menu_bgm_item
    bcc .value

    ldy.w #!menu_first_item
    lda !menu_bgm_disabled
    beq +
    ldy.w #!menu_bgm_text_length
+:
    stz !menu_draw_col
.bgm:
    phx
    tyx
    lda.l menu_bgm_text,x
    plx
    pha
    cmp #!menu_hidden_tile
    beq .bgm_hidden
    lda !menu_draw_col
    asl
    asl
    asl
    clc
    adc #!menu_value_x
    sta.l !menu_oam_buffer,x
    inx
    lda #!menu_y+(!menu_bgm_item*!menu_row_spacing)
    sta.l !menu_oam_buffer,x
    inx
    pla
    bra .bgm_tile
.bgm_hidden:
    lda #!zero_data_bank
    sta.l !menu_oam_buffer,x
    inx
    lda #!menu_oam_hidden_y
    sta.l !menu_oam_buffer,x
    inx
    pla
.bgm_tile:
    sta.l !menu_oam_buffer,x
    inx
    lda #!menu_oam_attributes
    sta.l !menu_oam_buffer,x
    inx
    iny
    inc !menu_draw_col
    lda !menu_draw_col
    cmp #!menu_bgm_text_length
    bcc .bgm
    plp
    rtl
warnpc $1FF400
pullpc
