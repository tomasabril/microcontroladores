#include <at89c5131.h>

sbit SCL=P4^0;
sbit SDA=P4^1;

//void Delay_us(long int k);

void I2CStart();

void I2CStop();

void I2CAck();

void I2CNak();

void I2CSend(unsigned char Data);

unsigned char I2CRead();
