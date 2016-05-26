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
;w_temp        EQU     0x0C        ; variable used for context saving 
;status_temp   EQU     0x0D        ; variable used for context saving



cblock	0x20			;start of general purpose registers
			count			;used in looping routines
			count1			;used in delay routine
			counta			;used in delay routine
			countb			;used in delay routine
			tmp1			;temporary storage
			tmp2
			p_temp			;save register
			s_temp			;save register
			w_temp			;save register
			tens			;tens storage
			units			;units storage
			hundreds		;hundreds storage
		endc




;**********************************************************************
		ORG     0x000             ; processor reset vector
  		goto    Initialise              ; go to beginning of program


		ORG     0x004             ; interrupt vector location
		;movwf   w_temp            ; save off current W register contents
	;	movf	STATUS,w          ; move status register into W register
	;	movwf	status_temp       ; save off contents of STATUS register

INT
		movwf	w_temp		; Save W register
		swapf	STATUS,W	; Swap status to be saved into W
		movwf	s_temp		; Save STATUS register
		movfw	PCLATH
		movwf	p_temp		; Save PCLATH 
	
		btfss	INTCON,INTF	; Flag set if TMR0 interrupt
		goto	INTX		; Jump if not timed out
		
		bcf	INTCON,INTF	; Clear the calling flag

		btfss	PORTB, 7	;check which LED was last
		goto	Do_tens
		movfw	units
		andlw	0x0F		;make sure in range of table
		call	LED_Table
		andlw	0x7F		;set to correct LED
		movwf	PORTB
		goto	INTX
Do_hundreds	movfw	hundreds
			andlw	0x1F
			call	LED_Table
			iorlw	0x80
			movwf	PORTB

Do_tens	movfw	tens
		andlw	0x0F		;make sure in range of table
		call	LED_Table
		iorlw	0x80		;set to correct LED
		movwf	PORTB


INTX
		movfw	p_temp
		movwf	PCLATH		; Restore PCLATH
		swapf	s_temp,W
		movwf	STATUS		; Restore STATUS register - restores bank
		swapf	w_temp,F
		swapf	w_temp,W	; Restore W register
		retfie

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


Initialise	movlw	0x07			
			bsf 	STATUS,		RP0	;select bank 1
			movlw	b'00000000'		;Set port data directions, data output
			movwf	TRISB
			bcf 	STATUS,		RP0	;select bank 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		movlw	b'00010110'		; Post scale /4, pre scale /16, TMR0 ON
		movwf	INTCON

		bsf 	STATUS,		RP0	;select bank 1

		movlw	.255			; Set up comparator
		movwf	INTCON

		bsf	INTCON,INTF		; Enable TMR2 interrupt

		bcf 	STATUS,		RP0	;select bank 0

		; Global interrupt enable

		bsf	INTCON,INTF		; Enable all peripheral interrupts
		bsf	INTCON,GIE		; Global interrupt enable

		bcf 	STATUS,		RP0	;select bank 0
	
		clrf	hundreds
		clrf	tens
		clrf	units
; isr code can go here or be located as a call subroutine elsewhere


	;	movf    status_temp,w     ; retrieve copy of STATUS register
	;;	movwf	STATUS            ; restore pre-isr STATUS register contents
	;	swapf   w_temp,f
	;;	swapf   w_temp,w          ; restore pre-isr W register contents
	;	retfie                    ; return from interrupt



Main
		call	Delay255
		call	Delay255
		call	Delay255
		call	Delay255
		incf	units,	f
		movf	units, 	w		;test first digit
		sublw	0x0A
		btfss	STATUS, Z
		goto	Main
		clrf	units
		incf	tens,	f
		movf	tens, 	w		;test second digit
		sublw	0x0A
		btfss	STATUS, Z
		goto	Main
		clrf	units
		clrf	tens
		incf	hundreds,	f
		movf	hundreds, 	w		;test third digit
		clrf	hundreds
		goto	Main			;loop for ever


Delay255	movlw	0xff			;delay 255 mS
			goto	d0
Delay100	movlw	d'100'			;delay 100mS
			goto	d0
Delay50		movlw	d'50'			;delay 50mS
			goto	d0
Delay20		movlw	d'20'			;delay 20mS
			goto	d0
Delay5		movlw	0x05			;delay 5.000 ms (4 MHz clock)
d0		movwf	count1
d1		movlw	0xC7			;delay 1mS
		movwf	counta
		movlw	0x01
		movwf	countb
Delay_0
		decfsz	counta, f
		goto	$+2
		decfsz	countb, f
		goto	Delay_0

		decfsz	count1	,f
		goto	d1
		retlw	0x00

	END