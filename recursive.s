index	EQU 	10			;Assigning a global value to index
		AREA fibonacci, code, readonly ;Declare new area
		ENTRY				;Declare as entry point
		THUMB				;Ensures THUMB instruction set will be used
		ALIGN 				;Ensures that __main addresses the following instruction.
__main	FUNCTION			;Enable Debug
		EXPORT __main		;Make __main as global to access from startup file
		
		
; R0: index value, R1: Resulft of the fib function, R2: Current sum		
		MOVS	R0, #index	;R0 shows the index of the currently running function
		CMP 	R0, #0		;Validating input
		BLE		inval 		;input is invalid if the input is less than or equal to zero
		BL 		fib			;Start fibonacci by branching with Link
		B 		stop		;When first fib function is completed program will jump to stop.

inval 	MOVS	R1, #0		;Give 0 as result
		B 		stop		;Stop the program if input is invaid
		
fib		PUSH	{R0,R2,LR} 	;Pushing index value, current sum and link register to stack
							;R0 needs to be saved since after calculating fib(index-1)
							;you need value of index to calculate fib(index-2)
							;R2 is stored since you have to sum fib(index-1) and fib(index-2)
							;R2 holds the result of fib(index-1) while calling fib(index-2)
							;LR is stored in order to return to the adress which this function is called from
		CMP		R0, #2		;check if index <= 2 
		BGT		resume		;if not keep calculating the value of fib(index)
		MOVS	R1, #1		;if yes result will be 1 since fib(1) = fib(2)= 1
		B		return		;jump to return in order to pop caller function's parameters
resume	SUBS	R0, #1		;Subtracting 1 from index since we'll calculate fib(index-1)
		BL		fib			;Call fib(index-1);
		MOV		R2, R1		;Save return value of fib(index-1) since R1 will be overwritten by fib(index-2)
		SUBS	R0,	#1		;Subtracting 1 from index since we'll calculate fib(index-2)
		BL		fib			;Call fib(index-2);
		ADDS	R1, R2, R1	;Add result of fib(index-2) and R2(fib(index-1)'s result) and write it to R1
							;Since R1 should return result for every fib function
return	POP	{R0,R2,PC}		;Popping values to their respected places R0, R2 takes their values as they were
							;in the caller function
							;value of LR written to PC so it can resume from the place it branched to current fib function

stop	B	 	stop		;Branch stop

		ENDFUNC				;Finish Function
		END					;Finish Assebly File
