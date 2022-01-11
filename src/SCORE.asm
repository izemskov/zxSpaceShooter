;SPACE SHOOTER GAME
;SCORE MODULE
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
        
;;;;;;;;;;;;;;
; DRAW SCORE ;
;;;;;;;;;;;;;;
DRAW_SCORE:
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL               
        
        ; loop counter
        LD B,4
        ; x position
        LD D,0
        LD HL,SCORES
SCORE_LOOP:
        LD A,(HL)
        INC A
        INC HL
        
        PUSH HL
        PUSH BC
        
        ; coords
        LD B,#0
        LD C,D
        INC D
        
        LD HL,NUMBER
        CALL DRAW_SPRITE
        
        POP BC
        POP HL                            

        DJNZ SCORE_LOOP                                       
        
        POP HL
        POP DE
        POP BC
        POP AF

        RET
        
;;;;;;;;;;;;;
; INC SCORE ;
;;;;;;;;;;;;;
INC_SCORE:
        PUSH HL
        PUSH AF
        PUSH DE
        
        LD HL,SCORES
        INC HL
        INC HL
        INC HL
        LD A,(HL)
        INC A
        LD (HL),A
        
        ; check digit overflow
CHECK_DIGIT_OVERFLOW:
        LD A,(HL)
        CP 10
        JR Z,DIGIT_OVERFLOW
        JR END_INC_SCORE
        
DIGIT_OVERFLOW:
        LD A,0
        LD (HL),A
        
        ; check last digit
        LD DE,SCORES
        LD A,H
        CP D
        JR NZ,NOT_LAST_DIGIT
        LD A,L
        CP E
        JR NZ,NOT_LAST_DIGIT
        ; last digit
        JR END_INC_SCORE
        
NOT_LAST_DIGIT:        
        DEC HL
        LD A,(HL)
        INC A
        LD (HL),A
        JR CHECK_DIGIT_OVERFLOW
        
END_INC_SCORE:
        POP DE
        POP AF
        POP HL

        RET
