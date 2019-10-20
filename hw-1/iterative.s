; Author:		Fatih ALTINPINAR
; Student ID 	150180707
index			EQU		10

                AREA    DATA_AREA,DATA, READWRITE	;Define this part will write in data area
				ALIGN	
__Array_Start
_fib_array      SPACE    index * 4					;Allocate space from memory, we multiply index by 4 since a word is 32 bits in ARM
__Array_End

;Our code
		AREA CODE_AREA, code, readonly				;Define this part will write as code
		ENTRY										;Declare as entry point
		THUMB										;Ensures THUMB instruction set will be used
		ALIGN 										;Ensures that __main addresses the following instruction.
__main	FUNCTION									;Enable Debug
		EXPORT __main								;Make __main as global to access from startup file
		LDR 	R0, =_fib_array						;Store start address of the fibonacci array
		MOVS	R1,	#index * 4						;Index is multiplied by 4 since a word is 32 bits in ARM
		SUBS	R1, #4								;Subtracting 4 because arrays starts at 0. Thus we need to subtract 1(*4) from the index value.
		BL 		fib									;Call fibonacci function
		B 		stop								;Jump to stop after completion of fibonacci function

fib		PUSH 	{LR}								;Push link register to stack so we can return to place where this function is called
		MOVS 	R2, #0								;i = 0
loop	CMP 	R2, #4								;Check if i <= 1 * 4 (arrays starts at 0, 0*4 is first element and 1*4 is the second)
		BGT		greater								;if not jump for calculating array[i] as array[i-1] + array[i-2]; 
		MOVS	R3,	#1								;Set r3 = 1, it'll be written into the array[i]
		B		loopend								;Jump to loopend
greater	SUBS	R2,	#8								;Subtracting 2*4 from i in order to obtain value of array[i-2]
		LDR		R3,	[R0, R2]						;Loading the value in array[i-2] to R3
		ADDS	R2, #4								;Adding 1*4 to i in order to obdatin value of array[i-1]
		LDR		R4,	[R0, R2]						;Writing value of array[i-1] into a temporary register, R4
		ADDS	R2, #4								;Adding 1*4 to i so we can write data into array[i]
		ADDS	R3, R4								;Summing both values into R3
loopend STR		R3,	[R0, R2]						;Storing R3 to array[i]
		ADDS	R2, #4								;Incresing i by 1*4 for next iteration
		CMP		R2, R1								;Checking if i <= index
		BLE		loop								;If yes keep looping
		POP		{PC}								;If not return
		
		
;LDR r0,=Array_Mem							;Store start address of the allocated space;
;		LDR r5,=__Array_End							;Store end address of the allocated space
;		MOVS r1,#2_101								;Move 5 in the R5 register
;		
;		STRB r1, [r0]								;Store this value to allocated space
stop	B stop										;Infinite loop
		ENDFUNC
		END
			
