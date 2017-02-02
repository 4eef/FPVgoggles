;FPV Goggles power supply and control using ATtiny44A

.INCLUDE "tn44Adef.inc"

;Variables
.equ	VOLTL	= RAMEND-0
.equ	VOLTH	= RAMEND-1
.equ	CHNL	= RAMEND-2
.equ	INDCTL	= RAMEND-3
.equ	INDCTH	= RAMEND-4
.equ	B1CNTL	= RAMEND-5
.equ	B1CNTH	= RAMEND-6
.equ	B2CNTL	= RAMEND-7
.equ	B2CNTH	= RAMEND-8
.equ	SHIFTL	= RAMEND-9
.equ	SHIFTH	= RAMEND-10
.equ	NSHIFT	= RAMEND-11
.equ	VOLTM	= RAMEND-12
;Constants
.equ	ZSHFTL	= 0xC8
.equ	ZSHFTH	= 0x00
.equ	THBNC	= 0x04
.equ	THSRTL	= 0x64
.equ	THSRTH	= 0x00
.equ	THLNGL	= 0xE8
.equ	THLNGH	= 0x03
.equ	DINT	= 0x64
.equ	UVTHRL	= 0xB8
.equ	UVTHRH	= 0x0B

	rjmp	RESET
	reti	;rjmp	EINT0
	reti	;rjmp	PCI0
	reti	;rjmp	PCI1
	reti	;rjmp	WDT
	reti	;rjmp	T1CAPT
	reti	;rjmp	T1CA
	reti	;rjmp	T1CB
	reti	;rjmp	T1OVF
	reti	;rjmp	T0CA
	reti	;rjmp	T0CB
	reti	;rjmp	T0OVF
	reti	;rjmp	ANA_COMP
	reti	;rjmp	ADC
	reti	;rjmp	EE_RDY
	reti	;rjmp	USI_STR
	reti	;rjmp	USI_OVF

RESET:	ldi	r16,	low(RAMEND-239)
	out	SPL,	r16
	ldi	r16,	high(RAMEND-239)
	out	SPH,	r16
	;Constants
	clr	r0
	sts	VOLTL,	r0
	sts	VOLTH,	r0
	sts	CHNL,	r0
	sts	INDCTL,	r0
	sts	INDCTH,	r0
	sts	B1CNTL,	r0
	sts	B1CNTH,	r0
	sts	B2CNTL,	r0
	sts	B2CNTH,	r0
	ldi	r17,	ZSHFTH
	ldi	r16,	ZSHFTL
	sts	SHIFTH,	r17
	sts	SHIFTL,	r16
	sts	NSHIFT,	r0
	;Pin connection explanation:
	;PA0 - D1 (CS1)
	;PA1 - D2 (CS2)
	;PA2 - 7-seg decoder enable
	;PA3 - D3
	;PA4 - D0 (CS0)
	;PA5 - boost converter enable
	;PA6 - least significant digit
	;PA7 - most significant digit
	;PB0 - upper button
	;PB1 - lower button
	ldi	r16,	0b11111111		;All at PORTA is outputs
	out	DDRA,	r16
	out	DDRB,	r0			;All at PORTB is inputs
	ldi	r16,	0b11000000
	out	PORTA,	r16			;Pull up the digit's PNPs
	ldi	r16,	0b00001111		;Pull up RESET and B1, B2 lines
	out	PORTB,	r16
	;TCNT1
	ldi	r16,	0b00001000		;CTC mode
	out	TCCR1B,	r16
	ldi	r17,	0x13			;1000000 Hz / 5000 = 200 Hz
	ldi	r16,	0x87
	out	OCR1AH,	r17
	out	OCR1AL,	r16
	ldi	r16,	0b00000010		;Output compare interrupt
	out	TIFR1,	r16
	out	TIMSK1,	r16
	out	TCNT1H,	r0			;Clear registers
	out	TCNT1L,	r0
	in	r16,	TCCR1B			;ftcnt=fck
	ori	r16,	0b00000001
	out	TCCR1B,	r16
	;MCU
	ldi	r16,	0b00100000		;SE, Idle
	out	MCUCR,	r16
	sbi	ACSR,	ACD			;Disable Analog Comparator
	sei
	;Displaying: 0 - Channel, 1 - Voltage
	set
	sbi	PORTA,	2			;Enable decoder
	sbi	PORTA,	5			;Turn on the converter

;*********************************MAIN ROUTINE*********************************
main:	clr	r0
	sleep
	;Scan both the pin states; increment the corresponting integrator(s)
	in	r15,	PINB
	sbrc	r15,	1			;Lower button
	rjmp	b1skip
	lds	r26,	B1CNTL
	lds	r27,	B1CNTH
	ldi	r16,	THLNGL			;Long press upper threshold
	ldi	r17,	THLNGH
	cp	r26,	r16
	cpc	r27,	r17
	brcc	PC+2
	adiw	r26,	1
	sts	B1CNTL,	r26
	sts	B1CNTH,	r27
b1skip:	sbrc	r15,	0			;Upper button
	rjmp	b2skip
	lds	r26,	B2CNTL
	lds	r27,	B2CNTH
	ldi	r16,	THLNGL			;Long press upper threshold
	ldi	r17,	THLNGH
	cp	r26,	r16
	cpc	r27,	r17
	brcc	PC+2
	adiw	r26,	1
	sts	B2CNTL,	r26
	sts	B2CNTH,	r27
b2skip:	
	;If button is released
	in	r15,	PINB
	in	r16,	PINB
	lsr	r16
	and	r16,	r15
	sbrs	r16,	0
	rjmp	bhold
	lds	r26,	B1CNTL
	lds	r27,	B1CNTH
	ldi	r16,	THBNC			;Anti-bounce
	cp	r16,	r26
	cpc	r0,	r27
	brcs	b1nbnc				;No bounce
	sts	B1CNTL,	r0
	sts	B1CNTH,	r0
	rjmp	b1rdy
	;Short press
b1nbnc:	sts	B1CNTL,	r0			;Zero the button press counter
	sts	B1CNTH,	r0
	sts	INDCTL,	r0			;Zero the indication counter
	sts	INDCTH,	r0
	ldi	r16,	ZSHFTL
	sts	SHIFTL,	r16			;Zero the shift threshold
	ldi	r16,	ZSHFTH
	sts	SHIFTH,	r16
	sts	NSHIFT,	r0			;Zero the number of shifts value
	ldi	r16,	THSRTL			;Short press threshold
	ldi	r17,	THSRTH
	cp	r16,	r26
	cpc	r17,	r27
	brcs	b1lng
	brts	b1rdy
	lds	r20,	CHNL
	tst	r20
	breq	PC+2
	dec	r20
;	rjmp	PC+2
;	cbi	PORTA,	5			;Turn off the converter
	sts	CHNL,	r20
	sbi	PORTA,	2			;Turn on the decoder
	rjmp	b1rdy
	;Lower button long press
b1lng:	cbi	PORTA,	5			;Turn off the converter
	sbi	PORTA,	2			;Turn on the decoder
b1rdy:	lds	r26,	B2CNTL
	lds	r27,	B2CNTH
	ldi	r16,	THBNC			;Anti-bounce
	cp	r16,	r26
	cpc	r0,	r27
	brcs	b2nbnc				;No bounce
	sts	B1CNTL,	r0
	sts	B1CNTH,	r0
	rjmp	b2rdy
	;Short press
b2nbnc:	sts	B2CNTL,	r0			;Zero the button press counter
	sts	B2CNTH,	r0
	sts	INDCTL,	r0			;Zero the indication counter
	sts	INDCTH,	r0
	ldi	r16,	ZSHFTL
	sts	SHIFTL,	r16			;Zero the shift threshold
	ldi	r16,	ZSHFTH
	sts	SHIFTH,	r16
	sts	NSHIFT,	r0			;Zero the number of shifts value
	ldi	r16,	THSRTL			;Short press threshold
	ldi	r17,	THSRTH
	cp	r16,	r26
	cpc	r17,	r27
	brcs	b2lng
	brts	b2rdy
	lds	r20,	CHNL
;	in	r16,	PINA
;	sbrc	r16,	5
	inc	r20
;	sbi	PORTA,	5			;Turn on the converter
	ldi	r21,	7
	cp	r21,	r20
	brcc	PC+4
	in	r16,	PINA
	sbrc	r16,	2
;	set
	rjmp	PC+2
	sts	CHNL,	r20
	sbi	PORTA,	2			;Turn on the decoder
	rjmp	b2rdy
	;Lower button long press
b2lng:	sbi	PORTA,	5			;Turn on the converter
	sbi	PORTA,	2			;Turn on the decoder
b2rdy:
bhold:
	;Measure the Vbat
vbmeas:	ldi	r16,	0b00100001		;Vcc as Vref, 1.1 V reference as input
	out	ADMUX,	r16
	ldi	r16,	0b00100000		;SE, Idle
	out	MCUCR,	r16
	ldi	r16,	0b10011010		;ADEN, ADSC, ADIF, ADIE, fadc=250 kHz
	out	ADCSRA,	r16
	ldi	r16,	16			;Skip 16 samples
advini:	sleep
	dec	r16
	brne	advini
	clr	r20
	clr	r21
	ldi	r16,	16
advsmp:	sleep
	in	r18,	ADCL
	in	r19,	ADCH
	add	r20,	r18			;Integrating of 16 samples (14-bit)
	adc	r21,	r19
	dec	r16
	brne	advsmp
	out	ADCSRA,	r0
	;Calculate the supply voltage
	ldi	r19,	0x01			;Constant - 18021300 (1,1*Nadc*1000)
	ldi	r18,	0x12
	ldi	r17,	0xFB
	ldi	r16,	0xB4
	rcall	div32u				;U=K/N, [mV]
	mov	r20,	r16
	mov	r21,	r17
	lds	r22,	VOLTL
	lds	r23,	VOLTH
	lds	r24,	VOLTM
	rcall	dm256u
	sts	VOLTL,	r22
	sts	VOLTH,	r23
	sts	VOLTM,	r24
	;Undervoltage protection
	ldi	r18,	UVTHRL
	ldi	r19,	UVTHRH
	cp	r22,	r18
	cpc	r23,	r19
	brcc	PC+2
	cbi	PORTA,	5
	;Trigger to choose displaying value
	brtc	dch
	;Display measured Vbat in hundreds of millivolts
dvolt:	lds	r17,	VOLTH
	lds	r16,	VOLTL
	rjmp	indval
	;Display the info
dch:	lds	r16,	CHNL			;Display current channel
	clr	r17
	;r16:r17 [BCD] <- r17:r16 [HEX]
indval:	clr	r18
	clr	r19
	clr	r20
	clr	xh
	ldi	r21,	16
hbcd1:	ldi	xl,	20+1
hbcd2:	ld	r22,	-x
	subi	r22,	-3
	sbrc	r22,	3
	st	x,	r22
	ld	r22,	x
	subi	r22,	-0x30
	sbrc	r22,	7
	st	x,	r22
	cpi	xl,	18
	brne	hbcd2
	lsl	r16
	rol	r17
	rol	r18
	rol	r19
	rol	r20
	dec	r21
	brne	hbcd1
	mov	r17,	r18
	mov	r16,	r19
	brts	PC+2
	mov	r16,	r18
	;Shift the value to display Vbat in millivolts
	brtc	dtrig
	lds	r20,	NSHIFT			;Number of shifts
	tst	r20
	breq	zrshft
shift:	lsl	r17
	rol	r16
	lsl	r17
	rol	r16
	lsl	r17
	rol	r16
	lsl	r17
	rol	r16
	dec	r20
	breq	PC+2
	rjmp	shift
zrshft:	lds	r19,	SHIFTH			;Shifting to display the millivolts
	lds	r18,	SHIFTL
	lds	r21,	INDCTH
	lds	r20,	INDCTL
	cp	r18,	r20
	cpc	r19,	r21
	brcc	prshft
	lds	r20,	NSHIFT
	ldi	r21,	1
	cp	r21,	r20
	brcs	PC+4
	inc	r20
	sts	NSHIFT,	r20
	ldi	r21,	DINT			;Displaying interval
	add	r18,	r21
	adc	r19,	r0
	sts	SHIFTH,	r19
	sts	SHIFTL,	r18
prshft:
	;Trigger to choose the displaying digit
dtrig:	brtc	lsd
	in	r17,	PINA
	sbrc	r17,	6
	rjmp	lsd	
msd:	sbi	PORTA,	6			;Turn off the LSD
	cbi	PORTA,	7			;Turn on the MSD
	lsr	r16				;Shift the value to LSBs
	lsr	r16
	lsr	r16
	lsr	r16
	rjmp	ddec
lsd:	sbi	PORTA,	7			;Turn off the MSD
	cbi	PORTA,	6			;Turn on the LSD
	andi	r16,	0b00001111		;AND the LSBs
	;Decode a decimal value (0...9) and put it out
ddec:	ldi	zl,	low(ddb*2)		;First cell address
	ldi	zh,	high(ddb*2)
	add	zl,	r16			;Add an offset to pointer
	adc	zh,	r0
	lpm	r17,	z			;Decoded value
	in	r16,	PINA			;Load old value
	andi	r16,	0b11100100		;Delete old value
	or	r16,	r17			;Insert new value
	out	PORTA,	r16			;Output new value
	;Count the displaying time
	lds	r26,	INDCTL
	lds	r27,	INDCTH
	ldi	r18,	0x58			;200 Hz * 2 s = 400
	ldi	r19,	0x02
	cp	r18,	r26
	cpc	r19,	r27
	brcc	goind
	sts	INDCTL,	r0			;Write zero to integrator
	sts	INDCTH,	r0
	ldi	r17,	ZSHFTH
	ldi	r16,	ZSHFTL
	sts	SHIFTH,	r17
	sts	SHIFTL,	r16
	cbi	PORTA,	2			;Disable output
	sbi	PORTA,	6			;Disable digits
	sbi	PORTA,	7
	clt
	rjmp	PC+5
goind:	adiw	r26,	1
	sts	INDCTL,	r26
	sts	INDCTH,	r27
	rjmp	main

;*********************************SUBROUTINES**********************************

	;Damping /256
dm256u:	tst	R22
	brne	d256ok
	tst	R23
	brne	d256ok
	movw	R22,	R20
d256ok:	push	R17
	push	R18
	push	R19
	clr	R17
	cp	R20,	R22
	cpc	R21,	R23
	brcc	mrd256
	movw	R18,	R22
	sub	R18,	R20
	sbc	R19,	R21
	sub	R24,	R18
	sbc	R22,	R19
	sbc	R23,	R17
	rjmp	d2uout
mrd256:	movw	R18,	R20
	sub	R18,	R22
	sbc	R19,	R23
	add	R24,	R18
	adc	R22,	R19
	adc	R23,	R17
d2uout:	pop	R19
	pop	R18
	pop	R17
	ret

	;r19:r18:r17:r16 <- r19:r18:r17:r16 / r21:r20
div32u:	push	r22
	push	r23
	push	r24
	push	r25
	push	r26
	push	r27
	clr	r22
	ldi	r23,	33
	clr	r24
	clr	r25
	clr	r26
	sub	r27,	r27
d32u_1:	rol	r16
	rol	r17
	rol	r18
	rol	r19
	dec	r23
	brne	d32u_2
	pop	r27
	pop	r26
	pop	r25
	pop	r24
	pop	r23
	pop	r22
	ret
d32u_2:	rol	r24
	rol	r25
	rol	r26
	rol	r27
	sub	r24,	r20
	sbc	r25,	r21
	sbc	r26,	r22
	sbc	r27,	r22
	brcc	d32u_3
	add	r24,	r20
	adc	r25,	r21
	adc	r26,	r22
	adc	r27,	r22
	clc
	rjmp	d32u_1
d32u_3:	sec
	rjmp	d32u_1

;********************************DECODER DATABASE******************************

ddb:
.db	0b00000000,	0b00010000
.db	0b00000001,	0b00010001
.db	0b00000010,	0b00010010
.db	0b00000011,	0b00010011
.db	0b00001000,	0b00011000

/*
indval:	ldi	r17,	99			;Limit for two decimal digits
	cp	r17,	r16			;If r16 > 99 than r16 = 99
	brcc	PC+2
	ldi	r16,	99
binbcd:	clr	r17				;r16 [BCD] <- r16 [HEX]
bbcd1:	subi	r16,	10
	brcs	bbcd2
	subi	r17,	-0x10
	rjmp	bbcd1
bbcd2:	subi	r16,	-10
	add	r16,	r17
*/
