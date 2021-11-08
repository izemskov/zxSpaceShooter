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
        LD DE,8
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
                
        PUSH BC
                
        LD B,0        
        CALL GET_RANDOM_X
        LD C,A
        
        INC HL
        
        LD (HL),B
        INC HL
        LD (HL),C        
        ; current frame
        INC HL
        LD (HL),1
        
        POP BC
        
NOT_CREATE_ENEMY:                
        
        POP DE
        POP BC
        POP AF
        POP HL 
    
        RET
        
;;;;;;;;;;;;;;;;;;;;;;;
; MOVE ENEMY FUNCTION ;
;;;;;;;;;;;;;;;;;;;;;;;
MOVE_ENEMY:
        PUSH AF
        PUSH BC
        PUSH HL
        PUSH DE
        
        ; load enemy info
        LD HL,ENEMY_INFO
        LD E,(HL)
        INC HL
        
        LD D,%00000001        
START_MOVE_ENEMY: 
        LD A,E
        AND D
        
        CP 0
        JR NZ,PROCESS_MOVE_ENEMY
        
CONTINUE_MOVE_ENEMIES:
        LD BC,8
        ADD HL,BC

        LD A,D
        RLCA
        LD D,A
        CP 1
        JR Z,END_ENEMY_MOVING
        JR START_MOVE_ENEMY
        
PROCESS_MOVE_ENEMY:
        ; load move counter
        LD A,(HL)        
        CP 0
        JR Z,DO_MOVE_ENEMY
ENEMY_INC_MOVE_COUNTER:
        LD A,(HL)
        INC A
        CP 25
        JR Z,ENEMY_RESET_MOVE_COUNTER
        JR ENEMY_WRITE_MOVE_COUNTER
        
ENEMY_RESET_MOVE_COUNTER:
        LD A,0
        
ENEMY_WRITE_MOVE_COUNTER:        
        LD (HL),A
        JR CONTINUE_MOVE_ENEMIES
        
DO_MOVE_ENEMY:
        PUSH HL
        
        INC HL
        LD B,(HL)
        LD A,B
        CP 23
        JR Z,ENEMY_BOUND_DOWN
        INC B
        LD (HL),B
        ; set change coordinates flag
        INC HL        
        
        ; change current frame        
        INC HL
        LD A,(HL)
        INC A
        CP 3
        JR NZ,WRITE_CURRENT_FRAME
        ; reset current frame
        LD A,1        

WRITE_CURRENT_FRAME:        
        LD (HL),A
        
        POP HL
        JR ENEMY_INC_MOVE_COUNTER
        
ENEMY_BOUND_DOWN:
        POP HL
        ; delete current enemy
        PUSH HL
        PUSH DE
        LD A,D
        CPL
        LD D,A
                       
        LD HL,ENEMY_INFO
        LD A,(HL)
        AND D                             
        LD (HL),A
        
        POP DE
        POP HL

END_ENEMY_MOVING:

        POP DE
        POP HL
        POP BC
        POP AF

        RET
        
;;;;;;;;;;;;;;;;;;
; CREATE_ENEMIES ;
;;;;;;;;;;;;;;;;;;        
CREATE_ENEMIES:
        PUSH AF
        
        CALL GET_RANDOM
        CP 10
        JR NC,MAIN_LOOP_NOT_CE
        CALL CREATE_ENEMY
MAIN_LOOP_NOT_CE:

        POP AF

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
        LD BC,8
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
                
        ; load current frame        
        INC HL
        LD A,(HL)
        LD HL,SPRITE_ALIEN
        CALL DRAW_SPRITE
        
        POP HL
        
        JR CONTINUE_DRAW_ENEMY
        
END_ENEMY_DRAWING:
        
        POP DE
        POP HL
        POP BC
        POP AF
        
        RET