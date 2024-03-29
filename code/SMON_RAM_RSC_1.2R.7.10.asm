; ###############################################################
; #                                                             #
; #  SMON-RAM RELOCATABLE SOURCE CODE                           #       
; #  Version 1.2R.8.10 (2023.10.10)                             #
; #  Copyright (c) 2022, 2023 Claus Schlereth                   #
; #                                                             #  
; #  Based on the source code from: cbmuser                     #
; #  https://github.com/cbmuser/smon-reassembly                 #
; #                                                             #
; #  This source is available at:                               #
; #  https://github.com/LeshanDaFo/SMON-RAM-VERSION             #
; #                                                             #
; #  SMON was written by:                                       #
; #  Norfried Mann und Dietrich Weineck                         #
; #                                                             #
; #  The PLUS-extension was written by:                         #
; #  Mark Richters                                              #
; #                                                             #
; #  The Ram-under-Rom function is based on a SMON version      #
; #  called DUDZMON https://csdb.dk/release/?id=50473           #
; #  provided to me by schumi, a member from FORUM64            #
; #  https://www.forum64.de/wcf/index.php?user/15606-schumi/    #
; #                                                             #
; #  additional function for floppy commands in Ram-under-Rom   #
; #  based on a SMON-version provided to me by rh70, also a     #
; #  member from FORUM64                                        #
; #  https://www.forum64.de/wcf/index.php?user/20464-rh70/      #
; #                                                             #
; #  This version of the source code is under MIT License       #
; ###############################################################

; History:
; V1.2R.6.10    =   this is the branch from the SMON RSC-Version, which can be found at https://github.com/LeshanDaFo/SMON-RelocatableSourceCode
                  ; for the comatibility, first i will not remove the other normal parts. 
                  ; with this version it is possible to build all versions of the SMON
; V1.2R.7.10    =   correct an reported error.
                  ; there was an error in the comma-command (disassemble change), a change by overwriting an value was not accepted.
; V1.2R.8.10    =   the last error was not corrected successful, it should work now

TASTBUF         = $0277
COLOR           = $0286                         ; charcolor
PCHSAVE         = $02A8                         ; PC hi
PCLSAVE         = $02A9                         ; PC lo
SRSAVE          = $02AA                         ; SR
AKSAVE          = $02AB                         ; A
XRSAVE          = $02AC                         ; XR
YRSAVE          = $02AD                         ; YR
SPSAVE          = $02AE                         ; SP
PRNNO           = $02AF                         ; Printer number
IONO            = $02B0                         ; Device-Number
MEM             = $02B1                         ; Buffer bis $02BA
TRACEBUF        = $02B8                         ; Buffer für Trace-Modus bis $02BF

IRQ_LO          = $0314                         ; Vector: Hardware IRQ Interrupt Address Lo
IRQ_HI          = $0315                         ; Vector: Hardware IRQ Interrupt Address Hi
BRK_LO          = $0316                         ; Vector: BRK Lo
BRK_HI          = $0317                         ; Vector: BRK Hi
LOADVECT        = $0330                         ; Vector: Kernal LOAD
SAVEVECT        = $0332                         ; Vector: Kernal SAVE

;READY
WARMSTART       = $A474                         ; Restart BASIC
FLOATC          = $BC49                         ; FLOAT UNSIGNED VALUE IN FAC+1,2
INTOUT          = $BDCD                         ; Output Positive Integer in A/X
INTOUT1         = $BDD1                         ; Output Positive Integer in A/X
FLPSTR          = $BDDD                         ; Convert FAC#1 to ASCII String
VIC_CTRL1       = $D011                         ; VIC Control Register 1
BORDER          = $D020                         ; Border Color
BKGRND          = $D021                         ; Background Clor
TIMERA_LO       = $DC04                         ; Timer A Low-Byte (Kernal-IRQ, Tape)
TIMERA_HI       = $DC05                         ; Timer A High-Byte (Kernal-IRQ, Tape)
CONTROL_REGA    = $DC0E                         ; Control Register A CIA#1
EN_TIMER        = $FDDD                         ; Enable Timer
SECND           = $FF93                         ; send SA after LISTEN
TKSA            = $FF96                         ; Set secondary address
IECIN           = $FFA5                         ; Read byte from IEC bus
CIOUT           = $FFA8                         ; handshake IEEE byte out
UNTALK          = $FFAB                         ; send UNTALK out IEEE
UNLSN           = $FFAE                         ; send UNLISTEN out IEEE
LISTN           = $FFB1                         ; send LISTEN out IEEE
TALK            = $FFB4                         ; send TALK out IEEE
SETLFS          = $FFBA                         ; set length and FN adr
SETNAM          = $FFBD                         ; Set file name
OPEN            = $FFC0                         ; OPEN Vector
CLOSE           = $FFC3                         ; CLOSE Vector
CHKIN           = $FFC6                         ; Set input file
CHKOUT          = $FFC9                         ; Set Output
CLRCHN          = $FFCC                         ; Restore I/O Vector
CHRIN           = $FFCF                         ; Input Vector
CHROUT          = $FFD2                         ; Output Vector
STOP            = $FFE1                         ; Test STOP Vector
GETIN           = $FFE4                         ; Vector: Kernal GETIN Routine

; addresses used from disk monitor:

SAVEX           = $02C1                         ; Temp storage for X- und Y-Register
TMPTRCK         = $02C2
TMPSECTO        = $02C3                         ; Temp storage for track and sector
DCMDST          = $02D0                         ; Disc command string
TRACK           = $02D8
SECTO           = $02DB                         ; Track and sector number
BUF1            = $033C                         ; Buffer for assembly command, until $03FC
BUF2            = $036C
BUF3            = $039C
BUF4            = $03CC

; used zero page addresses
_01BUFF         = $41                           ; Buffer for $01 zero page value used in ram under rom version
FLAG            = $AA                           ; Universal flag
ADRCODE         = $AB                           ; Addressing code for Assembler/Disassembler
COMMAND         = $AC                           ; SMON-command code
BEFCODE         = $AD                           ; Command code Ass./Disass.
LOPER           = $AE                           ; Low-Operand for Ass./Disass.
HOPER           = $AF                           ; High-Operand for Ass./Disass.
BEFLEN          = $B6                           ; Command length Ass./Disass.
PCL             = $FB                           ; SMON-programmcounter Low-Byte
PCH             = $FC                           ; SMON-programmcounter High-Byte

; hidden commands
HCK             = $27                           ; "'"
HCM             = $3a                           ; ":"
HCR             = $3b                           ; ";"
HCD             = $2C                           ; ","
; hidden cmds in PLUS
HCH             = $28                           ; '('
HCZ             = $29                           ; ")"
HCN             = $21                           ; "!"

; -----------------------------------------------------------
; ---------------------- SMON VERSION -----------------------
; -----------------------------------------------------------
; - SELECT ONLY ONE VERSION BY UNCOMMENTING IT -
; if nothing is selected here, SMON will be compiled without any extension

RAM = 1        ; this is the PLUS version with activated ram under rom function
;RAM1 = 1       ; this is the ILOC version with activated ram under rom function
; -----------------------------------------------------------
; -------------------END SMON VERSION -----------------------
; -----------------------------------------------------------

; -----------------------------------------------------------
; --------- define here the start address in memory ---------
        *= $C000
; -----------------------------------------------------------


; -----------------------------------------------------------
; feature to hide the bounding line after 'brk','rts' and 'jmp'
; -----------------------------------------------------------
; with this switch it is possible to hide the bounding lines
; which is normally displayed after some commands during disassemble
; commenting bndline will hide the lines
bndline = 1     ; change here
; -----------------------------------------------------------

!ifdef RAM1 {
    RAM = 1
    ILOC = 1
    !to"build/SMONRIx000.prg",cbm
} else {
    !ifdef RAM {
        !to"build/SMONRPx000.prg",cbm
    } 
}

; -----------------------------------------------------------
; ------------------ start of the program -------------------
; -----------------------------------------------------------

SETBRK:         lda     #<BREAK                         ; set break-vector to program start
                sta     BRK_LO
_brk_hb:        lda     #>BREAK
                sta     BRK_HI
                brk
; ------------------ here are the general commands ----------
CMDTBL:         !by     $27,$23,$24,$25,$2C,$3A,$3B,$3D ;"'#$%,:;=" 
                !by     $3F,$41,$42,$43,$44,$46,$47,$49 ;"?ABCDFGI"                
                !by     $4B,$4C,$4D,$4F,$50,$52,$53     ;"KLMOPRS"

; depending of the selection, different commands are defined

; remove the trace command if RAM is selected             
                !by     $56,$57,$58                     ; "VWX"
                !by     $00                             ; "."        
                !by     $00,$00                         ;".."
                !by     $00,$00
; the command addresses
CMDS:           !by     <TICK-1                         ; ' 01
                !by     >TICK-1
                !by     <BEFDEC-1                       ; # 02
                !by     >BEFDEC-1
                !by     <BEFHEX-1                       ; $ 03
                !by     >BEFHEX-1
                !by     <BEFBIN-1                       ; % 04
                !by     >BEFBIN-1
                !by     <COMMA-1                        ; , 05
                !by     >COMMA-1
                !by     <COLON-1                        ; : 06
                !by     >COLON-1
                !by     <SEMIS-1                        ; ; 07
                !by     >SEMIS-1
                !by     <COMP-1                         ; = 08
                !by     >COMP-1
                !by     <ADDSUB-1                       ; ? 09
                !by     >ADDSUB-1
                !by     <ASSEMBLER-1                    ; A 0A
                !by     >ASSEMBLER-1
                !by     <BASICDATA-1                    ; B 0B
                !by     >BASICDATA-1
                !by     <CONVERT-1                      ; C 0C
                !by     >CONVERT-1
                !by     <DISASS-1                       ; D 0D
                !by     >DISASS-1
                !by     <FIND-1                         ; F 0F
                !by     >FIND-1
                !by     <GO-1                           ; G 10
                !by     >GO-1
                !by     <IOSET-1                        ; I 11
                !by     >IOSET-1
                !by     <KONTROLLE-1                    ; K 12
                !by     >KONTROLLE-1
                !by     <LOADSAVE-1                     ; L 13
                !by     >LOADSAVE-1
                !by     <MEMDUMP-1                      ; M 14
                !by     >MEMDUMP-1
                !by     <OCCUPY-1                       ; O 15
                !by     >OCCUPY-1
; depending on the selected version, different command addresses are defined

; the DCOM command is used in ram under rom version
                !by     <DCOM-1                         ; P 16
                !by     >DCOM-1
                !by     <REGISTER-1                     ; R 17
                !by     >REGISTER-1
                !by     <LOADSAVE-1                     ; S 18
                !by     >LOADSAVE-1
                !by     <VERSCHIEB-1                    ; V 1A
                !by     >VERSCHIEB-1
                !by     <WRITE-1                        ; W 1B
                !by     >WRITE-1
                !by     <EXIT-1                         ; X 1C
                !by     >EXIT-1
!ifdef RAM1 {
                !by     <ILLEGAL-1
                !by     >ILLEGAL-1    
}

HCMDTAB:        !by     HCK,HCM,HCR,HCD,HCH,HCZ,HCN     ; "':;,()!"

                !by     $00,$00,$00

OFFSET:         !by     $FF,$FF,$01,$00            

; find commands
FINDTAB:        !by     $41,$5A,$49,$52,$54             ; "AZIRT"
FINDFLG:        !by     $80,$20,$40,$10,$00
FINDFLG1:       !by     $02,$01,$01,$02,$00

; code for generating basic lines
SYS172:         !by     $91,$91,$0D
                !by     $53,$D9,$31,$37,$32,$0D         ; "sY172." 
DATATAB:        !by     $00,$7D                         ; basic line number 32000
                !by     $4C                             ; jmp DATALOOP
                !by     <DATALOOP
BASJMP:         !by     >DATALOOP

; the register header
REGHEAD:        !by     $0D,$0D,$20,$2D,$50,$43,$2D,$20 ; ".. -PC- "  
                !by     $53,$52,$20,$41,$43,$20,$58,$52 ; "SR AC XR"
                !by     $20,$59,$52,$20,$53,$50,$20,$20 ; " YR SP  "
                !by     $4E,$56,$2D,$42,$44,$49,$5A,$43 ; "NV-BDIZC"

LC0AC:          !by     $00,$02,$04
LC0AF:          !by     $01,$2C,$00
LC0B2:          !by     $2C,$59,$29
LC0B5:          !by     $58,$9D,$1F,$FF,$1C,$1C,$1F,$1F
                !by     $1F,$1C,$DF,$1C,$1F,$DF,$FF,$FF
                !by     $03
LC0C6:          !by     $1F,$80,$09,$20,$0C,$04,$10,$01
                !by     $11,$14,$96,$1C,$19,$94,$BE,$6C
                !by     $03,$13
LC0D8:          !by     $01,$02,$02,$03,$03,$02,$02,$02
                !by     $02,$02,$02,$03,$03,$02,$03,$03
                !by     $03,$02
LC0EA:          !by     $00,$40,$40,$80,$80,$20,$10,$25
                !by     $26,$21,$22,$81,$82,$21,$82,$84
                !by     $08
LC0FB:          !by     $08,$E7,$E7,$E7,$E7,$E3,$E3,$E3
                !by     $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E7
                !by     $A7,$E7,$E7,$F3,$F3,$F7
LC111:          !by     $DF

; --------- 6510 COMMANDS -----------------------------------
LC112:          !by     $26,$46,$06,$66,$41,$81,$E1,$01   ;ROL,LSR,ASL,....
                !by     $A0,$A2,$A1,$C1,$21,$61,$84,$86
                !by     $E6,$C6,$E0,$C0,$24,$4C,$20,$90
                !by     $B0,$F0,$30,$D0,$10,$50,$70,$78
                !by     $00,$18,$D8,$58,$B8,$CA,$88,$E8
LC13A:          !by     $C8,$EA,$48,$08,$68,$28,$40,$60
                !by     $AA,$A8,$BA,$8A,$9A,$98,$38,$F8 

LC14A:          !by     $89,$9C,$9E
LC14D:          !by     $B2,$2A,$4A,$0A,$6A,$4F,$23,$93
                !by     $B3,$F3,$33,$D3,$13,$53,$73

; --------- 6510 COMMANDS CHAR ------------------------------
LC15C:          !by     $52,$4C,$41,$52,$45,$53,$53,$4F   ; "R L A R E S S O"     ;R
                !by     $4C,$4C,$4C,$43,$41,$41,$53,$53   ; "L L L C A A S S"
                !by     $49,$44,$43,$43,$42,$4A,$4A,$42   ; "I D C C B J J B"
                !by     $42,$42,$42,$42,$42,$42,$42,$53   ; "B B B B B B B S"
                !by     $42,$43,$43,$43,$43,$44,$44,$49   ; "B C C C C D D I"
                !by     $49,$4E,$50,$50,$50,$50,$52,$52   ; "I N P P P P R R"
                !by     $54,$54,$54,$54,$54,$54,$53,$53   ; "T T T T T T S S"

LC194:          !by     $4F,$53,$53,$4F,$4F,$54,$42,$52   ; "O S S O O T B R"     ;O
                !by     $44,$44,$44,$4D,$4E,$44,$54,$54   ; "D D D M N D T T"
                !by     $4E,$45,$50,$50,$49,$4D,$53,$43   ; "N E P P I M S C"
                !by     $43,$45,$4D,$4E,$50,$56,$56,$45   ; "C E M N P V V E"
                !by     $52,$4C,$4C,$4C,$4C,$45,$45,$4E   ; "R L L L L E E N"
                !by     $4E,$4F,$48,$48,$4C,$4C,$54,$54   ; "N O H H L L T T"
                !by     $41,$41,$53,$58,$58,$59,$45,$45   ; "A A S X X Y E E"

LC1CC:          !by     $4C,$52,$4C,$52,$52,$41,$43,$41   ; "L R L R R A C A"     ;L
                !by     $59,$58,$41,$50,$44,$43,$59,$58   ; "Y X A P D C Y X"
                !by     $43,$43,$58,$59,$54,$50,$52,$43   ; "C C X Y T P R C"
                !by     $53,$51,$49,$45,$4C,$43,$53,$49   ; "S Q I E L S C I"
                !by     $4B,$43,$44,$49,$56,$58,$59,$58   ; "K C D I V X Y X"
                !by     $59,$50,$41,$50,$41,$50,$49,$53   ; "Y P A P A P I S"
                !by     $58,$59,$58,$41,$53,$41,$43,$44   ; "X Y X A S A C D"

LC204:          !by     $08,$84,$81,$22,$21,$26,$20,$80
LC20C:          !by     $03,$20,$1C,$14,$14,$10,$04,$0C

; --------- SMON START --------------------------------------
BREAK:          cld
                lda     #$08
                sta     IONO                            ; set drive #8
                lda     #$04
                sta     PRNNO                           ; set printer #4   
                ldx     #$05
BREAK2:         pla
                sta     PCHSAVE,x                       ; save stack
                dex
                bpl     BREAK2
                lda     PCLSAVE
                bne     BREAK3
                dec     PCHSAVE                         ; PC high
BREAK3:         dec     PCLSAVE                         ; PC low  
                tsx
                stx     SPSAVE
                lda     #$52                            ; "R"-command
                jmp     CMDSTORE                        ; execute R-command
;
GETSTART:       jsr     GETRET                          ; check for return
                beq     GETSTRTS
GETSTART1:      jsr     GETADR1
                sta     PCLSAVE
                lda     PCH
                sta     PCHSAVE
GETSTRTS:       rts
;
GET3ADR:        ldx     #$A4
                jsr     GETADR
                jsr     GETADR
                bne     GETADR
;
GET12ADR:       jsr     GETADR1
                lda     #$FE
                sta     $FD
                lda     #$FF
                sta     $FE
                jsr     GETRET                          ; check for return
                bne     GETADR
                sta     TASTBUF
                inc     $C6
                rts
;
GET2ADR:        jsr     GETADR1
                !by     $2C
GETADR1:        ldx     #$FB
;
GETADR:         jsr     GETBYT
                sta     $01,x
                jsr     GETBYT1
                sta     $00,x
                inx
                inx
                rts
;
GETBYT:         jsr     GETCHRERR
_GETBYT:        cmp     #$20
                beq     GETBYT
                cmp     #$2C
                beq     GETBYT
                bne     ASCHEX
;
GETBYT1:        jsr     GETCHRERR
ASCHEX:         jsr     ASCHEX1
                asl
                asl
                asl
                asl
                sta     $B4
                jsr     GETCHRERR
                jsr     ASCHEX1
                ora     $B4
                rts
ASCHEX1:        cmp     #$3A
                bcc     ASCHEX2
                adc     #$08
ASCHEX2:        and     #$0F
                rts
;
SKIPSPACE:      jsr     GETCHRERR
                cmp     #$20
                beq     SKIPSPACE
                dec     $D3
                rts
;
GETRET:         
                jsr     R_CHRIN                         ; get input
                dec     $D3                             ; 
                cmp     #$0D                            ; await RETURN
GETBRTS:        rts
; --------- GET INPUT AND AWAIT RETURN ----------------------
GETCHRERR:      
                jsr     R_CHRIN                         ; get input
                cmp     #$0D                            ; await RETURN  
                bne     GETBRTS                         ; not CR
; --------- Faulty Userinput -------------------------------- 
ERROR:          lda     #$3F                            ; "?"
                jsr     R_CHROUT                           
EXECUTE:        ldx     SPSAVE                         
                txs
                ldx     #$00
                stx     $C6
                jsr     RETURN                          ; next line
                lda     ($D1,x)

                ldx     #$06                            ; amount of commands
CHKHCMD:        cmp     HCMDTAB,x                       ; check for hidden command
                beq     EXEC1                           ; if found, execute
                dex                                     ; 
                bpl     CHKHCMD                         ; check for next command
                lda     #$2E                            ; "."
                jsr     R_CHROUT                        ; draw point
EXEC1:          jsr     GETCHRERR                       ; await next input
                cmp     #$2E                            ; "." 
                beq     EXEC1                           ; ignore dot
                jmp     LINSTORE                        ; prepare buffer for J-command, and then jmp to CMDSTORE
NEXT:           jmp     MORECMD


CMDSTORE:       sta     COMMAND                         ; store command
                and     #$7F                            ; delete bit 7
                ldx     #$20                            ; amount of commands
; --------- Check User Input --------------------------------
CMDSEARCH:      cmp     CMDTBL-1,x                      ; compare users char
                beq     CMDFOUND                        ; matched
                dex
                bne     CMDSEARCH                       ; repaet compare

                beq     NEXT                            ; check for additonal plus commands

CMDFOUND:       jsr     CMDEXEC                         ; fetch routine offset
                jmp     EXECUTE                         ; go back, wait for next input

; --------- get address according command char and execute --
CMDEXEC:        txa
                asl
                tax
                inx
                lda     CMDS-2,x                        ; low address 
                pha                                     ; on stack
                dex
                lda     CMDS-2,x                        ; high address
                pha                                     ; on stack 
                rts                                     ; jump to execute command 
; --------- output PC as 4 digit hex -----------------------
HEXOUT:         lda     PCH                             ; load PC high byte
                jsr     HEXOUT1                         ; output 2 digit hex address
                lda     PCL                             ; load PC low byte
; --------- output value as 2 digit hex -----------------------
HEXOUT1:        pha                                     ; save byte
                lsr                                     ; shift 4 times to get low nibble
                lsr
                lsr
                lsr
                jsr     HEXOUT2                         ; output one nibble
                pla                                     ; get back saved value
                and     #$0F                            ; mask low nibble
HEXOUT2:        cmp     #$0A                            ; compare
                bcc     HEXOUT3                         ; output as number
                adc     #$06                            ; add 6 for letter
HEXOUT3:        adc     #$30                            ; add $30
                jmp     R_CHROUT                        ; output
; --------- output a char with leading CR ---------------------
CHARRET:        lda     #$0D                            ; next line
CHARR1:
                jsr     R_CHROUT                        ; output
                txa                                     ; get value from x
                jmp     R_CHROUT                        ; output
; --------- output 2 x space ----------------------------------
SPACE2:         jsr     SPACE
; --------- output space --------------------------------------
SPACE:          lda     #$20                            ; space
                jmp     R_CHROUT                        ; output
; --------- output CR -----------------------------------------
RETURN:         lda     #$0D                            ; next line
                jmp     R_CHROUT                        ; output

; --------- print string from address in a,y ------------------
PRINT:          sta     $BB                             ; pointer to address low byte
                sty     $BC                             ; pointer to address high byte
                ldy     #$00                            ; counter
PRINT1:         lda     ($BB),y                         ; get byte from address
                beq     PRINT2                          ; if 0 then end
                jsr     R_CHROUT                        ; otherwise print                       
                iny                                     ; increase counter
                bne     PRINT1                          ; more to print
PRINT2:         rts
; --------- increase PC -------------------------------------
PCINC:          inc     PCL                             ; increase low byte
                bne     PCRTS                           ; not 0, then finish
                inc     PCH                             ; otherwise increase also the high byte
PCRTS:          rts
; --------- EXIT (X) ----------------------------------------
EXIT:
                lda     #$37 
                sta     $01
                sta     _01BUFF
                ldx     SPSAVE                          ; restore stack  
                txs 
                jmp     WARMSTART                       ; basic warmstart 
; --------- REGISTER (R) ------------------------------------                        
REGISTER:       ldy     #>REGHEAD
                lda     #<REGHEAD
                jsr     PRINT
                ldx     #$3B                            ; ";"
                jsr     CHARRET                         ; print on screen
                lda     PCHSAVE                         ; PC high byte
                sta     PCH
                lda     PCLSAVE                         ; PC low byte
                sta     PCL
                jsr     HEXOUT                          ; output as 4 digit hex
                jsr     SPACE                           ; output space
                ldx     #$FB
REGISTER2:      lda     $01AF,x
                jsr     HEXOUT1                         ; output Register values as 2 digit hex values
                jsr     SPACE                           ; output space
                inx
                bne     REGISTER2
                lda     SRSAVE                          ; output space
                jmp     CHNGBIN                         ; output SR as bin
; --------- SEMIS (;) ---------------------------------------
SEMIS:          jsr     GETSTART1
                ldx     #$FB
SEMIS1:         jsr     GETCHRERR
                jsr     GETBYT1
                sta     $01AF,x
                inx
                bne     SEMIS1
                jsr     SPACE                           ; output space
                lda     SRSAVE,x
                jmp     CHNGBIN
CHNGBIN:        sta     FLAG
                lda     #$20
                ldy     #$09
CHANGB1:
                jsr     R_CHROUT
                asl     FLAG
                lda     #$30
                adc     #$00
                dey
                bne     CHANGB1
                rts
; --------- GO (G) ------------------------------------------
GO:
                jsr     R_GETSTART  
                ldx     SPSAVE
                txs
                ldx     #$FA
GO2:            lda     $01AE,x
                pha
                inx
                bne     GO2
                pla
                tay
                pla
                tax
                pla
                rti
; --------- MEMDUMP (M) -------------------------------------
MEMDUMP:        jsr     GET12ADR
MEMDUMP1:       ldx     #$3A                            ; ':'
                jsr     CHARRET
                jsr     HEXOUT                          ; output as 4 digit hex
                ldy     #$20
                ldx     #$00
MEMDUMP2:       jsr     SPACE                           ; output space
                lda     (PCL,x)
                jsr     HEXOUT1                         ; output 2 digit hex address
                lda     (PCL,x)
                jsr     ASCII
                bne     MEMDUMP2
                jsr     R_CONTIN         
                bcc     MEMDUMP1
                rts
; --------- COLON (:) ---------------------------------------
COLON:          jsr     GETADR1
                ldy     #$20
                ldx     #$00
COLON1:         jsr     GETCHRERR
                jsr     GETBYT1
                sta     (PCL,x)
                cmp     (PCL,x)
                beq     COLON2
                jmp     ERROR
COLON2:         jsr     ASCII
                bne     COLON1
                rts
ASCII:          cmp     #$20
                bcc     ASCII1
                cmp     #$60
                bcc     ASCII2
                cmp     #$C0
                bcc     ASCII1
                cmp     #$DB
                bcc     ASCII3
ASCII1:         lda     #$2E                            ; '.'
ASCII2:         and     #$3F
ASCII3:         and     #$7F
ASCII4:         sta     ($D1),y
                lda     COLOR
                sta     ($F3),y
ASCII5:         jsr     PCINC
                iny
                cpy     #$28
                rts

CONTIN:         jsr     TASTE
                jmp     CMPEND1

CMPEND:         jsr     PCINC
CMPEND1:        lda     PCL
                cmp     $FD
                lda     PCH
                sbc     $FE
                rts
;
TASTE:          jsr     PRINTER1
TASTE1:         jsr     SCANKEY
                beq     TASTRTS
TASTE2:         jsr     SCANKEY
                beq     TASTE2
                cmp     #$20
                bne     TASTRTS
                sta     TASTBUF
                inc     $C6
TASTRTS:        rts
;
SCANKEY:
                jsr     R_GETIN
                pha
                jsr     R_STOPT              
                beq     STOP_
                pla
SCANRTS:        rts
STOP_:          jmp     EXECUTE                         ; go back, wait for next input
;
PRINTER1:       ldy     #$28
PRINTER:        bit     COMMAND
                bpl     SCANRTS
                sty     $C8
                sty     $D0
                lda     #$FF
                jsr     R_CLOSE               
                lda     #$FF
                sta     $B8
                sta     $B9
                lda     PRNNO
                sta     $BA
                jsr     OPEN
                ldx     #$00
                stx     $D3
                dex
; ??????
                jsr     CHKOUT
PRLOOP:         jsr     CHRIN
                jsr     CHROUT
                cmp     #$0D
                bne     PRLOOP
                jsr     R_CLRCHN
                lda     #$91
                jsr     R_CHROUT
LC4CB:          ldy     #$00
                lda     (PCL),y
                bit     FLAG
                bmi     LC4D5
                bvc     LC4E1
LC4D5:          ldx     #$1F
LC4D7:          cmp     LC13A+2,x
                beq     LC50B
                dex
                cpx     #$15
                bne     LC4D7
LC4E1:          ldx     #$04
LC4E3:          cmp     LC14A-1,x
                beq     LC509
                cmp     LC14D,x
                beq     LC50B
                dex
                bne     LC4E3
                ldx     #$38
LC4F2:          cmp     LC111,x
                beq     LC50B
                dex
                cpx     #$16
                bne     LC4F2
LC4FC:          lda     (PCL),y
                and     LC0FB,x
                eor     LC111,x
                beq     LC50B
                dex
                bne     LC4FC
LC509:          ldx     #$00
LC50B:          stx     BEFCODE
                txa
                beq     LC51F
                ldx     #$11
LC512:          lda     (PCL),y
                and     LC0B5,x
                eor     LC0C6,x
                beq     LC51F
                dex
                bne     LC512
LC51F:          lda     LC0EA,x
                sta     ADRCODE
                lda     LC0D8,x
                sta     BEFLEN
; if selected ILOC      
!ifdef ILOC {
                jmp     _ILOCM
} else {
                ldx     BEFCODE
                rts        
}        
LC52C:          ldy     #$01
                lda     (PCL),y
                tax
                iny
                lda     (PCL),y
                ldy     #$10
                cpy     ADRCODE
                bne     LC541
                jsr     LC54A
                ldy     #$03
                bne     LC543
LC541:          ldy     BEFLEN
LC543:          stx     $00AE
                sta     $00AF
                rts
LC54A:          ldy     #$01
                lda     (PCL),y
                bpl     LC551
                dey
LC551:          sec
                adc     PCL
                tax
                inx
                beq     LC559
                dey
LC559:          tya
                adc     PCH
LC55C:          rts
; --------- DISASS (D) --------------------------------------
DISASS:         ldx     #$00
                stx     FLAG
                jsr     GET12ADR
LC564:          jsr     LC58C                           ; output one line
                lda     BEFCODE                         ; load command code
; here the bounding line after 'JMP','RTS' and 'BRK' will be printed
!ifdef bndline {
                cmp     #$16                            ; compare with "JMP"
                beq     LC576                           ; print one line with "-"
                cmp     #$30                            ; compare with "RTS"
                beq     LC576                           ; print one line with "-"
                cmp     #$21                            ; compare with "BRK"
                bne     LC586
                nop
LC576:          jsr     PRINTER1
                jsr     RETURN                          ; next line
                ldx     #$21                            ; amount of bounding line chars
                lda     #$2D                            ; load with '-'
LC580:
                jsr     R_CHROUT                        ; print char
                dex                                     ; dec amount
                bne     LC580                           ; not last
} 
; emd print bounding line                       
LC586:
                jsr     CONTIN
                bcc     LC564
                rts
LC58C:          ldx     #$2C
                jsr     CHARRET
                jsr     HEXOUT                          ; output as 4 digit hex
                jsr     SPACE                           ; output space
LC597:          jsr     LC675
                jsr     LC4CB                       
                jsr     SPACE                           ; output space
LC5A0:          lda     (PCL),y
                jsr     HEXOUT1                         ; output 2 digit hex address                         
                jsr     SPACE                           ; output space
                iny
                cpy     BEFLEN
                bne     LC5A0
                lda     #$03
                sec
                sbc     BEFLEN
                tax
                beq     SPCOC                           ; output opcode with leading space
LC5B5:          jsr     SPACE2                          ; output 2 x space
                jsr     SPACE                           ; output space
                dex
                bne     LC5B5

SPCOC:  ; output opcode with leading space
; if select ILOC
!ifdef ILOC {
                jmp     _ILOCD
                !by     $D2
                !by     $FF
} else {
                lda     #$20
                jsr     R_CHROUT        
}
                ldy     #$00
                ldx     BEFCODE
LC5C7:          bne     LC5DA
LC5C9:          ldx     #$03
LC5CB:          lda     #$2A
                jsr     R_CHROUT
                dex
                bne     LC5CB
                bit     FLAG
                bmi     LC55C
                jmp     LC66A
LC5DA:          bit     FLAG
                bvc     LC607
                lda     #$08
                bit     ADRCODE
                beq     LC607
                lda     (PCL),y
                and     #$FC
                sta     BEFCODE
                iny
                lda     (PCL),y
                asl
                tay
                lda     BUF1,y
                sta     $00AE
                iny
                lda     BUF1,y
                sta     $00AF
                jsr     LC6BE
                ldy     BEFLEN
                jsr     LC693
                jsr     LC4CB
LC607:          lda     LC15C-1,x
                jsr     R_CHROUT
                lda     LC194-1,x
                jsr     R_CHROUT
                lda     LC1CC-1,x
LC616:          jsr     R_CHROUT
                lda     #$20
                bit     ADRCODE
                beq     LC622
                jsr     SPACE2                          ; output 2 x space
LC622:          ldx     #$20
                lda     #$04
                bit     ADRCODE
                beq     LC62C
                ldx     #$28
LC62C:          txa
                jsr     R_CHROUT
                bit     ADRCODE
                bvc     LC639
                lda     #$23
                jsr     R_CHROUT
LC639:          jsr     LC52C
                dey
                beq     LC655
                lda     #$08
                bit     ADRCODE
                beq     LC64C
                lda     #$4D
                jsr     R_CHROUT
                ldy     #$01
LC64C:          lda     $00AD,y
                jsr     HEXOUT1                         ; output 2 digit hex address
                dey
                bne     LC64C
LC655:          ldy     #$03
LC657:          lda     LC0AC,y
                bit     ADRCODE
                beq     LC667
                lda     LC0AF,y
                ldx     LC0B2,y
                jsr     CHARR1
LC667:          dey
                bne     LC657
LC66A:          lda     BEFLEN
LC66C:          jsr     PCINC
                sec
                sbc     #$01
                bne     LC66C
                rts
LC675:          ldy     $D3
                lda     #$20
LC679:          sta     ($D1),y
                iny
                cpy     #$28
                bcc     LC679
                rts
LC681:          cpx     ADRCODE
                bne     LC689
                ora     BEFCODE
                sta     BEFCODE
LC689:          rts
LC68A:          lda     $00AD,y
                sta     (PCL),y
                cmp     (PCL),y
                bne     LC697
LC693:          dey
                bpl     LC68A
                rts
LC697:          pla
                pla
                rts
LC69A:          bne     LC6B8
                txa
                ora     ADRCODE
                sta     ADRCODE
LC6A1:          lda     #$04
                sta     $B5
LC6A5:
                jsr     R_CHRIN
                cmp     #$20
                beq     LC6B9
                cmp     #$24
                beq     LC6B9
                cmp     #$28
                beq     LC6B9
                cmp     #$2C
                beq     LC6B9
LC6B8:          rts
LC6B9:          dec     $B5
                bne     LC6A5
                rts
LC6BE:          cpx     #$18
                bmi     LC6D0
                lda     $00AE
                sec
                sbc     #$02
                sec
                sbc     PCL
                sta     $00AE
                ldy     #$40
LC6D0:          rts
; --------- ASSEMBLER (A) -----------------------------------
ASSEMBLER:      jsr     GETADR1
                sta     $FD
                lda     PCH
                sta     $FE
LC6DA:          jsr     RETURN                          ; next line
LC6DD:          jsr     LC6E4
                bmi     LC6DD
                bpl     LC6DA
LC6E4:          lda     #$00
                sta     $D3
                jsr     SPACE                           ; output space
                jsr     HEXOUT                          ; output as 4 digit hex
                jsr     SPACE                           ; output space
                jsr     R_CHRIN
                lda     #$01
                sta     $D3
                ldx     #$80
                bne     LC701
; --------- COMMA (,) ---------------------------------------
COMMA:          ldx     #$80
                stx     MEM
LC701:          stx     FLAG
                jsr     GETADR1
                lda     #$25
                sta     $C8
                bit     $02B1
                bpl     LC717
                ldx     #$0A
LC711:
                jsr     R_CHRIN
                dex
                bne     LC711
LC717:          lda     #$00
                sta     MEM
                jsr     LC6A1
                cmp     #$46
                bne     LC739
                lsr     FLAG
                pla
                pla
                ldx     #$02
LC729:          lda     $FA,x
                pha
                lda     PCH,x
                sta     $FA,x
                pla
                sta     PCH,x
                dex
                bne     LC729
                jmp     LC564
LC739:          cmp     #$2E
                bne     LC74E
                jsr     GETBYT1
                ldy     #$00
                sta     (PCL),y
                cmp     (PCL),y
                bne     LC74C
                jsr     PCINC
                iny
LC74C:          dey
                rts
LC74E:          ldx     #$FD
                cmp     #$4D
                bne     LC76D
                jsr     GETBYT1
                ldy     #$00
                cmp     #$3F
                bcs     LC74C
                asl
                tay
                lda     PCL
                sta     BUF1,y
                lda     PCH
                iny
                sta     BUF1,y
LC76A:          jsr     LC6A1
LC76D:          sta     $A9,x
                cpx     #$FD
                bne     LC777
                lda     #$07
                sta     $B7
LC777:          inx
                bne     LC76A
                ldx     #$38
LC77C:          lda     $A6
                cmp     LC15C-1,x
                beq     LC788
LC783:          dex
                bne     LC77C
                dex
                rts
LC788:          lda     $A7
                cmp     LC194-1,x
                bne     LC783
                lda     $A8
                cmp     LC1CC-1,x
                bne     LC783
                lda     LC111,x
                sta     BEFCODE
                jsr     LC6A1
                ldy     #$00
                cpx     #$20
                bpl     LC7AD
                cmp     #$20
                bne     LC7B0
                lda     LC14D,x
                sta     BEFCODE
LC7AD:          jmp     LC831
LC7B0:          ldy     #$08
                cmp     #$4D
                beq     LC7D6
                ldy     #$40
                cmp     #$23
                beq     LC7D6
                jsr     ASCHEX
                sta     $00AE
                sta     $00AF
                jsr     LC6A1
                ldy     #$20
                cmp     #$30
                bcc     LC7E9
                cmp     #$47
                bcs     LC7E9
                ldy     #$80
                dec     $D3
LC7D6:          jsr     LC6A1
                jsr     ASCHEX
                sta     $00AE
                jsr     LC6A1
                cpy     #$08
                beq     LC7E9
                jsr     LC6BE
LC7E9:          sty     ADRCODE
                ldx     #$01
                cmp     #$58
                jsr     LC69A
                ldx     #$04
                cmp     #$29
                jsr     LC69A
                ldx     #$02
                cmp     #$59
                jsr     LC69A
                lda     BEFCODE
                and     #$0D
                beq     LC810
                ldx     #$40
                lda     #$08
                jsr     LC681
                lda     #$18
                !by     $2C
LC810:
                lda     #$1C
                ldx     #$82
                jsr     LC681
                ldy     #$08
                lda     BEFCODE
                cmp     #$20
                beq     LC828
LC81F:          ldx     LC204-1,y
                lda     LC20C-1,y
                jsr     LC681
LC828:          dey
                bne     LC81F
                lda     ADRCODE
                bpl     LC830
                iny
LC830:          iny
LC831:          jsr     LC68A
                dec     $B7
                lda     $B7
                sta     $D3
                jmp     LC597

; --------- IO SET (I) --------------------------------------
IOSET:          jsr     GETBYT
                sta     IONO
                rts
LSERROR:        jmp     ERROR
; --------- LOAD/SAVE (L/S) ---------------------------------
LOADSAVE:       ldy     #$02
                sty     $BC
                dey
                sty     $B9
                sty     $BB
                dey
                sty     $B7
                jsr     GETCHRERR
                cmp     #$22                            ; ' " '
                bne     LSERROR
LSI:            jsr     GETCHRERR
                sta     ($BB),y
                iny
                inc     $B7
                cmp     #$22                            ; ' " '
                bne     LSI
                dec     $B7
                lda     IONO
                sta     $BA
                lda     COMMAND
                cmp     #$53
                beq     SAVE
LOAD_S:         jsr     GETRET                          ; check for return
                beq     LOAD1
                ldx     #$C3
                jsr     GETADR
                lda     #$00
                sta     $B9
LOAD1:          lda     #$00
                jmp     R_LDVEC
SAVE:           ldx     #$C1
                jsr     GETADR
                ldx     #$AE
                jsr     GETADR
                jmp     R_SVVEC
; --------- ADD/SUB (？) -------------------------------------
ADDSUB:         jsr     GETADR1
                jsr     GETCHRERR
                eor     #$02
                lsr
                lsr
                php
                jsr     GETADR
                jsr     RETURN                          ; next line
                plp
                bcs     LC8BA
                lda     $FD
                adc     PCL
                tax
                lda     $FE
                adc     PCH
LC8B7:          sec
                bcs     LC8C3
LC8BA:          lda     PCL
                sbc     $FD
                tax
                lda     PCH
                sbc     $FE
LC8C3:          tay
LC8C4:          txa
LC8C5:          sty     PCH
                sta     PCL
                sty     $62
                sta     $63
                php
                lda     #$00
                sta     $D3
                jsr     LC675
                lda     PCH
                bne     LC8E8
                jsr     SPACE2                          ; output 2 x space
                lda     PCL
                jsr     HEXOUT1                         ; output 2 digit hex address
                lda     PCL
                jsr     CHNGBIN
                beq     LC8EB
LC8E8:          jsr     HEXOUT                          ; output as 4 digit hex
LC8EB:          jsr     SPACE                           ; output space
                ldx     #$90
                lda     $01
                sta     MEM
                lda     #$37
                sta     $01
                plp
                jsr     FLOATC
                jsr     FLPSTR
                ldx     MEM
                stx     $01
                jmp     PRINT
; --------- CONVERT HEX ($) ---------------------------------
BEFHEX:         jsr     GETBYT
                tax
                ldy     $D3
                lda     ($D1),y
                eor     #$20
                beq     LC8B7
                txa
                tay
                jsr     GETBYT1
LC919:          sec
                bcs     LC8C5
; --------- CONVERT BINARY (%) ------------------------------
BEFBIN:         jsr     SKIPSPACE
                ldy     #$08
LC921:          pha
                jsr     GETCHRERR
                cmp     #$31
                pla
                rol
                dey
                bne     LC921
                beq     LC919
; --------- CONVERT DECIMAL (#) -----------------------------
BEFDEC:         jsr     SKIPSPACE
                ldx     #$00
                txa
LC934:          stx     PCL
                sta     PCH
                tay
                jsr     R_CHRIN
                cmp     #$3A
                bcs     LC8C4
                sbc     #$2F
                bcs     LC948
                sec
                jmp     LC8C4
LC948:          sta     $FD
                asl     PCL
                rol     PCH
                lda     PCH
                sta     $FE
                lda     PCL
                asl
                rol     $FE
                asl
                rol     $FE
                clc
                adc     PCL
                php
                clc
                adc     $FD
                tax
                lda     $FE
                adc     PCH
                plp
                adc     #$00
                jmp     LC934

; --------- BASICDATA (B) -----------------------------------
BASICDATA:      jsr     GET2ADR                         ; get 2 Addresses
                lda     #$37                            ; restore rom
                sta     $01
                ldx     #$04                            ; conter
LC975:          lda     DATATAB,x                       ; pointer to Basic line number and DATALOOP address
                sta     FLAG,x                          ; store it in $AA,x 
                dex
                bpl     LC975                           ; next
DATALOOP:       jsr     RETURN                          ; output return
                ldx     FLAG                            ; low byte basic address
                lda     ADRCODE                         ; high byte basic address
                jsr     INTOUT                          ; Output Positive Integer in A/X
                inc     FLAG                            ; increase low byte ; prepare next basic line address
                bne     LC98D                           ; check if need to increase high byte                               
                inc     ADRCODE                         ; increase high byte
LC98D:          lda     #$44                            ; "D"
                jsr     CHROUT                          ; output
                lda     #$C1                            ; "shifted A"
LC994:          jsr     CHROUT                          ; output
                ldy     #$00                            ; high byte = "00"
                lda     (PCL),y                         ; low byte load from memory
                sty     $62                             ; prepare for Output Positive Integer
                sta     $63
                jsr     INTOUT1                         ; Output Positive Integer with allready stored values
                jsr     CMPEND                          ; check for end
                ldx     #$03                            ; last basic line confirm with 2 tims CRSR UP and RETURN
                bcs     LC9B3                           ; branch if it was not last basic line
                lda     #$2C                            ; load ','
                ldx     $D3                             ; line length
                cpx     #$49                            ; compare with decimal '73' to avoid oversized basic lines
                bcc     LC994                           ; branch if space for more data in the line
                ldx     #$09                            ; amount for complete message to print on screen "CRSR UP, CRSR UP, RETURN, 'Sy172', Return"
LC9B3:          stx     $C6                             ; save x
LC9B5:          lda     SYS172-1,x                      ; coppy message
                sta     $0276,x                         ; into keybuffer
                dex                                     ; dec counter
                bne     LC9B5                           ; branch if not last
                jmp     EXIT                            ; execute in basic, either end and stay in basic, or execute SYS172

; --------- OCCUPY (O) --------------------------------------
OCCUPY:         jsr     GET2ADR
                jsr     GETBYT
_occupy:        ldx     #$00                            ; entrance from E-command
LC9C9:          sta     (PCL,x)
                pha
                jsr     CMPEND
                pla
                bcc     LC9C9
                rts
; --------- WRITE (W) ---------------------------------------
WRITE:          jsr     GET3ADR
_write:         lda     $A6                             ; entrance from Y-command
                bne     LC9DC
                dec     $A7
LC9DC:          dec     $A6
                jsr     LCA30
                stx     $B5
                ldy     #$02
                bcc     LC9EB
                ldx     #$02
                ldy     #$00
LC9EB:          clc
                lda     $A6
                adc     LOPER
                sta     FLAG
                lda     $A7
                adc     HOPER
                sta     ADRCODE
LC9F8:          lda     ($A4,x)
                sta     ($A8,x)
                eor     ($A8,x)
                ora     $B5
                sta     $B5
                lda     $A4
                cmp     $A6
                lda     $A5
                sbc     $A7
                bcs     LCA29
LCA0C:          clc
                lda     $A4,x
                adc     OFFSET,y
                sta     $A4,x
                lda     $A5,x
                adc     OFFSET+1,y
                sta     $A5,x
                txa
                clc
                adc     #$04
                tax
                cmp     #$07
                bcc     LCA0C
                sbc     #$08
                tax
                bcs     LC9F8
LCA29:          lda     $B5
                beq     LCA3C
                jmp     ERROR
LCA30:          sec
                ldx     #$FE
LCA33:          lda     FLAG,x
                sbc     $A6,x
                sta     $B0,x
                inx
                bne     LCA33
LCA3C:          rts
; --------- CONVERT (C) -------------------------------------
CONVERT:        jsr     LCA62
                jmp     _write
; --------- VERSCHIEB (V) -----------------------------------
VERSCHIEB:      jmp     LCA62
LCA46:          cmp     $A7
                bne     LCA4C
                cpx     $A6
LCA4C:          bcs     LCA61
                cmp     $A5
                bne     LCA54
                cpx     $A4
LCA54:          bcc     LCA61
                sta     $B4
                txa
                clc
                adc     LOPER
                tax
                lda     $B4
                adc     HOPER
LCA61:          rts
LCA62:          jsr     GET3ADR
                jsr     GET2ADR
_verschieb:     jsr     LCA30                             ; entrance from Y-command
LCA6B:          jsr     LC4CB
                iny
                lda     #$10
                bit     ADRCODE
                beq     LCA9B
                ldx     PCL
                lda     PCH
                jsr     LCA46
                stx     FLAG
                lda     (PCL),y
                sta     $B5
                jsr     LC54A
                ldy     #$01
                jsr     LCA46
                dex
                txa
                clc
                sbc     FLAG
                sta     (PCL),y
                eor     $B5
                bpl     LCAAE
                jsr     RETURN                          ; next line
                jsr     HEXOUT                          ; output as 4 digit hex
LCA9B:          bit     ADRCODE
                bpl     LCAAE
                lda     (PCL),y
                tax
                iny
                lda     (PCL),y
                jsr     LCA46
                sta     (PCL),y
                txa
                dey
                sta     (PCL),y
LCAAE:          jsr     LC66A
                jsr     CMPEND1
                bcc     LCA6B
                rts
; --------- KONTROLLE (K) -----------------------------------
KONTROLLE:      jsr     GET12ADR
LCABA:          ldx     #$27
                jsr     CHARRET
                jsr     HEXOUT                          ; output as 4 digit hex
                ldy     #$08
                ldx     #$00
                jsr     SPACE                           ; output space
LCAC9:          lda     (PCL,x)
                jsr     ASCII
                bne     LCAC9
                ldx     #$00
                jsr     CONTIN
                beq     LCADA
                jmp     LCABA
LCADA:          rts
; ???
TICK:           jsr     GETADR1
                ldy     #$03
LCAE0:
                jsr     R_CHRIN
                dey
                bne     LCAE0
LCAE6:          jsr     GETCHRERR
                cmp     #$2E
                beq     LCAEF
                sta     (PCL),y
LCAEF:          iny
                cpy     #$20
                bcc     LCAE6
                rts
; =
COMP:           jsr     GET2ADR
                ldx     #$00
LCAFA:          lda     (PCL,x)
                cmp     ($FD,x)
                bne     LCB0B
                jsr     PCINC
                inc     $FD
                bne     LCAFA
                inc     $FE
                bne     LCAFA
LCB0B:          jsr     SPACE                           ; output space
                jmp     HEXOUT                          ; output as 4 digit hex
; --------- FIND (F) ----------------------------------------
FIND:           lda     #$FF
                ldx     #$04
LCB15:          sta     $FA,x
                dex
                bne     LCB15
                jsr     GETCHRERR
                ldx     #$05
LCB1F:          cmp     FINDTAB-1,x
                beq     LCB69
                dex
                bne     LCB1F
LCB27:          stx     $A9
                jsr     LCBB4
                inx
                jsr     R_CHRIN
                cmp     #$20
                beq     LCB27
                cmp     #$2C
                bne     LCB3B
                jsr     GET2ADR
LCB3B:          jsr     RETURN                          ; next line
LCB3E:          ldy     $A9
LCB40:          lda     (PCL),y
                jsr     LCBD6
                bne     LCB5F
                dey
                bpl     LCB40
                jsr     HEXOUT                          ; output as 4 digit hex
                jsr     SPACE                           ; output space
                ldy     $D3
                cpy     #$24
                bcc     LCB5F
                jsr     PRINTER1
                jsr     TASTE1
                jsr     RETURN                          ; next line
LCB5F:          jsr     CMPEND
                bcc     LCB3E
                ldy     #$27
                jmp     PRINTER
LCB69:          lda     FINDFLG-1,x
                sta     $A8
                lda     FINDFLG1-1,x
                sta     $A9
                tax
                beq     LCB7C
LCB76:          jsr     LCBB4
                dex
                bne     LCB76
LCB7C:          jsr     GET2ADR
LCB7F:          jsr     LC4CB
                jsr     LC52C
                lda     $A8
                bit     ADRCODE
                bne     LCB94
                tay
                bne     LCBAF
                lda     BEFCODE
                bne     LCBAF
                beq     LCBA1
LCB94:          ldy     $A9
LCB96:          lda     BEFCODE,y
                jsr     LCBD6
                bne     LCBAF
                dey
                bne     LCB96
LCBA1:          sty     FLAG
                jsr     LC58C
                jsr     TASTE
LCBA9:          jsr     CMPEND1
                bcc     LCB7F
                rts
LCBAF:          jsr     LC66A
                beq     LCBA9
LCBB4:          jsr     LCBC0
                sta     BUF4,x
                lda     BUF1,x
                sta     BUF2,x
LCBC0:          jsr     GETCHRERR
                ldy     #$0F
                cmp     #$2A
                bne     LCBCB
                ldy     #$00
LCBCB:          jsr     ASCHEX1
                sta     BUF1,x
                tya
                sta     BUF3,x
                rts
LCBD6:          sta     $B4
                lsr
                lsr
                lsr
                lsr
                eor     BUF2,y
                and     BUF4,y
                and     #$0F
                bne     LCBF0
                lda     $B4
                eor     BUF1,y
                and     BUF3,y
                and     #$0F
LCBF0:          rts

; --------- NEW CODE FOR RAM/ROM ----------------------------
; --------------- (T) DCOM -- $CBF1 -------------------------
DCOM:
; check for disc command and execute
RCD32:          jsr     GETCHRERR                       ; get input
                cmp     #$20                            ; space
                beq     RCD32                           ; go get input
                cmp     #$22                            ; ' " '
                beq     RCD44                           ; execute disc command
RCD3D:          cmp     #$24                            ; "$"
                beq     RCD6D                           ; show directory
                cmp     #$40                            ; "@"
                beq     RCD12    

; else change memory location $01
                jsr     _GETBYT
                pha                                     ; save input
                jsr     SPACE2                          ; output 2 x space
                lda     $01                             ; load actual value from 01
                jsr     HEXOUT1                         ; output value as 2 digit hex
                pla                                     ; get input back
                sta     $01                             ; store in 01
                rts

; Disc status   ; P@
RCD12:          jsr     SWROM                           ; switch to ROM
                lda     #$0d                            ; return code
                jsr     CHROUT                          ; output
RCD18:          lda     IONO                            ; device no.
                sta     $BA
                jsr     TALK           
                lda     #$6f
                jsr     TKSA                            ; set secondary addres
RCD22:          jsr     IECIN
                jsr     CHROUT
                cmp     #$0d
                bne     RCD22
                jsr     UNTALK
                jsr     SHRAM                           ; switch 01 back
                rts

; Disc command  ; P"cmd"
RCD44:          jsr     SWROM                           ; switch on rom
                lda     $ba                             ; device no.
                jsr     LISTN                           ; LISTEN
                lda     #$6f                            ; secondary address
                jsr     SECND                           ; send to IEEE
                ldy     #$3a                            ; max bytes
RCD55:          jsr     CHRIN                           ; get next char from input
RCD58:          cmp     #$22                            ; ' " '
                beq     RCD62                           ; if yes branch end
                jsr     CIOUT                           ; else send byte out
                dey                                     ;
                bne     RCD55                           ; next char
RCD62:          jsr     UNLSN                           ; else send unlisten
                lda     #$0d                            ; return code
                jsr     CHROUT                          ; output
                jmp     RCD18                           ; close device

; show directory    ; P$
RCD6D:          jsr     SWROM                           ; switch on ROM
                lda     #$01                            ; file length
                ldx     #<RCD3D+1                       ; #$24 "$"
RCC4F:          ldy     #>RCD3D+1                       ; file name
                jsr     SETNAM
                ldx     IONO                            ; device no.
                ldy     #$00
                jsr     SETLFS                          ; set length and FN adr
                jsr     OPEN                            ; open
                bcc     RCD8C                           ; branch if ok
                jmp     RCDD4                           ; else close and end

RCD8C:          lda     $ba                             ; load device no.
                jsr     TALK                            ; send to IEEE
                lda     #$60                            ; load SA
                jsr     TKSA                            ; set secondary address
                jsr     IECIN
                jsr     IECIN
                lda     #$0d
                jsr     CHROUT
                jsr     IECIN
RCDA4:          jsr     IECIN
RCDA7:          jsr     IECIN
                tax
                jsr     IECIN
                jsr     INTOUT
                lda     #$20
                jsr     CHROUT
RCDB6:          jsr     STOP 
                beq     RCDD4
                jsr     IECIN
                beq     RCDC5
                jsr     CHROUT
                bne     RCDB6
RCDC5:          lda     #$0d
                jsr     CHROUT
                jsr     IECIN
                bne     RCDA4
                jsr     IECIN
                bne     RCDA7
RCDD4:          jsr     UNTALK
                lda     #$01
                jsr     CLOSE
                jsr     SHRAM
                rts
; --------- END DISC COMMANDS -------------------------------

; --------- switch on ROM -----------------------------------
SWROM:          php
                pha
                lda     $01
                sta     _01BUFF
                lda     #$37
                sta     $01
                pla
                plp
                cli
                rts
; --------- switch on RAM -----------------------------------
SHRAM:          sei
                php
                pha
                lda     _01BUFF
                sta     $01
                pla
                plp
                rts
; -----------------------------------------------------------
R_CHRIN:        jsr     SWROM:
                jsr     CHRIN
                jmp     SHRAM:
R_CHROUT:       jsr     SWROM:
                jsr     CHROUT
                jmp     SHRAM:
R_GETIN:        jsr     SWROM:
                jsr     GETIN
                jmp     SHRAM:
R_STOPT:        jsr     SWROM:
                jsr     STOP 
                jmp     SHRAM:
R_CLOSE:        jsr     SWROM:
                jmp     CLOSE
R_CLRCHN:       jsr     CLRCHN
                jmp     SHRAM:
; -----------------------------------------------------------
R_CONTIN:       bmi     _exit
                lda     $fb
                and     #$3f
                cmp     #$3f
                bne     _exit
                inc     $fb
                bne     _ret
                inc     $fc
_ret:           jsr     RETURN
_exit:          jmp     CONTIN    
 
; -----------------------------------------------------------
; --------- END OF NEW DISC COMMANDS ====--------------------
; -----------------------------------------------------------

; -----------------------------------------------------------
; --------- PLUS PART ONLY FROM LCE09 to END-----------------
; -----------------------------------------------------------

; --------- ZEICHENDATEN (Z) --------------------------------
; LCE09
ZCMD:           lda     #$80                            ; set Flag
                !by     $2c
; --------- ZEICHENDATEN EXT (H) -----------------------------
HCMD:           lda     #$00
                sta     ADRCODE
                jsr     GET12ADR                        ; start/end-address
L1:             bit     ADRCODE
                bpl     W8
                ldx     #HCZ                            ; hidden command
                !by     $2C
W8:             ldx     #HCH
                jsr     CHARRET
                jsr     HEXOUT                          ; print PC as 4 digit hex
                ldy     #$06                            ; column #6
L2:             ldx     #$00
                lda     (PCL,x)
L3:             asl
                pha                                     ; store byte
                bcs     BITSET                          ; BIT=1, then *
                lda     #$2E                            ; BIT=0, then .
                !by     $2c                             ; print out
BITSET:         lda     #$2A                            ; "*" 
                sta     ($D1),y
                lda     COLOR
                sta     ($F3),y
                pla                                     ; get byte back
                iny                                     ; push cursor
                inx                                     ; next byte
                cpx     #$08                            ; 8 Bit
                bne     L3                              ; further byte push
                jsr     PCINC                           ; increment counter
                cpy     #$1E
                lda     $AB
                bmi     W9                                
                bcc     L2
W9:
                jsr     R_CONTIN
                bcc     L1
                rts
;
ZCMDH:          ldy     #$08                            ; 1 Byte
                !by     $2C
HCMDH:
                ldy     #$18                            ; 3 Byte          
                jsr     GETADR1
                jsr     SKIPSPACE                       ; ignore space
A1:             ldx     #$08
                lda     #$00
                sta     FLAG
;
A2:             jsr     GETCHRERR
                cmp     #$2E                            ; . = BIT=0
                beq     BIT0
                cmp     #$2A                            ; * = BIT=1
                beq     BIT1
ERR1:           jmp     ERROR                           ; any other char
;
BIT0:           clc
BIT1:           rol     FLAG
                dey
                dex                                     ; Byte
                bne     A2                              ; not finished
                lda     FLAG
                sta     (PCL,x)                         ; write to
                cmp     (PCL,x)                         ; memory
                bne     ERR1
                jsr     PCINC
                cpy     #$00
                bne     A1                              ; not finished
LCE85:          rts
; --------- NORMALDARSTELLUNG (N) ---------------------------
NCMD:           lda     #$80
LCE88:          !by     $2c
; --------- UEBERSICHT (U) ----------------------------------
UCMD:           lda     #$00
                sta     ADRCODE
                jsr     GET12ADR
L5:             jsr     RETURN                          ; next line
                bit     ADRCODE
                bpl     U
                lda     #HCN                            ; hidden command
                jsr     R_CHROUT               
                jsr     HEXOUT                          ; output as 4 digit hex
                ldy     #$08                            ; column 8
                !by     $2c
U:              ldy     #$00   
                ldx     #$00
L4:             lda     (PCL,x)
                jsr     ASCII4                          ; as screen code
                bne     L4                              ; print
                jsr     R_CONTIN               
                bcc     L5                              ; next line
                rts
;
NCMDH:          jsr     GETADR1
                ldx     #$00
                ldy     #$08                            ; column 8
C1:             lda     ($D1),y
                sta     (PCL,x)                         ; write to
                cmp     (PCL,x)                         ; memory
                bne     ERR1
                jsr     ASCII5                          ; increment PC
                bcc     C1
                rts                                     ; line finish

; --------- new code for Save and Load ----------------------
R_SVVEC:        lda      #$36
                sta      $01
                lda      $0400
                sta      MEM
                lda      #$01
                ldx      $ba
                ldy      #$01
                jsr      SETLFS
                lda      $b7
                ldy      $bc
                ldx      $bb
                jsr      SETNAM
                jsr      OPEN
                ldx      #$01
                jsr      CHKOUT
                lda      $c1
                jsr      CHROUT
                lda      $c2
                jsr      CHROUT

Lcc1f:          sei
                lda      _01BUFF
                sta      $01
                ldy      #$00
                lda      ($c1),y
                sta      $0400
                lda      #$37
                sta      $01
                cli
                lda      $0400
                jsr      CHROUT
                inc      $c1
                lda      $c1
                cmp      #$00
                bne      Lcc3e
                inc      $c2

Lcc3e:          lda      $c1
                cmp      $ae
                bne      Lcc1f
                lda      $c2
                cmp      $af
                bne      Lcc1f
                jsr      CLRCHN
                lda      #$01
                jsr      CLOSE
                lda      _01BUFF
                sta      $01
                lda      MEM
                sta      $0400
                rts

R_LDVEC:        sta      MEM
                lda      #$36
                sta      $01
                lda      LOADVECT
                sta      Lcc73+1
                lda      LOADVECT+1
                sta      Lcc73+2
                lda      MEM
Lcc73:          jsr      $f4a5
                lda      _01BUFF
                sta      $01
                rts

R_GETSTART:     lda     #$36
                sta     $01
                jmp     GETSTART

; --------- end new code for Save and Load ------------------

!ifndef RAM1 {
; --------- KOPIERT SMON (Y) --------------------------------
CPSMON:         jsr     GETBYT
                and     #$F0                            ; get high-nibble
                sta     $FF                             ; store as new 4-k address
; --------- W - COMMAND ------------------------
                jsr     SETPTR
                jsr     _write                          ; jump into W-command
; --------- V - COMMAND ------------------------
                jsr     SETPTR                          ; prepare for V-command the start and end main address of new location
                lda     #<NEWCMDS                       ; end address low byte
                sta     $FD
                lda     #>NEWCMDS                       ; end address high byte
                jsr     and_or                          ; separate and ora with new address high-byte   
                sta     $FE
                lda     #<BREAK                         ; define start for V-command
                sta     PCL
                lda     #>BREAK
                jsr     and_or                          ; separate and ora with new address high-byte
                jsr     _verschieb                      ; jump into V-command
; --------- adjust main command table ----------
                lda     #<CMDS                          ; command table start low byte
                sta     $FB
                lda     #>CMDS                          ; high byte
                jsr     and_or                          ; separate and ora with new address high-byte
                ldy     #$33
D3:             jsr     cp                              ; load, change and store the bytes for the new addresses
                dey                                     ; decrease counter
                dey                                     ; decrease counter
                bpl     D3
; --------- adjust plus command table ----------
                lda     #<NEWADR                        ; plus-command table start low byte
                sta     $FB
                lda     #>NEWADR                        ; high byte
                jsr     and_or                          ; separate and ora with new address high-byte
                ldy     #$15
D2:             jsr     cp                              ; load, change and store the bytes for the new addresses
                dey                                     ; decrease counter
                dey                                     ; decrease counter
                bpl     D2
; --------- adjust other addresses -------------
                ldy     #$00
                ldx     #$07
D1:             lda     OFSTAB,x
                jsr     and_or                          ; separate and ora with new address high-byte
                dex
                lda     OFSTAB,x
                sta     $FB
                jsr     cp                              ; load, change and store the bytes for the new addresses
                dex
                bpl     D1
                rts
; prepare new address high byte
and_or:         and     #$0F                            ; separate high byte
                ora     $ff                             ; ora with high byte from new address
                sta     $fc                             ; store back as new high byte
                rts
; load, change and store the bytes for the new addresses
cp:             lda     ($fb),y                         ; load high byte from address
                and     #$0F                            ; separate high byte
                ora     $FF                             ; ora with high byte from new address
                sta     ($fb),y                         ; store back as new address high byte
                rts

;
SETPTR:         lda     $FF                             ; contains the high byte of the new address
                sta     $A9
                jsr     GETHI
GETHI:          pla                                     ; 2 times pla
                pla                                     ; the accu contains now the own address high byte
                and     #$F0                            ; separate the high nibble
                sta     $A5                             ; store it as start address high byte
                clc
                adc     #$10                            ; define end address high byte    
                sta     $A7                             ; store it
                lda     #$00                            ; low byte
                sta     $A4                             ; store as start address low byte
                sta     $A6                             ; store as end adress low byte
                sta     $A8                             ; store as new address low byte
LCF56:          rts
}
; --------- ERASE (E) ---------------------------------------
ERASE:          jsr     GET2ADR
                lda     #$00                            ; set defined value
                jmp     _occupy                         ; jump to O-ccupy

; --------- KOPIERE ZICHENSATZ (Q) --------------------------
CPCHR:          jsr     GETADR1
                ldy     #$00
                lda     #$D0                            ; pointer to char rom
                sty     $FD
                sta     $FE
                sei
                lda     #$03                            ; char rom enable
                sta     $01
                ldx     #$10                            ; 4-k counter
E1:             lda     ($FD),y
                sta     (PCL),y
                iny
                bne     E1
                inc     PCH
                inc     $FE
                dex
                bne     E1
                lda     #$27                            ; normal state
                sta     $01
                cli
                rts
; --------- print last command on screen (J) ----------------
LINSTORE:       pha                                     ; remember command
                cmp     #$4A                            ; "J"
                bne     STORE                           ; check other commands
                ldy     #$27                            ; char amount
G1:             lda     $0200,y                         ; get char from buffer
                sta     ($D1),y                         ; print line on screen
                dey                                     ; next
                bpl     G1                              ; not last
                pla                                     ; get last command back
                dec     $D6                             ; Cursor up
                jmp     EXECUTE                         ; go back, wait for next input
; --------- check for more PLUS commands --------------------
STORE:          ldy     #$06                            ; amount of commands
G3:             cmp     OUTCMDS,y                       ; check for "()!EYQ"
                bne     W3
                ldy     #$27
G2:             lda     ($D1),y
                sta     $0200,y
                dey
                bpl     G2
W3:             dey
                bpl     G3
                pla                                     ; get command back
                jmp     CMDSTORE                        ; store and compare command
; --------- execute PLUS COMMANDS ??? ------------------------
MORECMD:        ldx     #$0A
B1:             cmp     NEWCMDS-1,x
                beq     FOUND
                dex
                bne     B1
                jmp     ERROR
FOUND:          jsr     CMDEXEC2
                jmp     EXECUTE                         ; go back, wait for next input
CMDEXEC2:       txa
                asl
                tax
                lda     NEWADR-1,x
                pha
                lda     NEWADR-2,x
                pha
                rts 
; --------- PLUS COMMANDS -----------------------------------
NEWCMDS:        !by     $28,$29,$21,$45,$59,$51         ; "()!EYQ"
OUTCMDS:        !by     $48,$5A,$4E,$55,$44,$4B,$4D     ; "HZNUDKM"

NEWADR:         !by     <HCMDH-1
                !by     >HCMDH-1
                !by     <ZCMDH-1
                !by     >ZCMDH-1
                !by     <NCMDH-1
                !by     >NCMDH-1
                !by     <ERASE-1
                !by     >ERASE-1
!ifdef RAM1 {
                !by     <REGISTER-1                     ; R 17
                !by     >REGISTER-1
} else {
                !by     <CPSMON-1
                !by     >CPSMON-1    
}
                !by     <CPCHR-1
                !by     >CPCHR-1
                !by     <HCMD-1
                !by     >HCMD-1
                !by     <ZCMD-1
                !by     >ZCMD-1
                !by     <NCMD-1
                !by     >NCMD-1
                !by     <UCMD-1
                !by     >UCMD-1

;!ifndef RAM {
; this belongs to the CPSMON (Y) Function
!ifndef RAM1 {
OFSTAB:         !by     <_brk_hb+1
                !by     >_brk_hb+1
                !by     <REGISTER+1
                !by     >REGISTER+1
                !by     <RCC4F+1
                !by     >RCC4F+1

; this belongs to the "B" command
                !by     <BASJMP
                !by     >BASJMP
}

; -----------------------------------------------------------
; --------- ILLEGAL OPCODES PART ----------------------------
; -----------------------------------------------------------
!ifdef ILOC {
ILLEGAL:
; 6510 ilops
LCE09:          !by     $2b,$4b,$6b,$8b,$9b,$ab,$bb,$cb
                !by     $eb,$89,$93,$9f,$0b,$9c,$9e
   
; ilops char
LCE18:          !by     $4e,$53,$52,$53,$52,$53,$4c,$44,$49,$43 ; N S R S R S L D I C   ; N

LCE22:          !by     $4f,$4c,$4c,$52,$52,$41,$41,$43,$53,$52 ; O L L R R A A C S R   ; O

LCE2C:          !by     $50,$4f,$41,$45,$41,$58,$58,$50,$43,$41 ; P O A E A X X P C A   ; P

LCE36:          !by     $25,$26,$20,$21,$82,$80,$81
                !by     $22,$21,$82
LCE40:          !by     $81,$03,$13,$07,$17,$1b,$0f,$1f
                !by     $97,$d7,$bf
LCE4B:          !by     $df,$02,$02,$02,$02,$03,$03,$03
                !by     $02,$02,$03,$03

LCE57:          ldx     #$02
                bne     LCE83
_ILOCM:         ldx     BEFCODE
                bne     LCE8A
                ldx     #$01
                lda     (PCL),y
                cmp     #$9c
                beq     LCE9F
                cmp     #$80
                beq     LCE57
                cmp     #$89
                beq     LCE57
                and     #$0f 
                cmp     #$02
                beq     LCE8B
                cmp     #$0a
                beq     LCE83
                inx
                cmp     #$04
                beq     LCE83
                inx
                cmp     #$0c
                bne     LCE9F
LCE83:          stx     BEFLEN
                ldx     #$01
                stx     $02c5
LCE8A:          rts
LCE8B:          lda     (PCL),y
                and     #$90
                eor     #$80
                bne     LCE97
                ldx     #$02
                bne     LCE83
LCE97:          stx     BEFLEN
                ldx     #$0a
                stx     $02c5
                rts
LCE9F:          ldy     #$02
                sty     BEFLEN
                ldy     #$00
                sty     $02c5
                lda     (PCL),y
                ldx     #$0f
LCEAC:          cmp     ILLEGAL,x
                beq     LCE8A
                dex
                bne     LCEAC
                and     #$01
                beq     LCE8A
                lda     (PCL),y
                lsr
                lsr
                lsr
                lsr
                lsr
                clc
                adc     #$02
                sta     $02c5
                ldx     #$0b
ICEC7:          lda     (PCL),y
                and     LCE40,x
                cmp     LCE40,x
                beq     LCED4
                dex
                bne     ICEC7
LCED4:          lda     LCE36-1,x
                sta     ADRCODE
                lda     LCE4B,x
                sta     BEFLEN
                rts
_ILOCD:         ldy     #$00
                ldx     BEFCODE
                beq     ICEEB
                jsr     SPACE                           ; output space
                jmp     LC5DA
ICEEB:          ldx     $02c5
                bne     LCEF6
                jsr     SPACE                           ; output space
                jmp     LC5C9
LCEF6:          lda     #$2a
                jsr     R_CHROUT
                lda     LCE18-1,x
                jsr     R_CHROUT
                lda     LCE22-1,x
                jsr     R_CHROUT          
                lda     LCE2C-1,x
                jmp     LC616

}
; -----------------------------------------------------------
; --------- END ILLEGAL OPCODES PART ------------------------
; -----------------------------------------------------------