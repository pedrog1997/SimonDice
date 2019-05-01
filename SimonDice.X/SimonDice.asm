    RADIX DEC
    PROCESSOR 18F45K50
    #INCLUDE <P18F45K50.INC> 
    
    ; Variable definition
puntaje EQU 0x00
indice EQU 0x01
LCDConfig EQU 0x02
LCDData EQU 0x03
    
    ; Code for software simulation
    org 0x00	    ; Reset vector 
    goto 0X1000 
 
    org 0X08	    ; High Interrupt Vector 
    goto 0X1008 
 
    org 0X18	    ; Low Interrupt Vector 
    goto 0X1018 
    ; End of code for software simulation
    
    org 0X1000	    ; Reset Vector 
    goto main
    org 0X1008	    ; High Interrupt Vector 
    ;goto isrHigh   
    org 0X1018	    ; Low Interrupt Vector 
    ;goto isrLow

main:
    movlb 15
    clrf ANSELA, BANKED
    clrf TRISA, A
    clrf LATA, A
    
    clrf ANSELB, BANKED
    bcf INTCON2, 7, A	    ; Enable global pull-up
    movlw b'00001111'
    movwf TRISB, A
    movwf WPUB, A
    setf LATB, A
    
    clrf ANSELC, BANKED
    clrf TRISC, A
    clrf LATC, A
    
    clrf ANSELD, BANKED
    clrf TRISD, A
    clrf LATD, A
    
    call waitLCD
    
    clrf LCDConfig			    
    movlw b'00111000'		    ; Function set for LCD
    movwf LCDData
    call sendLCD
    
    movlw b'00000110'		    ; Entry mode
    movwf LCDData
    call sendLCD
    
    movlw b'00001111'		    ; Display on
    movwf LCDData
    call sendLCD
    
    movlw b'00000001'		    ; Clear display
    movwf LCDData
    call sendLCD
    
    
loop:
    call loadEEPROM
    ;call configT2
    call menuLCD
here goto here
    
loadEEPROM:
    movlw 0
    movwf EEADR, A	    ; 0x00 Primera secuencia
    movlw 8
    movwf EEDATA, A
    movlw b'00000100'
    movwf EECON1, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x01
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x02
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x03
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x04
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x05
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x06
    movlw 8
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x07
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x08
    movlw 8
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x09
    movlw 1
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x0A Segunda secuencia
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x0B
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x0C
    movlw 8
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x0D
    movlw 1
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x0E
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x0F
    movlw 1
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x10
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x11
    movlw 1
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x12
    movlw 8
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A	    ; 0x13
    movlw 4
    movwf EEDATA, A
    call writeToEE
    	
    bcf EECON1, WREN, A
    return
    
writeToEE:
    movlw 0x55
    movwf EECON2, A
    movlw 0x0AA
    movwf EECON2, A
    bsf EECON1, WR, A
    call waitWrite
    return
    
waitWrite:
    btfsc EECON1, WR, A
	goto waitWrite
    return

    
menuLCD:
    clrf LCDConfig, A		; Clear display
    movlw 1
    movwf LCDData, A
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig, A
    movlw a'J'
    movwf LCDData, A
    call sendLCD
    
    movlw a'u'
    movwf LCDData, A
    call sendLCD
    
    movlw a'g'
    movwf LCDData, A
    call sendLCD
    
    movlw a'a'
    movwf LCDData, A
    call sendLCD
    
    movlw a'r'
    movwf LCDData, A
    call sendLCD
    
    clrf LCDConfig, A		; Set DDRAM to 0x09
    movlw b'10001001'
    movwf LCDData, A
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig, A
    movlw a'1'
    movwf LCDData, A
    call sendLCD
    
    clrf LCDConfig, A		; Set DDRAM to 0x40
    movlw b'11000000'
    movwf LCDData, A
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig, A
    movlw a'P'
    movwf LCDData, A
    call sendLCD
    
    movlw a'u'
    movwf LCDData, A
    call sendLCD
    
    movlw a'n'
    movwf LCDData, A
    call sendLCD
    
    movlw a't'
    movwf LCDData, A
    call sendLCD
    
    movlw a'a'
    movwf LCDData, A
    call sendLCD
    
    movlw a'j'
    movwf LCDData, A
    call sendLCD
    
    movlw a'e'
    movwf LCDData, A
    call sendLCD
    
    clrf LCDConfig, A		; Set DDRAM to 0x49
    movlw b'11001001'
    movwf LCDData, A
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig, A
    movlw a'2'
    movwf LCDData, A
    call sendLCD
    
    return
    
    
sendLCD:
    movff LCDConfig, LATC		; Set values for RS and RW
    bsf LATC, 2, A		; Set enable bit
    movff LCDData, LATD		; Load Data port
    nop
    bcf LATC, 2, A		; Clear enable bit
    call waitLCD
    return
    
waitLCD:
    setf TRISD, A		; Change port D to input
    movlw b'001'
    movwf LATC, A		; Set values for E, RS and RW
    bsf LATC, 2, A		; Set enable bit
    btfsc PORTD, 7, A		; Checks busyflag
	goto waitLCD
    bcf LATC, 2, A		; Clear enable bit
    clrf TRISD, A		; Change port D back to output
    return
    
configT2:
    
jugar:
    
ciclo1:
    
ciclo2:
    
incorr:
    
corr:
    
puntajeLCD:
    
    
    
    end
    