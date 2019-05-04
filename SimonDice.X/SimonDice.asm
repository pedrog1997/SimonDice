    RADIX DEC
    PROCESSOR 18F45K50
    #INCLUDE <P18F45K50.INC> 
    
    ; Variable definition
puntaje EQU 0x00
indice EQU 0x01
LCDConfig EQU 0x02
LCDData EQU 0x03
NUM EQU 0x04
maxP EQU 0x05
iterator EQU 0x40
address EQU 0x41
comparador EQU 0x42
flag EQU 0x43
bitf EQU 0
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
    call configT2
    call menuLCD

    
check1:
    movlw b'11101111'
    movwf LATB, A
    btfss PORTB, 3, A
	call jugar
    movlw b'11011111'
    movwf LATB, A
    btfss PORTB, 3, A
	call puntajeLCD
    goto check1
    
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
    
    incf EEADR, F, A	    ; 0x14
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
    movff LCDConfig, LATC	; Set values for RS and RW
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
    clrf T2CON, A
    bsf T2CON, TMR2ON, A
    return
    
jugar:
    call delay
    btfss PORTB, 3, A
	goto jugar
    
    btfss TMR2, 0, A
	goto sec1
    movlw 0x0A 
    movwf indice, A
    movwf EEADR, A
    goto clc
sec1 
    clrf indice, A
    clrf EEADR, A
clc
    clrf puntaje, A
    call showScore

gameloop
    call updateScore
    call showSequence
    call waitSequence
    goto gameloop
    
showSequence:
    call showLED
ciclo1
    movf indice, W, A
    addwf puntaje, W, A
    cpfsgt EEADR, A
	goto c1F
    goto c1T
c1F movf indice, W, A
    movwf EEADR, A
    return
c1T
    incf EEADR, F, A
    call showLED
    goto ciclo1
    
waitSequence:
    call ckcT
    bcf EECON1, EEPGD, A
    bcf EECON1, CFGS, A
    bsf EECON1, RD, A
    movf EEDATA, W, A
    cpfseq comparador, A
	goto incorr
    incf EEADR, F, A
    movf indice, W, A
    addwf puntaje, W, A
    cpfseq EEADR, A
	goto waitSequence
    goto corr
    
corr
    movlw .32
    movwf LATA, A
    call delay1
    clrf LATA, A
    incf puntaje, F, A
    movlw .10
    cpfseq puntaje, A
	return 
    call setmaxpoints
    call win
    
incorr
    movlw .16
    movwf LATA, A
    call delay1
    clrf LATA, A
    movlw 0x14
    movwf EEADR, A
    bcf EECON1, EEPGD, A
    bcf EECON1, CFGS, A
    bsf EECON1, RD, A
    movf EEDATA, W, A
    cpfsgt puntaje, A
	call loose
    call setmaxpoints
    call loose
    
win:
    clrf LCDConfig, A		; Clear display
    movlw 1
    movwf LCDData, A
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig, A
    
    movlw a'F'
    movwf LCDData, A
    call sendLCD
    movlw a'e'
    movwf LCDData, A
    call sendLCD
    movlw a'l'
    movwf LCDData, A
    call sendLCD
    movlw a'i'
    movwf LCDData, A
    call sendLCD
    movlw a'c'
    movwf LCDData, A
    call sendLCD
    movlw a'i'
    movwf LCDData, A
    call sendLCD
    movlw a'd'
    movwf LCDData, A
    call sendLCD
    movlw a'a'
    movwf LCDData, A
    call sendLCD
    movlw a'd'
    movwf LCDData, A
    call sendLCD
    movlw a'e'
    movwf LCDData, A
    call sendLCD
    movlw a's'
    movwf LCDData, A
    call sendLCD
    
    goto here
    
loose:
    clrf LCDConfig, A		; Clear display
    movlw 1
    movwf LCDData, A
    call sendLCD
    
    movlw b'010'
    movwf LCDConfig, A
    
    movlw a'G'
    movwf LCDData, A
    call sendLCD
    movlw a'a'
    movwf LCDData, A
    call sendLCD
    movlw a'm'
    movwf LCDData, A
    call sendLCD
    movlw a'e'
    movwf LCDData, A
    call sendLCD
    movlw a'O'
    movwf LCDData, A
    call sendLCD
    movlw a'v'
    movwf LCDData, A
    call sendLCD
    movlw a'e'
    movwf LCDData, A
    call sendLCD
    movlw a'r'
    movwf LCDData, A
    call sendLCD
    
    goto here
    
showLED:
    bcf EECON1, EEPGD, A
    bcf EECON1, CFGS, A
    bsf EECON1, RD, A
    movf EEDATA, W, A
    movwf LATA, A
    call delay1
    clrf LATA, A
    return
		
;teclado
ckcT:   
    movlw b'11101111'
    movwf LATB,A
    btfss PORTB,3,A
	goto uno
    btfss PORTB,2,A
	goto uno
    btfss PORTB,1,A
	goto uno
    btfss PORTB,0,A
	goto uno

    movlw b'11011111'
    movwf LATB,A
    btfss PORTB,3,A
	goto dos
    btfss PORTB,2,A
	goto dos
    btfss PORTB,1,A
	goto dos
    btfss PORTB,0,A
	goto dos

    movlw b'10111111'
    movwf LATB,A
    btfss PORTB,3,A
	goto cuatro
    btfss PORTB,2,A
	goto cuatro
    btfss PORTB,1,A
	goto cuatro
    btfss PORTB,0,A
	goto cuatro

    movlw b'01111111'
    movwf LATB,A
    btfss PORTB,3,A
	goto ocho
    btfss PORTB,2,A
	goto ocho
    btfss PORTB,1,A
	goto ocho
    btfss PORTB,0,A
	goto ocho
    goto ckcT
	
uno
    call antirebotes
    movlw .1
    movwf comparador, A
    movwf LATA, A
    call delay1
    clrf LATA, A
    return
    
dos
    call antirebotes
    movlw .2
    movwf comparador, A
    movwf LATA,A
    call delay1
    clrf LATA, A
    return
    
cuatro
    call antirebotes
    movlw .4
    movwf comparador, A
    movwf LATA,A
    call delay1
    clrf LATA, A
    return
    
ocho
    call antirebotes
    movlw .8
    movwf comparador, A
    movwf LATA,A
    call delay1
    clrf LATA, A
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
    
setmaxpoints:
    movlw 0x14
    movwf EEADR
    movf puntaje, W, A
    movwf EEDATA, A
    movlw b'00000100'
    movwf EECON1, A
    call writeToEE
    bcf EECON1, WREN, A
    return
    
puntajeLCD:
    call delay
    btfss PORTB, 3, A
	goto puntajeLCD
    
    call maxPoints
    
    clrf LCDConfig, A		; Clear display
    movlw 1
    movwf LCDData, A
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
    
    movlw 0x0A
    cpfslt maxP, A
	call add6
    movlw b'11110000'
    andwf maxP, W, A
    swapf WREG, W, A
    movff WREG, NUM
    call displayNum		; D�gito m�s significativo
    movlw b'00001111'
    andwf maxP, W, A
    movff WREG, NUM
    call displayNum		; D�gito menos significativo
    
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
    
showScore:
    clrf LCDConfig, A		; Clear display
    movlw 1
    movwf LCDData, A
    call sendLCD
    
    call writeLCDPuntaje
    call updateScore
    
    return
    
updateScore:
    clrf LCDConfig, A		; Set DDRAM to 0x08
    movlw b'10001000'
    movwf LCDData, A
    call sendLCD
    
    movff puntaje, NUM
    call displayNum
    
    return
    
add6:
    movlw 6
    addwf maxP, F, A
    return
    
maxPoints:
    movlw 0x14
    movwf EEADR, A
    bcf EECON1, EEPGD, A
    bcf EECON1, CFGS, A
    bsf EECON1, RD, A
    movf EEDATA, W, A
    movwf maxP, A
    return
    
displayNum:
    movlw 0
    cpfsgt NUM, A
	goto display0
    movlw 1
    cpfsgt NUM, A
	goto display1
    movlw 2
    cpfsgt NUM, A
	goto display2
    movlw 3
    cpfsgt NUM, A
	goto display3
    movlw 4
    cpfsgt NUM, A
	goto display4
    movlw 5
    cpfsgt NUM, A
	goto display5
    movlw 6
    cpfsgt NUM, A
	goto display6
    movlw 7
    cpfsgt NUM, A
	goto display7
    movlw 8
    cpfsgt NUM, A
	goto display8
    goto display9
    
display0:
    movlw b'010'
    movwf LCDConfig
    movlw a'0'
    movwf LCDData
    call sendLCD
    return
    
display1:
    movlw b'010'
    movwf LCDConfig
    movlw a'1'
    movwf LCDData
    call sendLCD
    return
    
display2:
    movlw b'010'
    movwf LCDConfig
    movlw a'2'
    movwf LCDData
    call sendLCD
    return
    
display3:
    movlw b'010'
    movwf LCDConfig
    movlw a'3'
    movwf LCDData
    call sendLCD
    return
    
display4:
    movlw b'010'
    movwf LCDConfig
    movlw a'4'
    movwf LCDData
    call sendLCD
    return
    
display5:
    movlw b'010'
    movwf LCDConfig
    movlw a'5'
    movwf LCDData
    call sendLCD
    return
    
display6:
    movlw b'010'
    movwf LCDConfig
    movlw a'6'
    movwf LCDData
    call sendLCD
    return
    
display7:
    movlw b'010'
    movwf LCDConfig
    movlw a'7'
    movwf LCDData
    call sendLCD
    return
    
display8:
    movlw b'010'
    movwf LCDConfig
    movlw a'8'
    movwf LCDData
    call sendLCD
    return
    
display9:
    movlw b'010'
    movwf LCDConfig
    movlw a'9'
    movwf LCDData
    call sendLCD
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
delay1:
    movlw d'250'
    movwf 0x3A,A
rutDel3 call rutDel2
    incf 0x3A,F,A
    btfss STATUS,2
	goto rutDel3
    return
	
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
    
here goto here
    
    end