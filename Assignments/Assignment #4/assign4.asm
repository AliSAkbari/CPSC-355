//Ali Akbari Assignment 4
//CPSC 355 Lecture 02 Tutorial 07
//30010402


FALSE = 0											//Equating False to 0
TRUE = 1											//Equating True to 1

pointx_offset = 0										//Point X offset
pointy_offset = 4										//Point Y offset
dimensionWidth_offset = 8									//Dimension width offset
dimensionHeight_offset = 12									//Dimension height offset
area_offset = 16										//Area offset
totalOffsetOfOne = 20										//Total offset of 5 variables for one box
totalOffset  = totalOffsetOfOne * 2 								//Total offset needed for two boxes

alloc = -(16 + (totalOffset)) & -16 								//Calculating size for allocating memory
dealloc = -alloc										//Deallocating memory size

firstOffset = 16										//Offset of first box
secondOffset = firstOffset + totalOffsetOfOne							//Offset of the second box

newBoxAlloc = -(16 + totalOffsetOfOne) & -16							//Calculating needed size of memory for newbox function
newBoxDealloc =	-newBoxAlloc									//Deallocating memory size for newBox function

result_offset = 16										//Result offset for equal function
resultSize = 4											//Memory size for result
equalAlloc = -(16 + resultSize) & -16								//Calculating needed size for memory for equal function
equalDealloc = - equalAlloc									//Deallocating memory size for equal function

//Defining strings for print
boxValues:		.string "Box %s origin = (%d, %d) width = %d height = %d area = %d\n"	//All box values to be printed			
firstStr: 		.string "first"								//String first to be printed 
secondStr:		.string "second"							//String second to be printed
initialValues:		.string "Initial box values:\n"						//String for initial box values
changedValues:		.string "\nChanged box values: \n" 					//String for Changed box values

fp	.req x29										//Register equates for frame pointer
lr	.req x30										//Register equates for link register


	.balign 4										//Intstructions must be word aligned
	.global main										//Make 'main' visible to the OS

main: 
	stp	fp, x30, [sp, alloc]!								//Save FP and LR to stack, allocating alloc amount of bytes
	mov	fp, sp										//Update FP to current SP

	add	x8, fp, firstOffset								//Pass in first offset to newBox function
	bl	newBox										//Branch link to newBox	

	add	x8, fp, secondOffset								//Pass in second offset to newBox function
	bl	newBox										//Branch link to newBox
						

	adrp 	x0, initialValues								//Set 1st argument for printf		
	add 	x0, x0, :lo12:initialValues							//Address for string
	bl 	printf										//Branch to print function to print
	

	adrp 	x0, firstStr									//Set 1st argument for printf		
	add 	x0, x0, :lo12:firstStr								//Address for string
	add	x1, fp, firstOffset								//Place addres of first into x1
	bl 	printBox									//Branch to print function to print



	adrp 	x0, secondStr									//Set 1st argument for printf		
	add 	x0, x0, :lo12:secondStr								//Address for string
	add	x1, fp, secondOffset								//Place address of second into x1
	bl 	printBox									//Branch to print function to print
firstBreak:
	add	x0, fp, firstOffset								//Passing the address of first box
	add	x1, fp, secondOffset								//Passing the address of second box
	bl	equal										//Branch and link to equal funcion

	cmp	w0, TRUE									//Compare return value from equal to TRUE
	b.ne	endMain										//If not equal then continue
	
	add	x0, fp, firstOffset								//Calculate framerecord plus first box offset and pass it in
	mov	w1, -5										//Parameter 1 for move is -5
	mov	w2, 7										//Parameter 2 for move is 7
	bl	move										//Branch and link to move

	add	x0, fp, secondOffset								//Calculate framerecord plus second box offset and pass it in
	mov	w1, 3										//Parameter 1 for expand is 3
	bl	expand										//Branch and link to expand


endMain:

	adrp 	x0, changedValues								//Set 1st argument for printf		
	add 	x0, x0, :lo12:changedValues							//Address for string
	bl 	printf										//Branch to print function to print
	

	adrp 	x0, firstStr									//Set 1st argument for printf		
	add 	x0, x0, :lo12:firstStr								//Address for string
	add	x1, fp, firstOffset								//Place addres of first into x1
	bl 	printBox									//Branch and link to print box function to print



	adrp 	x0, secondStr									//Set 1st argument for printf		
	add 	x0, x0, :lo12:secondStr								//Address for string
	add	x1, fp, secondOffset								//Place address of second into x1
	bl	printBox									//Branch and link to print box function to print

	ldp 	fp, x30, [sp], dealloc								//Restore FP to LR from stack, deallocate memory 
	ret											//Return to caller/End program

newBox:	
	stp	fp, x30, [sp, newBoxAlloc]!							//Save FP and LR to stack, allocating newBoxalloc amount of bytes
	mov	fp, sp										//Update FP to current SP
	
	add	x9, fp, totalOffsetOfOne 							//Set x9 to the base address of variables
	str	wzr, [x9, pointx_offset]							//Point x = 0 and stored into stack
	str	wzr, [x9, pointy_offset]							//Point y = 0 and stored into stack
	mov	w19, 1										//Initialize w19 to 1 
	str	w19, [x9, dimensionWidth_offset]						//Width = 1 and stored into stack
	str	w19, [x9, dimensionHeight_offset]						//Hieght = 1 and stored into stack
	ldr	w19, [x9, dimensionWidth_offset]						//w19 = width, loaded from stack
	ldr	w20, [x9, dimensionHeight_offset]						//w20 = height,loaded from stack
	mul	w19, w19, w20									//w19 = width * height
	str	w19, [x9, area_offset]								//Area = width * height and stored into stack

	ldr	w19, [x9, pointx_offset]							//Load point x value from stack
	str	w19, [x8, pointx_offset]							//Sotre point x value to stack using address in x8
	ldr	w19, [x9, pointy_offset]							//Load point x value from stack
	str	w19, [x8, pointy_offset]							//Store point y value to stack using address in x8
	ldr	w19, [x9, dimensionWidth_offset]						//Load width value from stack
	str	w19, [x8, dimensionWidth_offset]						//Store width value to stack using address in x8
	ldr	w19, [x9, dimensionHeight_offset]						//Load height value from stack
	str	w19, [x8, dimensionHeight_offset]						//Store height value to stack using address in x8
	ldr	w19, [x9, area_offset]								//Load area value from stack
	str	w19, [x8, area_offset]								//Store area  value to stack using address in x8
		
	ldp	fp, x30, [sp], newBoxDealloc							//Restore FP to LR and deallocate memory
	ret											//Return to main function

printBox:
	stp	fp, x30, [sp, -16]!								//Save FP and LR to stack, allocating 16 bytes	
	mov	fp, sp										//Updating FP to current SP
	
	ldr	x2, [x1, pointx_offset]								//Loading point x value for print
	ldr	x3, [x1, pointy_offset]								//Loading point y value for print
	ldr	x4, [x1, dimensionWidth_offset]							//Loading width value for print
	ldr	x5, [x1, dimensionHeight_offset]						//Loading height value for print
	ldr	x6, [x1, area_offset]								//Loading area value for print

	mov	x1, x0										//Move passed in value(string) to first agrument for print
	adrp	x0, boxValues									//Set first argument for printf
	add	x0, x0, :lo12:boxValues								//Address for string
	bl	printf										//Branch and link to print function
	

	ldp	fp, x30, [sp], 16								//Restore pair FP and LR and deallocate memory
	ret											//Return to main function

equal:
	stp	fp, x30, [sp, equalAlloc]!							//Save FP and LR to stack, allocating equalAlloc amount of bytes	
	mov	fp, sp										//Updating FP to current SP

	mov	w9, FALSE									//Make w19 = False
	str	w9, [fp, result_offset]								//Store in local stack			

	ldr	w20, [x0, pointx_offset]							//Load point x with frame record & first box offset and point x offset
	ldr	w21, [x1, pointx_offset]							//Load point x with frame record & second box offset and point x offset
	cmp	w20, w21									//Compare the two x values from the boxes
	b.ne	endFunction									//If not equal continue

	ldr	w20, [x0, pointy_offset]							//Load point y with frame record & first box offset and point y offset
	ldr	w21, [x1, pointy_offset]							//Load point y with frame record & second box offset and point y offset
	cmp	w20, w21									//Compare the two y value from the boxes
	b.ne	endFunction									//If not equal continue

	ldr	w20, [x0, dimensionWidth_offset]						//Load width with frame record & first box offset and width offset
	ldr	w21, [x1, dimensionWidth_offset]						//Load width with frame record & second box offset and width offset
	cmp	w20, w21									//Compare the two width value from the boxes
	b.ne	endFunction									//If not equal continue

	ldr	w20, [x0, dimensionHeight_offset]						//Load height with frame record & first box offset and height offset
	ldr	w21, [x1, dimensionHeight_offset]						//Load height with frame record & second box offset and height offset
	cmp	w20, w21									//Compare the two height values from the boxes
	b.ne	endFunction									//If not equal continue

	mov	w9, TRUE									//If it pass all test cases then make w9 = TRUE
	str	w9, [fp, result_offset]								//Store w9 with result offset
	ldr	w0, [fp, result_offset]								//Load result to w0 for return value

endFunction:
	ldp	fp, x30, [sp], equalDealloc							//Restore pair FP and LR and deallocate memory
	ret											//Reutn to main	

move:
	stp	fp, x30, [sp, -16]!								//Save FP and LR to stack, allocating equalAlloc amount of bytes	
	mov	fp, sp										//Updating FP to current SP
	
	ldr	w9,[x0, pointx_offset]								//Load point x value with pass in frame record and offsets
	add	w9, w9, w1									//Add loaded value of w9 and value of first parameter passed in
	str	w9, [x0, pointx_offset]								//Store value of point x 
	
	ldr	w10,[x0, pointy_offset]								//Load point y value with pass in frame record and offsets
	add	w10, w10, w2									//Add loaded value of w9 and value of second parameter passed in
	str	w10, [x0, pointy_offset]							//Store value of point y 

	ldp	fp, x30, [sp], 16								//Restore pair FP and LR and deallocate memory
	ret											//Return to main

expand:
	stp	fp, x30, [sp, -16]!								//Save FP and LR to stack, allocating equalAlloc amount of bytes	
	mov	fp, sp										//Updating FP to current SP

	ldr	w9, [x0, dimensionWidth_offset]							//Load point width  with pass in frame record and offsets
	mul	w9, w19, w1									//Multiply loaded value of w9 and value of first parameter passed in
	str	w9, [x0, dimensionWidth_offset]							//Store value of width 

	ldr	w10, [x0, dimensionHeight_offset]						//Load height value with pass in frame record and offsets
	mul	w10, w10, w1									//Multiply loaded value of w10 and value of second parameter passed in
	str	w10, [x0, dimensionHeight_offset]						//Store value of height 
	
	mul	w10, w9, w10									//Calculate area, w10 = height * width
	str	w10, [x0, area_offset]								//Store value of area 


	mov	w0, 0										//Return value 0 to main
	ldp	fp, x30, [sp], 16								//Restore pair FP and LR and deallocate memory
	ret											//Return to main function
