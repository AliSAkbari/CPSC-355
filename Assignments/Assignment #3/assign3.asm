//Ali Akbari Assignment 3
//CPSC 355 Lecture 02 Tutorial 07
//30010402

//Equates
size = 			50								//Defining Size for array
sizeInBytes =		size * 4							//Size of Array in Bytes
i_Addr =		16								//I position/offset in stack
j_Addr =		20								//J position/offset in stack
tempAddr =		24								//Temp position/offset in stack
arrayOffset =		28								//Base address/offset of array

//Allocating size for memory
alloc =		-(16 + 16 + sizeInBytes) & 16						//Allocate (200 for elements/size of array, for i, j, temp and for base address)
dealloc =	-alloc									//For Deallocating


//Defining strings for print
unsortedArray:			.String "v[%d]: %d\n"					//Array to be printed			
sortedArrayString: 		.String "\nSorted Array:\n"				//For printing "Sorted array"

define(i, w19)										//Defining i
define(randValue, w20)									//Definging random value for rand function
define(j, w21)										//Defining j
define(temp1, w22)									//Defining temporary variable 1
define(temp2, w23)									//Defining temporary variable 2
define(base_addr, x28)

fp .req 	x29									//Register equates
lr .req		x30									//Register equates

	.balign 4									//Intstructions must be word aligned
	.global main									//Make 'main' visible to the OS

main: 
	stp	 fp, lr, [sp, alloc]!							//Save FP and LR to stack, allocating 16 bytes
	mov	 fp, sp									//Update FP to current SP

	add	base_addr, fp, arrayOffset						//Calculating arraybase address
	
	mov 	i, 0									//Initializing i to 0
	str	i, [fp, i_Addr]								//Storing i in stack
	bl clock									//Branch to clock function
	bl srand									//Branch ti srand function
	b	unsortedTest								//Branch to first loop test

unsortedTop:
	bl 	rand									//Branch to random function to make random number
	ldr	i, [fp, i_Addr]								//Load index i from stack
	AND	randValue, w0, 0xFF
	str	randValue, [base_addr, i, SXTW 2]					//Store random value

	adrp	x0,unsortedArray							//Set first argument for printf
	add	w0, w0, :lo12:unsortedArray						//Address for sting
	mov	w1, i									//Move i into first placeholder
	mov	w2, randValue								//Move randValue to second placeholder
	bl	printf									//Branch to printf
	
	add	i, i, 1									//Increment i
	str	i, [fp, i_Addr]								//Store updated i in stack

unsortedTest:	
	cmp 	i, size									//Compare counter/i to size
	b.lt 	unsortedTop								//If less than then branch to top

gdbUnsortedPrint:									//Used for gdb
	mov	i, 1									//Initialize i to 0 for next loop 
	str	i, [fp, i_Addr]								//Store i local variable to stack
	b	sortedTestOuter								//Branch to next loop test



sortedTopOuter:
	ldr	i, [fp,i_Addr]
	ldr	temp1, [base_addr, i, SXTW 2]						//Temp1 = V[i]
	str	temp1,[fp, tempAddr]							//Store v[i] in tempIndex address
	str	i, [fp, j_Addr]								//Store j = i into stack
	b	sortedTestInner								//Branch to inner loop test	

sortedTopInner:
	ldr	j,[fp, j_Addr]								//Loading j from stack		
	sub	w25,j,1									//J-1
	ldr	temp2,[base_addr, w25, SXTW 2]							//Loading v[j-1]
	str	temp2,[base_addr,j,SXTW 2]						//Storing v[j] = v[j-1] 
	sub	j, j, 1									//Decrement j by 1
	str	j,[fp, j_Addr]								//Store j back into stack

sortedTestInner:
	ldr	j, [fp, j_Addr]								//Load j value from stack
	cmp	j, 0									//Compare j to 0
	b.le	noSwitch								//Branch to noSwitch if less than and equal to 
	
	ldr	temp1, [fp,tempAddr]							//Loading temporary value from array in stack
	sub	w24,j,1									//w24 = j-1
	ldr	temp2, [base_addr, w24, SXTW 2]						//Load v[j-1] from stack
	
	cmp	temp1, temp2								//Compare temp1 and temp2
	b.ge	noSwitch								//If temp1 is greater or equal to temp2 then branch to noSwitch
	b	sortedTopInner								//If both conditions fail branch to sortedTopInner

noSwitch:
	ldr	temp1,[fp,tempAddr]							//Load temp1 from stack
	ldr	j, [fp,j_Addr]								//Load j from stack
	str	temp1, [base_addr, j, SXTW2]						//Store temp1 with index j

	ldr	i,[fp,i_Addr]								//Load i from stack
	add	i, i, 1									//Increment i	
	str	i,[fp, i_Addr]								//Store i back into stack

sortedTestOuter:
	ldr	i, [fp, i_Addr]								//Load local variable i from stack
	cmp	i, size									//Compare i with size
	b.lt	sortedTopOuter								//If less than branch to sortedTopOuter
	
	adrp	x0, sortedArrayString							//Else Print sortArrayString
	add	x0,x0, :lo12:sortedArrayString						//String address for printf
	bl	printf									//Branch to printf
	
	mov	i,0									//i = 0
	str	i,[fp,i_Addr]								//Store update i into stack
	b	printTest								//Branch to printTest	

printLoop:
	adrp	x0, unsortedArray							//Set first argument for string
	add	x0,x0, :lo12:unsortedArray						//Address for string
	ldr	w1, [fp,i_Addr]								//Pass in first argument for printf
	ldr	w2, [base_addr, w1, SXTW 2]						//Pass in second argument for printf
	bl	printf									//Branch to printf
	add	i, i, 1									//Increment i
	str	i,[fp,i_Addr] 								//Store i back into the stack

printTest:
	cmp	i, size									//Compare i/counter and size
	b.lt	printLoop								//Branch to printLoop

	mov 	w0, 0									//Set up return value for main
	ldp 	fp, lr, [sp], dealloc							//Restore FP to LR from stack

	ret										//Return to caller
	
