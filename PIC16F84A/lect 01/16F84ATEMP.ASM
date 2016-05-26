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


;		ORG     0x004             ; interrupt vector location
;		movwf   w_temp            ; save off current W register contents
;		movf	STATUS,w          ; move status register into W register
;		movwf	status_temp       ; save off contents of STATUS register
;
;
;; isr code can go here or be located as a call subroutine elsewhere
;
;
;		movf    status_temp,w     ; retrieve copy of STATUS register
;		movwf	STATUS            ; restore pre-isr STATUS register contents
;		swapf   w_temp,f
;		swapf   w_temp,w          ; restore pre-isr W register contents
;		retfie                    ; return from interrupt



main
		
		BSF STATUS,5	; bank 1
		CLRF TRISB		; setting the pins to be output
		BCF STATUS,5	; bank 0	
		
		;CLRF PORTB
		MOVLW b'10101010'
		MOVWF PORTB
		
		CLRF 14H
		CLRF 12h
lbl		InCFSZ	12h,f	
		goto lbl
		


; remaining code goes here










		END                     ; directive 'end of program'

