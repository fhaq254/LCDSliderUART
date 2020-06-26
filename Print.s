; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
SPACEASCII EQU 0
NUMBER     EQU 0x20

        PUSH {R0, R1, R2, R3, R4, LR};
        SUB SP, #8;               Allocate SPACEASCII
		
		MOV R2, #32;              ASCII Value of Space
		STR R2, [SP, #SPACEASCII]
		LDR R1, [SP, #SPACEASCII]
		
		AND R4, R4, #0;           R4 is Blank counter
        ADD R3, R0, #0;           R3 = R0 for modification purposes
		
		ADD R0, R3, #1;
		CMP R0, #0
		BNE Billions
		
MAX                     ;Max value 0xFFFFFFFF special case
        MOV R0, #52;                    4
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
        MOV R0, #50;                    2
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		MOV R0, #57;                    9
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
        MOV R0, #52;                    4
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		MOV R0, #57;                    9
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
        MOV R0, #54;                    6
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		MOV R0, #55;                    7
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
        MOV R0, #50;                    2
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		MOV R0, #57;                    9
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
        MOV R0, #53;                    5
	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Finish
		
		
		
		
		
Billions
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #1000;      R1= Decimal Place
		MOV R0, #1000;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
Loop1   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI Billion_Done;
        ADD R2, R2, #1;
		B Loop1;
Billion_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ Billion_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Billion_End
Billion_Zero
        ADD R4, R4, #1;            Blank Counter
Billion_End
        AND R1, R1, #0
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hundred_Mill
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #10;      R1= Decimal Place
		MOV R0, #10;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
Loop2   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI Hmill_Done;
        ADD R2, R2, #1;
		B Loop2;
Hmill_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ Hmill_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Ten_Mill
Hmill_Zero
        CMP R4, #0;                Check if zero is significant or not
	    BGT Hmill_End
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Ten_Mill
Hmill_End
         ADD R4, R4, #1;            Blank Counter
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Ten_Mill
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #10;      R1= Decimal Place
		MOV R0, #10;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		
Loop3   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI Tmill_Done;
        ADD R2, R2, #1;
		B Loop3;
Tmill_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ Tmill_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Mill
Tmill_Zero
        CMP R4, #1;                Check if zero is significant or not
	    BGT Tmill_End
		ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Mill
Tmill_End
       ADD R4, R4, #1;            Blank Counter
	   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Mill
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #10;      R1= Decimal Place
		MOV R0, #10;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
Loop4   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI mill_Done;
        ADD R2, R2, #1;
		B Loop4;
mill_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ mill_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Hundred_Thousand;
mill_Zero
        CMP R4, #2;                Check if zero is significant or not
	    BGT mill_End
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Hundred_Thousand;            
mill_End
        ADD R4, R4, #1;              Blank Counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hundred_Thousand
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #10;      R1= Decimal Place
		MOV R0, #10;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
Loop5   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI Hthou_Done;
        ADD R2, R2, #1;
		B Loop5;
Hthou_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ Hthou_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Ten_Thousand
Hthou_Zero
        CMP R4, #3;                Check if zero is significant or not
	    BGT Hthou_End
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Ten_Thousand
Hthou_End
        ADD R4, R4, #1;           Blank Counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Ten_Thousand
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #10;      R1= Decimal Place
		MOV R0, #10;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
Loop6   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI Tthou_Done;
        ADD R2, R2, #1;
		B Loop6;
Tthou_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ Tthou_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Thousand
Tthou_Zero
        CMP R4, #4;                Check if zero is significant or not
	    BGT Tthou_End
		ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Thousand
Tthou_End
        ADD R4, R4, #1;            Blank Counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Thousand
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #10;      R1= Decimal Place
		MOV R0, #10;
		MUL R1, R1, R0;
		MUL R1, R1, R0;
Loop7   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI thou_Done;
        ADD R2, R2, #1;
		B Loop7;
thou_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ thou_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5};
		B Hundred
thou_Zero
        CMP R4, #5;                Check if zero is significant or not
	    BGT thou_End
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Hundred          
thou_End
        ADD R4, R4, #1;             Blank Counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hundred
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #10;      R1= Decimal Place
		MOV R0, #10;
		MUL R1, R1, R0;
Loop8   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI hun_Done;
        ADD R2, R2, #1;
		B Loop8;
hun_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ hun_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Ten
hun_Zero
        CMP R4, #6;                Check if zero is significant or not
	    BGT hun_End
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Ten;
hun_End
        ADD R4, R4, #1;           Blank Counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Ten
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #10;      R1= Decimal Place
Loop9   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI Ten_Done;
        ADD R2, R2, #1;
		B Loop9;
Ten_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ Ten_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B One
Ten_Zero
        CMP R4, #7;                Check if zero is significant or not
	    BGT Ten_End
		ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B One;
Ten_End
        ADD R4, R4, #1;             Blank Counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
One
		AND R2, R2, #0;           R2= Decimal Value
        MOV R1, #1;      R1= Decimal Place
Loop10  SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI one_Done;
        ADD R2, R2, #1;
		B Loop10;
one_Done
        ADD R3, R3, R1;          Return to Positive
        CMP R2, #0;               
        BEQ one_Zero;          
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Blanks
one_Zero
        CMP R4, #8;                Check if zero is significant or not
	    BGT one_End
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Blanks;
one_End
        ADD R4, R4, #1;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Blanks
        CMP R4, #10
		BNE Lblank
		AND R0, R0, #0;                       Special Case zero
        ADD R0, R0, #0x30

	    PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}

Lblank  LDR R0, [SP, #SPACEASCII];            Load Spaces
        PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		SUBS R4, R4, #1;                       Loop output spaces
        BPL Lblank
Finish		
        ADD SP, #8;               Deallocate		
        POP {R0, R1, R2, R3, R4, LR}

      BX  LR
	  
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
Asterisk   EQU 0
DECIMAL    EQU 0x2E
Number     EQU 0x2A
	
LCD_OutFix


     PUSH {R0-R4, LR}
     SUB SP, #8;               Allocate SPACEASCII
	 
	 MOV R2, #0x2A;              ASCII Value of Space
	 STR R2, [SP, #Asterisk]
     LDR R1, [SP, #Asterisk]
	 
	 ADD R3, R0, #0          ; Max Value test
	 ADD R3, R3, #1
	 CMP R3, #0
	 BEQ Error;
	 
	 MOV R3, #9999
	 ADDS R3, R3, #0
     CMP R0, R3;
	 BGT Error;
	 ADD R3, R0, #0;
	 
Thousand2
		AND R2, R2, #0;           R2= Decimal Value
        AND R1, R1, #0;      R1= Decimal Place
		ADD R1, R1, #1000
LoopA   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI thous_Done;
        ADD R2, R2, #1;
		B LoopA;
thous_Done
        ADD R3, R3, R1;            Return to Positive         
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		LDR R0, =DECIMAL;
        PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5};        Output decimal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hundred2
		AND R2, R2, #0;           R2= Decimal Value
        AND R1, R1, #0;      R1= Decimal Place
		ADD R1, R1, #100
LoopB   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI huns_Done;
        ADD R2, R2, #1;
		B LoopB;
huns_Done
        ADD R3, R3, R1;          Return to Positive
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Ten2;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Ten2
		AND R2, R2, #0;           R2= Decimal Value
        AND R1, R1, #0;      R1= Decimal Place
		ADD R1, R1, #10;      R1= Decimal Place
LoopC   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI Tens_Done;
        ADD R2, R2, #1;
		B LoopC;
Tens_Done
        ADD R3, R3, R1;          Return to Positive
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B One2;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
One2
		AND R2, R2, #0;           R2= Decimal Value
        AND R1, R1, #0;      R1= Decimal Place
		ADD R1, R1, #1;      R1= Decimal Place
LoopD   SUBS R3, R3, R1;           Counter system makes R2 have value of Decimal place
        BMI ones_Done;
        ADD R2, R2, #1;
		B LoopD;
ones_Done
        ADD R3, R3, R1;          Return to Positive       
        ADD R0, R2, #0x30;         R0 is Ascii number to be outputed
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5}
		B Done
		

Error   
        LDR R0, [SP, #Asterisk]
		ADD R0, R1, #0;
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5};        Output Ones Asterisk
	    LDR R0, =DECIMAL
        PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5};        Output decimal
        LDR R0, [SP, #Asterisk]
		ADD R0, R1, #0;
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5};        Output Tenths Asterisk
        LDR R0, [SP, #Asterisk]
		ADD R0, R1, #0;
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5};        Output Hundredths Asterisk
	    LDR R0, [SP, #Asterisk]
		ADD R0, R1, #0;
		PUSH {R0-R5}
		BL ST7735_OutChar;
		POP {R0-R5};        Output Thousandths Asterisk
	 
Done	
        ADD SP, #8;               Deallocate		
	    POP {R0-R4, LR}
		BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
