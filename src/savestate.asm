include

; ============================================================
; 実機用セーブステート
;   R+Start セーブ / L+Start ロード (ゲームプレイ中のみ)
;   バッテリーバックアップSRAM 256KB ($70-$77:0000-$7FFF) を使用。
;   スナップショット:
;     $70-$73:0000-$7FFF : WRAM 128KB
;     $74-$75:0000-$7FFF : VRAM 64KB
;     $76:0000-$76:01FF : CGRAM
;     $76:0200-$76:03FF : OAM 低テーブル
;     $76:0400-$76:041F : OAM 高テーブル
;     $76:0420-         : CPU状態
; ============================================================

; ------------------------------------------------------------
; 入力判定
; ------------------------------------------------------------
org $00B920
state_save:
    lda !game_mode
    cmp #!game_mode_gameplay
    bne .released
    lda !controller_axlr
    and #!r_button
    beq .released
    lda !controller_axlr
    and #!l_button
    bne .released
    lda !controller_byetudlr
    and #!start_button
    beq .released
    lda !save_latch
    bne .done
    lda #!reset_latch_active
    sta !save_latch
    lda #!state_magic_invalid
    sta !sram_regs+!ss_magic_h
    sta !sram_regs+!ss_magic_l
    jmp save_state
.released:
    stz !save_latch
.done:
    rts

state_load:
    lda !game_mode
    cmp #!game_mode_gameplay
    bne .released
    lda !controller_axlr
    and #!l_button
    beq .released
    lda !controller_axlr
    and #!r_button
    bne .released
    lda !controller_byetudlr
    and #!start_button
    beq .released
    lda !load_latch
    bne .done
    lda #!reset_latch_active
    sta !load_latch
    jmp load_state
.released:
    stz !load_latch
.done:
    rts

; ------------------------------------------------------------
; セーブ本体
; ------------------------------------------------------------
save_state:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    pha
    phx
    phy
    rep #!status_accumulator_16bit
    sta !sram_regs+!ss_a
    tsc
    clc
    adc #!state_save_stack_offset
    sta !sram_regs+!ss_s
    tdc
    sta !sram_regs+!ss_d
    sep #!status_accumulator_8bit
    lda !state_stack_y_low,s
    sta !sram_regs+!ss_y
    lda !state_stack_y_high,s
    sta !sram_regs+!ss_y+1
    lda !state_stack_x_low,s
    sta !sram_regs+!ss_x
    lda !state_stack_x_high,s
    sta !sram_regs+!ss_x+1
    lda !state_stack_p,s
    sta !sram_regs+!ss_p
    phb
    pla
    sta !sram_regs+!ss_db
    lda !timer_state
    cmp #!timer_state_running
    bne .autojoy_only
    lda #!nmitimen_timer_enabled
    bra .save_nmitimen
.autojoy_only:
    lda #!nmitimen_autojoy_enabled
.save_nmitimen:
    sta !sram_regs+!ss_4200
    lda.b #state_resume>>16
    sta !sram_regs+!ss_k
    lda.b #state_resume
    sta !sram_regs+!ss_pc_l
    lda.b #state_resume>>8
    sta !sram_regs+!ss_pc_h
    lda #!state_format_version
    sta !sram_regs+!ss_format_version
    lda #!state_rom_compatibility
    sta !sram_regs+!ss_rom_compatibility
    ply
    plx
    pla
    plp
    stz !save_latch
    stz !load_latch
    stz !nmitimen
    jsr force_state_blank
    jsr capture_palette
    jsr capture_sprites
    jsr capture_vram
    jsr capture_wram
    lda #!state_magic_high
    sta !sram_regs+!ss_magic_h
    lda #!state_magic_low
    sta !sram_regs+!ss_magic_l
    lda #!inidisp_display_full
    sta !inidisp
    lda #!reset_latch_active
    sta !save_latch
    lda !rdnmi
    lda !sram_regs+!ss_4200
    sta !nmitimen
    rts

; ------------------------------------------------------------
; ロード本体
; ------------------------------------------------------------
load_state:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    lda !sram_regs+!ss_magic_h
    cmp #!state_magic_high
    bne .invalid
    lda !sram_regs+!ss_magic_l
    cmp #!state_magic_low
    bne .invalid
    lda !sram_regs+!ss_format_version
    cmp #!state_format_version
    bne .invalid
    lda !sram_regs+!ss_rom_compatibility
    cmp #!state_rom_compatibility
    bne .invalid
    stz !nmitimen
    jsr force_state_blank
    jsr restore_palette
    jsr restore_sprites
    jsr restore_vram
    jmp restore_wram_and_cpu
.invalid:
    plp
    rts

force_state_blank:
    lda #!inidisp_forced_blank_full
    sta !inidisp
.wait_active:
    lda !hvbjoy
    bmi .wait_active
.wait_vblank:
    lda !hvbjoy
    bpl .wait_vblank
    rts

; ------------------------------------------------------------
; CGRAM 保存・復元
; ------------------------------------------------------------
capture_palette:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    stz !cgadd
    ldx #!state_transfer_index_start
-
    lda !cgdata_read
    sta !sram_cgram,x
    lda !cgdata_read
    sta !sram_cgram+1,x
    inx
    inx
    cpx #!state_cgram_size
    bne -
    plp
    rts

restore_palette:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    stz !cgadd
    ldx #!state_transfer_index_start
-
    lda !sram_cgram,x
    sta !cgdata_write
    lda !sram_cgram+1,x
    sta !cgdata_write
    inx
    inx
    cpx #!state_cgram_size
    bne -
    plp
    rts

; ------------------------------------------------------------
; OAM 保存・復元
; ------------------------------------------------------------
capture_sprites:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    stz !oam_address_low
    stz !oam_address_high
    ldx #!state_transfer_index_start
-
    lda !oam_data_read
    sta !sram_oam,x
    inx
    cpx #!state_oam_size
    bne -
    stz !oam_address_low
    lda #!oam_high_table_select
    sta !oam_address_high
    ldx #!state_transfer_index_start
-
    lda !oam_data_read
    sta !sram_oam_high,x
    inx
    cpx #!state_oam_high_size
    bne -
    plp
    rts

restore_sprites:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    stz !oam_address_low
    stz !oam_address_high
    ldx #!state_transfer_index_start
-
    lda !sram_oam,x
    sta !oam_data
    inx
    cpx #!state_oam_size
    bne -
    stz !oam_address_low
    lda #!oam_high_table_select
    sta !oam_address_high
    ldx #!state_transfer_index_start
-
    lda !sram_oam_high,x
    sta !oam_data
    inx
    cpx #!state_oam_high_size
    bne -
    plp
    rts

; ------------------------------------------------------------
; VRAM 保存・復元
; ------------------------------------------------------------
capture_vram:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    lda #!vmain_inc_high
    sta !vmain
    stz !vmaddr_low
    stz !vmaddr_high
    lda !vram_data_read_low
    lda !vram_data_read_high
    ldx #!state_transfer_index_start
-
    lda !vram_data_read_low
    sta !sram_vram,x
    lda !vram_data_read_high
    sta !sram_vram+1,x
    inx
    inx
    cpx #!state_vram_chunk_size
    bne -
    ldx #!state_transfer_index_start
-
    lda !vram_data_read_low
    sta !sram_vram2,x
    lda !vram_data_read_high
    sta !sram_vram2+1,x
    inx
    inx
    cpx #!state_vram_chunk_size
    bne -
    plp
    rts

restore_vram:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    lda #!vmain_inc_high
    sta !vmain
    stz !vmaddr_low
    stz !vmaddr_high
    ldx #!state_transfer_index_start
-
    lda !sram_vram,x
    sta !vram_data_write_low
    lda !sram_vram+1,x
    sta !vram_data_write_high
    inx
    inx
    cpx #!state_vram_chunk_size
    bne -
    ldx #!state_transfer_index_start
-
    lda !sram_vram2,x
    sta !vram_data_write_low
    lda !sram_vram2+1,x
    sta !vram_data_write_high
    inx
    inx
    cpx #!state_vram_chunk_size
    bne -
    plp
    rts

; ------------------------------------------------------------
; WRAM 保存
; ------------------------------------------------------------
capture_wram:
    php
    rep #!status_registers_16bit
    ldx #!state_transfer_index_start
-
    lda !state_wram_7e_low,x
    sta !sram_wram,x
    inx
    inx
    cpx #!state_wram_chunk_size
    bne -
    ldx #!state_transfer_index_start
-
    lda !state_wram_7e_high,x
    sta !sram_wram2,x
    inx
    inx
    cpx #!state_wram_chunk_size
    bne -
    ldx #!state_transfer_index_start
-
    lda !state_wram_7f_low,x
    sta !sram_wram3,x
    inx
    inx
    cpx #!state_wram_chunk_size
    bne -
    ldx #!state_transfer_index_start
-
    lda !state_wram_7f_high,x
    sta !sram_wram4,x
    inx
    inx
    cpx #!state_wram_chunk_size
    bne -
    plp
    rts

; ------------------------------------------------------------
; WRAM 復元 (スタック未使用) + CPU 復元
; ------------------------------------------------------------
restore_wram_and_cpu:
    rep #!status_registers_16bit
    ldx #!state_transfer_index_start
-
    lda !sram_wram,x
    sta !state_wram_7e_low,x
    inx
    inx
    cpx #!state_wram_chunk_size
    bne -
    ldx #!state_transfer_index_start
-
    lda !sram_wram2,x
    sta !state_wram_7e_high,x
    inx
    inx
    cpx #!state_wram_chunk_size
    bne -
    ldx #!state_transfer_index_start
-
    lda !sram_wram3,x
    sta !state_wram_7f_low,x
    inx
    inx
    cpx #!state_wram_chunk_size
    bne -
    ldx #!state_transfer_index_start
-
    lda !sram_wram4,x
    sta !state_wram_7f_high,x
    inx
    inx
    cpx #!state_wram_chunk_size
    bne -
    sep #!status_accumulator_8bit
    lda #!l_button
    sta !controller_axlr
    lda #!start_button
    sta !controller_byetudlr
    lda #!reset_latch_active
    sta !save_latch
    sta !load_latch
    jmp restore_cpu

restore_cpu:
    rep #!status_accumulator_16bit
    lda !sram_regs+!ss_d
    tcd
    sep #!status_accumulator_8bit
    lda !sram_regs+!ss_db
    pha
    plb
    rep #!status_accumulator_16bit
    lda !sram_regs+!ss_s
    tax
    txs
    sep #!status_accumulator_8bit
    lda !sram_regs+!ss_k
    pha
    lda !sram_regs+!ss_pc_h
    pha
    lda !sram_regs+!ss_pc_l
    pha
    lda !sram_regs+!ss_p
    pha
    rep #!status_accumulator_16bit
    lda.l !sram_regs+!ss_x
    tax
    lda.l !sram_regs+!ss_y
    tay
    sep #!status_accumulator_8bit
    lda #!inidisp_display_full
    sta !inidisp
    lda !rdnmi
    lda !sram_regs+!ss_4200
    sta !nmitimen
    rep #!status_accumulator_16bit
    lda.l !sram_regs+!ss_a
    rti

state_resume:
    ldx !frame_counter_t
    jmp game_update_continue

warnpc $00C000
