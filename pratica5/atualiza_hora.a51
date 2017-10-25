

;; ;; ;; ;;
;; le hora, minuto, segundo do TECLADO
;; e grava no relogio
;; ;;;
;; o usuario precisa digitar EM ORDEM:
;;  hora, minuto, segundo, dia da semana, dia do mes, mes, ano (dois digitos)
;;  incluindo todos os zeros!
;; ;; ;; ;;
atualiza_hora:
    MOV LCD_POSITION, #80h
    MOV DPTR, #novahora
    ACALL sendString
    MOV LCD_POSITION, #8Ah
;----------------------
    ;pegando dezena da hora
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    RL A                  ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n�o esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV HOU, A
;----------------------
    MOV LCD_POSITION, #80h
    MOV DPTR, #novominuto
    ACALL sendString
    MOV LCD_POSITION, #8Ah
    ;pegando dezena do minuto
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    RL A                  ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n�o esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV MIN, A
;----------------------
    MOV LCD_POSITION, #80h
    MOV DPTR, #novosegundo
    ACALL sendString
    MOV LCD_POSITION, #8Ah
    ;pegando dezena do segundo
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    RL A                   ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n�o esta em conflito
    ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV SEC, A
;----------------------
    MOV LCD_POSITION, #80h
    MOV DPTR, #novodiasemana
    ACALL sendString
    MOV LCD_POSITION, #8Ah
    ;;pegar dia da semana
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    RL A                   ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n�o esta em conflito
        ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV DAY, A
;----------------------
    MOV LCD_POSITION, #80h
    MOV DPTR, #novodiames
    ACALL sendString
    MOV LCD_POSITION, #8Ah
    ;;pegar dia do mes
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    RL A                   ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n�o esta em conflito
        ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV DAT, A
;----------------------
    MOV LCD_POSITION, #80h
    MOV DPTR, #novomes
    ACALL sendString
    MOV LCD_POSITION, #8Ah
    ;;pegar Mes
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    RL A                   ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n�o esta em conflito
        ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV MON, A
;----------------------
    MOV LCD_POSITION, #80h
    MOV DPTR, #novoano
    ACALL sendString
    MOV LCD_POSITION, #8Ah
    ;;pegar ano, dois digitos
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    RL A                   ;;mandar pros mais significativos, o valor final ficara em BCD
    RL A
    RL A
    RL A
    MOV 2Bh, A          ;conferir se n�o esta em conflito
        ;pegando unidade
    ACALL returnPressedKey
    MOV A, 2Ah
    ACALL sendStringAlarm
    ORL A, 2Bh          ;juntando pra formar o numero completo
    MOV YEA, A


    ;;enviando para RTC
    ACALL setTime
    RET


;;;colocar la no fim
	novahora:      db "Horas:  ",0
	novominuto:    db "Minuto: ",0
	novosegundo:   db "Seg.:   ",0
	novodiasemana: db "Dia Sem:",0
	novodiames:    db "Dia Mes:",0
	novomes:       db "Mes:    ",0
	novoano:       db "Ano(XX):",0
