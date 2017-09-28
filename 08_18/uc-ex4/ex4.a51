;R0 -> guarda a entrada
;R1 -> guarda a saida
ORG 0000h
	
	;resolver fatorial de 4
inicio:
	MOV R1, #4
	MOV A, R1
	
fat:
	DEC R1
	MOV B, R1
	MUL AB
	;compara R1 com 1
	;e pula se ainda nao for igual 1
	CJNE R1, #1, fat
	MOV R0, A
	
	NOP
	
END