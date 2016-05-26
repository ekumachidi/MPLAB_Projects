;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F84A. This file contains the basic code               *
;   building blocks to build upon.                                    *  
;                                                                     *
;   If interrupts are not used all code presented between the ORG     *
;   0x004 directive and the label main can be removed. In addition    *
;   the variable assignments for 'w_temp' and 'status_temp' can       *
;   be removed.                                                       *                        
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional            *
;   information on the instruction set.                               *
;                                                                     *
;   Template file assembled with MPLAB V4.00.00 and MPASM V2.20.12.   *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    xxx.asm                                           *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files required:                                                  *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************


	list      p=16F84A            ; list directive to define processor
	#include <p16F84A.inc>        ; processor specific variable definitions

	__CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.




;***** VARIABLE DEFINITIONS
w_temp        EQU     0x0C        ; variable used for context saving 
status_temp   EQU     0x0D        ; variable used for context saving








;**********************************************************************
		ORG     0x000             ; processor reset vector
  		goto    main              ; go to beginning of program


		ORG     0x004             ; interrupt vector location
		movwf   w_temp            ; save off current W register contents
		movf	STATUS,w          ; move status register into W register
		movwf	status_temp       ; save off contents of STATUS register


; isr code can go here or be located as a call subroutine elsewhere


		movf    status_temp,w     ; retrieve copy of STATUS register
		movwf	STATUS            ; restore pre-isr STATUS register contents
		swapf   w_temp,f
		swapf   w_temp,w          ; restore pre-isr W register contents
		retfie                    ; return from interrupt



main
		CLRF PORTA
		MOVLW b'11111100'
		MOVWF TRISA
		BCF STATUS,RP0
		
main1	
	    CLRF PORTA						;00
		MOVLW B'11000000'
		MOVWF PORTB
		BSF PORTA,0
		BCF PORTA,0
		MOVLW B'11000000'
		MOVWF PORTB
		BSF PORTA,1
		BCF PORTA,1
		incfsz 20h
		
		MOVLW B'01000000' ;0
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'01111001' ;1
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
	    MOVLW B'00100100' ;2
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00110000' ;3
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00011001' ;4
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00010010' ;5
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00000010' ;6
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'01111000' ;7
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00000000' ;8 
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00010000' ;9
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'11111111' ; down
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00010000' ;9
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00000000' ;8 
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'01111000' ;7
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00000010' ;6
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00010010' ;5
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00011001' ;4
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00110000' ;3
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'00100100' ;2
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'01111001' ;1
		MOVWF PORTB
		CALL Delay
		CALL mydelay1
		MOVLW B'01000000' ;0
		MOVWF PORTB
		CALL Delay
		CALL mydelay1	
		GOTO main1
		;BSF PORTB,0	; bank 1
		;call Delay
		;BCF PORTB,0	; bank 0	
		;call Delay
		;GOTO main1
		;MOVLW B'11111000';3
    	;MOVWF PORTB
		;GOTO main1


Delay
	movlw .03
	movwf 20h

mydelay1	movlw .10
			movwf 21h
mydelay2	movlw .255
			movwf 22h
dec1	decfsz 22h,F
		goto dec1
		decfsz 21h
		goto mydelay2
		decfsz 20h
		goto mydelay1
		return


; remaining code goes here

LED_Table  	ADDWF   PCL       , f
            	RETLW   b'10001000'		;0
            	RETLW   b'10111011'		;1
            	RETLW   b'11000001'		;2
            	RETLW   b'10010001'		;3
            	RETLW   b'10110010'		;4
            	RETLW   b'10010100'		;5
            	RETLW   b'10000100'		;6
            	RETLW   b'10111001'		;7
            	RETLW   b'10000000'		;8
            	RETLW   b'10110000'		;9
            	RETLW   b'11111111'		;blank
            	RETLW   b'11111111'		;blank
            	RETLW   b'11111111'		;blank
            	RETLW   b'11111111'		;blank
            	RETLW   b'11111111'		;blank
            	RETLW   b'11111111'		;blank








		END                     ; directive 'end of program'

