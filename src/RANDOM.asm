;SPACE SHOOTER GAME
;RANDOM GENERATOR
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
; GET RANDOM X FUNCTION ;
;;;;;;;;;;;;;;;;;;;;;;;;;
;RETURN:
;   A - random number [0..31]
GET_RANDOM_X:               
        LD A,R
START_GET_RANDOM_X:
        CP 32
        JR C,END_GET_RANDOM_X
        SUB 32        
        JR START_GET_RANDOM_X
        
END_GET_RANDOM_X:        
        
        RET
