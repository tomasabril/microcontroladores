;Projeto Minimo

;----- DECLARACOES UNIVERSAIS ----------------------------------
	org 0000h
;--------DECLARACOES EXTRAS -----------------------------------
	AUX_A 				EQU R0
	AMOSTRAGEM	EQU R3
;--------DECLARACOES DELAYS -----------------------------------
	DELAY_TIME 		EQU	R1
	TF					EQU TF0		;mudar se precisar usar o Timer 0
	TR					EQU TR0		
;--------DECLARACOES LCD --------------------------------------
	LCD_RS 			EQU	P2.5
	LCD_RW 			EQU	P2.6
	LCD_EN 			EQU	P2.7
	LCD_DATA 		EQU	P0
	LCD_BUSY			EQU	P0.7
	LCD_POSITION 	EQU	R2
	
;--------DECLARACOES TECLADO ----------------------------------
	COL1 	EQU P2.0
	COL2 	EQU P2.1
	COL3	EQU P2.2
	COL4 	EQU P2.3

	LIN1 		EQU P1.4
	LIN2		EQU P2.4
	LIN3 		EQU P3.3
	LIN4 		EQU P3.5
;--------DECLARACOES SPI ---------------------------------------
	BDRCON EQU 9Bh
;--------DECLARACOES ADC --------------------------------------
	DO 	EQU P1.5
	DI		EQU P1.7
	CK 	EQU P1.6
	CS 	EQU P1.1
	
	LJMP init
;----- DECLARACOES UNIVERSAIS FIM -------------------------------
;----- INTERRUPCOES ---------------------------------------------
		ORG 0023h ;endereco serial
			;SERIAL INTERRUPT
		;serial_int:
			;JNB RI, ri_not_set ;esperando recepcao
			;CLR RI ; byte recebeu, entao devo zerar RI
			 ;para novo byte entrar
			;MOV A,SBUF ;byte recebido e armazenado no acc
			;SJMP end_serial ; vai pro final da subrotina
			;ri_not_set:
				;CLR TI ; se chegou aqui, e pq houve apenas
				 ;transmissao
				;entao zera-se o flag de transmissao
			;end_serial:
		RETI ; quando sair da int serial, volta ao main
		
		ORG 000Bh//200Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
			ACALL int_0
		RETI


;----- MAIN -----------------------------------------------------
	ORG 0100h
;--------Inicializacao ---------------------------------------------
	init:
		ACALL startLCD
		
		;SCON (serial control) register
		;CLR SM0
		;SETB SM1         ;UART mode 1 (8-bit variable)
		;CLR SM2          ;sem multi processamento
		;SETB REN         ;habilita recepcao da serial, receive enable
		;CLR TB8
		;CLR RB8
		;;as linhas acima podem ser substituidas por:
		MOV SCON, #50h
		MOV PCON, #80h
		
		SETB EA          ; habilita todas interrupcoes ; no nosso ja vai ter isso em algum lugar
		SETB ES          ;habilita a interrupcao serial
		SETB ET0
		SETB ET1         ;habilita interrupcao timer 1, parece que nao precisa pq estamos usando apenas pra sincronizar o baud-rate


		;ligando timer 
			;timer 1 controla o baud rate
			;timer 0 taxa de amostragem
		MOV TMOD, #21h      ;timer1, modo 2 auto-reload
		MOV TH1, #243d       ;isso e baud-rate de 4800, ou FAh
		MOV TH0, #100d
		SETB TR1
		SETB TR0
;--------Start ---------------------------------------------------
	mainloop:
		MOV DPTR, #hello
		MOV LCD_POSITION, #80h
		ACALL sendString
		
		ACALL returnPressedKey
		MOV A, 2Ah
		if1:
			CJNE	A,			#01h, 	if2
			MOV		AMOSTRAGEM, #50d
			AJMP	valid
		if2:
			CJNE	A,			#02h, 	if3
			MOV		AMOSTRAGEM, #100d		
			AJMP	valid
		if3:
			CJNE	A,			#03h, 	mainloop
			MOV		AMOSTRAGEM, #200d		
			AJMP	valid
		valid: 
			MOV TH0, AMOSTRAGEM 
			MOV		A, AMOSTRAGEM
			MOV LCD_POSITION, #0C0h
			ACALL printNumber
			ACALL returnPressedKey
			MOV A, 2Ah
			ifAST:
				CJNE	A,			#14h, 	valid
				MOV DPTR, #clear
				MOV LCD_POSITION, #0C0h
				ACALL sendString
				MOV DPTR, #clear
				MOV LCD_POSITION, #80h
				ACALL sendString
				;CLR TR0
		AJMP mainloop

;----- MAIN FIM --------------------------------------------------




;----- FUNCOES--------------------------------------------------
;--------FUNCAO DELAY ------------------------------------------
	timerDelay20ms:
		MOV R6, #200d
			delay0:
				DJNZ R6, delay0
		DJNZ DELAY_TIME, timerDelay20ms
	
		RET

;--------FUNCAO LCD --------------------------------------------
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
	
	printNumber:
		ACALL number2ascii
		MOV A, 30h
		ACALL sendNumber
		MOV A, LCD_POSITION
		INC A
		MOV LCD_POSITION, A
		MOV A, 31h
		ACALL sendNumber
		MOV A, LCD_POSITION
		INC A
		MOV LCD_POSITION, A
		MOV A, 32h
		ACALL sendNumber
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
			
;--------FUNCOES SPI --------------------------------------------
;--------FUNCOES ADC -------------------------------------------
;**********************************************************
; PULSE ÅEpulso de clock para o conversor A/D ADC0832
;**********************************************************
PULSE:
	SETB CK ;CLK em nivel alto
	NOP
	CLR CK ;CLK em nivel baixo
RET

;**********************************************************
; CONVAD ÅEleitura do conversor A/D ADC0832
; ENTRADA: A = endereco do mux
; SAIDA: A = valor da conversao
; DESTROI: B
;**********************************************************
CONVAD: 
	CLR CK
	CLR CS ;habilita o ADC0832
	MOV B, #3 ;3 bits a enviar
LOOPA: 
	RLC A
	MOV DI, C ;envia bit para DI
	ACALL PULSE ;pulso de clock
	DJNZ B, LOOPA
	ACALL PULSE
	MOV B, #8 ;8 bits a receber
LOOP2:
	MOV C, DO ;recebe bit de DO
	RLC A
	ACALL PULSE ;pulso de clock
	DJNZ B, LOOP2
	SETB CS ;desabilita o ADC0832
RET
;----- FUNCOES FIM ----------------------------------------------
	int_0:
			MOV A, #11100000b
			ACALL CONVAD
			MOV AUX_A, A
			MOV SBUF, A              ;carregando SBUF com dados
			parado: 
				JNB TI, parado   ;espera o fim do envio
				CLR TI                   ;limpa TI para ser usado na proxima vez
			MOV A, AUX_A
			MOV LCD_POSITION, #0C4h
			ACALL printNumber
			CLR TF0
			RET


	hello:	db "Amostragem", 0
	clear:	db "               ", 0	

END
