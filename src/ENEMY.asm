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
        
        ; shift memory to free enemy slot        
        LD DE,12
        LD A,B
        CP 0
        JR Z,ENEMY_END_SHIFT_MEM
ENEMY_START_SHIFT_MEM:                
        ADD HL,DE
        DJNZ ENEMY_START_SHIFT_MEM
        
ENEMY_END_SHIFT_MEM:
        ; create new enemy
        ; reset enemy move counter
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
        PUSH DE
        
        ; load enemy info
        LD HL,ENEMY_INFO
        LD E,(HL)
        INC HL
        
        LD D,%00000001
START_DRAW_ENEMY:
        LD A,E
        AND D
        
        CP 0
        JR NZ,PR_DRAW_ENEMY
CONTINUE_DRAW_ENEMY:
        LD BC,12
        ADD HL,BC

        LD A,D
        RLCA
        LD D,A
        CP 1
        JR Z,END_ENEMY_DRAWING
        JR START_DRAW_ENEMY        
               
PR_DRAW_ENEMY:
        PUSH HL
        ; skip move counter
        INC HL
        
        LD B,(HL)
        INC HL
        LD C,(HL)
        
        ; check enemy coordinates was changed
        PUSH AF
        
        INC HL
        LD A,(HL)
        CP 1
        JR Z,CLEAR_ENEMY
        JR NOT_CLEAR_ENEMY
        
CLEAR_ENEMY:
        ; for next time
        LD (HL),0
        
        PUSH HL
        PUSH BC
        
        ; load old coordinates
        INC HL
        LD B,(HL)
        INC HL
        LD C,(HL)
        LD HL,EMPTY_SPRITE1
        CALL DRAW_SPRITE
        
        POP BC
        POP HL
        
        ; put new coordinates to old coordinates
        INC HL
        LD (HL),B
        INC HL
        LD (HL),C
        
NOT_CLEAR_ENEMY:
        
        POP AF               
        
        LD HL,SPRITE_ALIEN
        LD A,1
        CALL DRAW_SPRITE
        POP HL
        
        JR CONTINUE_DRAW_ENEMY
        
END_ENEMY_DRAWING:
        
        POP DE
        POP HL
        POP BC
        POP AF
        
        RET