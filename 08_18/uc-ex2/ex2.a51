;objetivo: realizar multiplicacoes
; multiplicar 2 por 3 e armazenar o resultado em R1

ORG 0000h
	
	MOV A, #2h	;carrega o acc com 2
	MOV B, #3h	;carrega o B com 3
	MUL AB		;realiza aoperação de multiplicacao
	MOV R1, A	;copia o resultado da multiplicaçao dos LSB para o R1

	SJMP $		;fica aqui pra sempre
	
END