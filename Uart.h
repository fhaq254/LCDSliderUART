// Uart.h
// Runs on LM4F120/TM4C123
// Provides Prototypes for functions implemented in UART.c
// Last Modified: 11/15/2017 
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly



// UART initialization function 
// Input: none
// Output: none
void Uart_Init(void);

//------------UART_InChar------------
// Wait for new input,
// then return ASCII code
// Input: none
// Output: char read from UART
// Receiver is interrupt driven
char Uart_InChar(void);

//------------UART_OutChar------------
// Wait for new input,
// then return ASCII code
// Input: none
// Output: char read from UART
// Transmitter is busywait
void Uart_OutChar(char data);
