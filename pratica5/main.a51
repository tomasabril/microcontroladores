;Projeto Minimo

;----- DECLARACOES UNIVERSAIS ----------------------------------
	ORG 2000h
;--------DECLARACOES EXTRAS -----------------------------------
	AUX_A 				EQU R5
	AMOSTRAGEM			EQU R3
	MULT				EQU R4
	LED 				EQU P3.6
	LED2 				EQU P1.4
;--------DECLARACOES DELAYS -----------------------------------
	DELAY_TIME 		EQU	32h
	TF					EQU TF0		;mudar se precisar usar o Timer 0
	TR					EQU TR0		
;--------DECLARACOES LCD --------------------------------------
	LCD_RS 			EQU	P2.5
	LCD_RW 			EQU	P2.6
	LCD_EN 			EQU	P2.7
	LCD_DATA 		EQU	P0
	LCD_BUSY		EQU	P0.7
	LCD_POSITION 	EQU	R2
	
;--------DECLARACOES TECLADO ----------------------------------
	COL1 	EQU P1.0
	COL2 	EQU P1.1
	COL3	EQU P1.2
	COL4 	EQU P1.3

	LIN1 	EQU P1.4
	LIN2	EQU P1.5
	LIN3 	EQU P1.6
	LIN4 	EQU P1.7
;--------DECLARACOES SPI ---------------------------------------
	BDRCON EQU 9Bh
;--------DECLARACOES ADC --------------------------------------
	DO 	EQU P1.5
	DI	EQU P1.7
	CK 	EQU P1.6
	CS 	EQU P1.1
	
;--------DECLARACOES I2P e RTC --------------------------------------
	;P4 DATA 0C0h
	
	SDA		EQU	0C1h
	SCL		EQU	0C0h
	SIZE 	EQU	R6

	
	;;leitura e escrita do RTC
	;RADDR	EQU	0xD1
	;WADDR	EQU	0xD0
	
	;SSCON	EQU	93h
	;SSCS	EQU	94h
	;SSDAT	EQU	95h
	;SSADR	EQU	96h
	
	;;SSCON
	;SSIE	EQU	0x40
	;STA		EQU	0x20
	;STO		EQU	0x10
	;SI		EQU	0x08
	;AA		EQU	0x04
	
	;hora
	SEC 		EQU 50h
	MIN 		EQU 51h
	HOU 		EQU 52h
	DAY 		EQU 53h
	DAT 		EQU 54h
	MON			EQU 55h
	YEA 		EQU 56h
	CTR 		EQU 57h
		
	;do despertador
	ASEC EQU 58h
	AMIN EQU 59h
	AHOR EQU 60h
		
	BUZ EQU P2.0        ;<< mudar

	;memoria usada como flag do botao de interrupÁ„o
	BOT EQU 61h         ;<< mudar
	
	;funcao de i2c
	B2W		EQU 66h 	; bytes to write
	B2R 	EQU 67h 	; bytes to read
	ADDR 	EQU 68h 	; internal register address
	DBASE 	EQU 69h 	; endereco base dos dados a serem escritos.
	I2C_BUSY EQU 00h	; 0 livre, 1 ocupada
	
;--------DECLARACOES INTERRUPCAO --------------------------------------
	IEN0		EQU	0A8h
	IEN1		EQU	0B1h
	
	IPL1		EQU	0B2h
	IPH1		EQU	0B3h
	
;----- DECLARACOES UNIVERSAIS FIM -------------------------------
;----- INTERRUPCOES ---------------------------------------------
	ORG 2000h
	LJMP init
	
	ORG 2023h		;int serial
	RETI
	
	ORG 2043h		;iint i2c
	ACALL int_i2c
	RETI
	
	ORG 2010h		; interrupcao do botao
		MOV BOT, #1
		RETI
		
		;timer 1
	ORG 201Bh
		ACALL int_timer1
	RETI
	
	
;----- MAIN -----------------------------------------------------
;--------Inicializacao ---------------------------------------------
	ORG 2100h
	init:
		ACALL startLCD
		
		;desabilita interrupcao
		MOV IEN0, #0x00
		MOV IEN1, #0x00

		;timer0
		MOV TMOD, #0x11
		
		;;i2c
		;SETB SCL
		;SETB SDA
		;MOV SSCON, #01000001b
		
		;;interrupcoes
		;MOV IPL1, #0x02
		;MOV IPH1, #0x02
		;MOV IEN1, #0x02
		
		SETB EA
		
		ACALL initTime
		ACALL setTime
		
		
		MOV TH1,#0F0h
		SETB ET1
		
		
;--------Start ---------------------------------------------------
	mainloop:
		SETB TR1

		;se A pressionado -> setar alarme
		LCALL returnPressedKey
		CLR TR1
		MOV A, 2Ah
		CJNE A, #0Ah, checkb
		ACALL set_alarm_time
		
		;se B pressionado -> setar horario
		checkb:
		CLR TR1
		MOV A, 2Ah
		CJNE A, #0Bh, alarm
		ACALL atualiza_hora
	
		;conferir se precisa ligar alarme
		alarm:
		ACALL checkalarm
		
		JMP mainloop

;----- MAIN FIM --------------------------------------------------




;----- FUNCOES--------------------------------------------------

;; ;; ;; ;;
; compara se horario atual ÅEigual ao do alarme
; ser for, pisca buzzer e led em 1 Hz
; atÅEsetar uma memoria atraves da interrupcao do botao
;; ;; ;; ;;
checkalarm:
    MOV A, MIN
    CLR C
    SUBB A, AMIN
    JNZ horario_diferente
    MOV A, HOU
    CLR C
    SUBB A, AHOR
    JNZ horario_diferente
    ;se chegou atÅEaqui ÅEigual, vamos disparar alarme
    alarm_on:
        MOV A, BOT
        JNZ alarm_off
        SETB BUZ
        SETB LED
        ACALL timerDelay20ms
        CLR BUZ
        CLR LED
        ACALL runT0
        JMP alarm_on

    alarm_off:
        CLR BUZ
        CLR LED
		MOV BOT , #00h
    horario_diferente:
        RET

;; ;; ;; ;;
;; le hora, minuto, segundo do TECLADO
;; e salva na memoria
;; esse ÅEo horario que o alarme vai tocar
;; ;; ;; ;;
sendStringAlarm:
	INC LCD_POSITION
	ADD A, #30h
	ACALL sendNumber
	CLR C
	SUBB A, #30h
	RET

set_alarm_time:
    ;pegando dezena da hora
    MOV LCD_POSITION, #80h
	MOV DPTR, #alarme
	ACALL sendString
	
	MOV LCD_POSITION, #8Ah
	
	ACALL returnPressedKey
    MOV A, 2Ah
	ACALL sendStringAlarm
    RL A                  ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n„o esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
	ACALL sendStringAlarm
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV AHOR, A
	
	INC LCD_POSITION
	MOV DPTR, #doispontos
	ACALL sendString
	
    ;pegando dezena do minuto
    ACALL returnPressedKey
    MOV A, 2Ah
	ACALL sendStringAlarm
    RL A                  ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n„o esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
	ACALL sendStringAlarm
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV AMIN, A

    RET
	
;; ;; ;; ;;
;; le hora, minuto, segundo do TECLADO
;; e grava no relogio
;; ;; ;; ;;
atualiza_hora:
    ;pegando dezena da hora
    ACALL returnPressedKey
    MOV A, 2Ah
    RL A                  ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n„o esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV HOU, A

    ;pegando dezena do minuto
    ACALL returnPressedKey
    MOV A, 2Ah
    RL A                  ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n„o esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV MIN, A

    ;pegando dezena do segundo
    ACALL returnPressedKey
    MOV A, 2Ah
    RL A                   ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n„o esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV SEC, A

    ;;enviando para RTC
    ACALL setTime
    RET

;--------FUNCAO DELAY ------------------------------------------
	timerDelay20ms:
		MOV R6, #200d
			delay0:
				DJNZ R6, delay0
		DJNZ DELAY_TIME, timerDelay20ms
	
		RET
		
	runT0:
		MOV TH0,#0FCh 	;fclk CPU = 24MHz
		MOV TL0,#17h 	; ... base de tempo de 0,5ms
		SETB TR0 		;dispara timer

		JNB TF0,$ 		;preso CLR TR0 ;stop timer
		CLR TR0 		;para o timer 0
		CLR TF0 		;zera flag overflow
		DJNZ MULT,runT0
		RET 

;--------FUNCAO LCD --------------------------------------------
	printTime:
		MOV R0, #53h			;comeÁa na proxima posicao
		MOV R7, #3
		printTimeLoop:
			INC LCD_POSITION
			DEC R0
			
			MOV A, @R0
			ACALL bcdtoascii
			MOV A, 30h
			ACALL sendNumber
			
			INC LCD_POSITION
			MOV A, 31h
			ACALL sendNumber
			
			INC LCD_POSITION
			MOV DPTR, #doispontos
			ACALL sendString
			
			DJNZ R7, printTimeLoop
			
			MOV DPTR, #smallclear
			ACALL sendString
		RET
		
	printDays:
		MOV A, YEA
		ACALL bcdtoascii
		MOV A, 30h
		ACALL sendNumber
		
		INC LCD_POSITION
		MOV A, 31h
		ACALL sendNumber
		
		INC LCD_POSITION
		MOV DPTR, #traco
		ACALL sendString
		
		INC LCD_POSITION
		MOV A, MON
		ACALL bcdtoascii
		MOV A, 30h
		ACALL sendNumber
		
		INC LCD_POSITION
		MOV A, 31h
		ACALL sendNumber
		
		INC LCD_POSITION
		MOV DPTR, #traco
		ACALL sendString
		
		INC LCD_POSITION
		MOV A, DAT
		ACALL bcdtoascii
		MOV A, 30h
		ACALL sendNumber
		
		INC LCD_POSITION
		MOV A, 31h
		ACALL sendNumber
		
		INC LCD_POSITION
		MOV DPTR, #smallclear
		ACALL sendString
		
		INC LCD_POSITION
		MOV A, DAY
		
		printDaysif1:
			CJNE	A,			#01h, 	printDaysif2
			MOV DPTR, #domingo
			ACALL sendString
			AJMP	printDaysfim
		printDaysif2:
			CJNE	A,			#02h, 	printDaysif3
			MOV DPTR, #segunda
			ACALL sendString	
			AJMP	printDaysfim
		printDaysif3:
			CJNE	A,			#03h, 	printDaysif4
			MOV DPTR, #terca
			ACALL sendString		
			AJMP	printDaysfim
			
		printDaysif4:
			CJNE	A,			#04h, 	printDaysif5
			MOV DPTR, #quarta
			ACALL sendString		
			AJMP	printDaysfim
			
		printDaysif5:
			CJNE	A,			#05h, 	printDaysif6
			MOV DPTR, #quinta
			ACALL sendString	
			AJMP	printDaysfim
			
		printDaysif6:
			CJNE	A,			#06h, 	printDaysif7
			MOV DPTR, #sexta
			ACALL sendString		
			AJMP	printDaysfim
			
		printDaysif7:
			CJNE	A,			#07h, 	printDaysfim
			MOV DPTR, #sabado
			ACALL sendString
			
			AJMP	printDaysfim
		printDaysfim: 
		RET
		
;; recebe valor em Acc
bcdtoascii:
    MOV 30h, A       ;Mantem copia de BCD original em r2
    ANL A, #0Fh     ;zera primeiros 4 bits que contem algarismo de dezena
    ORL A, #30h     ;soma 30 pra virar ascii
    MOV 31h, A       ;salva resultado parcial
    MOV A, 30h       ;volta dado original bcd
    ANL A, #0F0h    ; zera bits do algarismo unidade
    RR A            ;girando ate valores ficarem nos bits menos significativos
    RR A
    RR A
    RR A
    ORL A, #30h     ;somando 30h pra virar ascii
	MOV 30h, A
	RET
	
	
	doInstruction:
		CLR		LCD_RS
		SETB	LCD_RW
		SETB	LCD_BUSY
		busy:											;checa se a instrucao terminou
			SETB 	LCD_EN
			JNB 		LCD_BUSY, notBusy
			CLR 		LCD_EN
			JMP 		busy							;modificiado, pulava pro busy
		notBusy:
			CLR 		LCD_RW
			RET

	sendInstruction:
		ACALL	doInstruction
		CLR		LCD_RS
		SETB	LCD_EN
		MOV		LCD_DATA, 	A
		CLR		LCD_EN
		RET

	startLCD:
		MOV 	A,	#0x30
		ACALL	sendInstruction
		ACALL	sendInstruction
		ACALL	sendInstruction
		MOV		A,	#0x38
		ACALL	sendInstruction
		MOV		A,	#0x0C
		ACALL	sendInstruction
		MOV		A,	#0x02
		ACALL	sendInstruction
		MOV		A,	#0x01
		ACALL	sendInstruction
		RET

	sendDataMode:								;ativa o modo de envio de dados
		ACALL	doInstruction
		SETB	LCD_RS
		CLR		LCD_RW
		SETB	LCD_EN
		MOV		LCD_DATA, A
		CLR		LCD_EN
		RET

	sendPositionMode:						;ativa o modo de envio de posicao
		ACALL	doInstruction
		CLR		LCD_RS
		CLR		LCD_RW
		SETB	LCD_EN
		MOV		LCD_DATA, A
		CLR		LCD_EN
		RET

	sendString:								;colocar a string no DPTR e a posicao no LCD_POSITION ANTES DE CHAMAR
		MOV 	A, LCD_POSITION	
		ACALL 	sendPositionMode
	sendWhatsLeft:
		MOV		A,	#00h
		MOVC 	A, @A+DPTR
		JZ 		endString
		ACALL 	sendDataMode
		INC 		DPTR
		JMP		sendWhatsLeft					;se voltar pro send String vai escrever em cima
	endString:
		RET

	sendNumber:
		MOV		AUX_A, A
		MOV 	A, LCD_POSITION							;Nao sei se eh boa pratica colocar no B, mas pra poder usar de novo essas funcoes e garantir que nao vai apagar um registrador que a gente precise usar...
		ACALL 	sendPositionMode
		MOV		A, AUX_A
		ACALL 	sendDataMode
		RET
		
;--------FUNCAO TECLADO ---------------------------------------
returnPressedKey:
		MOV 	DELAY_TIME, #0Ah 		// R0 x 20 ms de delay - para nao sentir o efeito de bounce no teclado matricial
		ACALL 	timerDelay20ms

		CLR  	COL1
		SETB 	COL2
		SETB 	COL3
		SETB 	COL4
		JNB  	LIN1, digit1
		JNB  	LIN2, digit2
		JNB  	LIN3, digit3
		JNB  	LIN4, digitA
		
		CLR  	COL2
		SETB 	COL1
		JNB  	LIN1, digit4
		JNB  	LIN2, digit5
		JNB  	LIN3, digit6
		JNB  	LIN4, digitB
		
		CLR  	COL3
		SETB 	COL2
		JNB  	LIN1, digit7
		JNB  	LIN2, digit8
		JNB  	LIN3, digit9
		JNB  	LIN4, digitC
		
		CLR  	COL4
		SETB 	COL3
		JNB  	LIN1, ast
		JNB  	LIN2, digit0
		JNB  	LIN3, hash
		JNB  	LIN4, digitD
		
		JMP  	returnPressedKey

		digit1: 
			MOV 	A, #1h
			AJMP 	saveKeyValue
		digit2: 
			MOV 	A, #2h
			AJMP 	saveKeyValue
		digit3: 
			MOV 	A, #3h
			AJMP 	saveKeyValue
		digit4: 
			MOV 	A, #4h
			AJMP 	saveKeyValue
		digit5: 
			MOV 	A, #5h
			AJMP 	saveKeyValue
		digit6: 
			MOV 	A, #6h
			AJMP 	saveKeyValue
		digit7: 
			MOV 	A, #7h
			AJMP 	saveKeyValue
		digit8: 
			MOV 	A, #8h
			AJMP 	saveKeyValue
		digit9: 
			MOV 	A, #9h
			AJMP 	saveKeyValue
		digit0: 
			MOV 	A, #0h
			AJMP 	saveKeyValue

		digitA: 
			MOV 	A, #0Ah
			AJMP 	saveKeyValue 
		digitB: 
			MOV 	A, #0Bh
			AJMP 	saveKeyValue
		digitC: 
			MOV 	A, #0Ch
			AJMP 	saveKeyValue
		digitD: 
			MOV 	A, #0Dh
			AJMP 	saveKeyValue

		ast: 
			MOV 	A, #14h
			AJMP 	saveKeyValue
		hash: 
			MOV 	A, #15h
			AJMP	saveKeyValue

		saveKeyValue:
			MOV 	2Ah, A
			RET
			
;--------FUNCOES RTC e I2C--------------------------------------------
initTime: ;inicia o tempo e o I2C
	MOV SEC, #00h ; BCD segundos, deve ser iniciado 
								; com valor PAR para o relogio funcionar.
	MOV MIN, #00h ; BCD minutos
	MOV HOU, #22h ; BCD hora, se o bit mais alto for 1,
								; o relogio e 12h, senao BCD 24h
	MOV DAY, #06h ; Dia da semana
	MOV DAT, #20h ; Dia
	MOV MON, #10h ; Mes
	MOV YEA, #17h ; Ano
	MOV CTR, #00h ; SQW desativada em nivel 0
	
	SETB SDA
	SETB SCL
	RET

	;nao parece ter funcionando usando as flags STA e STO, entao vou fazer na mao
restart:
	CLR SCL
	SETB SDA
	NOP
	SETB SCL
	CLR SDA
	RET

start:
	SETB SCL
	NOP
	CLR SDA
	CLR SCL
	RET
	
stop:
	CLR SCL
	CLR SDA
	SETB SCL
	SETB SDA
	RET

send:
	MOV SIZE, #08
	sendback:
		CLR SCL
		RLC A
		MOV SDA, C
		SETB SCL
		DJNZ SIZE, sendback
	CLR SCL
	SETB SDA
	SETB SCL
	MOV C, SDA
	CLR SCL
	RET

receive:
	MOV SIZE, #08
	receiveback:
		CLR SCL
		SETB SCL
		MOV C, SDA
		RLC A
		DJNZ SIZE, receiveback
	CLR SCL
	SETB SDA
	RET
	
ack:
	CLR SDA
	SETB SCL
	CLR SCL
	SETB SDA
	RET

nack:
	SETB SDA
	SETB SCL
	CLR SCL
	SETB SCL
	RET

;7-Bit format: 0b1101000 = 0x68
;Slave address for I2C Write: 0b11010000 = 0xD0
;Slave address for I2C Read: 0b11010001 = 0xD1
i2cCheckSend:
	ACALL send
	;JNC i2cCheckSend		;slave nao enviou ACK 
	RET
	
setTime:
	;SEND SLAVE ADDRESS
	ACALL start
	
	MOV A, #0D0h
	ACALL i2cCheckSend
	
	;SEND REGISTER ADDRESS
	
	MOV A, #00h
	
	ACALL i2cCheckSend	
	
	MOV	R0, #50h		;ENDERECO NA MEMORIA DO SEGUNDO
	MOV AUX_A, #8
	
	setTimeLoop:
		MOV A, @R0
		ACALL i2cCheckSend	;a cada send incrementa o endereco dos registradores internos
		INC R0
		DJNZ AUX_A, setTimeLoop
	
	ACALL stop	
	RET
	
getTime:
	;DUMMY WRITE
	;SEND SLAVE ADDRESS
	ACALL start
	
	MOV A, #0D0h
	ACALL i2cCheckSend
	
	;SEND REGISTER ADDRESS
	
	MOV A, #00h
	ACALL i2cCheckSend	

	ACALL restart
	
	MOV A, #0D1h
	ACALL i2cCheckSend	
	
	MOV R0, #50h
	MOV AUX_A, #8
	
	getTimeLoop:
		ACALL receive
		MOV @R0, A
		INC R0
		
		CJNE AUX_A, #1, SendAck
		ACALL nack
		JMP nextRead
		
		sendAck:
			ACALL ack
		nextRead:
			DJNZ AUX_A, getTimeLoop
			ACALL stop
	RET
;----- FUNCOES FIM ----------------------------------------------

;----- Interrupcoes INICIO ----------------------------------------------
int_i2c:
RET

int_timer1:
			;escreve hora atual no LCD
			;CPL LED1			; toggle no led
			MOV R6, #0x03		; 4x
				again:
				MOV MULT, #0xFA		; 250x
				ACALL runT0			; 0.5ms
				DJNZ R6, again		; = 1s

			ACALL	getTime
			MOV LCD_POSITION, #80h
			ACALL printTime
			MOV LCD_POSITION, #0C0h
			ACALL printDays
			CLR TF1
RET

	hello:	db "Amostragem", 0
	clear:	db "               ", 0	
	doispontos:	db ":", 0
		traco:	db "-", 0
	smallclear: db " ", 0
		
	domingo: db"SUN",0
	segunda:db "MON",0
	terca:	 db"TUE",0
	quarta:	db "WED",0
	quinta:	db "THU",0
	sexta:	 db"FRI",0
	sabado: db "SAT",0
	alarme: db "Alarme: ",0

END
