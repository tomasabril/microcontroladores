;;precisa configurar essas memorias antes!
;do despertador
ASEC EQU 53h            ;<< mudar
AMIN EQU 54h
AHOR EQU 55h

;; ;; ;; ;;
;; le hora, minuto, segundo do TECLADO
;; e salva na memoria
;; esse é o horario que o alarme vai tocar
;; ;; ;; ;;
set_alarm_time:
    ;pegando dezena da hora
    ACALL returnPressedKey
    MOV A, 2Ah
    RL                  ;;mandar pros mais significativos, o valor final ficara em BCD
    RL
    RL
    RL
    MOV 2Bh, A          ;conferir se não esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV AHOR, A

    ;pegando dezena do minuto
    ACALL returnPressedKey
    MOV A, 2Ah
    RL                  ;;mandar pros mais significativos, o valor final ficara em BCD
    RL
    RL
    RL
    MOV 2Bh, A          ;conferir se não esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV AMIN, A

    ;pegando dezena do segundo
    ACALL returnPressedKey
    MOV A, 2Ah
    RL                  ;;mandar pros mais significativos, o valor final ficara em BCD
    RL
    RL
    RL
    MOV 2Bh, A          ;conferir se não esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV ASEC, A

    RET
