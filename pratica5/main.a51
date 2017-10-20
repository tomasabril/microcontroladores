;Projeto Minimo

;----- DECLARACOES UNIVERSAIS ----------------------------------
	org 0000h
;--------DECLARACOES EXTRAS -----------------------------------
	AUX_A 				EQU R0
	AMOSTRAGEM	EQU R3
	MULT				EQU R4
	LED1 				EQU P3.6
	LED2 				EQU P1.4
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
	
;--------DECLARACOES I2P e RTC --------------------------------------
	P4 DATA 0C0h
	
	SDA		EQU	P4.1
	SCL		EQU	P4.0
	
	;leitura e escrita do RTC
	RADDR	EQU	0xD1
	WADDR	EQU	0xD0
	
	SSCON	EQU	93h
	SSCS	EQU	94h
	SSDAT	EQU	95h
	SSADR	EQU	96h
	
	;SSCON
	SSIE		EQU	0x40
	STA		EQU	0x20
	STO		EQU	0x10
	SI			EQU	0x08
	AA		EQU	0x04
	
	;hora
	SEC 		EQU 50h
	MIN 		EQU 51h
	HOU 		EQU 52h
	DAY 		EQU 53h
	DAT 		EQU 54h
	MON		EQU 55h
	YEA 		EQU 56h
	CTR 		EQU 57h
	
	;funcao de i2c
	B2W		EQU 66h 	; bytes to write
	B2R 		EQU 67h 	; bytes to read
	ADDR 	EQU 68h 	; internal register address
	DBASE 	EQU 69h 	; endereco base dos dados a serem escritos.
	I2C_BUSY EQU 00h	; 0 livre, 1 ocupada
	
;--------DECLARACOES INTERRUPCAO --------------------------------------
	IEN0		EQU	0A8h
	IEN1		EQU	0B1h
	
	IPL1		EQU	0B2h
	IPH1		EQU	0B3h
	
;----- DECLARACOES UNIVERSAIS FIM -------------------------------
;----- INTERRUPCOES ---------------------------------------------
	ORG 2000h
	LJMP init
	
	ORG 2023h		;int serial
	RETI
	
	ORG 2043h		;iint i2c
	ACALL int_i2c
	RETI
	
	
;----- MAIN -----------------------------------------------------
;--------Inicializacao ---------------------------------------------
	ORG 207Bh
	init:
		ACALL startLCD
		
		;desabilita interrupcao
		MOV IEN0, #0x00
		MOV IEN1, #0x00

		;timer0
		MOV TMOD, #0x01
		
		;i2c
		SETB SCL
		SETB SDA
		MOV SSCON, #01000001b
		
		;interrupcoes
		MOV IPL1, #0x02
		MOV IPH1, #0x02
		MOV IEN1, #0x02
		
		SETB EA
		
		ACALL initialTime
		ACALL setTime
		
;--------Start ---------------------------------------------------
	mainloop:
	MOV R7, #0x05
		reload:
		CPL LED1			; toggle no led
		MOV R6, #0x04		; 4x
			again:
			MOV MULT, #0xFA		; 250x
			ACALL runT0			; 0.5ms
			DJNZ R6, again		; = 1s

		DJNZ R7, reload		; 5s

	ACALL	getTime
	MOV LCD_POSITION, #80h
	ACALL printTime

 	JMP mainloop

;----- MAIN FIM --------------------------------------------------




;----- FUNCOES--------------------------------------------------
;--------FUNCAO DELAY ------------------------------------------
	timerDelay20ms:
		MOV R6, #200d
			delay0:
				DJNZ R6, delay0
		DJNZ DELAY_TIME, timerDelay20ms
	
		RET
		
	runT0:
		MOV TH0,#0FCh 	;fclk CPU = 24MHz
		MOV TL0,#17h 	; ... base de tempo de 0,5ms
		SETB TR0 		;dispara timer

		JNB TF0,$ 		;preso CLR TR0 ;stop timer
		CLR TR0 		;para o timer 0
		CLR TF0 		;zera flag overflow
		DJNZ MULT,runT0
		RET 

;--------FUNCAO LCD --------------------------------------------
	printTime:
		ACALL bcdtoascii
		MOV A, 31h
		ACALL sendNumber
		INC LCD_POSITION
		MOV A, 30h
		ACALL sendNumber
		RET
		
;; recebe valor em Acc
;; apaga valores de R2, R3
;; retorna em Acc unidade
;; retorna em R3 dezena
bcdtoascii:
    MOV 30h, A       ;Mantem copia de BCD original em r2
    ANL A, #0Fh     ;zera primeiros 4 bits que contem algarismo de dezena
    ORL A, #30h     ;soma 30 pra virar ascii
    MOV 31h, A       ;salva resultado parcial
    MOV A, 30h       ;volta dado original bcd
    ANL A, #0F0h    ; zera bits do algarismo unidade
    RR A            ;girando ate valores ficarem nos bits menos significativos
    RR A
    RR A
    RR A
    ORL A, #30h     ;somando 30h pra virar ascii
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
			
;--------FUNCOES RTC --------------------------------------------
initialTime:
	MOV SEC, #00h ; BCD segundos, deve ser iniciado 
								; com valor PAR para o relogio funcionar.
	MOV MIN, #00h ; BCD minutos
	MOV HOU, #22h ; BCD hora, se o bit mais alto for 1,
								; o relogio e 12h, senao BCD 24h
	MOV DAY, #06h ; Dia da semana
	MOV DAT, #20h ; Dia
	MOV MON, #10h ; Mes
	MOV YEA, #17h ; Ano
	MOV CTR, #00h ; SQW desativada em nivel 0
	RET

setTime:
	MOV ADDR, #0x00		; endereco do reg interno
	MOV B2W, #(8+1) 	; a quantidade de bytes que deverao 
						; ser enviados + 1.
	MOV B2R, #(0+1)		; a quantidade de bytes que serao 
						; lidos + 1.
	MOV DBASE, #SEC		; endereco base dos dados

	; gera o start, daqui pra frente e tudo na interrupcao.
	MOV A, SSCON
	ORL A, #STA
	MOV SSCON, A

	; devemos aguardar um tempo "suficiente"
	; para ser gerada a interrupcao de START
	MOV MULT, #0xA ; 5ms
	LCALL runT0

	JB I2C_BUSY, $

	RET
	
getTime:
 	MOV ADDR, #0x00		; endereco do reg interno
	MOV B2W, #(0+1) 	; a quantidade de bytes que deverao 
						; ser enviados + 1.
	MOV B2R, #(3+1)		; a quantidade de bytes que serao 
	 					; lidos + 1.
	MOV DBASE, #SEC		; endereco base dos dados (buffer)

	; gera o start, daqui pra frente e tudo na interrupcao.
	MOV A, SSCON
	ORL A, #STA
	MOV SSCON, A

	; devemos aguardar um tempo "suficiente"
	; para ser gerada a interrupcao de START
	MOV MULT, #0xA
	LCALL runT0

	JB I2C_BUSY, $

	RET
;----- FUNCOES FIM ----------------------------------------------

;----- Interrupcoes INICIO ----------------------------------------------
int_i2c:
	CPL LED2 ; "pisca" um led na int somente para debug.
   	
	MOV A, SSCS ; pega o valor do Status
	RR A		; faz 1 shift (divide por 2)

	LCALL decode ; opera o PC, faz cair exatamente no
				 ; local correto abaixo.
								 
	; Como isso funciona? :
	; cada LJMP tem 3 bytes, NOP 1 byte.
	; LJMP + NOP = 4 bytes.
	; os codigos de retorno do SSCS sao multiplos de 8, 
	; dividindo por 2 ficam multiplos de 4
	; quando "chamamos" decode com LCALL, o PC de retorno (
	; que e o primeiro LJMP abaixo deste comentario)
	; fica salvo na pilha.
	; capturo o PC de retorno da pilha e somo esse multiplo.
	; quando acontecer o RET, estaremos no LJMP exato
	; para atender a int!
	
	; Erro no Bus (00h)
	LJMP ERRO ; 0
	NOP
	; start	(8h >> 1 = 4)
	LJMP START
	NOP	
	; re-start (10h >> 1 = 8)
	LJMP RESTART
	NOP
	; W ADDR ack (18h >> 1 = 12)
	LJMP W_ADDR_ACK
	NOP
	; W ADDR Nack (20h >> 1 = 16)
	LJMP W_ADDR_NACK
	NOP
	; Data ack W (28h >> 1 = 20)
	LJMP W_DATA_ACK
	NOP
	; Data Nack W (30h >> 1 = 24)
	LJMP W_DATA_NACK
	NOP
	; Arb-Lost (38h >> 1  = 28)
	LJMP ARB_LOST
	NOP
	; R ADDR ack (40h >> 1 = 32)
	LJMP R_ADDR_ACK
	NOP
	; R ADDR Nack (48h >> 1 = 36)
	LJMP R_ADDR_NACK
	NOP
	; Data ack R (50h >> 1 = 40)
	LJMP R_DATA_ACK
	NOP
	; Data Nack R (58h >> 1 = 44)
	LJMP R_DATA_NACK
	NOP

	; slave receive nao implementado
	LJMP not_impl
	NOP ; 60
	LJMP not_impl
	NOP ; 68
	LJMP not_impl
	NOP ; 70
	LJMP not_impl
	NOP ; 78
	LJMP not_impl
	NOP ; 80
	LJMP not_impl
	NOP ; 88
	LJMP not_impl
	NOP ; 90
	LJMP not_impl
	NOP ; 98
	LJMP not_impl
	NOP ; A0
	;slave transmit nao implementado
	LJMP not_impl
	NOP ; A8
	LJMP not_impl
	NOP ; B0
	LJMP not_impl
	NOP ; B8
	LJMP not_impl
	NOP ; C0
	LJMP not_impl
	NOP ; C8

	; codigos nao implementados
	LJMP not_impl
	NOP ; D0
	LJMP not_impl
	NOP ; D8
	LJMP not_impl
	NOP ; E0
	LJMP not_impl
	NOP ; E8
	LJMP not_impl
	NOP ; F0

	; nada a ser feito (apenas "cai" no fim da int)
	LJMP end_i2c_int
	NOP ; F8
;------------------------------------------------------------
not_impl:
end_i2c_int:
	RETI
;============================================================
; Esta e a funcao que opera o PC e faz o retorno
; ir para o local correto.
;============================================================
decode:
	POP DPH
	POP DPL			; captura o PC "de retorno"
	ADD A, DPL
	MOV DPL, A		; soma nele o valor de A (A = SSCS/2)
	JNC termina
	MOV A, #1
	ADD A, DPH		; se tiver carry, aumenta a parte alta.
	MOV DPH, A
termina:
	PUSH DPL		; poem o novo pc na pilha 
	PUSH DPH		; e ...
	RET				; pula pra ele!


;------------------------------------------------------------
; Aqui se iniciam as "verdadeiras" ISRs
; A implementacao dessas ISRs seguiu os modelos 
; propostos no datasheet
; Porem nao foram implementadas todas as possibilidades
; para todos os codigos
; foram implementadas apenas as necessarias para garantir
; um fluxo de dados de escrita e leitura como master, 
; contemplando inclusive as possiveis falhas
;------------------------------------------------------------
ERRO:
	MOV A, SSCON
	ANL A, #STO ; gera um stop
	MOV SSCON, A
	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int
;------------------------------------------------------------
START:
; um start SEMPRE vai ocasionar uma escrita
; pois para ler, preciso primeiro escrever de onde vou ler!
; SSDAT = SLA + W
; STO = 0 e SI = 0
	SETB I2C_BUSY		; seta o flag de ocupado
	MOV SSDAT, #WADDR
	MOV A, SSCON
	ANL A, #~(STO | SI)	; zera os bits STO e SI
	MOV SSCON, A
	LJMP end_i2c_int
;------------------------------------------------------------
RESTART:
; o Restart sera utilizado apenas para leituras,
; onde ha a necessidade de fazer um
; start->escrita->restart->leitura->stop
; SSDAT = SLA + R
; STO = 0 e SI = 0
	MOV SSDAT, #RADDR
	MOV A, SSCON
	ANL A, #~(STO | SI)	; zera os bits STO e SI
	MOV SSCON, A
	LJMP end_i2c_int
;------------------------------------------------------------
W_ADDR_ACK:
; apos um W_addr_ack temos que escrever o
; registrador interno!
; SSDAT = ADDR
; STA = 0, STO = 0, SI = 0
	MOV SSDAT, ADDR
	MOV A, SSCON
	ANL A, #~(STA | STO | SI)	; zera os bits STA, STO e SI
	MOV SSCON, A
	LJMP end_i2c_int
;------------------------------------------------------------
W_ADDR_NACK:
; em caso de nack, ou o end ta errado ou o slave
; nao esta conectado. nao vamos fazer retry,
; encerramos a comunicacao.
; STA = 0, SI = 0
; STO = 1
	MOV A, SSCON
	ANL A, #~(STA | SI)	; zera os bits STA e SI
	ORL A, #STO					; seta STO
	MOV SSCON, A
	LJMP end_i2c_int
;------------------------------------------------------------
W_DATA_ACK:
; apos o primeiro data ack (registrador interno)
; temos 2 opcoes:
; 1 - escrever um novo byte
; 2 - gerar um restart para leitura
	DJNZ B2W, wda1		; enquanto tiver bytes para
						; escrever, pula para wda1

	; se nao tiver mais bytes para escrever, comece a ler
	DJNZ B2R, wda2		;se tiver algum byte pra ler,
						; pula para wd
	MOV A, SSCON 
	ANL A, #~(STA | SI)	; senao..
	ORL A, #STO			; gera um STOP
	MOV SSCON, A
	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int
wda2:
	MOV A, SSCON 
	ANL A, #~(STO | SI)
	ORL A, #STA			; ..gera um restart!
	MOV SSCON, A
	LJMP end_i2c_int
wda1:
	MOV R0, DBASE
	MOV SSDAT, @R0	; ...escreve o proximo!
	MOV A, SSCON
	ANL A, #~(STA | STO | SI) ; zera STA, STO e SI
	MOV SSCON, A
	INC DBASE		; incrementa o indice do buffer
	LJMP end_i2c_int
;------------------------------------------------------------
W_DATA_NACK:
; apos um data_nack, podemos repetir ou encerrar
; vamos encerrar
	MOV A, SSCON 
	ANL A, #~(STA | SI)
	ORL A, #STO			; gera um STOP
	MOV SSCON, A
	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int	
;------------------------------------------------------------
ARB_LOST:
; apos um arb-lost podemos acabar sendo
; enderecados como slave
; o arb-lost costuma ocorrer em 2 situacoes:
; 1 - problemas fisicos no bus
; 2 - ambiente multi-master (nao e o caso)
; em ambos os casos, nao vamos fazer nada!
; pois nao estamos implementando a comunicacao em modo slave.
	LJMP end_i2c_int	
;------------------------------------------------------------
R_ADDR_ACK:
; depois de um R ADDR ACK, recebemos os bytes!
	MOV A, SSCON
	ANL A, #~(STA | STO | SI) ; receberemos o proximo byte
	
	DJNZ B2R, raa1 ; decrementa a quantidade de
				   ; bytes a receber!
	; se der 0, e o ultimo byte a ser recebido
	ANL A, #~AA	; retorne NACK
	SJMP raa2
	; se nao...
raa1:
	ORL A, #AA	; retorne ACK para o slave!
raa2:	
	MOV SSCON, A
	LJMP end_i2c_int	
;------------------------------------------------------------
R_ADDR_NACK:
; idem ao w_addr_nack
	MOV A, SSCON 
	ANL A, #~(STA | SI)
	ORL A, #STO			; gera um STOP
	MOV SSCON, A
	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int	
;------------------------------------------------------------
R_DATA_ACK:
; se tiver mais bytes pra ler, de um ack, senao de um nack

	MOV R0, DBASE
	MOV	@R0, SSDAT ; le o byte que ja chegou

	MOV A, SSCON
	ANL A, #~(STA | STO | SI) ; receberemos o proximo byte
	
	DJNZ B2R, rda1  ; decrementa a quantidade de 
					; bytes a receber!
	; se der 0, e o ultimo byte a ser recebido
	ANL A, #~AA	; retorne NACK
	SJMP rda2
	; se nao...
rda1:
	ORL A, #AA	; retorne ACK para o slave!
rda2:	
	MOV SSCON, A
	INC DBASE ; incrementa o buffer
	LJMP end_i2c_int
;------------------------------------------------------------
R_DATA_NACK:
; salva o ultimo byte e termina

	MOV R0, DBASE
	MOV	@R0, SSDAT ; le o byte que ja chegou

	MOV A, SSCON 
	ANL A, #~(STA | SI)
	ORL A, #STO			; gera um STOP
	MOV SSCON, A

	INC DBASE ; inc o buffer

	CLR	I2C_BUSY ; zera o flag de ocupado
	LJMP end_i2c_int	


	hello:	db "Amostragem", 0
	clear:	db "               ", 0	

END
