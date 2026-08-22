include

org $00B390
open_stage_select:
    lda !controller_byetudlr
    cmp #!stage_select_buttons
    bne .done
    jsr timer_deactivate
    jmp stage_select_init

.done:
    rts

org $00B680
reload_current_room:
    jsr timer_deactivate
    jsr room_reset_blank
    rep #!status_index_16bit
    ldx.w #!stack_initial
    txs
    lda !room_checkpoint_active
    beq .level
    jmp load_room_checkpoint

.level:
    jmp load_current_area

room_reset_blank:
    php
    rep #!status_index_16bit
    phx
    lda #!inidisp_forced_blank
    sta !inidisp
    ldx.w #!room_reset_blank_frames

.wait_active:
    lda !hvbjoy
    bmi .wait_active
.wait_vblank:
    lda !hvbjoy
    bpl .wait_vblank
    dex
    bne .wait_active
    plx
    plp
    rts

org $00B660
prepare_area_load:
    stz !room_checkpoint_active
    stz !room_checkpoint_restore_pending
    jsr calc_stage_index ; original instruction
    rts

org $00B6C0
capture_room_transition:
    sta !transition_animation_state ; original instruction
    php
    pha
    lda.l !room_transition_table,x
    cmp #!room_transition_standard
    bne .unsupported
    stx !room_checkpoint_record
    lda !room_variant
    sta !room_checkpoint_variant
    lda !ball_count
    sta !room_checkpoint_ball_count
    lda #!room_checkpoint_active_value
    sta !room_checkpoint_active
    bra .done

.unsupported:
    stz !room_checkpoint_active
.done:
    pla
    plp
    rts

clear_instant_transition:
    stz !room_restore_position ; original instruction
    stz !room_checkpoint_active
    rts

org $00B700
load_room_checkpoint:
    rep #!status_index_16bit
    ldx !room_checkpoint_record
    rep #!status_accumulator_16bit
    lda !saved_position
    sta !room_checkpoint_previous_position
    lda !saved_camera_x
    sta !room_checkpoint_previous_camera_x
    lda !saved_camera_y
    sta !room_checkpoint_previous_camera_y
    lda.l !room_transition_position,x
    sta !saved_position
    lda.l !room_transition_camera,x
    and #!room_camera_x_mask
    asl
    asl
    asl
    asl
    sta !saved_camera_x
    lda.l !room_transition_camera,x
    and #!room_camera_y_mask
    xba
    sta !saved_camera_y
    sep #!status_accumulator_8bit
    lda #!room_checkpoint_active_value
    sta !room_checkpoint_restore_pending
    lda !room_checkpoint_variant
    sta !room_variant
    lda !room_checkpoint_ball_count
    sta !room_reload_state
    lda #!room_checkpoint_active_value
    sta !screen_transition_flag
    jmp load_room

org $00B760
restore_game_checkpoint:
    lda !room_checkpoint_restore_pending
    beq .original
    phy
    ldy !room_checkpoint_previous_position
    sty !saved_position
    ldy !room_checkpoint_previous_camera_x
    sty !saved_camera_x
    ldy !room_checkpoint_previous_camera_y
    sty !saved_camera_y
    ply
    stz !room_checkpoint_restore_pending

.original:
    lda !room_reload_state ; original instruction
    rts

org $00B790
reload_level:
    lda !controller_axlr
    and #!reload_level_axlr_buttons
    cmp #!reload_level_axlr_buttons
    bne .done
    lda !controller_byetudlr
    and #!reload_level_byetudlr_buttons
    cmp #!reload_level_byetudlr_buttons
    bne .done
    lda !reset_latch
    bne .done
    lda #!reset_latch_active
    sta !reset_latch
    jsr timer_deactivate
    rep #!status_index_16bit
    ldx.w #!stack_initial
    txs
    jmp load_level

.done:
    rts

reload_room:
    lda !controller_axlr
    and #!reload_room_buttons
    cmp #!reload_room_buttons
    bne .released
    lda !reset_latch
    bne .done
    lda #!reset_latch_active
    sta !reset_latch
    jmp reload_current_room

.released:
    stz !reset_latch
.done:
    rts

warnpc $00B800
