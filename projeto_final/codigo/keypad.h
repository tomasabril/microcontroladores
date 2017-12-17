#include <at89c5131.h>

//Keypad Connections
sbit R1=P1^0;
sbit R2=P1^1;
sbit R3=P1^2;
sbit R4=P1^3;
sbit C1=P1^4;
sbit C2=P1^5;
sbit C3=P1^6;
sbit C4=P1^7;
//End Keypad Connections

unsigned char Read_Keypad();
void Delay_key(int a);