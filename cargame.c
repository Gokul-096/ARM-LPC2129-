#include<lpc21xx.h>			  
#include "headerall.h"
unsigned char car[]={0x00,0x04,0x0e,0x1f,0x1f,0x0a,0x00,0x00};
unsigned char obj[]={0x04,0xe,0x1f,0x1f,0x1f,0x04,0x04,0x04};
char car_addr1=0x80,car_addr2=0xc0,inter=0,object1=0x8f,object2=0xcc;
int count=0,i;
unsigned int score=0;
void car_cg(void)
{
char i;
cmd(0x40);
for(i=0;i<8;i++)
data(car[i]);
}
void obj_cg(void)
{
char i;
cmd(0x48);
for(i=0;i<8;i++)
data(obj[i]);
}

void interr(void) __irq
{
EXTINT=0X01;
	inter++;
VICVectAddr=0;
}

int main()
{
init();
PINSEL1=0X01;
for(i=3;i>=0;i--)
{
cmd(0x81);
string("GAME START IN");
cmd(0xc7);
integer(i);
delay(1000);
}

 car_cg();
 obj_cg();

VICIntSelect=0;
VICVectCntl0=(0x20)|14;
VICVectAddr0=(unsigned long)interr;

EXTMODE=0X01;
EXTPOLAR=0X00;

VICIntEnable=1<<14;
while(1)
{
cmd(0x01);
if((inter%2)==0)
{
cmd(car_addr1);
}
else
cmd(car_addr2);

data(0);
cmd(object1--);
if(object1==0x7f)
object1=0x8f;
data(1);
cmd(object2--);
if(object2==0xbf)
object2=0xcd;
data(1);
delay(200);
if((object1==0x80)||(object2==0xc0))
count++;
if((car_addr1==object1)&&(inter%2==0))
break;
if((car_addr2==object2)&&(inter%2!=0))
break;
}
cmd(0x01);
cmd(0x84);
string("game over");
cmd(0xc5);
string("score ");
integer(count-1);
}

