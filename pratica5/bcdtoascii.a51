MOV A, #29h         ;exemplo de numero de entrada

;; recebe valor em Acc
;; apaga valores de R2, R3
;; retorna em Acc unidade
;; retorna em R3 dezena
bcdtoascii:
    MOV R2, A       ;Mantem copia de BCD original em r2
    ANL A, #0Fh     ;zera primeiros 4 bits que contem algarismo de dezena
    ORL A, #30h     ;soma 30 pra virar ascii
    MOV R3, A       ;salva resultado parcial
    MOV A, R2       ;volta dado original bcd
    ANL A, #0F0h    ; zera bits do algarismo unidade
    RR A            ;girando até valores ficarem nos bits menos significativos
    RR A
    RR A
    RR A
    ORL A, #30h     ;somando 30h pra virar ascii
    RET
