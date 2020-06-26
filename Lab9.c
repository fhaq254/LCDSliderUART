// Lab9.c
// Runs on LM4F120 or TM4C123
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly
// Last Modified: 11/15/2017 

// Analog Input connected to PE2=ADC1
// displays on Sitronox ST7735
// PF3, PF2, PF1 are heartbeats
// UART1 on PC4-5
// * Start with where you left off in Lab8. 
// * Get Lab8 code working in this project.
// * Understand what parts of your main have to move into the UART1_Handler ISR
// * Rewrite the SysTickHandler
// * Implement the s/w Fifo on the receiver end 
//    (we suggest implementing and testing this first)

#include <stdint.h>

#include "ST7735.h"
#include "PLL.h"
#include "ADC.h"
#include "print.h"
#include "tm4c123gh6pm.h"
#include "Uart.h"
#include "FiFo.h"

//*****the first three main programs are for debugging *****
// main1 tests just the ADC and slide pot, use debugger to see data
// main2 adds the LCD to the ADC and slide pot, ADC data is on Nokia
// main3 adds your convert function, position data is no Nokia

void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts

#define PF1       (*((volatile uint32_t *)0x40025008))
#define PF2       (*((volatile uint32_t *)0x40025010))
#define PF3       (*((volatile uint32_t *)0x40025020))
uint32_t Data;        // 12-bit ADC
uint32_t WrongMes = 0;    // Error variable for incorrect message
int32_t Position;     // 32-bit fixed-point 0.001 cm
char  MessageBuf[8] = {0x02, 0, 0x2E, 0, 0, 0, 0x0D, 0x03};  // Stores an 8-byte message
uint32_t TxCounter = 0;
//uint32_t ADCMail;     // input from Systick Handler sampling ADC
//uint8_t  flag = 0;    // ADC flag

// Initialize Port F so PF1, PF2 and PF3 are heartbeats
void PortF_Init(void){
	SYSCTL_RCGCGPIO_R |= 0x20;        // 1) activate clock for Port F
  while((SYSCTL_PRGPIO_R&0x20) == 0){};
		
	GPIO_PORTF_LOCK_R = 0x4C4F434B;   // 2) unlock GPIO Port F
  GPIO_PORTF_CR_R = 0x1F;           // allow changes to PF4-0
  // only PF0 needs to be unlocked, other bits can't be locked
  GPIO_PORTF_AMSEL_R = 0x00;        // 3) disable analog on PF
  GPIO_PORTF_PCTL_R = 0x00000000;   // 4) PCTL GPIO on PF4-0
  GPIO_PORTF_DIR_R = 0x0E;          // 5) PF4,PF0 in, PF3-1 out
  GPIO_PORTF_AFSEL_R = 0x00;        // 6) disable alt funct on PF7-0
  GPIO_PORTF_PDR_R = 0x11;          // enable pull-down on PF0 and PF4
  GPIO_PORTF_DEN_R = 0x1F;          // 7) enable digital I/O on PF4-0
}

// Get fit from excel and code the convert routine with the constants
// from the curve-fit
uint32_t Convert(uint32_t input){
  return ((511*input)/1250)+263;   // for Rafael's and Fawad's potentiometer
}


// Initializes Systick for Interrupts at priority 2
void SysTick_Init(uint32_t period){
  NVIC_ST_CTRL_R = 0;
	NVIC_ST_RELOAD_R = period; 
	NVIC_ST_CURRENT_R = 0;
	NVIC_SYS_PRI3_R = (NVIC_SYS_PRI3_R&0x00FFFFFF)|0x40000000; // priority 2
	NVIC_ST_CTRL_R = 0x00000007; //0111
}

// final main program for bidirectional communication
// Sender sends using SysTick Interrupt
// Receiver receives using RX
int main(void){ 
  PLL_Init(Bus80MHz);     // Bus clock is 80 MHz 
  ST7735_InitR(INITR_REDTAB);
  ADC_Init();    // initialize to sample ADC
  PortF_Init();
  Uart_Init();       // initialize UART
	ST7735_SetCursor(0,0);
  LCD_OutFix(0);
  ST7735_OutString(" cm");
  SysTick_Init(1600000);
  EnableInterrupts();
  //you send the address of your fifo variable, your FifoGet rewrites it, and you access it that way and check it
	while(1){char element; uint32_t i; 
    ST7735_SetCursor(0,0);  // Reset position after every message		
		for(i = 0; i < 8; i++){
	    while(Fifo_Get(&element) == 0){} // wait until start bit is here
	    // case structure depending on i and checking for correct message, otherwise error
	    switch(i){
				case 0: if(element != 0x02){WrongMes++;}; break;           // check for the correct form of the message
				case 1: if(element > 0x39 || element < 0x30){WrongMes++;}; 
				        ST7735_OutChar(element);
				        break;
				case 2: if(element != 0x2E){WrongMes++;}; 
				        ST7735_OutChar(element);
				        break;
				case 3: if(element > 0x39 || element < 0x30){WrongMes++;}; 
				        ST7735_OutChar(element);
				        break;
				case 4: if(element > 0x39 || element < 0x30){WrongMes++;}; 
				        ST7735_OutChar(element);
				        break;
				case 5: if(element > 0x39 || element < 0x30){WrongMes++;}; 
				        ST7735_OutChar(element);
				        break;
				case 6: if(element != 0x0D){WrongMes++;}; break;
				case 7: if(element != 0x03){WrongMes++;}; break;
			} // end of switch
    } // end of for 
		ST7735_OutString(" cm");
	} // end of while
} // end of main

// Temp Main program to test transmitter
int maintest(void){
	PLL_Init(Bus80MHz);
	ST7735_InitR(INITR_REDTAB);
  ADC_Init();    // initialize to sample ADC
  PortF_Init();
  Uart_Init();       // initialize UART
	ST7735_SetCursor(0,0);
  LCD_OutFix(0);
  ST7735_OutString(" cm");
  SysTick_Init(1600000);
  EnableInterrupts();
  while(1){
	} // end of while
} // end of main
/* SysTick ISR
*/
void SysTick_Handler(void){
	int32_t temp = 0; 
	int8_t count = 0; 
	uint32_t decimal = 1000;
	uint8_t i = 1;
	
	PF1 ^= 0x02;
	Data = ADC_In();          // Sample ADC
	PF1 ^= 0x02;
	
	Position = Convert(Data); // Convert to distance
	
	// Create 8-byte message
	temp = Position;          // begin the temp variable
	
	while(i != 6){            // subtract by a tens place and count 
		if(decimal == 100){i++;}  // increment index to skip the place for the decimal ascii in the message
		temp = temp - decimal;
		while(temp >= 0){
			temp = temp - decimal;
			count++;
		}
		MessageBuf[i] = count + 0x30; // Make into ASCII
		count = 0;
		temp = temp + decimal;
		decimal = decimal/10;
		i++;
	}
	
	PF2 ^= 0x04;
	for(i = 0; i < 8; i++){     // send message to UART1
		Uart_OutChar(MessageBuf[i]);
	}
	PF2 ^= 0x04;
	
	TxCounter++;  // debugging

}


uint32_t Status[20];             // entries 0,7,12,19 should be false, others true
char GetData[10];  // entries 1 2 3 4 5 6 7 8 should be 1 2 3 4 5 6 7 8
int mainfifo(void){ // Make this main to test FiFo
  Fifo_Init(); // Assuming a buffer of size 6
  for(;;){
    Status[0]  = Fifo_Get(&GetData[0]);  // should fail,    empty
    Status[1]  = Fifo_Put(1);            // should succeed, 1 
    Status[2]  = Fifo_Put(2);            // should succeed, 1 2
    Status[3]  = Fifo_Put(3);            // should succeed, 1 2 3
    Status[4]  = Fifo_Put(4);            // should succeed, 1 2 3 4
    Status[5]  = Fifo_Put(5);            // should succeed, 1 2 3 4 5
    Status[6]  = Fifo_Put(6);            // should succeed, 1 2 3 4 5 6
    Status[7]  = Fifo_Put(7);            // should fail,    1 2 3 4 5 6 
    Status[8]  = Fifo_Get(&GetData[1]);  // should succeed, 2 3 4 5 6
    Status[9]  = Fifo_Get(&GetData[2]);  // should succeed, 3 4 5 6
    Status[10] = Fifo_Put(7);            // should succeed, 3 4 5 6 7
    Status[11] = Fifo_Put(8);            // should succeed, 3 4 5 6 7 8
    Status[12] = Fifo_Put(9);            // should fail,    3 4 5 6 7 8 
    Status[13] = Fifo_Get(&GetData[3]);  // should succeed, 4 5 6 7 8
    Status[14] = Fifo_Get(&GetData[4]);  // should succeed, 5 6 7 8
    Status[15] = Fifo_Get(&GetData[5]);  // should succeed, 6 7 8
    Status[16] = Fifo_Get(&GetData[6]);  // should succeed, 7 8
    Status[17] = Fifo_Get(&GetData[7]);  // should succeed, 8
    Status[18] = Fifo_Get(&GetData[8]);  // should succeed, empty
    Status[19] = Fifo_Get(&GetData[9]);  // should fail,    empty
  }
}

