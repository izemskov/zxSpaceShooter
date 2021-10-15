;SPACE SHOOTER GAME
;ENEMY MODULE
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

;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE ENEMY FUNCTION ;
;;;;;;;;;;;;;;;;;;;;;;;;;
CREATE_ENEMY:
        PUSH HL
        PUSH AF
        PUSH BC
        PUSH DE
        
        ; load enemy info
        LD HL,ENEMY_INFO
        
        ; check free slots for new enemy
        LD A,(HL)
        
        ; do not have free enemy slot
        CP 255
        JR Z,NOT_CREATE_ENEMY
        
        ; find free slot number
        PUSH AF
        ; couter for skip memory
        LD B,0
        ; mask for mark busy slots
        LD C,%00000001
ENEMY_START_FIND_SLOT:
        RRCA
        JR NC,ENEMY_END_FIND_SLOT
        
        PUSH AF
        LD A,C
        RLCA
        LD C,A
        POP AF
        INC B
        
        JR ENEMY_START_FIND_SLOT
        
ENEMY_END_FIND_SLOT: 
        POP AF
        ; set slot place
        OR C
        LD (HL),A
        INC HL
        
        ; shift memory to free shot slot        
        LD DE,12
        LD A,B
        CP 0
        JR Z,ENEMY_END_SHIFT_MEM
ENEMY_START_SHIFT_MEM:                
        ADD HL,DE
        DJNZ ENEMY_START_SHIFT_MEM
        
ENEMY_END_SHIFT_MEM:
        ; create new shot
        ; reset shot move counter
        LD A,0
        LD (HL),A
        
        ; put fire coordinates of player
        ; load player coordinates
        PUSH BC
                
        LD B,0        
        CALL GET_RANDOM_X
        LD C,A
        
        INC HL
        
        LD (HL),B
        INC HL
        LD (HL),C
        INC HL
        ; changes coordinates flag
        LD (HL),0
        INC HL
        LD (HL),B
        INC HL
        LD (HL),C
        
        POP BC
        
NOT_CREATE_ENEMY:                
        
        POP DE
        POP BC
        POP AF
        POP HL 
    
        RET
        
;;;;;;;;;;;;;;;;;;;;;;;
; DRAW ENEMY FUNCTION ;
;;;;;;;;;;;;;;;;;;;;;;;
DRAW_ENEMY:
        PUSH AF
        PUSH BC
        PUSH HL
        
        ; load enemy info
        
        
        POP HL
        PUSH BC
        POP AF
        
        RET