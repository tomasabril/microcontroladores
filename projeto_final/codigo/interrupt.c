#include "interrupt.h"

void interrupt0(){
	EA = 1;
	EX0 = 1;	
	IT0 = 1;
}

void interrupt1(){
	EA = 1;
	EX1 = 1;
	IT1 = 1;
}