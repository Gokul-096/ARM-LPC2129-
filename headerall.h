#include<lpc21xx.h>
#define LCD_D 0XFF<<0
#define RS	1<<8
#define E 1<<9
void init(void);
void cmd(unsigned char);
void data(unsigned char);
void string(unsigned char *);
void integer(unsigned int);
void delay(int ms)
{
T0PR=15000-1;
T0TCR=0X01;
while(T0TC<ms);
T0TCR=0X03;
T0TCR=0X00;
}
void init(void)
{
cmd(0x01);
cmd(0x02);
cmd(0x0C);
cmd(0x38);
cmd(0x80);
}
void cmd(unsigned char s)
{
IOCLR0=LCD_D;
IOSET0=s;
IOCLR0=RS;
IOSET0=E;
delay(2);
IOCLR0=E;
}
void data(unsigned char d)
{
IOCLR0=LCD_D;
IOSET0=d;
IOSET0=RS;
IOSET0=E;
delay(2);
IOCLR0=E;
}
void string(unsigned char *n)
{
while(*n)
{
data(*n++);
}
}
void integer(unsigned int n)
{

unsigned char arr[20];
signed char i=0;
if(n==0)
{
data('0');
}
else
{
if(n<0)
{
data('-');
n=-n;
}
}
while(n>0)
{
arr[i++]=n%10;
n=n/10;
}
for(i=i-1;i>=0;i--)
data(arr[i]+48);
}
