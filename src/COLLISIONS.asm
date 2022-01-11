;SPACE SHOOTER GAME
;COLLISIONS
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CHECK SHOT COLLISIONS FUNCTION ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PARAMETERS:
        ; BC - Y and X coordinates of shot
;RETURN:
        ; A  - 0 - destroy shot; 1 - not destroy shot
CHECK_SHOT_COLLISION:        
        PUSH BC
        PUSH DE
        PUSH HL
        
        ; load enemy info
        LD HL,ENEMY_INFO
        LD E,(HL)
        INC HL
        
        LD D,%00000001
START_CHCKCO_SHOT:
        LD A,E
        AND D
        
        CP 0
        JR NZ,PROCESS_CHCKCO_SHOT
        
CONTINUE_CHCKCO_SHOT:
        PUSH BC
        LD BC,8
        ADD HL,BC
        POP BC

        LD A,D
        RLCA
        LD D,A
        CP 1
        JR Z,END_CHCKCO_SHOT
        JR START_CHCKCO_SHOT
        
PROCESS_CHCKCO_SHOT:        
        PUSH HL
        PUSH DE
        PUSH AF
        ; skip move counter
        INC HL 
        ; load current coordinates
        LD D,(HL)
        INC HL
        LD E,(HL)
        
        ; check y coordinates
        LD A,D
        CP B
        JR NZ,NOT_COLLISION_SHOT
        LD A,E
        CP C
        JR NZ,NOT_COLLISION_SHOT
        
        POP AF
        POP DE        
        POP HL               
        
        ; destroy enemy
        CALL INC_SCORE
        
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
        
        LD A,0
        
        JR END_CHCKCO_SHOT 
                
NOT_COLLISION_SHOT:                
        POP AF
        POP DE        
        POP HL
        
        JR CONTINUE_CHCKCO_SHOT        

END_CHCKCO_SHOT:
        
        POP HL
        POP DE
        POP BC        

        RET
        