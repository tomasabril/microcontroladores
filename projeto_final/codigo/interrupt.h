#ifndef _interrupt_H
#define _interrupt_H

#include <at89c5131.h>	

sfr IE = 0xA8;
sfr IP = 0xB8;

void interrupt0();
void interrupt1();

void timer0();
void timer1();
#endif