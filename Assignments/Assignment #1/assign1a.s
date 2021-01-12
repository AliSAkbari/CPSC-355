// Minimum calculator for y = (5x^3) + (27x^2) - 27x -43
//Loops 13 times, prints the minimum for the equation

//Define a string for printf call
minimum: .string "The current minimum is %d \t The values of X,Y are (%d, %d) \n"

	.balign 4			//Aligning the instructions
	.global main			//Make "main" visible to the OS

main: stp x29, x30, [sp, -16]!		//Save FP and LR to stack, allocating 16 bytes, pre-increment SP

	mov x29, x30			//Update FP to current SP

	mov x19, -6			//Move immediate integer -6 to register x19
	mov x20, 5			//Move immediate integer 5 to register x20
	mov x21, 27			//Move immediate integer 27 to register x21
	mov x28, 12345			//Intialize register x28 to 12345, made big value as it is needed to be compared for conditional

test: cmp x19, 7			//Compare contents of register x19 to integer 7
	b.eq done			// If the contents of register x19 is equal to 7 then exit the loop, continue execution at label done: and end the program

	mul x22, x19, x19		//Register x22 is equal to the square of register x19 (x22 = x^2)
	mul x23, x22, x19		//Register x23 is equal to the cube of register x19 (x23 = x^3)
	mul x24, x23, x20		//Register x24 is equal to the cube of register x19 (x23)  multiplied by x20 (x24 = 5x^3)
	mul x25, x21, x22		//Register x25 is equal to the square of register x19 (x22) multiplied by x21 (x25 = 27x^2)
	mul x26, x21, x19		//Register x26 is equal to  x19 multiplied by x21(27) ---(x26 = 27(x19))
 	add x27, x24, x25		//Register x27 is equal to the addition of registers x24, x25 (x27 = x24 + x25)
	sub x27, x27, x26		//Add contents of register x26 to register x27 (x27 = x27 + x26)
	sub x27, x27, 43		//Subtract integer 43 from register x27 (x27 = x27 - 43)

	cmp x28, x27			//Compare contents of the two registers to make a conditional (if x28 <= x27)
	b.le elseif			//If the contents of x28 is less than or equal to x27 than continue from label elseif
	mov x28, x27			//If it isn't less than or equal to, than move contents of x27 to x28


elseif:
	adrp x0, minimum		//Set the 1st argument of printf(fmt, var1, var2)(high- order bits)
	add x0, x0, :lo12:minimum	//Set the 1st argument of printf(fmt, var1, var2...) (lower 12 bits)
	add x1, x28, 0			//Set the 2nd argument of printf()
	mov x2, x19			//Set the 3rd argument of printf()
	mov x3, x27			//Set the 4th argumrnt of printf()

	bl printf			//Call the printf() function

	add x19, x19, 1			//Increment contents of register x19 by 1 (loop incrementation)

	b test				// Loop iteration has ended, goto test  to check if we need to execute loop again

// return 0 in main
done: mov w0,0
	//Restore registers and return to calling code(OS)
	ldp x29, x30, [sp], 16		//Restore fp and lr from stack, post-increment sp
	ret				//Return to caller

