#include "LCD.h"
#include "interrupt.h"
#include "rtc.h"
#include "keypad.h"
#include "delay.h"                                                                                                                                                                                                                                                          
#include <at89c5131.h> //adicionar nos demais headers se nao funcionar

#define PERIMETRO 2

bit inRun = 0;

unsigned char tecla = '0';
unsigned char a[7]; // valores do RTC em 
unsigned char texto[16] = "________________"; //texto para imprimir
unsigned char dist[16] = "________________"; //texto para imprimir
unsigned char dist_final[8] = "00,00km";

unsigned char seg = 0;
unsigned char seg_final = 0;
unsigned char min = 0;
unsigned char min_final = 0;
unsigned char hor = 0;
unsigned char hor_final = 0;

unsigned long int loops = 0;
unsigned long int distancia = 0;
unsigned long int distancia_ant = 0;

unsigned int i=0;
unsigned char resultado[2];


void intToChar(int num){
	int dezena;
	int unidade;

	dezena = num/10;
	unidade = num%10;
	
	resultado[0] = 0x30 + dezena;
	resultado[1] = 0x30 + unidade;
}

void cleartexto(){
	i =0;
	while(i<16){
		texto[i] = '_';
		i++;
	}
}

int Dec_To_BCD(int dec) { return ((dec / 10 * 16) + (dec % 10)); }

int BCD_To_Dec(int val) { return ( (val/16*10) + (val%16) );    }

void readAllReg() {
	unsigned char j = 0;
  I2CStart();
  I2CSend(0xD0);
  I2CSend(0x00);
  I2CStop();
  I2CStart();
  I2CSend(0xD1);
	
  for (j = 0; j < 8; j++) {
    a[j] = I2CRead();
    if (j == 7)
      I2CNak();
    else
      I2CAck();
  }
  I2CStop();
}

void setTime(int Sec, int Min, int Hour, int Dow, int Dom, int Month,
             int Year) {
  I2CStart();
  I2CSend(0xD0);
  I2CSend(0x00);
  I2CSend(Dec_To_BCD(Sec) & 0x7f);
  I2CSend(Dec_To_BCD(Min) & 0x7f);
  I2CSend(Dec_To_BCD(Hour) & 0x3f);
  I2CSend(Dec_To_BCD(Dow) & 0x07);
  I2CSend(Dec_To_BCD(Dom) & 0x3f);
  I2CSend(Dec_To_BCD(Month) & 0x1f);
  I2CSend(Dec_To_BCD(Year) & 0xff);
  I2CStop();
}
						 
void initRtcSqrt(){
	I2CStart();
	I2CSend(0xD0);	//slave address
	I2CSend(0x07);	//control register address
	I2CSend(0x10);	//control register 1
	I2CStop();
	
}

void writeTime(){
	seg = BCD_To_Dec(a[0]);
	min = BCD_To_Dec(a[1]);
	hor = BCD_To_Dec(a[2]);

	cleartexto();

	intToChar(hor);
	texto[0] = resultado[0];
	texto[1] = resultado[1];
	texto[2] = ':';
	
	intToChar(min);
	texto[3] = resultado[0];
	texto[4] = resultado[1];
	texto[5] = ':';
	
	intToChar(seg);
	texto[6] = resultado[0];
	texto[7] = resultado[1];
	
	
	LCDwrite(texto, 0x80);
}

void writeDistancia(){
	unsigned int km, m;
	
	distancia_ant = distancia;
	distancia = PERIMETRO*loops;
	
	km = distancia/1000;
	m = distancia % 1000;
	m = m/10;
	
	cleartexto();
	intToChar(km);
	dist[0] = resultado[0];
	dist[1] = resultado[1];
	dist[2] = ',';
	
	intToChar(m);
	dist[3] = resultado[0];
	dist[4] = resultado[1];
	
	dist[5] = 'k';
	dist[6] = 'm';
	
	LCDwrite(dist, 0xC0);

}

void velocidade_inst(){
	//imprime na tela em km/h
	//distancia em metros
	//distancia_ant
	unsigned long int diferenca = distancia - distancia_ant;
	unsigned long int vel_inst = diferenca/3.6;
	intToChar(vel_inst);
	LCDwrite(resultado, 0xC9);
	LCDwrite("km/h", 0xCC);
}

void clear() {
	// as operacoes fazem em sua maioria OR com os registradores especiais
	// entao antes do programa iniciar, essa funcao limpa todos os registradores
	// interrupcoes
	IE = 0x00;
	IP = 0x00;
	// timers
	TMOD = 0x00;
	TCON = 0x00;
}

void velocidade_final(){
//imprime na tela em km/h
//distancia em metros
unsigned int tempo_final = seg + min*60 + hor*60*60; //tempo percorrido em segundos
unsigned int vel_med = (distancia/tempo_final)/3.6;

	if(tempo_final == 0) vel_med = 0;
intToChar(vel_med);
LCDwrite(resultado, 0xC9);
LCDwrite("km/h", 0xCC);
}

// responsavel pela contagem do sensor
// tem prioridade maxima
void int_interrupt0(void) interrupt 0 {
	loops++;
	DELAY_ms(200);
	//colocar um delay menor que 240ms aqui!
}

void int_interrupt1(void) interrupt 2 {
	readAllReg();
	writeTime();
	writeDistancia();
	velocidade_inst();
}

void setup() {
  clear();
  LCD();
  initRtcSqrt();
}

void lastRun(){
	intToChar(hor_final);
	texto[0] = resultado[0];
	texto[1] = resultado[1];
	texto[2] = ':';
	
	intToChar(min_final);
	texto[3] = resultado[0];
	texto[4] = resultado[1];
	texto[5] = ':';
	
	intToChar(seg_final);
	texto[6] = resultado[0];
	texto[7] = resultado[1];
	
	LCDwrite(texto, 0x80);
	LCDwrite(dist_final, 0xC0);
	
	velocidade_final();
	while(tecla != '*') 
		tecla = Read_Keypad();
}

void loop() {
	
	
	while(inRun == 0){
		LCDwrite("Nova Corrida?", 0x80);
		LCDwrite("________________", 0xC0);
		tecla = Read_Keypad();
		if(tecla == '#'){
			lastRun();
			tecla = '_';
		}
		else if (tecla == '*'){
			inRun = 1;
			//Sec Min Hour DayofWeek DayofMonth Month Year
			setTime(0, 0, 0, 0, 0, 0, 0);
			interrupt0();
			interrupt1();
			loops = 0;
			distancia = 0;
			}
		else inRun = 0;
		}
	
	tecla = '_';
	
	while(tecla != '#'){
		tecla = Read_Keypad();
	}
	EA = 0;
	inRun = 0;
	
	for(i = 0; i < 7; i++){
		dist_final[i] = dist[i];
	}
	readAllReg();
	seg_final = seg;
	min_final = min;
	hor_final = hor;
	
	LCDwrite("Fim Corrida!", 0x80);
	LCDwrite("* Nova, # Ultima", 0xC0);
	
}

void main() {
  setup();
  while (1)
    loop();
}
