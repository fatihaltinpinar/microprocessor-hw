; Author:		Fatih ALTINPINAR
; Student Id:	150180707
		
					AREA	data, DATA, readwrite			; Reserve memory space for the array
					ALIGN									
_yarray_Start												; Label showing beginning of the array
yarray  SPACE   40											; Array for holding data
_yarray_End													; Label showing ending of the array

					AREA main, code, readonly 				; Reserve memory for code
					ENTRY									; Declare as entry point
					THUMB									; Ensures THUMB instruction set will be used
					ALIGN 									; Ensures that __main addresses the following instruction.
__main				FUNCTION								; Enable Debug
					EXPORT __main							; Make __main as global to access from startup file
					
					BL			Initialize_Timer			; Call initialize timer function
					LDR		r4,	=yarray						; r4 is the pointer shows array[i]
					MOVS	r5, #0							; r5 = i
for					CMP		r5, #10							; check if r5 < 10
					BGE		for_end							; if r5 >= 10 go to end of the for loop
					STR 	r5, [r4]						; str r5 in array[i] array[i] = i
					ADDS 	r5, #1							; increase r5 => i + 1
					ADDS 	r4, #4							; inrease r4 by 4 since 
					MOVS	r0, r5							; r0 = r5 
					MOVS	r1, #100						; r1 = 100 for multiplication
					MULS 	r0, r1, r0						; r0 = r0 x 100
					BL		delayMilliseconds				; Call delayMilliseconds function pass n by r0
					B		for								; Jump back to loop
for_end														; End of the for loop
loop_forever		B 		loop_forever					; while(1); Loop forever when program ends

					ENDFUNC									; End of the Function

Start_Timer 		FUNCTION								; Start of the function
					EXPORT 	Start_Timer						; Makes Start_Timer as global to access from startup file
					LDR		r0, SYST_CSR					; Move address of SysTick Control and Status Register to r0
					LDR		r1, [r0]						; Load value in SYST_CSR register to r1
					MOVS	r2, #0x2						; Load r2 with 0b0010 for setting bit(1) of SYST_CSR
					ORRS	r1, r2							; Setting bit(1) of SYST_CSR to 1
					STR		r1, [r0]						; Storing value in SYST_CSR which will let SysTick exception requests
					BX		lr								; Return from function
					ENDFUNC									; End of the function
					

	
Stop_Timer			FUNCTION								; Start of the function
					EXPORT 	Stop_Timer						; Makes Stop_Timer as global to access from startup file
					LDR		r0, SYST_CSR					; Move address of SysTick Control and Status Register to r0
					LDR		r1, [r0]						; Load value in SYST_CSR register to r1
					MOVS	r2, #0x2						; Load r2 with 0b0010 for setting bit(1) of SYST_CSR
					BICS	r1, r2							; Setting bit(1) of SYST_CSR to 0
					STR		r1, [r0]						; Storing value in SYST_CSR which will disable SysTick exception requests
					BX		lr								; Return from function
					ENDFUNC 								; End of the function
					
;r0 parameter n, 	r1= adress of n_count, r2= current n
delayMilliseconds	FUNCTION								; Start of the function
					EXPORT 	delayMilliseconds				; Makes delatMilliseconds as global to access from startup file
					PUSH	{r0, lr}						; Push r0 in order to save function parameter on stack
															; Push LR since this function will call other functions (not a leaf function)
					BL		Start_Timer						; Call Start_Timer function
while_n				LDR		r2, [sp]						; Load value at [sp] (which is n) to r2
					CMP 	r2, #0							; The value in [sp] (which is n) will be decreased by SysTick exception routine
					BGT		while_n							; Loop until r2 is equal to 0
					BL 		Stop_Timer						; Stop timer when n = 0, which means we have waited n x 0.001 seconds
					POP		{r0, pc}						; Pop stored values from stack
					ENDFUNC									; End of the function

Initialize_Timer 	FUNCTION								; Start of the function
					EXPORT 	Initialize_Timer				; Makes Initialize_Timer as global to access from startup file
					LDR 	r0, IRQ_SysTick					; Load address of SysTick exception request in interrupt vector table
					LDR 	r1,	=SysTick_Handler			; Load address of SysTick_Handler function
					STR		r1, [r0]						; Store address of SysTick_Handler function to IRQ_SysTick so systemm will call this function
															; when an interrupt caused by the timer
					LDR		r0, SYST_CSR					; Load address of SysTick Control and Status Register
					LDR		r1, [r0]						; Load value inside SYST_CSR
					MOVS	r2, #0x5						; Load r2 with 0b0101
					ORRS	r1, r2							; Set bit(0) and bit(2) of the SYST_CSR to 1
					STR		r1, [r0]						; Store value in SYST_CSR which will enable counter since bit(0) = 1
															; and will use processor CLK since bit(2) = 1
					LDR		r0, SYST_RVR					; Load address of SysTick Reload Value Register
					LDR		r1, RVR_Value					; Load reload value from label
					STR		r1, [r0]						; Store reload value to SYST_RVR which will send a timer interrupt request after every
															; 'Reload' times of clock cycles passes.
					BX 		lr								; Return from function
					ENDFUNC									; End of the function

SysTick_Handler		FUNCTION								; Start of the function
					EXPORT 	SysTick_Handler					; Makes SysTick_Handler as global to access from startup fil
					LDR		r1, [sp, #32]					; Value of n(r0) loaded from stack
					SUBS	r1, #1							; Subtract 1 from n
					STR		r1, [sp, #32]					; Store it back to stack
					BX 		lr								; Return from interrupt
					ENDFUNC									; End of the function
					
SYST_CSR			DCD 	0xE000E010						; Address of SysTick Control and Status Register
SYST_RVR			DCD		0xE000E014						; Address of SysTick Reload Value Registe
IRQ_SysTick 		DCD 	0x3C							; Address of SysTick interrupt vector
RVR_Value			DCD		72000							; Reload value = 72MHZ / 1000 = 72000
	
					END										;End of the File
