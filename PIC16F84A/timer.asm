list      p=16F84A            ; list directive to define processor
	#include <p16F84A.inc>        ; processor specific variable definitions

	__CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.




;***** VARIABLE DEFINITIONS
w_temp        EQU     0x0C        ; variable used for context saving 
status_temp   EQU     0x0D        ; variable used for context saving

CBLOCK 0x0E
DEL
DEL1
DEL2
DEL3
DEL4
CNT
CNT1
CNT2
CNT3
NUM_TEMP
TENS
UNITS
ENDC

;**********************************************************************
		ORG     0x000             ; processor reset vector
  		goto    main              ; go to beginning of program


		ORG     0x004             ; interrupt vector location
		movwf   w_temp            ; save off current W register contents
		movf	STATUS,w          ; move status register into W register
		movwf	status_temp       ; save off contents of STATUS register
		
		
; isr code can go here or be located as a call subroutine elsewhere
; No need to disable GIE and TIE because the interrupt occurs in 2ms.
; there is more than enough time to service the ISR before another interrupt	

		MOVLW .6			  ;reload timer0 6 to get a 2ms delay 
		MOVWF TMR0
		INCF CNT1
		MOVF CNT1,W
		SUBLW .250
		BTFSS STATUS,Z
		GOTO ISR1
		MOVLW .1	;Reset CNT1 to initial value 1
		MOVWF CNT1
		INCF CNT2	; when CNT1 is equal to 255 increase CNT2
		BTFSS CNT2,1	; check to see if CNT2 has the value of 2 (when it is 2 then 500cnts have elapsed)
		GOTO ISR1
		CLRF CNT2	;clear CNT2 to zero
		INCF CNT3
		MOVF CNT3,W	;
		SUBLW .10	;
		BTFSC STATUS,Z	;check if value has reached 10. note bit z will be 1 if this is true
		CLRF CNT3	;when cnt3 is cleared then TENS register will increase
		BTFSC STATUS,Z	;check the z bit again. it will be 1 if CNT3 was cleared otherwise skip
		INCF TENS					;not correct check later
		CLRF TENS
		
ISR1	BCF INTCON,T0IF  ;clear timer0 interrupt flag	
	
		
		movf    status_temp,w     ; retrieve copy of STATUS register
		movwf	STATUS            ; restore pre-isr STATUS register contents
		swapf   w_temp,f
		swapf   w_temp,w          ; restore pre-isr W register contents
		retfie                    ; return from interrupt

			
;***********************************************************************************************
;Initialize Microcontoller
;Configure PORTA and PORTB as outputs
;Use Timer0 interrupt. configure with prescaler of 1:8, load timer with 6 to give 2ms interrrupt
;Enable Global interrupt
;***********************************************************************************************

main
			CLRF CNT2
			CLRF CNT3
			MOVLW 0x01 ;initialize cnt1 to one this variable is used for timing logic in interrupt
			MOVWF CNT1
			BCF STATUS,RP0
			MOVLW .6		;initialize timer0 with 6 to get a 2ms delay 
			MOVWF TMR0		;after overflow. note prescaler is 1:8
			BSF STATUS,RP0	; goto bank1
			MOVLW 0x00		;configure PORTA and PORTB as outputs
			MOVWF TRISB		;
			MOVWF TRISA		;
			
			MOVLW 0xA0		; Enable Global interrrupt and 
			MOVWF INTCON	; timer0 interrrupt
			MOVF   OPTION_REG,W
			ANDLW  0xC0		;Disable PORTB pullups and Configure timer0 clock source as internal
			IORLW  0x02		;Assign prescaler to timer0 and set prescaler to 1:8
			MOVWF  OPTION_REG
			BCF STATUS,RP0		;goto bank0
			CLRF PORTA

RUN	        							
			MOVF CNT3,W
			;MOVF UNITS,W
			CALL DISPLAY
			MOVWF PORTB
			BSF PORTA,3
			CALL ShortDelay
			BCF PORTA,3
			MOVF TENS,W
			CALL DISPLAY
			MOVWF PORTB
			BSF PORTA,2
			CALL ShortDelay
			BCF PORTA,2
					
			GOTO RUN


ShortDelay
		
		MOVLW .2
		MOVWF DEL3
		MOVWF .0
		MOVWF DEL4
		DECFSZ DEL4,F
		GOTO $-1
		DECFSZ DEL3,F
		GOTO $-5
		RETURN		

	


DISPLAY 
		ADDWF PCL,F
		RETLW 0xC0
		RETLW 0xF9
		RETLW 0xA4
		RETLW 0xB0
		RETLW 0x99
		RETLW 0x92
		RETLW 0x82
		RETLW 0xF8
		RETLW 0x80
		RETLW 0x90


		END                     ; directive 'end of program'
