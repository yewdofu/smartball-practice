include

; Controller
!controller_axlr = $046B
!controller_byetudlr = $046C
!change_level_buttons = %00011000
!reload_room_buttons = $30
!reload_level_axlr_buttons = $B0
!reload_level_byetudlr_buttons = $80
!stage_select_buttons = $30

; Game state
!game_mode = $0466
!game_mode_gameplay = $01
!game_mode_title = $02
!transition_animation_state = $0440
!screen_transition_flag = $0472
!room_variant = $1E6B
!room_reload_state = $1E3C
!player_hp = $1E7C
!highest_unlocked_level = $1E33
!all_levels_unlocked = $0F

; Player position
!player_state = $0449
!position_x = $1E2F
!position_y = $1E31
!ball_count = $1E3C

; Level
!level_idx_world = $0433       ; current
!level_idx_world2 = $1E37      ; next
!level_idx_level = $0435       ; current
!level_idx_level2 = $1E38      ; next
!level_clear = $0470

; Room checkpoint
!saved_position = $1E96
!saved_camera_x = $1E98
!saved_camera_y = $1E9A
!room_restore_position = $1E9C
!room_transition_table = $10DA00
!room_transition_position = $10D9FD
!room_transition_camera = $10D9FF

; Frame counter
!frame_counter_e = $1E44       ; effective
!frame_counter_t = $1E3E       ; true

; Timer WRAM
!timer_frame = $1F9B           ; 0-59
!timer_sec = $1F9C             ; 0-59
!timer_min = $1F9D             ; 0-99
!timer_state = $1F9E
!timer_visible = $1F9F         ; bit0: visible
!timer_tmp = $1FA0             ; M1 M2 S1 S2 c1 c2
!timer_snapshot_frame = $1FA6
!timer_snapshot_sec = $1FA7
!timer_snapshot_min = $1FA8
!timer_sequence = $1FA9
!timer_snapshot_sequence = $1FAA
!reset_latch = $1FAB
!room_checkpoint_active = $1FAC
!room_checkpoint_record = $1FAD
!room_checkpoint_variant = $1FAF
!room_checkpoint_previous_position = $1FB0
!room_checkpoint_previous_camera_x = $1FB2
!room_checkpoint_previous_camera_y = $1FB4
!room_checkpoint_restore_pending = $1FB6
!room_checkpoint_ball_count = $1FB7
!room_timer_checkpoint_frame = $1FB8
!room_timer_checkpoint_sec = $1FB9
!room_timer_checkpoint_min = $1FBA
!room_timer_capture_pending = $1FBB
!room_timer_restore_pending = $1FBC
!room_hp_restore_pending = $1FBD
!room_checkpoint_player_state = $1FBE
!room_checkpoint_hp = $1FBF

; Hardware registers
!inidisp = $2100
!nmitimen = $4200
!rdnmi = $4210
!oam_address_low = $2102
!oam_address_high = $2103
!oam_data = $2104
!hvbjoy = $4212

; Timer limits and conversion
!timer_frames_per_second = 60
!timer_seconds_per_minute = 60
!timer_max_minutes = 100
!timer_state_inactive = $00
!timer_state_running = $01
!timer_state_stopped = $02
!timer_visible_value = $01
!timer_sequence_write_mask = $01
!reset_latch_active = $01
!room_checkpoint_active_value = $01
!room_timer_pending_value = $01
!room_timer_restore_ready_value = $02
!room_transition_standard = $02
!room_camera_x_mask = $00F0
!room_camera_y_mask = $000F
!room_reset_blank_frames = 30
!inidisp_forced_blank = $80
!stack_initial = $01FF
!decimal_base = 10
!bcd_initial_tens = 0

; NMI
!nmitimen_autojoy_enabled = $01
!nmitimen_timer_enabled = $81
!zero_data_bank = $00

; Timer temporary digit indexes
!timer_min_tens = 0
!timer_min_ones = 1
!timer_sec_tens = 2
!timer_sec_ones = 3
!timer_centisec_tens = 4
!timer_centisec_ones = 5

; Timer OAM
!timer_tile_base = $10
!timer_tile_period = $3F
!timer_tile_colon = $3E
!timer_period_marker = $FE
!timer_colon_marker = $FF
!timer_oam_slot = 112
!timer_oam_base_address = (!timer_oam_slot*2)
!timer_oam_count = 8
!timer_oam_x = $B8
!timer_oam_y = $08
!timer_oam_attributes = $30
!timer_oam_hidden_y = $F0
!timer_oam_high_table_address = $0E
!timer_oam_high_table_flag = $01
!timer_oam_first_entry = $00

; Processor status masks
!status_accumulator_8bit = $20
!status_accumulator_16bit = $20
!status_index_16bit = $10
!status_registers_8bit = $30
