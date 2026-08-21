include

org $00840D
load_level:

org $0088CC
update_game:
    jsr every_frame_patch
