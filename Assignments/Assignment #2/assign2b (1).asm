//Ali Akbari Assignment 2 Part A
//CPSC 355 Lecture 02 Tutorial 07
//30010402


//Defining strings for print
initialvalues:		.String "\nMultiplier = 0x%08x %d, Multiplicand = 0x%08x %d \n"	//Initial values to be printed			
productNmultiplier: 	.String "Product = 0x%08x,	multiplier = 0x%08x\n"		//Product and multiplier to be printed
longResult:		.String "64-bit result = 0x%0161 (%ld)\n"			//Result to be printed


define(False,0)										//Defining False
define(True, 1)										//Defining True				
define(multiplier, w19)									//Defining multiplier
define(multiplicand, w20)								//Defining multiplicand
define(product, w21)									//Defining product
define(i, w22)										//Defining i
define(negative, w23)									//Defining negative
define(temp1, x24)									//Defining temp1 as a long int
define(temp2, x25)									//Defining temp2 as a long int
define(result, x26)									//Defining result as a long int

	.balign 4									//Intstructions must be word aligned
	.global main									//Make 'main' visible to the OS

main: 
	stp	 x29, x30, [sp, -16]!							//Save FP and LR to stack, allocating 16 bytes
	mov	 x29, sp								//Update FP to current SP

	mov 	multiplicand, 522133279							//Initializing multiplicand
	mov 	multiplier, 200								//Initializing multiplier
	mov	product, 0								//Initializing product
	mov 	i, 0									//Initializing i counter
	mov 	negative, 0								//Initializing negative as False							

	adrp 	x0, initialvalues							//Set 1st argument for printf		
	add 	x0, x0, :lo12:initialvalues						//Address for string
	mov 	w1, multiplier								//Passing in first hexadecimal value for placeholder
	mov 	w2, multiplier								//Passing in first value for placeholder
	mov 	w3, multiplicand							//Passing in second hexadecimal value for placeholder 
	mov 	w4, multiplicand							//Passing in second value for placeholder 
	bl 	printf									//Branch to print function to print

	cmp	multiplier, 0								//Comparing if multiplier is negative or not
	b.gt	loop									//If multiplier is positive skip to loop
	mov	negative, 1								//Change to True

loop:
	tst	multiplier, 0x1								//Tst operation (ands) to set flags
	b.eq	secondIf								//Branch to second if statement if Z flag is set 
	add	product, product, multiplicand						//Add multiplicand to product

secondIf:		
	asr	multiplier, multiplier, 1						//Arithmetic shift right by 1 
	tst	product, 0x1								//Tst operation (ands) on multiplier to set flags 
	b.eq	else									//Branch to else if Z flag is not set
	orr	multiplier, multiplier, 0x80000000					//Esle bitwise Inclusive orr operation on multiplier
	b	outsideIf								//Branch to skip esle statement
else:
	and 	multiplier, multiplier, 0x7FFFFFFF					//And operation on multiplier

outsideIf:		
	asr	product, product, 1							//Arithemitic shift the right on product
	add 	i, i, 1									//Increment i counter

test:
	cmp 	i, 32									//Compare i and 33
	b.lt 	loop									//If less than branch to loop
	

	cmp 	negative, 1								//Compare if negative is true 
	b.ne 	continue								//If positive than branch to continue
	sub	product, product, multiplicand						//Else subtracte multiplicand from product

continue:
	adrp 	x0, productNmultiplier							//Set 1st argument for printf		
	add 	x0, x0, :lo12:productNmultiplier					//Address for string
	mov 	w1, product								//Passing in first hexadecimal value for placeholder
	mov 	w2, multiplier								//Passing in first hexadecimal value for placeholder
	bl 	printf									//Branch to print function to print
	sxtw	temp1, product								//Sign extend product into temp1
	and 	temp1, temp1, 0xFFFFFFFF						//And operation between productLong and temp1
	lsl	temp1, temp1, 32							//Arithmetics shift to the left by 32
	sxtw	temp2, multiplier							//Sign extend multipler into temp2
	and	temp2, temp2, 0xFFFFFFFF						//And operation between multiplierLong and temp2
	add	result, temp1, temp2							//Add temp1 to temp2 and store in result
	
	adrp 	x0, longResult								//Set 1st argument for printf		
	add 	x0, x0, :lo12:longResult						//Address for string
	mov 	x1, result								//Passing in first hexadecimal value for placeholder
	mov 	x2, result								//Passing in value for placeholder
	bl 	printf									//Branch to print function to print

	mov 	w0, 0									//Set up return value for main
	ldp 	x29, x30, [sp], 16							//Restore FP to LR from stack

	ret										//Return to caller
	
