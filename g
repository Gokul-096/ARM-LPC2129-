#include <LPC21xx.h>
#include <string.h>
#include <stdio.h>

#define IR_SENSOR   (1<<16)
#define MOTOR       (1<<17)
#define BUZZER      (1<<18)

void delay_ms(unsigned int);
void uart0_init(void);
void uart1_init(void);
void uart0_tx(char);
void uart1_tx(char);
char uart0_rx(void);
char uart1_rx(void);
void gsm_send_string(char *);
void send_sms(char *);
unsigned char RFID_read(void);

char valid_tag[] = "5300A1B2C3D4";  // Example RFID Tag ID (replace yours)
char received_tag[20];
char temp;

int main(void)
{
    IO0DIR |= MOTOR | BUZZER; // Outputs
    IO0DIR &= ~IR_SENSOR;     // Input (IR)
    
    uart0_init();  // GSM
    uart1_init();  // RFID

    gsm_send_string("AT\r");
    delay_ms(1000);
    gsm_send_string("ATE0\r");   // Echo off
    delay_ms(500);
    gsm_send_string("AT+CMGF=1\r");  // SMS Text mode
    delay_ms(1000);

    while(1)
    {
        int i = 0;
        // Wait for RFID tag
        while(1)
        {
            temp = uart1_rx();   // Read RFID data
            if(temp == '\n') break;
            received_tag[i++] = temp;
        }
        received_tag[i] = '\0';
        
        if(strcmp(received_tag, valid_tag) == 0)
        {
            IO0CLR = BUZZER;
            IO0SET = MOTOR;  // Start motor
        }
        else
        {
            IO0SET = BUZZER;
            IO0CLR = MOTOR;  // Stop motor
            send_sms("Unauthorized RFID detected!");
        }

        // Check for IR Sensor Trigger (intrusion)
        if(!(IO0PIN & IR_SENSOR)) // active low IR
        {
            IO0SET = BUZZER;
            IO0CLR = MOTOR;
            send_sms("Intrusion detected! Vehicle Locked.");
            delay_ms(5000);
            IO0CLR = BUZZER;
        }
    }
}

// =================== UART Functions ===================

void uart0_init(void)
{
    PINSEL0 |= 0x00000005;  // TxD0, RxD0
    U0LCR = 0x83;           // 8-bit, DLAB=1
    U0DLL = 97;             // 9600 baud @15MHz
    U0LCR = 0x03;
}

void uart1_init(void)
{
    PINSEL0 |= 0x00050000;  // TxD1, RxD1
    U1LCR = 0x83;
    U1DLL = 97;
    U1LCR = 0x03;
}

void uart0_tx(char ch)
{
    while(!(U0LSR & 0x20));
    U0THR = ch;
}

void uart1_tx(char ch)
{
    while(!(U1LSR & 0x20));
    U1THR = ch;
}

char uart0_rx(void)
{
    while(!(U0LSR & 0x01));
    return U0RBR;
}

char uart1_rx(void)
{
    while(!(U1LSR & 0x01));
    return U1RBR;
}

// =================== GSM ===================

void gsm_send_string(char *str)
{
    while(*str)
    {
        uart0_tx(*str++);
    }
}

void send_sms(char *msg)
{
    gsm_send_string("AT+CMGS=\"+911234567890\"\r"); // Replace with owner’s number
    delay_ms(1000);
    gsm_send_string(msg);
    uart0_tx(0x1A);  // Ctrl+Z
    delay_ms(5000);
}

// =================== Delay ===================

void delay_ms(unsigned int ms)
{
    unsigned int i, j;
    for(i=0; i<ms; i++)
        for(j=0; j<2000; j++);
}
