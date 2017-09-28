;realizar a leitura do status da entrada digital
; P0.4 e enviar nivel logico alto para saida P1.0
; e 0 para as demais saidas de P1, quando a entrada for 1
; caso a entrada seja zero todos os bits da P1 devem ser 0

ORG 0000h
	
	;loop para verifica o estado do pino
	loop:
		MOV A, P0			;copio o valor do port para o Acc
		ANL A, #00010000b	;aplico a mascara em acc
		
		MOV R1, #4
		
	rot:
		RR A
		DJNZ R1, rot
		CJNE A, #1, aux		;se o acc nao for 1 entao a porta nao esta setada
		
	Mov P1, #0
	JMP loop
	
	aux:
		MOV P1, #1
		JMP loop
	
	NOP
	JMP $
		
	
END