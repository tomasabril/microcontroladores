#include "keypad.h"

void Delay_key(int a){
  int j;
  int i;
  for(i=0;i<a;i++)
  {
    for(j=0;j<100;j++)
    {
    }
  }
}


unsigned char Read_Keypad()
{
  C1=1;
  C2=1;
  C3=1;
  C4=1;
  R1=0;
  R2=1;
  R3=1;
  R4=1;
  if(C1==0){
	  Delay_key(100);
	  while(C1==0);
	  return 'D';
	}
  if(C2==0){Delay_key(100);while(C2==0);return 'C';}
  if(C3==0){Delay_key(100);while(C3==0);return 'B';}
  if(C4==0){Delay_key(100);while(C4==0);return 'A';}
  R1=1;
  R2=0;
  R3=1;
  R4=1;
  if(C1==0){Delay_key(100);while(C1==0);return '#';}
  if(C2==0){Delay_key(100);while(C2==0);return '9';}
  if(C3==0){Delay_key(100);while(C3==0);return '6';}
  if(C4==0){Delay_key(100);while(C4==0);return '3';}
  R1=1;
  R2=1;
  R3=0;
  R4=1;
  if(C1==0){Delay_key(100);while(C1==0);return '0';}
  if(C2==0){Delay_key(100);while(C2==0);return '8';}
  if(C3==0){Delay_key(100);while(C3==0);return '5';}
  if(C4==0){Delay_key(100);while(C4==0);return '2';}
  R1=1;
  R2=1;
  R3=1;
  R4=0;
  if(C1==0){Delay_key(100);while(C1==0);return '*';}
  if(C2==0){Delay_key(100);while(C2==0);return '7';}
  if(C3==0){Delay_key(100);while(C3==0);return '4';}
  if(C4==0){Delay_key(100);while(C4==0);return '1';}
  return 0;
}
