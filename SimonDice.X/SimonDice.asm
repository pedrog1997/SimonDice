    RADIX DEC
    PROCESSOR 18F45K50
    #INCLUDE <P18F45K50.INC> 
    
    ; Variable definition
#define SECMAX 10
    
puntaje EQU 0x00
prendidos EQU 0x01
secuencia EQU 0x04
comparador EQU 0x05
LCDConfig EQU 0x02
LCDData EQU 0x03
reg EQU 0x10
dig1 EQU 0x11
dig0 EQU 0x12
DCounter1 EQU 0X0C
DCounter2 EQU 0X0D
 
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
    
    clrf ANSELE, BANKED
    clrf TRISE, A
    clrf LATE, A
    
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
    
    call loadEEPROM
    call configT0

loop:
    clrf puntaje
    
    call menuLCD
    
    call waitKey
    
    goto loop
    
waitKey:
    movlw b'11101111'
    movwf LATB, A
    btfss PORTB, 3, A
	goto jugar
    movlw b'11011111'
    movwf LATB, A
    btfss PORTB, 3, A
	goto displayPuntaje
    goto waitKey
    
jugar:
    call antirebotes
    call score
    btfss TMR0L, 0, A
	goto sec
    movlw 0x0A
    goto secu
sec movlw 0
secu movwf secuencia
gameloop:
    clrf prendidos, A
    call prenderSecuencia
    clrf prendidos, A
    call esperarSecuencia
    incf puntaje, F, A
    call updateScore
    movlw SECMAX
    cpfseq puntaje, A
	goto gameloop
    goto win
    
win:
    movlw 0x14
    movwf EEADR
    movlw SECMAX
    movwf EEDATA
    movlw b'00000100'
    movwf EECON1, A
    call writeToEE
    
    call felicidades
    return
    
loose:
    movlw 0x14
    movwf EEADR
    call readEE
    cpfsgt puntaje, A
	goto over
    movff puntaje, EEDATA
    movlw b'00000100'
    movwf EECON1, A
    call writeToEE
over
    call gameOver
    return
    
prenderSecuencia:
    incf puntaje, W, A
    cpfseq prendidos, A
	goto prenderSig
    return
prenderSig
    movf prendidos, W, A
    addwf secuencia, W, A
    movwf EEADR, A
    call readEE
    call prenderLED
    incf prendidos, F, A
    goto prenderSecuencia
    
esperarSecuencia:
    call waitButton
    call delay1s
    movf prendidos, W, A
    addwf secuencia, W, A
    movwf EEADR, A
    call readEE
    cpfseq comparador, A
	goto loose
    incf prendidos, F, A
    movf puntaje, W, A
    cpfsgt prendidos, A
	goto esperarSecuencia
    return
    
prenderLED:
    movwf LATA
    call delay1s
    clrf LATA
    call delay1s
    return
    
waitButton:
    movlw b'11101111'
    movwf LATB, A
    btfss PORTB, 3, A
	goto uno
    btfss PORTB, 2, A
	goto uno
    btfss PORTB, 1, A
	goto uno
    btfss PORTB, 0, A
	goto uno
    movlw b'11011111'
    movwf LATB, A
    btfss PORTB, 3, A
	goto dos
    btfss PORTB, 2, A
	goto dos
    btfss PORTB, 1, A
	goto dos
    btfss PORTB, 0, A
	goto dos
    movlw b'10111111'
    movwf LATB, A
    btfss PORTB, 3, A
	goto cuatro
    btfss PORTB, 2, A
	goto cuatro
    btfss PORTB, 1, A
	goto cuatro
    btfss PORTB, 0, A
	goto cuatro
    movlw b'01111111'
    movwf LATB, A
    btfss PORTB, 3, A
	goto ocho
    btfss PORTB, 2, A
	goto ocho
    btfss PORTB, 1, A
	goto ocho
    btfss PORTB, 0, A
	goto ocho
    goto waitButton
    
uno:
    movlw 1
    movwf comparador, A
    movwf LATA, A
    call antirebotes
    clrf LATA, A
    return
    
dos:
    movlw 2
    movwf comparador, A
    movwf LATA, A
    call antirebotes
    clrf LATA, A
    return
    
cuatro:
    movlw 4
    movwf comparador, A
    movwf LATA, A
    call antirebotes
    clrf LATA, A
    return
    
ocho:
    movlw 8
    movwf comparador, A
    movwf LATA, A
    call antirebotes
    clrf LATA, A
    return
    
displayPuntaje:
    call antirebotes
    
    clrf LCDConfig
    movlw 1
    movwf LCDData
    call sendLCD
    
    call writeLCDPuntaje
    
    clrf LCDConfig, A		; Set DDRAM to 0x07
    movlw b'10000111'
    movwf LCDData, A
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig, A
    movlw a'M'
    movwf LCDData, A
    call sendLCD
    
    movlw a'a'
    movwf LCDData, A
    call sendLCD
    
    movlw a'x'
    movwf LCDData, A
    call sendLCD
    
    clrf LCDConfig, A		; Set DDRAM to 0x11
    movlw b'10001011'
    movwf LCDData, A
    call sendLCD
    
    movlw 0x14
    movwf EEADR, A
    call readEE
    movwf reg, A
    call displayReg
    
waitZero:
    movlw b'11011111'
    movwf LATB, A
waitReturn
    btfss PORTB, 0, A
	goto antirebotes
    goto waitReturn
    
readEE:
    bcf EECON1, EEPGD, A
    bcf EECON1, CFGS, A
    bsf EECON1, RD, A
    movf EEDATA, W, A
    return
    
antirebotes:
    call delay
    btfss PORTB, 0, A
	goto antirebotes
    btfss PORTB, 1, A
	goto antirebotes
    btfss PORTB, 2, A
	goto antirebotes
    btfss PORTB, 3, A
	goto antirebotes
    return  
    
displayReg:
    movlw b'11110000'
    andwf reg, W, A
    swapf WREG, W, A
    movwf dig1, A
    
    movlw b'00001111'
    andwf reg, W, A
    movwf dig0, A
    
    movlw 48
    addwf dig1, F, A
    addwf dig0, F, A
    
    movlw b'010'
    movwf LCDConfig
    movff dig1, LCDData
    call sendLCD
    
    movff dig0, LCDData
    call sendLCD

    return
    
sendLCD:
    call waitLCD
    movf LCDConfig, W, A
    movwf LATE			; Set values for RS and RW	
    bsf LATE, 2, A		; Set enable bit
    movf LCDData, W, A
    movwf LATD, A		; Load Data port
    nop
    bcf LATE, 2, A		; Clear enable bit
    return
    
waitLCD:
    setf TRISD, A		; Change port D to input
    movlw b'001'
    movwf LATE, A		; Set values for E, RS and RW
    bsf LATE, 2, A		; Set enable bit
waitFlag 
    btfsc PORTD, 7, A		; Checks busyflag
	goto waitFlag
    bcf LATE, 2, A		; Clear enable bit
    clrf TRISD, A		; Change port D back to output
    return
    
writeLCDPuntaje:
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
    
    return
    
score:
    clrf LCDConfig
    movlw 1
    movwf LCDData
    call sendLCD
    
    call writeLCDPuntaje
    
    call updateScore
    
    return
    
updateScore:
    clrf LCDConfig	
    movlw b'10001000'
    movwf LCDData		; Set DDRAM to 0x08
    call sendLCD
    
    movff puntaje, reg
    call displayReg
    
    return
    
loadEEPROM:
    movlw 0
    movwf EEADR, A		; 0x00 Primera secuencia
    movlw 8
    movwf EEDATA, A
    movlw b'00000100'
    movwf EECON1, A
    call writeToEE
    
    incf EEADR, F, A		; 0x01
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x02
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x03
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x04
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x05
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x06
    movlw 8
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x07
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x08
    movlw 8
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x09
    movlw 1
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x0A Segunda secuencia
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x0B
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x0C
    movlw 8
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x0D
    movlw 1
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x0E
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x0F
    movlw 1
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x10
    movlw 2
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x11
    movlw 1
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x12
    movlw 8
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x13
    movlw 4
    movwf EEDATA, A
    call writeToEE
    
    incf EEADR, F, A		; 0x14
    clrf EEDATA, A
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
    
configT0:
    movlw b'01001000'
    movwf T0CON, A
    bsf T0CON, TMR0ON, A
    return
    
menuLCD:
    clrf LCDConfig
    movlw 1
    movwf LCDData
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig
    movlw a'1'
    movwf LCDData
    call sendLCD
    
    clrf LCDConfig
    movlw b'10000010'
    movwf LCDData
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig
    movlw a'J'
    movwf LCDData
    call sendLCD
    movlw a'u'
    movwf LCDData
    call sendLCD
    movlw a'g'
    movwf LCDData
    call sendLCD
    movlw a'a'
    movwf LCDData
    call sendLCD
    movlw a'r'
    movwf LCDData
    call sendLCD
    
    clrf LCDConfig
    movlw b'11000000'	    ; Set DDRAM 0x40
    movwf LCDData
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig
    movlw a'2'
    movwf LCDData
    call sendLCD
    
    clrf LCDConfig
    movlw b'11000010'	    ; Set DDRAM 0x42
    movwf LCDData
    call sendLCD
    
    call writeLCDPuntaje
    
    return
    
felicidades:
    clrf LCDConfig
    movlw 1
    movwf LCDData
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig
    movlw a'F'
    movwf LCDData
    call sendLCD
    movlw a'e'
    movwf LCDData
    call sendLCD
    movlw a'l'
    movwf LCDData
    call sendLCD
    movlw a'i'
    movwf LCDData
    call sendLCD
    movlw a'c'
    movwf LCDData
    call sendLCD
    movlw a'i'
    movwf LCDData
    call sendLCD
    movlw a'd'
    movwf LCDData
    call sendLCD
    movlw a'a'
    movwf LCDData
    call sendLCD
    movlw a'd'
    movwf LCDData
    call sendLCD
    movlw a'e'
    movwf LCDData
    call sendLCD
    movlw a's'
    movwf LCDData
    call sendLCD
    
    call waitZero
    
    return
    
gameOver:
    clrf LCDConfig
    movlw 1
    movwf LCDData
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig
    movlw a'G'
    movwf LCDData
    call sendLCD
    movlw a'a'
    movwf LCDData
    call sendLCD
    movlw a'm'
    movwf LCDData
    call sendLCD
    movlw a'e'
    movwf LCDData
    call sendLCD
    movlw a'O'
    movwf LCDData
    call sendLCD
    movlw a'v'
    movwf LCDData
    call sendLCD
    movlw a'e'
    movwf LCDData
    call sendLCD
    movlw a'r'
    movwf LCDData
    call sendLCD
    
    call waitZero
    
    goto loop
  
	
delay:
    movlw 0xe3
    movwf DCounter1
    movlw 0X68
    movwf DCounter2
loopdelay
    decfsz DCounter1, 1
    goto loopdelay
    decfsz DCounter2, 1
    goto loopdelay
    return
    
rutDel incf 0x38,F,A
    btfss STATUS,2
	goto rutDel
	return	
rutDel2 call rutDel
    incf 0x39,F,A
    btfss STATUS,2
	goto rutDel2
	return
delay1s:
    movlw d'250'
    movwf 0x3A,A
rutDel3 call rutDel2
    incf 0x3A,F,A
    btfss STATUS,2
	goto rutDel3
    return
	
    
    
    end