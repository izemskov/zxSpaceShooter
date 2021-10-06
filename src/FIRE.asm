;SPACE SHOOTER GAME
;FIRE MODULE
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

;CREATE SHOT FUNCTION
DO_SHOT:
        PUSH HL
        PUSH AF
        
        ; load fire info
        LD HL,FIRE_INFO
        LD A,(HL)
        
        CP 0
        JR Z,CREATE_FIRE
        JR NOT_CREATE_FIRE
        
CREATE_FIRE:
        LD A,1
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
        
        POP BC        
        
NOT_CREATE_FIRE:                
        
        POP AF
        POP HL 
    
        RET
        
;MOVE SHOT FUNCTION
MOVE_SHOT:
        PUSH AF
        PUSH BC
        PUSH HL         
        
        LD HL,FIRE_INFO
        LD A,(HL)
        CP 0
        JR Z,END_FIRE_MOVING
        CP 1
        JR Z,MOVE_FIRE
INC_MOVE_COUNTER:        
        LD A,(HL)
        INC A
        CP 30
        JR Z,RESET_MOVE_COUNTER
        JR WRITE_MOVE_COUNTER
        
RESET_MOVE_COUNTER:
        LD A,1
        
WRITE_MOVE_COUNTER:        
        LD (HL),A
        JR END_FIRE_MOVING
        
MOVE_FIRE:        
        PUSH HL
        INC HL
        LD B,(HL)
        LD A,B
        CP 0
        JR Z,FIRE_BOUND_UP        
        DEC B
        LD (HL),B
        POP HL        
        JR INC_MOVE_COUNTER        
        
FIRE_BOUND_UP:
        POP HL
        LD A,0
        LD (HL),A
                                                                         
END_FIRE_MOVING:

        POP HL
        POP BC
        POP AF

        RET
