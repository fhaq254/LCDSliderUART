// Uart.c
// Runs on LM4F120/TM4C123
// Use UART1 to implement bidirectional data transfer to and from 
// another microcontroller in Lab 9.  This time, interrupts and FIFOs
// are used.
// Daniel Valvano
// November 15, 2017
// Modified by EE345L students Charlie Gough && Matt Hawk
// Modified by EE345M students Agustinus Darmawan && Mingjie Qiu

/* Lab solution, Do not post
 http://users.ece.utexas.edu/~valvano/
*/

// U1Rx (VCP receive) connected to PC4
// U1Tx (VCP transmit) connected to PC5
#include <stdint.h>
#include "Fifo.h"
#include "Uart.h"
#include "tm4c123gh6pm.h"

#define PF3       (*((volatile uint32_t *)0x40025020))
	
uint32_t DataLost; 
uint32_t RxCounter = 0;
// Initialize UART1 and Port C
// Baud rate is 115200 bits/sec
// Make sure to turn ON UART1 Receiver Interrupt (Interrupt 6 in NVIC)
// Write UART1_Handler
void Uart_Init(void){volatile unsigned delay;
	SYSCTL_RCGCUART_R |= 0x02;  // activate UART1
	delay = 0x30;
	SYSCTL_RCGCGPIO_R |= 0x04;  // activate Port C
	delay = 0x40;
	UART1_CTL_R       &= ~0x01; // disable UART
	// IBRD = int(800000/(16*115200)) = int(43.4028)
	UART1_IBRD_R = 43;
	// FBRD = round(0.4028 * 64) = 26
	UART1_FBRD_R = 26;  
	UART1_LCRH_R = 0x70;        // 8-bit length, enables FIFO
	UART1_CTL_R  = 0x0301;      // enable RXE, TXE, and UART    
	GPIO_PORTC_AFSEL_R |= 0x30; // alt function
	GPIO_PORTC_PCTL_R = (GPIO_PORTC_PCTL_R&0xFF00FFFF)+0x00220000;
	GPIO_PORTC_DEN_R |= 0x30;   // digital I/O on PC5-4
	GPIO_PORTC_AMSEL_R &= ~0x30;// No analog on PC5-4
	// clear global error count
	DataLost = 0;
	// Initialize Fifo
	Fifo_Init();
	// enable interrupts
	UART1_IM_R |= 0x10;        //Arm RXRIS
	UART1_IFLS_R = (0x02)<<3;  //Trigger when hardware FIFO >= 1/2 full
	NVIC_PRI1_R &= ~0x0E00000; //Priority 0 for bits 21-23
	NVIC_EN0_R = 0x40;         //Set bit 6 to activate interrupts
}

// input ASCII character from UART
// spin if RxFifo is empty
// Receiver is interrupt driven
char Uart_InChar(void){
  while((UART1_FR_R&0x0010) != 0); 
  // wait until RXFE is 0
  return((uint8_t)(UART1_DR_R&0xFF));
}
//------------UART1_OutChar------------
// Output 8-bit to serial port
// Input: letter is an 8-bit ASCII character to be transferred
// Output: none
// Transmitter is busywait
void Uart_OutChar(char data){
  while((UART1_FR_R&0x0020) != 0);  
  // wait until TXFF is 0
  UART1_DR_R = data;
}

// hardware RX FIFO goes from 7 to 8 or more items
// UART receiver Interrupt is triggered; This is the ISR
void UART1_Handler(void){uint32_t i; 
  PF3 ^= 0x08;
	PF3 ^= 0x08;
	
	for(i = 0; i < 8; i++){
    if(Fifo_Put(Uart_InChar()) == 0){DataLost++;}  // Uart_InChar already waits for RXFE to be 0
	}	                                              // Increment Error counter if FIFO is full
	RxCounter++;
	
	UART1_ICR_R = 0x10;  // clears bit 4 (RXRIS) in the register

  PF3 ^= 0x08;	
}
