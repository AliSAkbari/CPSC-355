//Ali Akbari Assignment 5 Part A
//CPSC 355 Lecture 02 Tutorial 07
//30010402

FALSE = 	0										//Equating False to 0
TRUE =		1										//Equating True to 1
QUEUESIZE = 	8										//Equating queue size to 8
MODMASK =	0X7										//Equating the modmask to 0x7

//Defining strings for print
fullEnqueue:	.string "\nQueue overflow! Cannot enqueue into a full queue.\n"			//If full and enqueue overflow print			
emptyDequeue: 	.string "\nQueue underflow! Cannot dequeue from an empty queue.\n"		//If empty and dequeue underflow print
emptyStr:	.string "\nEmpty queue\n"							//If queue empty print empty 
currentContents:.string "\nCurrent queue contents:\n"						//Current contents of queue is printed
queueElement:	.string "%d"									//Element of queue[i]
newLine:	.string "\n"									//New line string
headValStr:	.string " <-- head of queue" 							//Value of the head of the queue
tailValStr:	.string " <-- tail of queue"							//Value of the tail of the queue

		
.data												//Data section
head: .word 	-1										//Initialize head global variable	
tail: .word	-1										//Initialize tail global variable
.bss												//BSS section
queue:		.skip QUEUESIZE * 4								//Initializing queue array as gloabal variable
.text												//Read only text section

//Defined register for readablity  
define(baseAddr_r, x19)										//Address register for head, tail of queue

define(enqPara_r, w9)										//Parameter value register passed in for enqueue
define(enqTailVal_r, w10)									//Tail value register for enqueue	

define(deqHead_r, w11)										//Head value register for dequeue
define(deqTail_r, w12)										//Tail value register for dequeue
define(deqReturn_r, w13)									//The return value for dequeue

define(headFull_r, w14)										//Head value register for queueFull
define(tailFull_r, w15)										//Tail value register for queueFull

define(headEmpt_r, w15)										//Head value register for queueEmpty

define(disHead_r, w21)										//Head value register for display
define(disTail_r, w22)										//Tail value register for display
define(j_counter_r, w23)									//Loop counter register for display
define(i_element_r, w24)									//Index i value of queue register for display
define(count_r, w25)										//Number of times loop runs 

fp	.req x29										//Register equates for frame pointer
lr	.req x30										//Register equates for link register

	//Intructions must be word aligned 
	//Make these functions global to main 
	.balign 4								
	.global queueFull									//Make queueFull function visible
	.global	queueEmpty									//Make queueEmpty function visible
	.global enqueue										//Make enqueue function visible 
	.global dequeue										//Make dequeue function visible
	.global display										//Make display function visible

queueFull: 
	stp	fp, x30, [sp, -16]!								//Save FP and LR to stack, allocating alloc amount of bytes
	mov	fp, sp										//Update FP to current SP
	
	adrp	baseAddr_r, tail								//Put tail in base
	add	baseAddr_r, baseAddr_r, :lo12:tail						//Format lower 12 bits						
	ldr	tailFull_r, [baseAddr_r]							//Load tailFull to equal tail
	add	tailFull_r, tailFull_r, 1							//Incrment tailFull by 1
	and	tailFull_r, tailFull_r, MODMASK							//Logical And it with modmask

	adrp	baseAddr_r, head								//Place head address in base register
	add	baseAddr_r, baseAddr_r, :lo12:head						//Format lower 12 bits 
	ldr	headFull_r, [baseAddr_r]							//Load value into headFull register
	
	mov	w0, TRUE									//w0 is equal to true
	cmp	tailFull_r, headFull_r								//Compare if tailFull with the increment and logical and is equal to headFull
	b.eq	next										//If equal branch to next and end function and return
	mov	w0, FALSE									//Else return False in w0
next:	
	ldp	fp, x30, [sp], 16								//Restore pair FP and LR and deallocate memory
	ret											//Return to main function

queueEmpty: 
	stp	fp, x30, [sp, -16]!								//Save FP and LR to stack, allocating alloc amount of bytes
	mov	fp, sp										//Update FP to current SP
	
	adrp	baseAddr_r, head								//Place head in base register
	add	baseAddr_r, baseAddr_r, :lo12:head						//Format lower 12 bitd
	ldr	headEmpt_r, [baseAddr_r]							//Load value of head
	mov	w0, TRUE									//Set return to true
	cmp	headEmpt_r, -1									//Compare head with -1
	b.eq	nextB										//If equal branch to nextb
	mov	w0, FALSE									//Else return False
 
nextB:	ldp	fp, x30, [sp], 16								//Restore pair FP and LR and deallocate memory
	ret											//Return to main function



enqueue: 
	stp	fp, x30, [sp, -16]!								//Save FP and LR to stack, allocating alloc amount of bytes
	mov	fp, sp										//Update FP to current SP
	mov 	enqPara_r, w0									//Store parameter in w0
	bl	queueFull									//Branch to queueFull to check if full
	cmp	w0, TRUE									//Compare return value with true
	b.ne	nextEnq_A									//If it is not full continue to nextEnq_A
	
	adrp	x0, fullEnqueue									//If it is full then print overflow string
	add	x0, x0,:lo12:fullEnqueue							//String address
	bl	printf										//Branch to printf
	b	endEnq										//Branch to end of the function


nextEnq_A:
	bl	queueEmpty									//Branch to queueEmpty
	cmp	w0, TRUE									//Compare return value in w0 with true
	b.ne	nextEnq_B									//If it is not empty branch to nextEnq_B

	adrp	baseAddr_r, head								//If it is empty place head in base 
	add	baseAddr_r, baseAddr_r,:lo12:head						//Lower 12 bits formated
	str	wzr, [baseAddr_r]								//Store head as 0
	adrp 	baseAddr_r, tail								//Place tail in base
	add	baseAddr_r, baseAddr_r, :lo12:tail						//Lower 12 bits formated
	str	wzr, [baseAddr_r]								//Store tail as zero

	b	nextEnq_C									//End part of enqueue

nextEnq_B:
	adrp	baseAddr_r, tail								//Place tail in base 
	add	baseAddr_r, baseAddr_r,:lo12:tail						//Formate lower 12 bits
	
	ldr	enqTailVal_r, [baseAddr_r]							//Load tail value
	add	enqTailVal_r, enqTailVal_r, 1							//Increment tail value by 1
	and	enqTailVal_r, enqTailVal_r, MODMASK						//Logical AND Tail value with mod mask
	str	enqTailVal_r, [baseAddr_r]							//Store tail value 


nextEnq_C:
	ldr	enqTailVal_r, [baseAddr_r]							//Load tail value
	adrp	baseAddr_r, queue								//Place queue address in base 
	add	baseAddr_r, baseAddr_r, :lo12:queue						//Formate lower 12 bits
	str	enqPara_r, [baseAddr_r, enqTailVal_r, SXTW 2]					//Store parameter in queue 	
	

endEnq:
	ldp	fp, x30, [sp], 16								//Restore pair FP and LR and deallocate memory
	ret											//Return to main function


dequeue: 
	stp	fp, x30, [sp, -16]!								//Save FP and LR to stack, allocating alloc amount of bytes
	mov	fp, sp										//Update FP to current SP

	bl	queueEmpty									//Branch link to queueEmpty function
	cmp	w0, TRUE									//Compare return value with true
	b.ne	nextDeq_A									//If not equal to branch to nextDeq_A
	adrp	x0, emptyDequeue								//Else place string in x0
	add	x0, x0, :lo12:emptyDequeue							//Format lower 12 bits
	bl 	printf										//Branch to printf
	mov	w0, -1										//Move -1 to return value
	b	endDeq										//Branch to endDeq

nextDeq_A:
	adrp	baseAddr_r, head								//Place head address in base register
	add	baseAddr_r, baseAddr_r, :lo12:head						//Format lower 12 bits
	ldr	deqHead_r, [baseAddr_r]								//Load head into deqHead_r
	
	adrp	baseAddr_r, tail								//Place tail address in base register
	add	baseAddr_r, baseAddr_r, :lo12:tail						//Format lower 12 bits
	ldr	deqTail_r, [baseAddr_r]								//Load tail into deqHead_r
				
	adrp	baseAddr_r, queue								//Place queue address in base register
	add	baseAddr_r, baseAddr_r, :lo12:queue						//Format lower 12 bits
	ldr	deqReturn_r, [baseAddr_r, deqHead_r, SXTW 2]					//Load return value
	
	cmp	deqHead_r, deqTail_r								//Compare head and tail
	b.ne	nextDeq_B									//If not equal to then branch to nextDeq_B

	adrp	baseAddr_r, head								//Place head address in base register
	add	baseAddr_r, baseAddr_r, :lo12:head						//Format lower 12 bits
	mov	w20, -1										//Make w20 = -1
	str	w20, [baseAddr_r]								//Store -1 for head
	
	adrp	baseAddr_r, tail								//Place tail address in base register
	add	baseAddr_r, baseAddr_r, :lo12:tail						//Format lower 12 bits
	
	str	w20, [baseAddr_r]								//Store -1 for head

	mov	w0, deqReturn_r									//Set return value
	b	endDeq										//Branch to end of the function

nextDeq_B:
	add	deqHead_r, deqHead_r, 1								//Increment deqHead
	and	deqHead_r, deqHead_r, MODMASK							//Logical AND deqHead and ModMask
	adrp	baseAddr_r, head								//Place head address in base register 
	add	baseAddr_r, baseAddr_r, :lo12:head						//Fortmat lower 12 bits
	str	deqHead_r, [baseAddr_r]							
	mov	w0, deqReturn_r									//Set return value

endDeq:
	ldp	fp, x30, [sp], 16								//Restore pair FP and LR and deallocate memory
	ret											//Return to main function


display: 
	stp	fp, x30, [sp, -16]!								//Save FP and LR to stack, allocating alloc amount of bytes
	mov	fp, sp										//Update FP to current SP
	
	bl	queueEmpty									//Branch and link to queueEmpty
	cmp	w0, TRUE									//Compare return result
	b.ne	nextDis_A									//If not equal branch to nextDis_A

	adrp	x0, emptyStr									//Else print Empty String message
	add	x0, x0, :lo12:emptyStr								//Format lower 12 bits
	bl	printf										//Call to printf
	b	endDis										//Branch to end of the function

nextDis_A:

	adrp	baseAddr_r, head								//Place head address in base register
	add	baseAddr_r, baseAddr_r, :lo12:head						//Format lower 12 bits
	ldr	disHead_r, [baseAddr_r]								//Load head into disHead_r
	
	adrp	baseAddr_r, tail								//Place tail address in base register
	add	baseAddr_r, baseAddr_r, :lo12:tail						//Format lower 12 bits
	ldr	disTail_r, [baseAddr_r]								//Load tail into disHead_r

	sub	count_r, disTail_r, disHead_r							//Initializing count_r = tail - head
	add	count_r, count_r, 1								//Count_r = tail - head + 1
	
	cmp	count_r, 0									//Compare count and 0
	b.gt	nextDis_B									//If greater than zero continue 
	add	count_r, count_r, QUEUESIZE							//Else count_r = count_r + QUEUESIZE

nextDis_B: 
				
	adrp	x0, currentContents								//Place currentContents string in x0
	add	x0, x0, :lo12:currentContents							//Format lower 12 bits
	bl 	printf										//Branch to printf

	mov	i_element_r, disHead_r								//i_element = head
	mov	j_counter_r, 0									//Set loop 
	b	disTestLoop									//Branch to the test part of the loop
disLoop:	
	adrp 	x0, queueElement								//Place queue elment in x0
	add	x0, x0,:lo12: queueElement 							//Format lower 12 bits						
	adrp	baseAddr_r, queue								//Put queue in base register	
	add	baseAddr_r, baseAddr_r, :lo12:queue						//Format lower 12 order bits		
	ldr	w1, [baseAddr_r, i_element_r, SXTW 2]						//w1 = queue[i]
	bl	printf										//Branch and link to printf

	cmp	i_element_r, disHead_r								//Compare head and i element
	b.ne	notEqual									//If not equal branch to notEqual

	adrp	x0, headValStr									//x0 holds headValStr string		
	add	x0, x0, :lo12:headValStr							//Lower order 12 bits format			
	bl	printf										//Branch to printf							 
notEqual:
	cmp	i_element_r, disTail_r								//Compare tail and i element
	b.ne	skip										//If not equal branch to skip
	adrp	x0, tailValStr									//x0 holds tailValStr string		
	add	x0, x0, :lo12:tailValStr							//Lower order 12 bits format			
	bl	printf										//Branch to printf					
skip:	
	adrp	x0, newLine									//x0 holds newLine string		
	add	x0, x0, :lo12:newLine								//Lower order 12 bits format			
	bl	printf										//Branch to printf
	add	i_element_r, i_element_r, 1							//Increment i		
	and	i_element_r, i_element_r, MODMASK						//Logical and i with MODMASK
	add	j_counter_r, j_counter_r, 1							//Increment loop counter j
disTestLoop:
	cmp	j_counter_r, count_r								//Compare j to count 
	b.lt	disLoop										//If less than branch to loop
endDis:
	mov	w0, 0										//Return value
	ldp	fp, x30, [sp], 16								//Restore pair FP and LR and deallocate memory
	ret											//Return to main function


