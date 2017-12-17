#include "LCD.h"
#include <string.h>

void LCD(){
	LCDinst(0x30);
	LCDinst(0x30);
	LCDinst(0x30);
	
	LCDinst(0x38);
	
	LCDinst(0x0C);
	
	LCDinst(0x02);
	
	LCDinst(0x01);
}

void LCDbusy(){
	LCD_RS = 0;
	LCD_RW = 1;
	LCD_BUSY = 1;
	
	while(LCD_BUSY){
		LCD_EN = 1;
		if(!LCD_BUSY)
			break;
		LCD_EN = 0;
	}
	LCD_RW = 0;
}

void LCDinst(unsigned char inst){
	LCDbusy();
	LCD_RS = 0;
	LCD_EN = 1;
	
	LCD_DATA = inst;
	LCD_EN = 0;
}

void LCDposi(unsigned char posi){
	LCDbusy();
	LCD_RS = 0;
	LCD_RW = 0;
	LCD_EN = 1;
	
	LCD_DATA = posi;
	LCD_EN = 0;
}

void LCDdata(unsigned char c){
	LCDbusy();
	LCD_RS = 1;
	LCD_RW = 0;
	LCD_EN = 1;
	
	LCD_DATA = c;
	LCD_EN = 0;
}

void LCDwrite(unsigned char text[], unsigned char posi){
	int i;
	LCDposi(posi);
	
	for(i = 0; i < strlen(text); i++){
		if(text[i] != NULL) LCDdata(text[i]);
		else break;
	}
}
