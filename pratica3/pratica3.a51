;Pratica 3 - Motor DC, PWM
;Autor: Isabella Mika Taninaka & Tomas Abril

;OPERANDO EM ASCII halfsize

;;
;  P2.0 é o pino de saida no PWM_SETUP
;  3Bh é o espaco de memoria que controla a largura do pulso. de 0d a 255d
;  P2.1 e P2.2 são as saidas que vao pro IN1 e IN2 da ponte H
;; 

;Configuracao
	LCD_RS		EQU	P2.5
	LCD_RW		EQU	P2.6
	LCD_EN		EQU	P2.7
	LCD_DATA		EQU	P0
	LCD_BUSY		EQU	P0.7
	
		ORG 2000h
		
		MOV IE, 		#10000001b
		MOV IP,			#00000000b
		MOV TCON, 	#00000001b
		
		JMP start
		
		ORG 2010h
			MOV R3, #0
		RETI
		
		
;;;;interrupcao do timer 0 ;;;;;;;;;;;;;;;;;;
; sobre timers
; http://what-when-how.com/8051-microcontroller/programming-8051-timers/

ORG 00Bh
TIMER_0_INTERRUPT:
	; tempo de HIGH é setado baseado em 3Bh, tempo de LOW é FFh -(menos) tempo de high
	; F0 é apenas um bit para alternar entre as duas funcoes possiveis abaixo
	; tem algo melhor que F0 pra usar? nao sei
	
	JB F0, HIGH_DONE	; If F0 flag is set then we just finished
						; the high section of the cycle so Jump to HIGH_DONE
	LOW_DONE:
		SETB F0			; Make F0=1 to indicate start of high section
		SETB P2.0		; Make PWM output pin High
		MOV TH0, 3Bh	; Load high byte of timer with 3Bh
						; (pulse width control value)
		CLR TF0			; Clear the Timer 0 interrupt flag
		RETI
	HIGH_DONE:
		CLR F0			; Make F0=0 to indicate start of low section
		CLR P2.0		; Make PWM output pin low
		MOV A, #0FFH	; Move FFH (255) to A
		CLR C			; Clear C (the carry bit) so it does; not affect the subtraction
		SUBB A, 3Bh		; Subtract 3Bh from A. A = 255 - 3Bh
		MOV TH0, A		; so the value loaded into TH0 + 3Bh = 255
		CLR TF0			; Clear the Timer 0 interrupt flag
		RETI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		ORG 2100h

;;;;;;;;;;;; aqui comeca nossa "main" <<<<<<<<<<<<<<<<<<<<-----------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Escreve Saudacao
	start:
	
		PWM_SETUP:
		MOV TMOD,#01h ; Timer0 in Mode 1
		;; largura do pulso pode ser entre 0 e 255d
		MOV 3Bh, #0d ; essa memoria controla a largura do pulso
		SETB EA 	; Enable Interruptions
		;;SETB ET0 ; Enable Timer 0 Interrupt; se ja ligou todas não precisa, certo?
		SETB TR0 ; Start Timer
		
		ACALL paramotor

		MOV R3, #1
		MOV 3Bh, #00h
		MOV 3Ch, #04h
		MOV R2, #0C0h
		ACALL	startLCD
		
		
		MOV	DPTR, #hello
		MOV	B, #80h		;linha 1, coluna 1
		ACALL	sendString

;Espera entrada
	
	waitingInput:
		NOP
		LCALL 	returnPressedKey
		MOV A, 2Ah
		CJNE A, #0FFh, if0		;Arranjar uma solucao melhor que essa pra garantir que a entrada @e de 1 a 9
		AJMP goBack
	goBack:
		;MOV	DPTR, #hello
		;MOV	B, #80h		;linha 1, coluna 1
		;ACALL	sendString
		AJMP	waitingInput
	
	if0:
		CJNE	A,			#00h, 	if1
		AJMP	apertouzero
	if1:
		CJNE	A,			#01h, 	if2
		AJMP	perc20
	if2:
		CJNE	A,			#02h, 	if3
		AJMP	perc40
	if3:
		CJNE	A,			#03h, 	if4
		AJMP	perc60
	if4:
		CJNE	A,			#04h, 	if5
		AJMP	perc80
	if5:
		CJNE	A,			#05h, 	ifast
		AJMP	perc100
	ifast:
		CJNE	A,			#14h, 	ifhash
		AJMP 	girahorario
	ifhash:
		CJNE	A,			#15h, 	notValid
		AJMP 	giraantihorario

	notValid:
		MOV		DPTR, #invalidomsg
		MOV		B, #80h
		ACALL	sendString
		MOV		DPTR, #clearmsg
		MOV		B, #0C0h
		ACALL	sendString
		AJMP	goBack
		
		
	girahorario:
		;; falta mostrar firecao do motor no LCD
		ACALL umavoltahorario
		AJMP waitingInput
	giraantihorario:
		ACALL umavoltaantihorario
		AJMP waitingInput
	
	apertouzero:
		ACALL paramotor
		AJMP waitingInput

	perc20:
		;; falta mostrar velocidade do motor do LCD
		MOV 3Bh, #51d
		AJMP valid
	perc40:
		MOV 3Bh, #102d
		AJMP valid
	perc60:
		MOV 3Bh, #153d
		AJMP valid
	perc80:
		MOV 3Bh, #204d
		AJMP valid
	perc100:
		MOV 3Bh, #255d
		AJMP valid

	valid:
		; velocidade do motor ficara em 3Bh
		AJMP waitingInput


		fim:
		MOV	DPTR, #fimmsg
		MOV	B, #80h		;linha 1, coluna 1
		ACALL	sendString
		MOV		DPTR, #clearmsg
		MOV		B, #0C0h
		ACALL	sendString

		AJMP start
	


;;;;;;;;;;;; aqui acaba nossa "main" <<<<<<<<<<<<<<<<<<<<<-----------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Funcoes do motor

	;;aproximadamente 0,01sec provavelmente
	delayrapido:
		rloop3:
		MOV A, R4
		MOV R7, A 
		;repete delay de 0,5ms 250 vezes
		rdelay_do_delay:
			MOV R6, #1d
			;gasta 2 us cada vez, 500 us no total
			rdelay0:
				DJNZ R6, rdelay0
			DJNZ R7, rdelay_do_delay
		DJNZ R0, rloop3
		RET

	;; dar uma volta no motor de passo
	;;   a velocidade depende da funcao delay rapido
	;; usando a ponte H do link abaixo
	;; https://www.filipeflop.com/blog/motor-dc-arduino-ponte-h-l298n/
	umavoltahorario:
		; seta o motor pra girar sentido horario
		SETB P2.1
		CLR P2.2
		RET

	umavoltaantihorario:
		; seta o motor pra girar sentido anti-horario
		CLR P2.1
		SETB P2.2
		RET
	
	paramotor:
		; motor colocado no ponto morto
		CLR P2.1
		CLR P2.2
		RET
		
;;https://stackoverflow.com/questions/14261374/8051-lcd-hello-world-replacing-db-with-variable		
	number2ascii:							;colocar o numero que quer tranformar em A
		MOV 	B, 		#100d
		DIV		AB
		ADD		A, 		#30h
		MOV 	30h, A
		
		MOV		A, 		B
		
		MOV 	B, 		#10d
		DIV		AB
		ADD		A, 		#30h
		MOV 	31h, A
		
		MOV		A,			B
		ADD		A,			#30h
		MOV		32h, A
		RET


	;imprimi no LCD
		;muda a primeira linha
		;multiplicador x multiplicando = resposta
		;0Bh 'x' 0Ch = A	
	printEq:
		ACALL number2ascii
		MOV		A,			30h
		MOV		B,			3Ah
		ACALL				sendNumber
		MOV		A,			31h
		INC		B
		ACALL				sendNumber		
		MOV		A,			32h
		INC 		B
		ACALL				sendNumber		
		RET


;Funcoes Teclado
	;http://what-when-how.com/8051-microcontroller/keyboard-interfacing/
returnPressedKey:						;retorna FF enquanto nao estiver apertada
	
		MOV	A, 2Ah
		CJNE A, #0FFh, botValido
        JMP botFF
        botValido:
        MOV 2Eh, 2Ah
        botFF:
	
	SETB P1.0
	SETB P1.1
	SETB P1.2
	SETB P1.3
	
	
	CLR P1.0
	JNB P1.4, bot1
	JNB P1.5, bot2
	JNB P1.6, bot3
	JNB P1.7, botA
	;ACALL shortDelay

	SETB P1.0
	CLR P1.1
	JNB P1.4, bot4
	JNB P1.5, bot5
	JNB P1.6, bot6
	JNB P1.7, botB
	;ACALL shortDelay
	
	SETB P1.1
	CLR P1.2
	JNB P1.4, bot7
	JNB P1.5, bot8
	JNB P1.6, bot9
	JNB P1.7, botC
	;ACALL shortDelay

	SETB P1.2
	CLR P1.3
	JNB P1.4, botAST
	JNB P1.5, bot0
	JNB P1.6, botHASH
	JNB P1.7, botD
	;ACALL shortDelay
	
	MOV 2Ah, #0FFh
	JMP fimleitura

	bot1:
		MOV 2Ah, #01h
		JMP retornaBotao
	bot2:
		MOV 2Ah, #02h
		JMP retornaBotao
	bot3:
		MOV 2Ah, #03h
		JMP retornaBotao
	bot4:
		MOV 2Ah, #04h
		JMP retornaBotao
	bot5:
		MOV 2Ah, #05h
		JMP retornaBotao
	bot6:
		MOV 2Ah, #06h
		JMP retornaBotao
	bot7:
		MOV 2Ah, #07h
		JMP retornaBotao
	bot8:
		MOV 2Ah, #08h
		JMP retornaBotao
	bot9:
		MOV 2Ah, #09h
		JMP retornaBotao
	bot0:
		MOV 2Ah, #00h
		JMP retornaBotao
	botA:
		MOV 2Ah, #0Ah
		JMP retornaBotao
	botB:
		MOV 2Ah, #0Bh
		JMP retornaBotao
	botC:
		MOV 2Ah, #0Ch
		JMP retornaBotao
	botD:
		MOV 2Ah, #0Dh
		JMP retornaBotao
	botAST:
		MOV 2Ah, #14h
		JMP retornaBotao
	botHASH:
		MOV 2Ah, #15h
		JMP retornaBotao

	retornaBotao:
		SETB P1.0
		SETB P1.1
		SETB P1.2
		SETB P1.3
		;; se o botao apertado ainda e o mesmo esperar delay
		mesmo:
			MOV A, 2Eh
			CJNE A, 2Ah, fimleitura
			ACALL delay1sec
		fimleitura:
		RET

	delay1sec:
		MOV		2Fh, #22h
		dloop3:
		MOV R7, #170d 
		;repete delay de 0,5ms 250 vezes
		delay_do_delay:
			MOV R6, #250d
			;gasta 2 us cada vez, 500 us no total
			delay0:
				DJNZ R6, delay0
			DJNZ R7, delay_do_delay
		DJNZ R0, dloop3
		MOV		2Fh, #00h
		RET
		
	shortDelay:
		MOV R6, #200d
		shortLoop:
			DJNZ R6, shortLoop
		RET


;Funcoes do LCD
	doInstruction:
		CLR		LCD_RS
		SETB	LCD_RW
		SETB	LCD_BUSY
		busy:											;checa se a instrucao terminou
			SETB 	LCD_EN
			JNB 		LCD_BUSY, 	notBusy
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
		MOV 	A,		#0x30
		ACALL			sendInstruction
		ACALL			sendInstruction
		ACALL			sendInstruction
		MOV		A,		#0x38
		ACALL			sendInstruction
		MOV		A,		#0x0C
		ACALL			sendInstruction
		MOV		A,		#0x02
		ACALL			sendInstruction
		MOV		A,		#0x01
		ACALL			sendInstruction
		RET
	
	sendDataMode:								;ativa o modo de envio de dados
		ACALL	doInstruction
		SETB	LCD_RS
		CLR		LCD_RW
		SETB	LCD_EN
		MOV		LCD_DATA, 	A
		CLR		LCD_EN
		RET
	
	sendPositionMode:						;ativa o modo de envio de posicao
		ACALL	doInstruction
		CLR		LCD_RS
		CLR		LCD_RW
		SETB	LCD_EN
		MOV		LCD_DATA,		A
		CLR		LCD_EN
		RET
		
	sendString:									;colocar a string no DPTR e a posicao no B ANTES DE CHAMAR
		MOV 	A, 	B							;Nao sei se eh boa pratica colocar no B, mas pra poder usar de novo essas funcoes e garantir que nao vai apagar um registrador que a gente precise usar...
		ACALL 	sendPositionMode
	sendWhatsLeft:
		MOV		A,		#00h
		MOVC 	A, 	@A+DPTR
		JZ 		endString
		ACALL 	sendDataMode
		INC 		DPTR
		JMP		sendWhatsLeft					;se voltar pro send String vai escrever em cima
	endString:
		RET
	
	sendNumber:
		MOV		R0,	A
		MOV 	A, 	B							;Nao sei se eh boa pratica colocar no B, mas pra poder usar de novo essas funcoes e garantir que nao vai apagar um registrador que a gente precise usar...
		ACALL 	sendPositionMode
		MOV		A, 	R0
		ACALL 	sendDataMode
		RET	
		
	;sendNumberAscii:		
		;MOV 	A, 	B							;Nao sei se eh boa pratica colocar no B, mas pra poder usar de novo essas funcoes e garantir que nao vai apagar um registrador que a gente precise usar...
		;ACALL 	sendPositionMode
	;sendWhatsLeftN:
		;MOVX 	A, 	@DPTR
		;JZ 		endStringN
		;ACALL 	sendDataMode
		;INC 		DPTR
		;JMP		sendWhatsLeftN					;se voltar pro send String vai escrever em cima
	;endStringN:
		;RET		
		
	hello:	db "Motor Parado: ", 0
	sentidomsg: db "Sentido:		",0
	
	velocidademsg: db "Velocidade:		",0
	rapidomsg: db "Rapido		",0
	devagarmsg: db "Devagar		",0

	fimmsg:	db "Fim             ", 0
	invalidomsg:	db "Invalido!       ", 0
	validomsg:	db "valido!       ", 0

	clearmsg:	db "          ", 0
	END
