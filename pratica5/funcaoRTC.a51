;; setando variaveis;;;;;;;;;;
;; isso veio daquele repositorio do github que te mandei uma vez pelo telegram

#include "at89c5131.h"
; endereços de leitura e escrita do RTC
#define RADDR 0xD1
#define WADDR 0xD0

; SSCON
#define SSIE	0x40
#define STA		0x20
#define STO		0x10
#define SI		0x08
#define AA 		0x04

;***********
;;* I2C e RTC
#define I2C_SDA P4.1
#define I2C_SCL P4.0
// Deve ser colocado na posição correta do JP5.
#define RTC_SQW P3.4

; Variáveis RTC
;===============================
MULT EQU 40h
; Serão utilizados para setar e pegar a data/hora do RTC
SEC EQU 50h
MIN EQU 51h
HOU EQU 52h
DAY EQU 53h
DAT EQU 54h
MON EQU 55h
YEA EQU 56h
CTR EQU 57h
; serão utilizados para chamar as funções do i2c
B2W	EQU 66h 	; bytes to write
B2R EQU 67h 	; bytes to read
ADDR EQU 68h 	; internal register address
DBASE EQU 69h 	; endereço base dos dados a serem escritos.










;; funcoes do RTC



;;;ler data da placa

;;;ler ler horario da placa

;;;setar horario

;;;setar data
