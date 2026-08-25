include

; Controller
!controller_axlr = $046B
!controller_byetudlr = $046C
!controller_axlr_prev = $046D
!controller_byetudlr_prev = $046E
!change_level_buttons = %00011000
!reload_room_buttons = $30
!reload_level_axlr_buttons = $B0
!reload_level_byetudlr_buttons = $80
!stage_select_buttons = $30
!menu_right_button = $01
!menu_left_button = $02
!menu_down_button = $04
!menu_up_button = $08
!menu_b_button = $80
!menu_a_button = $80
!pause_button = $20
!pause_resume_sound = $07

; Game state
!game_mode = $0466
!game_mode_gameplay = $01
!game_mode_title = $02
!transition_animation_state = $0440
!screen_transition_flag = $0472
!room_variant = $1E6B
!room_reload_state = $1E3C
!player_hp = $1E7C
!player_max_hp = $1E7B
!continue_count = $1E7E
!apu_command = $1E4E
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
!save_latch = $1FC0
!load_latch = $1FC1
!menu_active = $1FC2
!menu_cursor = $1FC3
!menu_level = $1FC4
!menu_area = $1FC5
!menu_lives = $1FC6
!menu_hp = $1FC7
!menu_balls = $1FC8
!menu_bgm_disabled = $1FC9
!menu_cancel_requested = $1FCB
!menu_apply_pending = $1FCC
!menu_resume_after_load = $1FCD
!menu_input_edge = $1FCE
!menu_draw_row = $1FCF
!menu_draw_col = $1FD0
!menu_draw_pending = $1FD2
!menu_draw_initialized = $1FD3

; Hardware registers
!inidisp = $2100
!nmitimen = $4200
!rdnmi = $4210
!oam_address_low = $2102
!oam_address_high = $2103
!oam_data = $2104
!hvbjoy = $4212
!vmain = $2115
!vmain_inc_high = $80
!vmaddr_low = $2116
!vmaddr_high = $2117
!vram_data_write_low = $2118
!vram_data_write_high = $2119
!cgadd = $2121
!cgdata_write = $2122
!oam_data_read = $2138
!vram_data_read_low = $2139
!vram_data_read_high = $213A
!cgdata_read = $213B
!dma_control = $4300
!dma1_control = $4310
!dma1_bbus_address = $4311
!dma1_source_address = $4312
!dma1_source_bank = $4314
!dma1_transfer_size = $4315
!dma_enable = $420B

; Save state buttons (このゲームの入力規約: $046B=L/R, $046C=Start/Select)
!r_button = $10
!l_button = $20
!start_button = $10

; Save state transfer
!state_magic_high = $A5
!state_magic_low = $5B
!state_magic_invalid = $00
!state_format_version = $01
!state_rom_compatibility = $01
!state_save_stack_offset = $000A
!state_stack_y_low = $01
!state_stack_y_high = $02
!state_stack_x_low = $03
!state_stack_x_high = $04
!state_stack_p = $06
!inidisp_forced_blank_full = $8F
!inidisp_display_full = $0F
!oam_high_table_select = $01
!state_transfer_index_start = $0000
!state_cgram_size = $0200
!state_oam_size = $0200
!state_oam_high_size = $0020
!state_vram_chunk_size = $8000
!state_wram_chunk_size = $8000

; Save state WRAM sources
!state_wram_7e_low = $7E0000
!state_wram_7e_high = $7E8000
!state_wram_7f_low = $7F0000
!state_wram_7f_high = $7F8000

; Save state SRAM layout (256KB battery SRAM, 32KB per LoROM bank)
!sram_wram = $700000
!sram_wram2 = $710000
!sram_wram3 = $720000
!sram_wram4 = $730000
!sram_vram = $740000
!sram_vram2 = $750000
!sram_cgram = $760000
!sram_oam = $760200
!sram_oam_high = $760400
!sram_regs = $760420
!sram_bgm_disabled = $760440
!menu_oam_backup = $770000
!menu_oam_backup_high = $770200
!menu_oam_buffer = $770400
!menu_oam_buffer_high = $770600
!menu_palette_backup = $770620
!menu_oam_backup_address = $0000
!menu_oam_backup_high_address = $0200
!menu_oam_buffer_address = $0400
!menu_oam_buffer_high_address = $0600
!menu_palette_backup_address = $0620
!menu_oam_sram_bank = $77
!ss_s = 0
!ss_d = 2
!ss_x = 4
!ss_y = 6
!ss_a = 8
!ss_p = 10
!ss_db = 11
!ss_4200 = 12
!ss_k = 13
!ss_pc_l = 14
!ss_pc_h = 15
!ss_magic_h = 16
!ss_magic_l = 17
!ss_format_version = 18
!ss_rom_compatibility = 19

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

; Practice menu
!menu_inactive = $00
!menu_active_value = $01
!menu_request_value = $01
!menu_draw_full = $01
!menu_draw_cursor = $02
!menu_draw_value = $03
!menu_first_item = 0
!menu_level_item = 0
!menu_area_item = 1
!menu_lives_item = 2
!menu_hp_item = 3
!menu_balls_item = 4
!menu_bgm_item = 5
!menu_apply_item = 6
!menu_item_count = 7
!menu_setting_count = 6
!menu_text_columns = 6
!menu_text_entries = 42
!menu_level_min = 1
!menu_level_max = 8
!menu_area_min = 1
!menu_area_max = 2
!menu_lives_min = 0
!menu_lives_max = 9
!menu_hp_min = 1
!menu_hp_max = 8
!menu_balls_min = 0
!menu_balls_max = 8
!menu_bgm_min = 0
!menu_bgm_max = 1
!menu_bgm_value_count = 2
!menu_font_digit_base = $00
!menu_font_cursor_tile = $0A
!menu_font_vram_word_address = $1000
!menu_font_transfer_size = $04E0
!menu_font_data_address = $F400
!menu_font_data_bank = $1F
!menu_font_palette_data_address = $F8E0
!menu_font_palette_data_bank = $1F
!menu_font_palette_size = $0020
!menu_font_palette_cgram_address = $F0
!controller_invert_mask = $FF
!menu_hidden_tile = $FF
!menu_oam_slot = 0
!menu_oam_base_address = (!menu_oam_slot*2)
!menu_oam_high_address = (!menu_oam_slot/8)
!menu_oam_high_bytes = 18
!menu_oam_count = (!menu_oam_high_bytes*4)
!menu_oam_low_size = (!menu_oam_count*4)
!menu_oam_used_count = 38
!menu_oam_tail_base_address = (!menu_oam_used_count*2)
!menu_oam_tail_count = (!menu_oam_count-!menu_oam_used_count)
!menu_cursor_oam_count = 1
!menu_visible_label_count = 29
!menu_numeric_value_oam_slot = (!menu_oam_slot+!menu_cursor_oam_count+!menu_visible_label_count)
!menu_numeric_value_oam_base_address = (!menu_numeric_value_oam_slot*2)
!menu_bgm_oam_slot = (!menu_numeric_value_oam_slot+!menu_bgm_item)
!menu_bgm_oam_base_address = (!menu_bgm_oam_slot*2)
!menu_cursor_x = $40
!menu_label_x = $50
!menu_value_x = $A8
!menu_y = $30
!menu_tile_spacing = 8
!menu_row_spacing = 16
!menu_oam_attributes = $3F
!menu_oam_selected_attributes = $3F
!menu_oam_hidden_y = $F0
!menu_bgm_text_length = 3
!bgm_silent_command = $00
!dma_mode0_cpu_to_ppu = $00
!dma_mode0_ppu_to_cpu = $80
!dma_mode1_cpu_to_ppu = $01
!dma_bbus_oam_write = $04
!dma_bbus_oam_read = $38
!dma_bbus_vram_write = $18
!dma_bbus_cgram_write = $22
!dma_bbus_cgram_read = $3B
!dma_channel1_enable = $02

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
!timer_tile_base = $00
!timer_tile_period = $26
!timer_tile_colon = $25
!timer_period_marker = $FE
!timer_colon_marker = $FF
!timer_oam_slot = 112
!timer_oam_base_address = (!timer_oam_slot*2)
!timer_oam_count = 8
!timer_oam_x = $B8
!timer_oam_y = $08
!timer_oam_attributes = $33
!timer_oam_hidden_y = $F0
!timer_oam_high_table_address = $0E
!timer_oam_high_table_flag = $01
!timer_oam_first_entry = $00

; Processor status masks
!status_accumulator_8bit = $20
!status_accumulator_16bit = $20
!status_index_16bit = $10
!status_registers_8bit = $30
!status_registers_16bit = $30
