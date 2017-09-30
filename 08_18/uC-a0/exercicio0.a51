;Objetivo: verificar os diferentes tipos de endere�amento

ORG 0000h

	;endere�amento por registrador
	;o conteudo do registrador R0
	; � copiado para o acumulador
	MOV A, R0
	
	
	;endere�amento direto
	;endereco do dado � carregado diretamente da memoria
	MOV A, 32h
	
	
	;enderecamento indireto
	;o dado � acesado pelo endereco armazenado
	; no registrador R0
	MOV R0, #44h
	MOV A, @R0
	
	
	;enderecamento imediato
	;o valor do operando esta na instru�ao
	;o acumulador recebe o decimal 25
	MOV A, #25
	
	;enderecamento relativo
	;permite saltos para um endere�o
	;apenas saltos curtos -128 bytes a + 128 bytes
;linhadecima:
;	SJMP pulaum
;	NOP
;pulauma:
;	SJMP linhadecima
	
	
	;enderecamento absoluto
	;permite pular para o endere�o dentro
	; da mesma pagina de 2k
	;AJMP 03h
	
	
	;enderecamento longo
	;permite o salto para qualquer endereco
	LJMP 77ACh
	
	
	;enderecamento indexado
	;endere�amento direto para acesso
	;A = (A+DPTR)
	MOVC A, @A+DPTR
	
	; Fique na mesma linha para toda a eternidade
	SJMP $

END