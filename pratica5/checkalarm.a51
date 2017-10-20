;variaveis necessaria pra funcionar:
;mudar as posicoes de memoria   <<<<<
;;do relogio
SEC EQU 50h
MIN EQU 51h
HOR EQU 52h
;do despertador
ASEC EQU 53h        ;<< mudar
AMIN EQU 54h
AHOR EQU 55h

BUZ EQU P2.1        ;<< mudar
LED EQU P2.2

;memoria usada como flag do botao de interrupção
BOT EQU 30h         ;<< mudar


;; ;; ;; ;;
; compara se horario atual é igual ao do alarme
; ser for, pisca buzzer e led em 1 Hz
; até setar uma memoria atraves da interrupcao do botao
;; ;; ;; ;;
checkalarm:
    MOV A, SEC
    CLR C
    SUBB A, ASEC
    JNZ horario_diferente
    MOV A, MIN
    CLR C
    SUBB A, AMIN
    JNZ horario_diferente
    MOV A, HOR
    CLR C
    SUBB A, AHOR
    JNZ horario_diferente
    ;se chegou até aqui é igual, vamos disparar alarme
    alarm_on:
        MOV A, BOT
        JNZ alarm_off
        SETB BUZ
        SETB LED
        ACALL shortdelay
        CLR BUZ
        CLR LED
        ACAL delay1sec
        JMP alarm_on

    alarm_off:
        CLR BUZ
        CLR LED
    horario_diferente:
        RET
