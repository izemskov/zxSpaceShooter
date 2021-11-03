;SPACE SHOOTER GAME
;PLAYER MODULE
;
;ASM:     SJASMPLUS v1.18.3
;CPU:     Zilog Z80, 3.5MHz
;RAM:     48Kb or 128Kb
;SCREEN:  265x192 pixels,
;         32x24 color attributes
;CTRL:    Keyboard and joystick
;
;AUTHOR:  Ilya Zemskov, 2021
;         pascal.ilya@gmail.com

;;;;;;;;;;;;;;;
; DRAW PLAYER ;
;;;;;;;;;;;;;;;
DRAW_PLAYER:
        PUSH AF
        PUSH BC
        PUSH HL
        
        ; load player coordinates
        DI
        
        LD HL,PLAYER_COORD
        LD B,(HL)
        INC HL
        LD C,(HL)   
        
        EI
        
        LD A,1               
        LD HL,SPRITE_PLAYER
        CALL DRAW_SPRITE
        
        POP HL
        POP BC
        POP AF

        RET
