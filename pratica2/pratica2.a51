;Pratica 2 - Bobinador, 
;Autor: Isabella Mika Taninaka & Tomas Abril

;OPERANDO EM ASCII halfsize

;Configuracao
	LCD_RS 		EQU	P2.5
	LCD_RW 		EQU	P2.6
	LCD_EN 		EQU	P2.7
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
		
		ORG 2100h

;;;;;;;;;;;; aqui comeca nossa "main" <<<<<<<<<<<<<<<<<<<<-----------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Escreve Saudacao
	start:
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
		;ACALL delay1sec
		NOP
		LCALL 	returnPressedKey
		MOV A, 2Ah
		CJNE A, #0FFh, if0		;Arranjar uma solucao melhor que essa pra garantir que a entrada @e de 1 a 9
		AJMP goBack
	goBack:
		MOV	DPTR, #hello
		MOV	B, #80h		;linha 1, coluna 1
		ACALL	sendString
		AJMP	waitingInput
	
	if0:
		CJNE	A,			#00h, 	if1
		AJMP	valid
	if1:
		CJNE	A,			#01h, 	if2
		AJMP	valid
	if2:
		CJNE	A,			#02h, 	if3
		AJMP	valid
	if3:
		CJNE	A,			#03h, 	if4
		AJMP	valid
	if4:
		CJNE	A,			#04h, 	if5
		AJMP	valid
	if5:
		CJNE	A,			#05h, 	if6
		AJMP	valid
	if6:
		CJNE	A,			#06h, 	if7
		AJMP	valid
	if7:
		CJNE	A,			#07h, 	if8
		AJMP	valid
	if8:
		CJNE	A,			#08h, 	if9
		AJMP	valid
	if9:
		CJNE	A,			#09h, 	ifa
		AJMP 	valid
	ifa:
		CJNE	A,			#0Ah, 	ifb
		AJMP 	valid
	ifb:
		CJNE	A,			#0Bh, 	ifast
		AJMP 	valid
	ifast:
		CJNE	A,			#14h, 	notValid
		AJMP 	start
	notValid:
		MOV		DPTR, #invalidomsg
		MOV		B, #80h
		ACALL	sendString
		MOV		DPTR, #clearmsg
		MOV		B, #0C0h
		ACALL	sendString
		ACALL  returnPressedKey
		MOV		A, 2Ah
		MOV 3Bh, #00h
		MOV 3Ch, #04h
		CJNE	A, #14h, notValid
		AJMP	goBack
	valid:
		
		
; nosso numero de voltas ficara em 3Bh
	; 3CH e o contador de quantos numeros ja foram digitados, comeca em 4
		DJNZ 3Ch, numero
		AJMP sentido
		numero:
			MOV A, 2Ah
			MOV A, 3Ch
			CJNE A, #03h, dezena
		centena:
			MOV A, 2Ah
			MOV B, A	;Coloca o multiplicando no B
			MOV A, #100d
			CLR C
			MUL AB
			;;MOV 2Dh, A		;resultado em A
			ADD A, 3Bh
			MOV	3Bh, A
			MOV 3Ah, #0C0h
			ACALL printvoltas
			AJMP waitingInput
		dezena:
			MOV A, 3Ch
			CJNE A, #02h, unidade
			MOV A, 2Ah
			MOV B, A	;Coloca o multiplicando no B
			MOV A, #10d
			CLR C
			MUL AB
			;;MOV 2Dh, A		;resultado em A
			ADD A, 3Bh
			MOV	3Bh, A
			INC	3Ah
			ACALL printvoltas
					AJMP waitingInput
		unidade:
			MOV A, 3Ch
			CJNE A, #01h, sentido
			MOV A, 2Ah
			MOV B, A	;Coloca o multiplicando no B
			MOV A, #1d
			CLR C
			MUL AB
			;;MOV 2Dh, A		;resultado em A
			ADD A, 3Bh
			MOV	3Bh, A
			MOV	3Bh, A
			INC	3Ah
			ACALL printvoltas
					AJMP waitingInput
		sentido:
			MOV A, 3Bh
			CLR C
			SUBB A, #255d
			JC	sentidovalido
			JNZ	notValid
			JMP	sentidovalido
		sentidovalido:
		velocvalido:
			MOV DPTR, #velocidademsg 
			MOV B, #80h
			ACALL sendString
			
			MOV DPTR, #clearmsg
			MOV B, #0C0h
			ACALL sendString
			
			ACALL returnPressedKey
			MOV	A, 2Ah
			CJNE A, #0Ch, ifD
			AJMP devagar
			ifD:
				CJNE A, #0Dh, velocvalido
				AJMP rapido
		devagar:
			MOV R4, #6d
			MOV DPTR, #devagarmsg
			MOV B,  #0C0h
			ACALL sendString
			AJMP velocidadesetada
			
		rapido:
			MOV R4, #3d
			MOV DPTR, #rapidomsg
			MOV B,  #0C0h
			ACALL sendString
			AJMP velocidadesetada
		
		velocidadesetada:
			MOV DPTR, #sentidomsg 
			MOV B, #80h
			ACALL sendString
			
			ACALL returnPressedKey
			MOV	A, 2Ah
			CJNE A, #0Ah, antihorario
		horario:
			MOV DPTR, #hello
			MOV B, #80h
			ACALL sendString
			
			MOV A, 3Bh
			MOV 3Ah, #0C0h
			ACALL printEq

			ACALL umavoltahorario	
			MOV A, R3
			JZ restart1
			
			DJNZ 3Bh, horario
			AJMP fim
		antihorario:
			CJNE A, #0Bh, provavelmenteinvalido
		antihorario1:
			MOV DPTR, #hello
			MOV B, #80h
			ACALL sendString			
			MOV A, 3Bh
			MOV 3Ah, #0C0h
			ACALL printEq
			ACALL umavoltaantihorario
			DJNZ 3Bh, antihorario1
			AJMP fim
			
		restart1:
			LJMP start
		
		provavelmenteinvalido:
			CJNE A, #14h, velocidadesetada
			AJMP waitingInput
		
		presentidovalido:
			LJMP sentidovalido

		
		fim:
		MOV	DPTR, #fimmsg
		MOV	B, #80h		;linha 1, coluna 1
		ACALL	sendString
		MOV		DPTR, #clearmsg
		MOV		B, #0C0h
		ACALL	sendString
		ACALL  returnPressedKey
		MOV		A, 2Ah
		MOV 3Bh, #00h
		MOV 3Ch, #04h
		CJNE	A, #14h, fim
		AJMP start	
	
		
	printvoltas:
		;; escreve na tela o valor digitado ate agora
		MOV A, 2Ah
		ADD A, #30h
		MOV B, 3Ah
		ACALL sendNumber
		RET

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
	;; reference: https://www.8051projects.net/wiki/Stepper_Motor_Tutorial
	umavoltahorario:
		;; em A colocar a quantidade de passos para dar uma volta
		MOV R2, #4d
		repetehorario:
		MOV R1, #129d
		umpasso_h:
			MOV A, R3
			JZ restart
			AJMP go
			restart: 
			RET
			go:
			SETB P2.0
			SETB P2.1
			CLR P2.2
			CLR P2.3
			ACALL delayrapido
			CLR P2.0
			SETB P2.1
			SETB P2.2
			CLR P2.3
			ACALL delayrapido
			CLR P2.0
			CLR P2.1
			SETB P2.2
			SETB P2.3
			ACALL delayrapido
			SETB P2.0
			CLR P2.1
			CLR P2.2
			SETB P2.3
			ACALL delayrapido
			DJNZ R1, umpasso_h
		DJNZ R2, repetehorario
		RET

	umavoltaantihorario:
		;; em A colocar a quantidade de passos para dar uma volta
		MOV R2, #4d
		repeteantihorario:
			MOV R1, #129d
		umpasso_ah:
			MOV A, R3
			JZ antirestart
			AJMP antigo
			antirestart: 
			RET
			antigo:
			SETB P2.0
			CLR P2.1
			CLR P2.2
			SETB P2.3
			ACALL delayrapido
			CLR P2.0
			CLR P2.1
			SETB P2.2
			SETB P2.3
			ACALL delayrapido
			CLR P2.0
			SETB P2.1
			SETB P2.2
			CLR P2.3
			ACALL delayrapido
			SETB P2.0
			SETB P2.1
			CLR P2.2
			CLR P2.3
			ACALL delayrapido
			DJNZ R1, umpasso_ah
		DJNZ R2, repeteantihorario
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
		MOV R7, #200d 
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
		
	hello:	db "N. de Voltas: ", 0
	sentidomsg: db "Sentido:		",0
	
	velocidademsg: db "Velocidade:		",0
	rapidomsg: db "Rapido		",0
	devagarmsg: db "Devagar		",0

	fimmsg:	db "Fim             ", 0
	invalidomsg:	db "Invalido!       ", 0
	validomsg:	db "valido!       ", 0

	clearmsg:	db "          ", 0
	END
