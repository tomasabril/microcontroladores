#ifndef _LCD_H
#define _LCD_H

#include <at89c5131.h>
	
sbit LCD_RS = P2^5;
sbit LCD_RW = P2^6;
sbit LCD_EN = P2^7;
sbit LCD_BUSY = P0^7;
sfr LCD_DATA = 0x80;


void LCD();
void LCDbusy();
void LCDinst(unsigned char inst);
void LCDposi(unsigned char posi);
void LCDdata(unsigned char c);
void LCDwrite(unsigned char text[], unsigned char posi);

#endif
