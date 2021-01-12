//Ali Akbari Assignment 1 Part B
//CPSC 355 Lecture 02 Tutorial 07
//30010402

maximum: .string "X value is: %ld, Y value is: %ld, The current Maximum is: %ld \n"	//Defining string for call to printf()
	.balign 4									//Intstructions must be word aligned
	.global main									//Make 'main' visible to the OS

	define(currentMax, x19) 							//Defining maximum
	define(coefXcube, x20)								//Defining coeffiecient of X^3
	define(coefXsquareConstant, x21) 						//Defining coeffiecient of X^2 & constant
	define(coefX, x22)								//Defining coeffiecient of X
	define(counter, x23)								//Defining counter
	define(valueHolder, x24)							//Defining temporary variable used in program as value holder
	define(valueY, x25)								//Defining Y

main: 
	stp x29, x30, [sp, -16]!							//Save FP and LR to stack, allocating 16 bytes
	mov x29, sp									//Update FP to current SP

	mov currentMax, -100								//initializing maximum
	mov coefXcube,-5								//Initailizing coeffiecient of X^3
	mov coefXsquareConstant, -31							//Initailizing coeffiecient of X^2 and constant
	mov coefX, 4									//Initailizing coeffiecient of X
	mov counter, -6									//Initailizing counter/ range
	mov valueHolder, 0								//Initailizing value place holder variable
	mov valueY, 0									//Initailizing Y

	b test										//Branch to test


top:
	mul valueHolder, counter, counter						//X*X
	mul valueHolder, valueHolder, counter						//X*X*X

	mul valueHolder, valueHolder, coefXcube						//-5X^3
	mov valueY, valueHolder								//Y= -5X^3

	mov valueHolder, 0
	mul valueHolder, counter, counter						//X*X
	mul valueHolder, valueHolder, coefXsquareConstant 				//-31X^2
	add valueY, valueY, valueHolder							//Y= -5X^3 + (-31X^2)
	
	mov valueHolder, 0
	madd valueY, coefX, counter, valueY						//Y= -5X^3 + (-31X^2) + 4X Use of madd instruction
	Sub valueY, valueY, coefXsquareConstant  					//Y= -5x^3 + (-31X^2) + 4X - (-31)
	
	cmp currentMax, valueY								//Compare the current maximum to value of Y
	b.lt changeMax 									//Branch if less than to update current maximum
	b print										//Else continue to print

changeMax:										//Label thats called for current max update
	mov currentMax, valueY								//Update maximum value	

print:
	mov x1, counter									//Pass counter for x value for print
	mov x2, valueY									//Pass value of y for print
	mov x3, currentMax 								//Pass current max y value for print

	adrp x0, maximum								//Set 1st argument for printf
	add x0, x0, :lo12:maximum							//Address of string
	
	bl printf									//Call the printf() function       

	add counter, counter, 1								//Increment counter
	mov valueHolder, 0								//Reseting/ initializing back to 0
	mov valueY, 0									//Reseting/ initializing back to 0


test: 
	cmp counter, 5									//Compare the counter to range limiter
	b.le top									//Branch to top if limiter is not met

final:	
	mov w0, 0									//Set up return value for main
	ldp x29, x30, [sp], 16								//Restore FP to LR from stack

	ret										//Return to caller
	
