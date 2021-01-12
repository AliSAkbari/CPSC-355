//Ali Akbari Assignment 1 Part A
//CPSC 355 Lecture 02 Tutorial 07
//30010402

maximum: .string "X value is: %ld, Y value is: %ld, The current Maximum is: %ld \n"	//Defining string for call to printf()
	.balign 4									//Intstructions must be word aligned
	.global main									//Make 'main' visible to the OS

main: stp x29, x30, [sp, -16]!								//Save FP and LR to stack, allocating 16 bytes
	mov x29, sp									//Update FP to current SP

	mov x19, -100 									//Defining/initailizing maximum
	mov x20, -5									//Defining/initailizing coeffiecient of X^3
	mov x21, -31 									//Defining/initailizing coeffiecient of X^2 & constant
	mov x22, 4									//Defining/initailizing coeffiecient of X
	mov x23, -6									//Defining/initailizing counter/ range
	mov x24, 0									//Defining/initailizing value place holder variable
	mov x25, 0									//Defining/initailizing Y

top:
	cmp x23, 5									//Compare counter to range limiter
	b.gt test									//Skip loop body to test if range limiter is met

	mul x24, x23, x23								//X*X
	mul x24, x24, x23								//X*X*X

	mul x24, x24, x20								//-5X^3
	add x25, x25, x24								//Y= -5X^3

	mov x24, 0
	mul x24, x23, x23								//X*X
	mul x24, x24, x21 								//-31X^2
	add x25, x25, x24								//Y= -5X^3 + (-31X^2)
	
	mov x24, 0
	mul x24, x22, x23								//4X
	add x25, x25, x24								//Y= -5X^3 + (-31X^2) + 4X
	Sub x25, x25, x21								//Y= -5x^3 + (-31X^2) + 4X - (-31)
	
	cmp x19, x25									//Compare current maximum value to current Y value
	b.lt changeMax 									//If less than then branch
	b print										//Else print

changeMax:	
	mov x19, x25									//Update maximum
print:
	mov x1, x23									//Pass parameter 1 for stirng x value 
	mov x2, x25									//Pass parameter 2 for string y value
	mov x3, x19 									//Pass parameter 3 for string maximum value

	adrp x0, maximum								//Set 1st argument for printf
	add x0, x0, :lo12:maximum							//Address for string
	
	bl printf									//Call the printf() function       

	add x23, x23, 1									//Increment counter for loop and x value
	mov x24, 0									//Reseting/ initializing back to 0
	mov x25, 0									//Reseting/ initializing back to 0
	
	b top										//Branch back to top for loop

test:
 
	mov w0, 0									//Set up return value for main	
	ldp x29, x30, [sp], 16								//Restore FP to LR from stack

	ret										//Return to caller
	
