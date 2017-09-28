;objetivo: criar um temporizador e verificar seu tempo de execução

ORG 0000h
	
	;carrega o R6 com um valor para fazer um laço
	
	MOV R0, #9d

loop3:
	MOV R7, #221d 
	;repete delay de 0,5ms 250 vezes
	delay_do_delay:
		MOV R6, #250d
		;gasta 2 us cada vez, 500 us no total
		delay:
			DJNZ R6, delay
		DJNZ R7, delay_do_delay
	DJNZ R0, loop3
	
	NOP
	JMP $	;preso aqui
	
END