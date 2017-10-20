; ;hora
; SEC 		EQU 50h
; MIN 		EQU 51h
; HOU 		EQU 52h
; DAY 		EQU 53h
; DAT 		EQU 54h
; MON		EQU 55h
; YEA 		EQU 56h
; CTR 		EQU 57h



;; ;; ;; ;;
;; le hora, minuto, segundo do TECLADO
;; e grava no relogio
;; ;; ;; ;;
atualiza_hora:
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
    MOV HOU, A

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
    MOV MIN, A

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
    MOV SEC, A

    ;;enviando para RTC
    ACALL setTime
    RET
