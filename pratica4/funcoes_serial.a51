
;; funcoes para comunicacao serial
; para entender mais http://what-when-how.com/8051-microcontroller/8051-serial-port-programming-in-assembly/

;;;;
; P3.0 Rx recebe dados
; P3.1 Tx envia  dados
;
;
;;;;

;; configs para usar serial;;;;;;;;;;;;;;;;;;;;;

;SCON (serial control) register
CLR SM0
SETB SM1         ;UART mode 1 (8-bit variable)
CLR SM2          ;sem multi processamento
SETB REN         ;habilita recepção da serial, receive enable
CLR TB8
CLR RB8
;;as linhas acima podem ser substituidas por:
;MOV SCON, #50h

SETB EA          ; habilita todas interrupções ; no nosso ja vai ter isso em algum lugar
SETB ES          ;habilita a interrupção serial
;;SETV ET1         ;habilita interrupção timer 1, parece que nao precisa pq estamos usando apenas pra sincronizar o baud-rate

;ligando timer que controla o baud rate
MOV TMOD, #20h      ;timer1, modo 2 auto-reload
MOV TH!, #-6d       ;isso é baud-rate de 4800, ou FAh
SETB TR1            ;start timer1

; >>as linhas abaixo estavam no slide mas n entendi<<<<<
;MOV BRL,#243     ;definição de taxa (baud rate) em 4800 bps (bps por seg)
;MOV BDRCON,#00000110b  ; RBCK e SPD=1
;ORL PCON,#1000000b     ; mascara SMOD=1 sem mexer nos demais bits
;ORL BDRCON,#00010000b ;set BRR=1 sem mexer no resto

;;;;;;;;;fim dos configs para serial;;;;;;;;;;;;;;;;;;;


;função de escrever na serial, coloca no acumulador o que for pra enviar
serialSend:
    MOV SBUF, A              ;carregando SBUF com dados
    parado: JNB TI, parado   ;espera o fim do envio
    CLR TI                   ;limpa TI para ser usado na proxima vez
RET
