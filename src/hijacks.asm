include

org $0088CC
update_game:
    jsr ingame_patch

org $0084BA
    jsr prepare_area_load

org $00856E
    jsr restore_game_checkpoint

org $009A01
    jsr capture_room_transition

org $009A3C
    jsr clear_instant_transition
