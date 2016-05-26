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

cblock	0x0E			;start of general purpose registers
			DEL			;used in looping routines
			DEL1		;used in delay routine
			DEL2			;used in delay routine
			DEL3			;used in delay routine
			DEL4			;temporary storage
			CNT
			CNT1			;save register
			CNT2			;save register
			CNT3			;save register
			NUM_TEMP			;tens storage
			TENS			;units storage
			UNITS		;hundreds storage
		endc
;**********************************************************************
		ORG     0x000             ; processor reset vector
  		goto    main              ; go to beginning of program


		ORG     0x004             ; interrupt vector location
		movwf   w_temp            ; save off current W register contents
		movf	STATUS,w          ; move status register into W register
		movwf	status_temp       ; save off contents of STATUS register


; isr code can go here or be located as a call subroutine elsewhere
		MOVLW	.6
DELAY	movwf	TMR0
		INCF	CNT1
		MOVF	CNT1,W
		SUBLW	.250
		BTFSS	STATUS,Z
		GOTO	ISR1
		MOVLW	.1
		MOVWF	CNT1
		INCF	CNT2
		BTFSS	CNT2,1
		GOTO	ISR1
		CLRF	CNT2
		INCF	CNT3
		MOVF	CNT3,W
		SUBLW	.10
		BTFSS	STATUS,Z
		CLRF	CNT3
		BTFSC	STATUS,Z
		CLRF	CNT3
		BTFSC	STATUS,Z
		INCF	TENS

ISR1	BCF	INTCON,T0IF

		movf    status_temp,w     ; retrieve copy of STATUS register
		movwf	STATUS            ; restore pre-isr STATUS register contents
		swapf   w_temp,f
		swapf   w_temp,w          ; restore pre-isr W register contents
		retfie                    ; return from interrupt


main
		CLRF	CNT2
		CLRF	CNT3
		MOVLW	0X01
		MOVWF	CNT1
		BCF		STATUS, RP0
		MOVLW	.6
		MOVWF	TMR0
		BSF		STATUS, RP0
		MOVLW	0x00
		MOVWF	TRISB
		MOVWF	TRISA
		MOVLW	0xA0
		MOVWF	INTCON
		MOVF	OPTION_REG,W
		ANDLW	0xC0
		IORLW	0x02
		MOVWF	OPTION_REG
		BCF		STATUS, RP0
		CLRF	PORTA

RUN
		MOVF	CNT3,W
		CALL	DISPLAY
		MOVWF	PORTB
		BSF		PORTA,3
		CALL	SHORTDELAY
		BCF		PORTA,3
		MOVF	TENS,W
		CALL	DISPLAY
		MOVWF	PORTB
		BSF		PORTA,2
		CALL	SHORTDELAY
		BCF		PORTA,2
		GOTO	RUN

SHORTDELAY
		MOVLW	.2
		MOVWF	DEL3
		MOVWF	.0
		MOVWF	DEL4
		DECFSZ	DEL4,F
		GOTO	$-1
		DECFSZ	DEL3,F
		GOTO	$-5
		RETURN

DISPLAY
			ADDWF   PCL       , F
           	RETLW   0XC0		;0
           	RETLW   0XF9		;1
           	RETLW   0XA4		;2
           	RETLW   0XB0		;3
           	RETLW   0X99		;4
           	RETLW   0X92		;5
           	RETLW   0X82		;6
           	RETLW   0XF8		;7
           	RETLW   0X80		;8
           	RETLW   0X90		;9

		END                     ; directive 'end of program'

