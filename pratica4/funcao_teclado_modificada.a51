
;Funcoes Teclado modificado, testar pra ver se é melhor
	;http://what-when-how.com/8051-microcontroller/keyboard-interfacing/
returnPressedKey:						;retorna FF enquanto nao estiver apertada

		MOV	A, 2Ah
		CJNE A, #0FFh, botValido	; se o ultimo botao apertado for FFh, ou seja nada
        JMP botFF
        botValido:
        MOV 2Eh, 2Ah
        botFF:

	SETB P1.0
	SETB P1.1
	SETB P1.2
	SETB P1.3

	CLR P1.0
	ACALL veryshortDelay
	JNB P1.4, bot1
	JNB P1.5, bot2
	JNB P1.6, bot3
	JNB P1.7, botA

	SETB P1.0
	CLR P1.1
	ACALL veryshortDelay
	JNB P1.4, bot4
	JNB P1.5, bot5
	JNB P1.6, bot6
	JNB P1.7, botB

	SETB P1.1
	CLR P1.2
	ACALL veryshortDelay
	JNB P1.4, bot7
	JNB P1.5, bot8
	JNB P1.6, bot9
	JNB P1.7, botC

	SETB P1.2
	CLR P1.3
	ACALL veryshortDelay
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
		ACALL shortDelay
;		;; se o botao apertado ainda e o mesmo esperar delay
;		mesmo:
;			MOV A, 2Eh
;			CJNE A, 2Ah, fimleitura
;			ACALL delay1sec
	fimleitura:
		RET

	delay1sec:
		dloop3:
		MOV R7, #100d
		;repete delay de 0,5ms 250 vezes
		delay_do_delay:
			MOV R6, #250d
			;gasta 2 us cada vez, 500 us no total
			delay0:
				DJNZ R6, delay0
			DJNZ R7, delay_do_delay
		DJNZ R0, dloop3
		RET

	shortDelay:
		MOV R6, #70d
		shortLoop:
			DJNZ R6, shortLoop
		RET
	vetyshortDelay:
        NOP
        NOP
        NOP
		RET
		
		

