;SPACE SHOOTER GAME
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

        device zxspectrum128

SCREEN_STREAM    EQU 5633

        ORG #6000   ; start address
        ; save old stack value
begin_file:        
        ; save old registry values
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL
        
        ; enable im2 interrupt
        PUSH AF
        PUSH DE
        PUSH HL
        
        DI
        
        ; HL - IM2 addr
        LD H,IM2_I_REG
        LD L,IM2_B_DATA
        LD A,H
        LD I,A
        
        ; load callback to addres in HL
        ; in reverse order
        ; (in registry big endian in memory little endian)
        LD DE,IM2
        LD (HL),E
        INC HL
        LD (HL),D

        ; enable IM2 interrupt
        IM 2
        
        EI
        
        POP HL
        POP DE
        POP AF

        ; set output stream to screen
        LD A,2      
        CALL SCREEN_STREAM
        
        LD A,%01000101
        CALL FILL_BACKGROUND                              
                      
        ; start position
        LD HL,PLAYER_COORD
        LD (HL),#05
        INC HL
        LD (HL),#05
        
MAIN_LOOP:
        ;DI

        CALL CLEAR_SHADOW_SCREEN               

        CALL DRAW_PLAYER

        CALL DRAW_SHOT
        
        CALL DRAW_ENEMY       
        
        CALL CREATE_ENEMIES
        
        ;EI
        
        HALT
        CALL COPY_SHADOW_SCREEN
        
        JR MAIN_LOOP
        
        ; return old registry values
        POP HL
        POP DE
        POP BC
        POP AF
        
        RET
    
;INTERRUPT FUNCTION CALLED EVERY 1/50 SECOND
;USING FOR CHECK KEY PRESSED
IM2:
        DI
        PUSH HL
        PUSH BC                              
        PUSH AF
        
        ; check keys
        ;;;;;;;;;;;;
        ; W - Key
        ;;;;;;;;;;;;
        LD A,251
        IN A,(254)        
        BIT 1,A
        JR Z,P_KEY_W
        JR NP_KEY_W
        
P_KEY_W:
        ; W - pressed
        LD HL,KEY_INFO_W
        LD A,(HL)
        CP 0
        JR Z,MOVE_UP
        JR CONTINUE_P_KEY_W
        
MOVE_UP:        
        PUSH HL
        PUSH AF
        LD HL,PLAYER_COORD
        LD B,(HL)
        LD A,B
        CP 0
        JR Z,BOUND_UP
        DEC B
BOUND_UP:        
        LD (HL),B        
        POP AF
        POP HL
        
CONTINUE_P_KEY_W:
        INC A
        CP 10
        JR Z,DROP_KEY_W
        JR WRITE_KEY_W
        
DROP_KEY_W:
        LD A,0

WRITE_KEY_W:
        LD (HL),A
        JR AFTER_PROCESS_W
        
NP_KEY_W:
        LD HL,KEY_INFO_W
        LD (HL),0
        
AFTER_PROCESS_W:
        ;;;;;;;;;;;;
        ; S - Key
        ;;;;;;;;;;;;
        LD A,253
        IN A,(254)        
        BIT 1,A
        JR Z,P_KEY_S
        JR NP_KEY_S
        
P_KEY_S:
        ; S - pressed
        LD HL,KEY_INFO_S
        LD A,(HL)
        CP 0
        JR Z,MOVE_DOWN
        JR CONTINUE_P_KEY_S
        
MOVE_DOWN:        
        PUSH HL
        PUSH AF
        LD HL,PLAYER_COORD
        LD B,(HL)
        LD A,B
        CP 23
        JR Z,BOUND_DOWN
        INC B
BOUND_DOWN:        
        LD (HL),B        
        POP AF
        POP HL
        
CONTINUE_P_KEY_S:
        INC A
        CP 10
        JR Z,DROP_KEY_S
        JR WRITE_KEY_S
        
DROP_KEY_S:
        LD A,0

WRITE_KEY_S:
        LD (HL),A
        JR AFTER_PROCESS_S
        
NP_KEY_S:
        LD HL,KEY_INFO_S
        LD (HL),0
        
AFTER_PROCESS_S:
        ;;;;;;;;;;;;
        ; A - Key
        ;;;;;;;;;;;;
        LD A,253
        IN A,(254)        
        BIT 0,A
        JR Z,P_KEY_A
        JR NP_KEY_A
        
P_KEY_A:
        ; A - pressed
        LD HL,KEY_INFO_A
        LD A,(HL)
        CP 0
        JR Z,MOVE_LEFT
        JR CONTINUE_P_KEY_A
        
MOVE_LEFT:        
        PUSH HL
        PUSH AF
        LD HL,PLAYER_COORD
        INC HL
        LD B,(HL)
        LD A,B
        CP 0
        JR Z,BOUND_LEFT
        DEC B
BOUND_LEFT:        
        LD (HL),B        
        POP AF
        POP HL
        
CONTINUE_P_KEY_A:
        INC A
        CP 10
        JR Z,DROP_KEY_A
        JR WRITE_KEY_A
        
DROP_KEY_A:
        LD A,0

WRITE_KEY_A:
        LD (HL),A
        JR AFTER_PROCESS_A
        
NP_KEY_A:
        LD HL,KEY_INFO_A
        LD (HL),0
        
AFTER_PROCESS_A:      
        ;;;;;;;;;;;;
        ; D - Key
        ;;;;;;;;;;;;
        LD A,253
        IN A,(254)        
        BIT 2,A
        JR Z,P_KEY_D
        JR NP_KEY_D
        
P_KEY_D:
        ; D - pressed
        LD HL,KEY_INFO_D
        LD A,(HL)
        CP 0
        JR Z,MOVE_RIGHT
        JR CONTINUE_P_KEY_D
        
MOVE_RIGHT:        
        PUSH HL
        PUSH AF
        LD HL,PLAYER_COORD
        INC HL
        LD B,(HL)
        LD A,B
        CP 30
        JR Z,BOUND_RIGHT
        INC B
BOUND_RIGHT:        
        LD (HL),B        
        POP AF
        POP HL
        
CONTINUE_P_KEY_D:
        INC A
        CP 10
        JR Z,DROP_KEY_D
        JR WRITE_KEY_D
        
DROP_KEY_D:
        LD A,0

WRITE_KEY_D:
        LD (HL),A
        JR AFTER_PROCESS_D
        
NP_KEY_D:
        LD HL,KEY_INFO_D
        LD (HL),0
        
AFTER_PROCESS_D:
        ;;;;;;;;;;;;
        ; Space - Key
        ;;;;;;;;;;;;
        LD A,127
        IN A,(254)        
        BIT 0,A
        JR Z,P_KEY_SP
        JR NP_KEY_SP
        
P_KEY_SP:
        ; Space - pressed
        LD HL,KEY_INFO_SP
        LD A,(HL)
        CP 0
        JR Z,FIRE
        JR CONTINUE_P_KEY_SP
        
FIRE:   
        CALL CREATE_SHOT
        
CONTINUE_P_KEY_SP:
        INC A
        CP 10
        JR Z,DROP_KEY_SP
        JR WRITE_KEY_SP
        
DROP_KEY_SP:
        LD A,0

WRITE_KEY_SP:
        LD (HL),A
        JR AFTER_PROCESS_SP
        
NP_KEY_SP:
        LD HL,KEY_INFO_SP
        LD (HL),0
        
AFTER_PROCESS_SP:

        ;;;;;;;;;;;;
        ; move fires
        ;;;;;;;;;;;;
        CALL MOVE_SHOT
        
        CALL MOVE_ENEMY

        POP AF        
        POP BC
        POP HL
        
        EI
        RET

        INCLUDE "PLAYER.asm"
        INCLUDE "FIRE.asm"
        INCLUDE "ENEMY.asm"
        INCLUDE "RANDOM.asm"
        INCLUDE "COLLISIONS.asm"
        INCLUDE "COMMON.asm"

; GLOBAL VARIABLES AND DATA
;;;;;;;;;;;
; SPRITES ;
;;;;;;;;;;;
SPRITE_PLAYER   DEFB 2,1
                DEFB 0,0,69
                DEFB 0,3,7,15,127,255,113,0
                DEFB 1,0,69
                DEFB 0,192,224,240,254,255,142,0
                
SPRITE_ALIEN    DEFB 1,2
                DEFB 0,0,69
                ; frame 1
                DEFB 24,60,126,219,255,36,90,165
                ; frame 2
                DEFB 24,60,126,219,255,90,129,66
                
FIRE_SPITE      DEFB 1,1
                DEFB 0,0,69
                DEFB 0,0,24,60,60,24,0,0                

;;;;;;;;
; DATA ;
;;;;;;;;
                ; 0,1 - current coordinates                
PLAYER_COORD    DEFB 0,0

                ; 0   - bit mask current shots (max 8 shots)
                ; 1   - shot move counter
                ; 3,4 - current coordinates
                ; 5   - flag changes coordinates
                ; 6,7 - old coordinates
FIRE_INFO       DEFB 0
                DEFB 0,0,0,0,0,0
                DEFB 0,0,0,0,0,0
                DEFB 0,0,0,0,0,0
                DEFB 0,0,0,0,0,0
                DEFB 0,0,0,0,0,0
                DEFB 0,0,0,0,0,0
                DEFB 0,0,0,0,0,0
                DEFB 0,0,0,0,0,0
                
ENEMY_INFO      DEFB 0
                ; 0     - move counter
                ; 1,2   - current coordinates
                ; 3     - flag changes coordinates
                ; 4,5   - old coordinates
                ; 6     - current frame
                ; 7     - is shot
                ; 8     - shot move counter
                ; 9,10  - shot current coordinates
                ; 11    - flag changes shot coordinates
                ; 12,13 - old coordinates                
                DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0
                DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0
                DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0
                DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0
                DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0
                DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0
                DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0
                DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0
                               
KEY_INFO_W      DEFB 0
KEY_INFO_S      DEFB 0
KEY_INFO_A      DEFB 0
KEY_INFO_D      DEFB 0
KEY_INFO_SP     DEFB 0

end_file:

        display "code size: ", /d, end_file - begin_file

        savehob "game.$C", "game.C", begin_file, end_file - begin_file

        savesna "game.sna", begin_file
        
        labelslist "game.l"
