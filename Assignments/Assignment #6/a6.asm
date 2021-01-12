//Ali Akbari Assignment 6, File I/O / Floating Point
//Tutorial 07		
//30010402

//Assembler equates
buf_size = 8								//Assembler equates for buf size		
alloc = -(16 + buf_size) & -16						//Assembler equates for alloc		
dealloc = -alloc							//Assembler equates for dealloc		
buf_s = 16								//Assembler equates for buf_s		
AT_FDCWD = -100								//Assembler equates for AT_FDCWD		


//Define macros for heavily used registers
define(i_r, w19)							//Define i_r macro
define(argc_r, w21)							//Define argc_r macro
define(argv_r, x22)							//Define argv_r macro
define(fd_r, w23)							//Define fd_r macro
define(nread_r, x20)							//Define nread_r macro
define(buf_base_r, x21)							//Define buf_base_r macro

inputVal	.req d19						//Input value from file
xVal		.req d20						//X value starting and x prime
yVal		.req d22						//Y value 
dyVal		.req d23						//Change in y
dydxVal		.req d24						//Derivative
tempVal		.req d25						//Temporary value
	.data								//Data section of memory	
limit:		.double 0r1.0e-10					//Double value used for loop and precision
zero:		.double 0r0.0						//Double value of zero

	.text								//Text section of memory
// Format strings
pn:		.string "%s"						//Used for file name	
Exception:	.string "Error opening file: %s\nAborting.\n"		//Error print message
fmt1:		.string "Input Value\t Cube Root\n"			//Column header
fmt2:		.string "%13.10f\t"					//Used for print input value
fmt3:		.string "%13.10f\t\n"					//Used for printing x cube root value

	//Intructions are word aligned
	.balign	4
	//Making main visible
	.global	main
main:
	stp	x29, x30, [sp, -16]!					//Allocating 16 bytes of memory
	mov	x29, sp							//Updating FP to current Sp

	mov	i_r, 1							//Index i_r is equal to 1
	mov	argc_r, w0						//Getting my argument counter from cmd
	mov	argv_r, x1						//Getting my argument value from cmd
	bl	open							//Branch to open
exit:
	ldp	x29, x30, [sp], 16					//Deallocating 16 bytes of memory
	ret								//Return to calling code

open:
	stp	x29, x30, [sp, alloc]!					//Allocationg alloc amount of bytes of memory
	mov	x29, sp							//Updating FP to current sp

	adrp 	x0, fmt1						//Set 1st argument to pass to printf, printing header
	add 	x0, x0, :lo12:fmt1					//Fomat lower 12 order bits
	bl 	printf							//Branch to printf

	// int fd = openat(int dirfd, const char *pathname, int flags, mode_t mode);
	// Open existing binary file
	mov	w0, AT_FDCWD						// 1st arg (cwd)

	adrp 	x1, pn							//Getting the address of pn
	add 	x1, x1, :lo12:pn					//Formating lower order bits
	ldr 	x1, [argv_r, i_r, SXTW 3]				//Loading file based on cmd argument

	mov	w2, 0							//3rd  arg (read-only)
	mov	w3, 0							//4th arg (not used)
	mov	x8, 56							//Openat I/O request
	svc	0							//Call system function
	mov	fd_r, w0						//Record file descriptor

	// Do error checking for openat()
	cmp	fd_r, 0							//Error check: branch over
	b.ge	openok							//If file opened successfully

	adrp	x0, Exception						//Error handling code
	add	x0, x0, :lo12:Exception					//1st arg
	adrp	x1, pn							//2nd arg
	add	x1, x1, :lo12:pn					//Format lower 12 order bits
	ldr	x1, [argv_r, i_r, SXTW 3]				//Load string from cmd passed in
	bl	printf							//Print error message

	b	done							//Exit program

openok:	
	add	buf_base_r, x29, buf_s					//Calculate buf base

	// long n_read = read(int fd, void *buf, unsigned long n);
	// Read long ints from bniary file one buffer at a time in a loop
top:	mov	w0, fd_r						//1st arg (fd)
	mov	x1, buf_base_r						//2nd arg (buf)
	mov	w2, buf_size						//3rd arg (n)
	mov	x8, 63							//Read I/O request
	svc	0							//Call system function
	mov	nread_r, x0						//Record $ of bytes actually read

	// Do error checking for read()
	cmp	nread_r, buf_size					//If nread != 8, then
	b.ne	end							//Branch to end

	adrp	x0, fmt2						//Setting up string address for printing x
	add	x0, x0, :lo12:fmt2					//Formating lower 12 order bits
	ldr	d0, [buf_base_r]					//2nd arg (the long int) the input value
	bl	printf							//Branch to printf

	//Taking parameters and branching to subroutine CalculatePos
	bl 	calculate						//Branch to calculate

	adrp 	x0, fmt3						//Set 1st argument
	add	x0, x0, :lo12:fmt3					//Setting 2nd argument for printf	
	fmov	d1, d0							//Argument for printing of x cube root value 
	bl 	printf							//Branch to printf
	b	top							//Go to top of loop

	// Close the binary file
end:	mov	w0, fd_r						//1st arg (fd)
	mov	x8, 57							//Close I/O request
	svc	0							//Call system function
done:
	mov	w0, 0							//Return 0
	ldp	x29, x30, [sp], dealloc					//Deallocate memory, restore FP and LR
	ret								//Return to caller code


calculate:
	stp	x29, x30, [sp, -16]!					//Allocate 16 bytes of memory
	mov	x29, sp							//Update Fp to current sp
	fmov	d26, 3.0						//d26 = 3.0 initializing a double

	adrp	x10, limit						//Address setup for limit
	add	x10, x10, :lo12:limit					//Formating lower 12 bits
	ldr	d10,[x10]						//Loading limit double into d10
	
	ldr	d0, [buf_base_r]					//Loading input value into d0
	
	adrp	x10, zero						//Address setup for zero
	add	x10, x10, :lo12:zero					//Formating lower 12 bits
	ldr	d11, [x10]						//Loading zero double into d11

	fcmp	d0, d11							//Comparing input to zero double
	b.le	preFin							//If input is negative or zero branch to prefin
		
	fmul	d10, d10, d0						//d10 = limit * input					

	fmov	inputVal, d0						//inputVal = input
	fdiv	xVal, inputVal, d26					//xVal = inputVal / 3
calTop:
	fmul	yVal, xVal, xVal					//yVal = xVal * xVal			y = x * x
	fmul	yVal, yVal, xVal					//yVal = xVal * xVal * xVal		y = x^3
	fsub	dyVal, yVal, inputVal					//dyVal = yVal - inputVal 		dy = y - input 
	fmul	dydxVal, d26, xVal					//dY/dX = 3 * xVal			dy/dx = 3x 
	fmul	dydxVal, dydxVal, xVal					//dY/dX = 3 * xVal * xVal		dy/dx = 3x^2
	fdiv	tempVal, dyVal, dydxVal					//tempVal = dyVal/(dY/dX)		temp = dy/(dy/dx)
	fsub	xVal, xVal, tempVal					//xVal = xVal - tampVal			x' = x - (dy/(dy/dx))
	fabs	dyVal, dyVal						//|dy|					|dy|
test:	
	fcmp	dyVal, d10						//Compare dyVal to d10 (limit * input)
	b.gt	calTop							//If greater, then breanch to top of loop
	fmov	d0, xVal						//Else move new x value to d0 to return
	b	final							//Branch to final to end function

preFin:	

	adrp	x10, zero						//Address setup for zero
	add	x10, x10, :lo12:zero					//Formating lower 12 bits
	ldr	d11, [x10]						//Loading zero double into d11
	fmov	d0, d11							//Move zero double for return
final:
	ldp	x29, x30, [sp], 16					//Deallocate 16 bytes of memory and restore FP and LR
	ret								//Return to caller code


