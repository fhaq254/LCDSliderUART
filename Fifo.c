// Fifo.c
// Runs on LM4F120/TM4C123
// Provide functions that implement the Software FiFo Buffer
// Last Modified: 11/29/2017 
// Student names: Fawadul Haq and Rafael Herrejon
// Last modification date: change this to the last modification date or look very silly

#include <stdint.h>
// --UUU-- Declare state variables for Fifo
//        buffer, put and get indexes
#define FIFO_SIZE 20

int32_t static PutI; // Index to put new
int32_t static GetI; // Index of oldest 
int16_t static FIFO[FIFO_SIZE]; // 1 byte is a whole frame, each element has a frame

// *********** Fifo_Init**********
// Initializes a software FIFO of a
// fixed size and sets up indices for
// put and get operations
void Fifo_Init() {
	PutI = GetI = 0;
}

// *********** Fifo_Put**********
// Adds an element to the FIFO
// Input: Character to be inserted
// Output: 1 for success and 0 for failure
//         failure is when the buffer is full
uint32_t Fifo_Put(int32_t data) {
	if (((PutI+1)%FIFO_SIZE) == GetI) {return(0);} // if buffer is full
	
  FIFO[PutI] = data;
  PutI = (PutI+1)%FIFO_SIZE;
  return(1);
}

// *********** FiFo_Get**********
// Gets an element from the FIFO
// Input: Pointer to a character that will get the character read from the buffer
// Output: 1 for success and 0 for failure
//         failure is when the buffer is empty
uint32_t Fifo_Get(int32_t *datapt){
	if (GetI == PutI) {return(0);}   // if buffer is empty
	
  *datapt = FIFO[GetI];
  GetI = (GetI+1)%FIFO_SIZE;
  return(1);
}
