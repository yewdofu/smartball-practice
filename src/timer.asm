include

; ============================================================
; Timer HUD (OAM)
;   font.bin の数字とコロンを既存のOBJフォント転送元へ組み込む。
;   OAM 112-119 に "MM:SS:cc" を表示する。
; ============================================================
org $00FFEA
    dw timer_nmi

org $10E200
    incbin "gfx/font.bin":$0000..$013F

org $10E7C0
    incbin "gfx/font.bin":$05C0..$05DF

org $10E7E0
    incbin "gfx/font.bin":$05E0..$05FF

; ------------------------------------------------------------
; レベル準備完了時はタイマーを待機状態にする。
; ------------------------------------------------------------
pushpc
org $0085B7
    jsr timer_prepare
    nop
    nop
pullpc

org $00B3A0
timer_prepare:
    jsr timer_deactivate
    jsr apply_practice_settings
    lda !room_timer_restore_pending
    beq .gameplay
    lda #!room_timer_restore_ready_value
    sta !room_timer_restore_pending
.gameplay:
    lda #!game_mode_gameplay ; 置換した元処理
    sta !game_mode
    rts

warnpc $00B400

; ------------------------------------------------------------
; レベル準備完了後、操作を受け付ける最初のフレームで開始する。
; ------------------------------------------------------------
org $00B400
timer_update:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    lda !game_mode
    cmp #!game_mode_title
    bcs .hide
    lda !level_clear
    bne .show
    lda !game_mode
    cmp #!game_mode_gameplay
    bne .hide
    lda !timer_state
    bne .show
    jsr timer_start
    bra .done
.show:
    lda #!timer_visible_value
    sta !timer_visible
    bra .done
.hide:
    stz !timer_visible
.done:
    plp
    rts

; ------------------------------------------------------------
; メインループ側のタイマー状態更新とHUD描画
; ------------------------------------------------------------
pushpc
org $009283
    jsr timer_frame_hook
pullpc

timer_frame_hook:
    phx
    phy
    jsr timer_update
    jsr draw_timer_oam
    ply
    plx
    lda !controller_axlr  ; タイマーフレームフックで置換した元命令
    rts

; ------------------------------------------------------------
; タイマー開始・無効化
; ------------------------------------------------------------
timer_start:
    php
    sep #!status_accumulator_8bit
    rep #!status_index_16bit
    stz !timer_state
    lda !room_timer_restore_pending
    beq .reset
    cmp #!room_timer_restore_ready_value
    bne .defer
    stz !room_timer_restore_pending
    lda !room_timer_checkpoint_frame
    sta !timer_frame
    lda !room_timer_checkpoint_sec
    sta !timer_sec
    lda !room_timer_checkpoint_min
    sta !timer_min
    bra .activate

.reset:
    stz !timer_frame
    stz !timer_sec
    stz !timer_min
.activate:
    lda !room_hp_restore_pending
    bne .checkpoint_restored
    lda !ball_count
    sta !room_checkpoint_ball_count
    lda !player_state
    sta !room_checkpoint_player_state
    lda !player_hp
    sta !room_checkpoint_hp
    bra .start

.checkpoint_restored:
    stz !room_hp_restore_pending
.start:
    stz !timer_sequence
    lda #!timer_state_running
    sta !timer_state
    lda #!timer_visible_value
    sta !timer_visible
    lda !rdnmi
    lda #!nmitimen_timer_enabled
    sta !nmitimen
.defer:
    plp
    rts

timer_deactivate:
    stz !timer_state
    stz !timer_visible
    lda #!nmitimen_autojoy_enabled
    sta !nmitimen
    rts

; ------------------------------------------------------------
; OAM 112-119 に MM:SS:cc を描画
; ------------------------------------------------------------
draw_timer_oam:
    lda !menu_active
    beq +
    rts
+:
    php
    sep #!status_registers_8bit
    cld
    lda !timer_visible
    bne .snapshot
    jmp .hide

.snapshot:
    lda !timer_sequence
    and #!timer_sequence_write_mask
    bne .snapshot
    lda !timer_sequence
    sta !timer_snapshot_sequence
    lda !timer_frame
    sta !timer_snapshot_frame
    lda !timer_sec
    sta !timer_snapshot_sec
    lda !timer_min
    sta !timer_snapshot_min
    lda !timer_sequence
    cmp !timer_snapshot_sequence
    bne .snapshot

    lda !timer_snapshot_min
    jsr bin2bcd
    sta !timer_tmp+!timer_min_ones
    tya
    sta !timer_tmp+!timer_min_tens
    lda !timer_snapshot_sec
    jsr bin2bcd
    sta !timer_tmp+!timer_sec_ones
    tya
    sta !timer_tmp+!timer_sec_tens

    ldx #!timer_oam_first_entry
    lda !timer_snapshot_frame
    tax
    lda.l timer_centiseconds,x
    jsr bin2bcd
    sta !timer_tmp+!timer_centisec_ones
    tya
    sta !timer_tmp+!timer_centisec_tens

    lda #!timer_oam_base_address
    sta !oam_address_low
    stz !oam_address_high
    ldx #!timer_oam_first_entry
-
    lda.l timer_oam_x_offset,x
    clc
    adc #!timer_oam_x
    sta !oam_data
    lda #!timer_oam_y
    sta !oam_data
    lda.l timer_oam_digit_index,x
    cmp #!timer_colon_marker
    beq .colon
    cmp #!timer_period_marker
    beq .period
    tay
    lda !timer_tmp,y
    clc
    adc #!timer_tile_base
    bra .tile
.period:
    lda #!timer_tile_period
    bra .tile
.colon:
    lda #!timer_tile_colon
.tile:
    sta !oam_data
    lda #!timer_oam_attributes
    sta !oam_data
    inx
    cpx #!timer_oam_count
    bne -
    bra .high_table

.hide:
    lda #!timer_oam_base_address
    sta !oam_address_low
    stz !oam_address_high
    ldx #!timer_oam_first_entry
-
    lda #!timer_oam_hidden_y
    sta !oam_data
    sta !oam_data
    stz !oam_data
    lda #!timer_oam_attributes
    sta !oam_data
    inx
    cpx #!timer_oam_count
    bne -

.high_table:
    lda #!timer_oam_high_table_address
    sta !oam_address_low
    lda #!timer_oam_high_table_flag
    sta !oam_address_high
    stz !oam_data        ; X high=0, small OBJ size
    stz !oam_data
    plp
    rts

; ------------------------------------------------------------
; A(0-99) → Y=十の位, A=一の位
; ------------------------------------------------------------
bin2bcd:
    ldy #!bcd_initial_tens
-
    cmp #!decimal_base
    bcc +
    sbc #!decimal_base
    iny
    bra -
+
    rts

timer_oam_digit_index:
    db $00,$01,$FF,$02,$03,$FE,$04,$05
timer_oam_x_offset:
    db $00,$08,$10,$18,$20,$28,$30,$38

; floor(frame * 100 / 60)
timer_centiseconds:
    db $00,$01,$03,$05,$06,$08,$0A,$0B,$0D,$0F
    db $10,$12,$14,$15,$17,$19,$1A,$1C,$1E,$1F
    db $21,$23,$24,$26,$28,$29,$2B,$2D,$2E,$30
    db $32,$33,$35,$37,$38,$3A,$3C,$3D,$3F,$41
    db $42,$44,$46,$47,$49,$4B,$4C,$4E,$50,$51
    db $53,$55,$56,$58,$5A,$5B,$5D,$5F,$60,$62

; ------------------------------------------------------------
; NMI timer tick
;   Preserve the interrupted CPU state and do not touch PPU/APU.
; ------------------------------------------------------------
warnpc $00B600
org $00B600
timer_nmi:
    pha
    phx
    phy
    phb
    php
    sep #!status_accumulator_8bit
    lda #!zero_data_bank
    pha
    plb

    lda !timer_state
    cmp #!timer_state_running
    bne .done
    lda !level_clear
    beq .tick
    lda #!timer_state_stopped
    sta !timer_state
    lda #!nmitimen_autojoy_enabled
    sta !nmitimen
    bra .done

.tick:
    inc !timer_sequence
    inc !timer_frame
    lda !timer_frame
    cmp #!timer_frames_per_second
    bcc .finish
    stz !timer_frame
    inc !timer_sec
    lda !timer_sec
    cmp #!timer_seconds_per_minute
    bcc .finish
    stz !timer_sec
    inc !timer_min
    lda !timer_min
    cmp #!timer_max_minutes
    bcc .finish
    stz !timer_min

.finish:
    inc !timer_sequence
.done:
    plp
    plb
    ply
    plx
    pla
    rti

; ------------------------------------------------------------
; ルーム遷移の明転完了時に、操作再開フレームのタイマーを保存する。
; ------------------------------------------------------------
org $00B800
finish_room_transition:
    jsr room_transition_fade_in ; original instruction
    php
    pha
    lda !room_timer_capture_pending
    beq .done
    stz !room_timer_capture_pending
    jsr timer_capture_room_checkpoint
    lda #!room_checkpoint_active_value
    sta !room_checkpoint_active

.done:
    pla
    plp
    rts

timer_capture_room_checkpoint:
.snapshot:
    lda !timer_sequence
    and #!timer_sequence_write_mask
    bne .snapshot
    lda !timer_sequence
    sta !timer_snapshot_sequence
    lda !timer_frame
    sta !room_timer_checkpoint_frame
    lda !timer_sec
    sta !room_timer_checkpoint_sec
    lda !timer_min
    sta !room_timer_checkpoint_min
    lda !timer_sequence
    cmp !timer_snapshot_sequence
    bne .snapshot
    rts

warnpc $00B840
