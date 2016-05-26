;Tutorial 10.1 - Nigel Goodwin 2005
;7 segment LED display - count up from zero

	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F84.inc"		;include the defaults for the chip
	ERRORLEVEL	0,	-302	;suppress bank selection messages
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)




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
			ones			;ones storage
		endc

SEG_PORT	Equ	PORTB			;7 segment port
SEG_TRIS	Equ	TRISB


		org	0x0000
		goto	Initialise

;**************************************************************************	
;			     	Interrupt routine
;**************************************************************************



; 	Interrupt routine handles TMR2 which generates a 1ms tick

;	Interrupt vector

	ORG	0x0004


INT
		movwf	w_temp		; Save W register
		swapf	STATUS,W	; Swap status to be saved into W
		movwf	s_temp		; Save STATUS register
		movfw	PCLATH
		movwf	p_temp		; Save PCLATH 
	
		btfss	PIR1,TMR2IF	; Flag set if TMR2 interrupt
		goto	INTX		; Jump if not timed out

		; Timer (TMR2) timeout every 1 milli second
	

		bcf	PIR1,TMR2IF	; Clear the calling flag


		btfss	SEG_PORT, 7	;check which LED was last
		goto	Do_tens
		movfw	ones
		andlw	0x0F		;make sure in range of table
		call	LED_Table
		andlw	0x7F		;set to correct LED
		movwf	SEG_PORT
		goto	INTX

Do_tens		movfw	tens
		andlw	0x0F		;make sure in range of table
		call	LED_Table
		iorlw	0x80		;set to correct LED
		movwf	SEG_PORT



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
		movwf	CMCON			;turn comparators off (make it like a 16F84)
		bsf 	STATUS,		RP0	;select bank 1
		movlw	b'00000000'		;Set port data directions, data output
		movwf	SEG_TRIS
		bcf 	STATUS,		RP0	;select bank 0
	

		;	Set up Timer 2.
	
		;movlw	b'01111110'		; Post scale /16, pre scale /16, TMR2 ON
		;uncomment previous line, and comment next line, to slow multiplexing speed
		;so you can see the multiplexing happening
		movlw	b'00010110'		; Post scale /4, pre scale /16, TMR2 ON
		movwf	T2CON

		bsf 	STATUS,		RP0	;select bank 1

		movlw	.249			; Set up comparator
		movwf	PR2

		bsf	PIE1,TMR2IE		; Enable TMR2 interrupt

		bcf 	STATUS,		RP0	;select bank 0

		; Global interrupt enable

		bsf	INTCON,PEIE		; Enable all peripheral interrupts
		bsf	INTCON,GIE		; Global interrupt enable

		bcf 	STATUS,		RP0	;select bank 0
	
		clrf	tens
		clrf	ones

	

Main
		call	Delay255
		call	Delay255
		call	Delay255
		call	Delay255
		incf	ones,	f
		movf	ones, 	w		;test first digit
		sublw	0x0A
		btfss	STATUS, Z
		goto	Main
		clrf	ones
		incf	tens,	f
		movf	tens, 	w		;test second digit
		sublw	0x0A
		btfss	STATUS, Z
		goto	Main
		clrf	tens
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
