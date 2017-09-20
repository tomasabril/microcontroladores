;Pratica 1 - Teclado Matricial e LCD
;Autor: Isabella Mika Taninaka & Tomas Abril

;OPERANDO EM ASCII halfsize

;Configuracao
	LCD_RS 		EQU	P2.5
	LCD_RW 		EQU	P2.6
	LCD_EN 		EQU	P2.7
	LCD_DATA		EQU	P0
	LCD_BUSY		EQU	P0.7
	
		ORG 2000h
		JMP start
		ORG 2100h

	delay1sec:
		MOV		2Fh, #22h
		dloop3:
		MOV R7, #250d 
		;repete delay de 0,5ms 250 vezes
		delay_do_delay:
			MOV R6, #100d
			;gasta 2 us cada vez, 500 us no total
			delay0:
				DJNZ R6, delay0
			DJNZ R7, delay_do_delay
		DJNZ R0, dloop3
		MOV		2Fh, #00h
		RET
		
		delay1secDEVERDADE:
		MOV		2Fh, #22h
		dloop31:
		MOV R7, #221d 
		;repete delay de 0,5ms 250 vezes
		delay_do_delay1:
			MOV R6, #250d
			;gasta 2 us cada vez, 500 us no total
			delay01:
				DJNZ R6, delay01
			DJNZ R7, delay_do_delay1
		DJNZ R0, dloop31
		MOV		2Fh, #00h
		RET
;Escreve Saudacao
	start:

		ACALL		startLCD
		MOV 		DPTR, 	#hello	
		MOV 		B, 		#80h			;linha 1, coluna 1
		ACALL				sendString									
		;Uma variavel para cada tabuada de 1 a 9
													;Vai guardar o multiplicando, NAO O VALOR DA MULTIPLICACAO 
													;Senao ia precisar descobrir o multiplicando cada vez que trocasse 
		MOV		A, #30h                    	;zero em ascii
		MOV		21h, A                       ;1 - R1 com RS1 e RS2 em 0 0 - 01h
		MOV		22h, A                       ;2 - R2 com RS1 e RS2 em 0 0 - 02h
		MOV		23h, A                       ;3 - R3 com RS1 e RS2 em 0 0 - 03h
		MOV		24h, A                       ;4 - R4 com RS1 e RS2 em 0 0 - 04h
		MOV		25h, A                       ;5 - R5 com RS1 e RS2 em 0 0 - 05h
		MOV		26h, A                       ;6 - R6 com RS1 e RS2 em 0 0 - 06h
		MOV		27h, A                       ;7 - R7 com RS1 e RS2 em 0 0 - 07h
		MOV		28h, A                       ;8 - R1 com RS1 e RS2 em 0 1 - 08h
		MOV		29h, A                       ;9 - R2 com RS1 e RS2 em 0 1 - 09h
		MOV		2Ah, A
		MOV		2Bh, A
		MOV		2Ch, A
;Espera Input
	;Mantem a tela anterior ate nova entrada
		;Entrada Atual 0Ah -> mandar ela em ascii pelo amor de deus
	;Multiplicador Atual 0Bh
	;Multiplicando Atual 0Ch
	;Resposta  em A 0Dh
	
	;tudo vai ser guardado ja em ascii e se nao der problema vai ser show
	;lembrar de tirar 30h cada vez que for operar 
				
	waitingInput:
		;ACALL delay1sec
		ACALL 				returnPressedKey
		MOV		A, 		2Ah
		CJNE	A, 		#0FFh,	if1			;Arranjar uma solucao melhor que essa pra garantir que a entrada @e de 1 a 9
		AJMP	goBack
	goBack:
		AJMP	waitingInput
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
		CJNE	A,			#09h, 	notValid
		AJMP 	valid
	notValid:
		AJMP	goBack
	valid:
		ADD		A, 		#30h				;ascii
		MOV		2Ah, 		A
	writeTitle:
		MOV 	DPTR,	#title
		MOV		B,			#80h
		ACALL				sendString
		
		MOV		A,			2Ah
		MOV		B,			#88h		;poem o numero
		ACALL				sendNumber
		MOV		A, 2Ah
		CJNE	A, 2Bh, 	inputNotEqual
		
		
		;Se entrada atual  == entrada anterior, continua multiplicando
		;o mul usa 4 ciclos pra resolver e o add/inc usa 1 so. Como eh a proxima fracao, da pra acelerar um pouco aqui
		;e cada vez que usa o mul ab, os valores que tao nos dois vao ser perdido
		;entao vai precisar copiar tudo deles pra fora e os operando de volta pra eles a cada operacao

		;soma 1 no multiplicando
		;soma o multiplicador com resposta anterior e tira 30h
		
		;Multiplicador Atual 0Bh
		;Multiplicando Atual 0Ch
		;Resposta  em A 0Dh
		
	inputEqual:
		INC		2Ch
		MOV		A, 		2Ch
		CJNE	A,			#3Ah, smallerThan10
		MOV		2Ch,		#30h
		MOV		2Dh,		#00h
	smallerThan10:
		MOV		A,			2Ch
		CJNE	A, 		#30h, isntZero
		AJMP	isZero
	isntZero:
		MOV		A, 		2Bh
		CLR		C
		SUBB	A,			#30h
		ADD		A,			2Dh
		MOV		2Dh,		A
	isZero:
		ACALL				printEq
		LJMP				fim
	
	;Se entrada atual != entrada anterior		
	inputNotEqual:
		;not working
		MOV		A,			2Bh
		CLR		C
		SUBB	A, 		#10h			;gera o enderaco que guarda o multiplicando
		MOV		R0, 		A
		INC		2Ch
		MOV		A, 		2Ch
		CJNE	A,			#3Ah, smallerThan101
		MOV		2Ch,		#30h
		MOV		2Dh,		#00h
	smallerThan101:
		MOV		@R0,		2Ch
		
		MOV		2Bh, 		2Ah			;copia a entrada atual para o entrada anterior
		
		MOV		A,			2Bh
		CLR		C
		SUBB	A, 		#10h			;gera o enderaco que guarda o multiplicando
		MOV		R0, 		A
		MOV		2Ch, 	@R0			;copia 2Ch para o  @(0Bh - 30h + 20h)
		
		MOV		A, 		2Ah		
		MOV		A, 		2Ch			;2Ch sempre guarda ascii
		CLR		C
		SUBB	A, 		#30h			
		MOV		B, 		A				;Coloca o multiplicando no B
		MOV 	A, 		2Bh
		CLR		C
		SUBB	A,			#30h			;gera o valor real do multiplicador ie 33h -> 03h
		MUL		AB
		MOV		2Dh, 		A				;guarda a resposta original 2Dh eh o unico que nao guarda ascii!!!! pq pode ter mais de um digito!!!!!
		ACALL 				printEq
		LJMP				fim

	fim: 
		MOV		A,			2Bh
		CJNE	A, #39h, 	doNothing
		MOV		A, 		2Ch
		CJNE	A, #39h, 	doNothing
		CLR		P2.0
 		ACALL delay1secDEVERDADE
		SETB	P2.0
	doNothing:
		LJMP	waitingInput
		
		

;;https://stackoverflow.com/questions/14261374/8051-lcd-hello-world-replacing-db-with-variable		
	number2ascii:							;colocar o numero que quer tranformar em A
		MOV 	B, 		#10
		DIV		AB
		ADD		A, 		#30h
		MOV 	30h, A
		INC		DPTR
		
		MOV		A,			B
		ADD		A,			#30h
		MOV		31h, A
		RET


	;imprimi no LCD
		;muda a primeira linha
		;multiplicador x multiplicando = resposta
		;0Bh 'x' 0Ch = A	
	printEq:
		MOV		A,			2Bh
		MOV		B,			#0C0h		;linha 2, coluna 1
		ACALL				sendNumber
		
		MOV 	DPTR,	#x
		MOV		B,			#0C1h		;linha 2, coluna 3
		ACALL				sendString
		
		MOV		A,			2Ch
		CJNE	A,	#3Ah, isnt10
		AJMP is10
	isnt10:
		MOV		B,			#0C2h		;linha 2, coluna 5
		ACALL				sendNumber
		
		MOV 	DPTR,	#equal
		MOV		B,			#0C3h			;linha 2, coluna 7
		ACALL				sendString
		
		MOV		A,			2Dh
		ACALL number2ascii
		MOV		A,			30h
		MOV		B,			#0C4h		;linha 2, coluna 9
		ACALL				sendNumber
		MOV		A,			2Dh
		ACALL number2ascii
		MOV		A,			31h
		MOV		B,			#0C5h		;linha 2, coluna 9
		ACALL				sendNumber		
		RET
		
	is10:
		MOV		A,			2Ch
		ACALL number2ascii
		MOV		A,			30h
		MOV		B,			#0C4h		;linha 2, coluna 9
		ACALL				sendNumber
		MOV		A,			2Dh
		ACALL number2ascii
		MOV		A,			31h
		MOV		B,			#0C5h		;linha 2, coluna 9
		ACALL				sendNumber	
		RET
		
				MOV 	DPTR,	#equal
		MOV		B,			#0C3h			;linha 2, coluna 7
		ACALL				sendString
		
		MOV		A,			2Dh
		ACALL number2ascii
		MOV		A,			30h
		MOV		B,			#0C4h		;linha 2, coluna 9
		ACALL				sendNumber
		MOV		A,			2Dh
		ACALL number2ascii
		MOV		A,			31h
		MOV		B,			#0C5h		;linha 2, coluna 9
		ACALL				sendNumber		
		RET

;Funcoes Teclado
;Funcoes Teclado
	;http://what-when-how.com/8051-microcontroller/keyboard-interfacing/
returnPressedKey:						;retorna FF enquanto nao estiver apertada
	
		MOV	A, 2Ah
		CJNE A, #0FFh, botValido
        JMP botFF
        botValido:
        MOV 2Eh, 2Ah
        botFF:

	CLR P1.0
	JNB P1.4, bot1
	JNB P1.5, bot2
	JNB P1.6, bot3
	JNB P1.7, botA

	SETB P1.0
	CLR P1.1
	JNB P1.4, bot4
	JNB P1.5, bot5
	JNB P1.6, bot6
	JNB P1.7, botB

	SETB P1.1
	CLR P1.2
	JNB P1.4, bot7
	JNB P1.5, bot8
	JNB P1.6, bot9
	JNB P1.7, botC

	SETB P1.2
	CLR P1.3
	JNB P1.4, botAST
	JNB P1.5, bot0
	JNB P1.6, botHASH
	JNB P1.7, botD
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
		MOV 2Ah, #10h
		JMP retornaBotao
	botB:
		MOV 2Ah, #11h
		JMP retornaBotao
	botC:
		MOV 2Ah, #12h
		JMP retornaBotao
	botD:
		MOV 2Ah, #13h
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
			CLR	C
			SUBB A, #30h
			CJNE A, 2Ah, fimleitura
			ACALL delay1sec
		fimleitura:
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

		
	hello:	db "Pratica1 ", 0
	title:		db "Tabuada ", 0
	x: 			db "x", 0
	buffer:	ds 17
	equal:	db "=", 0
		
	END