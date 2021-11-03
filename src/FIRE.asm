;SPACE SHOOTER GAME
;SHOT MODULE
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

;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE SHOT FUNCTION ;
;;;;;;;;;;;;;;;;;;;;;;;;
CREATE_SHOT:
        PUSH HL
        PUSH AF
        PUSH BC
        PUSH DE
        
        ; load shot info
        LD HL,FIRE_INFO        
        
        ; check free slots for new shot
        LD A,(HL)
        
        ; do not have free shot slot
        CP 255
        JR Z,NOT_CREATE_SHOT
        
        ; find free slot number
        PUSH AF
        ; couter for skip memory
        LD B,0
        ; mask for mark busy slots
        LD C,%00000001
START_FIND_SLOT:        
        RRCA
        JR NC,END_FIND_SLOT
        
        PUSH AF
        LD A,C
        RLCA
        LD C,A
        POP AF
        INC B
        
        JR START_FIND_SLOT
        
END_FIND_SLOT: 
        POP AF
        ; set slot place
        OR C
        LD (HL),A
        INC HL
        
        ; shift memory to free shot slot        
        LD DE,6
        LD A,B
        CP 0
        JR Z,END_SHIFT_MEM
START_SHIFT_MEM:                
        ADD HL,DE
        DJNZ START_SHIFT_MEM
        
END_SHIFT_MEM:
        ; create new shot
        ; reset shot move counter
        LD A,0
        LD (HL),A
        
        ; put fire coordinates of player
        ; load player coordinates
        PUSH BC
        
        PUSH HL
        LD HL,PLAYER_COORD
        LD B,(HL)
        INC HL
        LD C,(HL)
        POP HL
        
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
        
NOT_CREATE_SHOT:                
        
        POP DE
        POP BC
        POP AF
        POP HL 
    
        RET

;;;;;;;;;;;;;;;;;;;;;;
; MOVE SHOT FUNCTION ;
;;;;;;;;;;;;;;;;;;;;;;
MOVE_SHOT:
        PUSH AF
        PUSH BC
        PUSH HL
        PUSH DE
        
        ; load shot info
        LD HL,FIRE_INFO
        LD E,(HL)
        INC HL
        
        LD D,%00000001        
START_MOVE_SHOT: 
        LD A,E
        AND D
        
        CP 0
        JR NZ,PROCESS_MOVE_SHOT
        
CONTINUE_MOVE_SHOTS:
        LD BC,6
        ADD HL,BC

        LD A,D
        RLCA
        LD D,A
        CP 1
        JR Z,END_SHOT_MOVING
        JR START_MOVE_SHOT
        
PROCESS_MOVE_SHOT:                
        ; load move counter
        LD A,(HL)        
        CP 0
        JR Z,DO_MOVE_SHOT
INC_MOVE_COUNTER:        
        LD A,(HL)
        INC A
        CP 10
        JR Z,RESET_MOVE_COUNTER
        JR WRITE_MOVE_COUNTER
        
RESET_MOVE_COUNTER:
        LD A,0
        
WRITE_MOVE_COUNTER:        
        LD (HL),A
        JR CONTINUE_MOVE_SHOTS
        
DO_MOVE_SHOT:        
        PUSH HL
        
        INC HL
        LD B,(HL)
        LD A,B
        CP 0
        JR Z,SHOT_BOUND_UP
        DEC B
        LD (HL),B
        ; set change coordinates flag
        INC HL        
        LD C,(HL)
        INC HL
        LD (HL),1
        
        CALL CHECK_SHOT_COLLISION
        ; check A registry for destroy shot
        CP 0
        JR Z,SHOT_BOUND_UP
        
        POP HL               
        
        JR INC_MOVE_COUNTER
        
SHOT_BOUND_UP:
        POP HL
        ; delete current shot
        PUSH HL
        PUSH DE
        LD A,D
        CPL
        LD D,A
                       
        LD HL,FIRE_INFO
        LD A,(HL)
        AND D                             
        LD (HL),A
        
        POP DE
        POP HL
        
        JR CONTINUE_MOVE_SHOTS

END_SHOT_MOVING:

        POP DE
        POP HL
        POP BC
        POP AF

        RET

;;;;;;;;;;;;;;;;;;;;;;
; DRAW SHOT FUNCTION ;
;;;;;;;;;;;;;;;;;;;;;;
DRAW_SHOT:
        PUSH AF
        PUSH BC
        PUSH HL
        PUSH DE
        
        ; draw fire
        LD HL,FIRE_INFO
        LD E,(HL)
        INC HL
        
        LD D,%00000001
START_DRAW_SHOT:
        LD A,E
        AND D
        
        CP 0
        JR NZ,PR_DRAW_SHOT
CONTINUE_DRAW_SHOTS:
        LD BC,6
        ADD HL,BC

        LD A,D
        RLCA
        LD D,A
        CP 1
        JR Z,END_SHOT_DRAWING
        JR START_DRAW_SHOT        
               
PR_DRAW_SHOT:
        PUSH HL
        ; skip move counter
        INC HL
        
        LD B,(HL)
        INC HL
        LD C,(HL)               
        
        LD A,B
        CP 0
        JR Z,OUTOFBOUND_SHOT
        
        LD HL,FIRE_SPITE
        LD A,1
        CALL DRAW_SPRITE
OUTOFBOUND_SHOT:
        POP HL
        
        JR CONTINUE_DRAW_SHOTS
        
END_SHOT_DRAWING:
        
        POP DE
        POP HL
        POP BC        
        POP AF

        RET