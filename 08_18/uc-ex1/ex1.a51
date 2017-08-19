; Analisar as diferencas formas de representacao
; numerica e a movimentação de dados entre registradores

ORG 0000h
	
	;enderecamento por registrador e imediato
	MOV R0, #11			;movimenta o numero 11 em decimal para o reg R0
	MOV R1, #11h		;movimenta o numero 11 em hexa para o reg R1
	MOV R2, #00001011b	;movimenta o num 11d na notacao binaria
	
	;enderecamentos de registradores
	MOV R3, #3h			;movimenta o numero 3 para o reg R3
	MOV A, R3			; movimenta o conteudo do reg3 para o acc
	MOV R7, A			;movimenta o conteudo do acc para o R7
	MOV B, R1			;movimenta o conteudo do R1 para o B
	
	
END