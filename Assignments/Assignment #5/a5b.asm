//Ali Akbari Assignment 5 Part B
//CPSC 355 Lecture 02 Tutorial 07
//30010402

//Register defined 
define(argc_r, w19)										//Used to hold number of arguments 
define(argv, x20)										//Array with argument values

define(month_r, w21)										//Used to hold month argument value	
define(day_r, w22) 										//Used to hold day argument value

define(season_r, w23)										//Used to hold season value which is for array index of seasons
define(season_cal, w24)										//Used to hold numerical value of the day in the season

define(ending_r, w25)										//Used to hold the suffix value which is for array index of endings

//Strings defined/ declared to hold month strings which is used for month array
jan_str:	.string "January"								//January string
feb_str:  	.string "February"								//February string
mar_str:  	.string "March"									//March string
apr_str: 	.string "April"									//April string
may_str:  	.string "May"									//May string
jun_str: 	.string "June"									//June string
jul_str: 	.string "July"									//July string
aug_str:  	.string "August"								//August string
sep_str:  	.string "September"								//September string
oct_str: 	.string "October"								//October string
nov_str: 	.string "November"								//November string
dec_str: 	.string "December"								//December string
//Strings defined/ declared to hold seasons strings which is used for season array
sum_str:	.string "Summer"								//Summer string
fal_str:	.string "Fall"									//Fall string
win_str:	.string "Winter"								//Winter string
spr_str:	.string "Spring"								//Spring string
//Strings defined/ declared to hold suffix strings which is used for ending array
st_str:		.string "st"									//String for st suffix
nd_str:		.string "nd"									//String for nd suffix
th_str:		.string "th" 									//String for th suffix
rd_str:		.string "rd"									//String for rd suffix

//Print Statements 
usage_str: 	.string "usage: a5b mm dd\n"							//Print statement for incorrect command line inputs	
invalidRange:   .string "Invalid range for either command line argument!\n"			//Print statement for incorrect range for command line arguments
display_print:	.string "%s %d%s is %s\n"							//Print statement used to print result	
		.data										//Data section of memory
		.balign 8 									//These tables must be 8 byte aligned for the string array
//Arrays made from above defined strings, one array for month, one for season, one for suffix 
months: 	.dword jan_str, feb_str, mar_str, apr_str, may_str, jun_str, jul_str, aug_str, sep_str, oct_str, nov_str, dec_str
seasons:	.dword win_str, spr_str, sum_str, fal_str
endings:	.dword st_str, nd_str, th_str, rd_str
  	
	.text											//Readable text section of memory				
	.balign 4										//Align to 4 bits 
	.global main										//Make main visible
main:
	stp	x29, x30, [sp, -16]!								//Allocate 16 bytes of memory
	mov	x29, sp										//Move/update frame pointer to  stack pointer

	mov	argc_r, w0  									//Store the number of arguments
	mov   	argv, x1									//Store the array of argument

	cmp	argc_r, 3									//Compare if three and number of arguments 					
	b.eq	next_a										//If it is equal to 3 three arguments then branch to next_a	
		
	adrp	x0, usage_str									//Else store usage message string in x0
	add	x0, x0, :lo12:usage_str								//Formate lower 12 bits 
	bl	printf										//Branch and link to printf
	b	exit_main									//Branch to exit main function to terminate program
	
next_a:
	mov	w27, 1										//Temporary variable in w27	
    	ldr	x0, [argv, w27, SXTW 3]								//Load second argument into x0
    	bl	atoi         									//Branch into atoi to convert string in x0 into integar 	
   	mov	month_r, w0									//Move return value from atoi to month_r	

	add	w27, w27, 1									//Increment temporary variable in w27 by 1 
	ldr	x0, [argv, w27, SXTW 3]								//Load third argument into x0
	bl	atoi										//Branch into atoi to convert string in x0 into integar
	mov	day_r, w0									//Move return value from atoi into day_r

    	cmp	month_r, 0  									//Compare month argument with 0, since atoi may return zero if it fails to convert
    	b.le	range_limit									//If less than or equal to 0 branch to range_limit fucntion, since month cannot be 0 or negatives

    	cmp 	day_r, 0									//Compare day argument with 0, since atoi may return zero if it fails to convert
	b.le	range_limit									//If less than or equal to 0 branch to range_limit fucntion, since day cannot be 0 or negatives

	cmp	month_r, 12									//Compare month with 12
	b.gt	range_limit									//If month is greater, then branch to range_limit

	cmp	day_r, 31									//Compare day with 31
	b.gt	range_limit									//If day is greater, then branch to range_limit
		
	cmp	month_r, 2									//Compare month with 2 (February)
	b.ne	next_b										//If it is not equal to 2 (February) then branch to next_b
	cmp	day_r, 28									//Else if month is 2 compare day with 28
	b.gt	range_limit									//If day is greater than 28 branch to range_limit
next_b:		
	cmp	month_r, 4									//Compare month with 4 (April)
	b.eq	check_30_days									//If month is 4 branch to check_30_days
	
	cmp	month_r, 6									//Compare month with 6 (June)
	b.eq	check_30_days									//If month is 6 branch to check_30_days
								
	cmp	month_r, 9									//Compare month with 9 (September)
	b.eq	check_30_days									//If month is 9 branch to check_30_days

	
	cmp	month_r, 11									//Compare month with 11 (November)
	b.eq	check_30_days									//If month is 11 branch to check_30_days

	b	season_check									//Branch to season_check 

check_30_days:
	cmp	day_r, 30									//Compare days with 30
	b.gt	range_limit									//If greater than 30 then branch to range_limit 

season_check:
	mov	w28, 30										//Temporary constant 
	madd	season_cal, month_r, w28, day_r							//season_cal = (month * 30) + day
	//Range checker for spring
	cmp	season_cal, 111									//Comapre season_cal with 111
	b.ls	next_c										//If less than then branch to next_c
	cmp	season_cal, 200									//Compare season_cal with 200
	b.gt	next_c										//If greather than, then branch to next_c
	
	mov	season_r, 1									//If both above conditions are met then season is set to 1 (Spring)
	b	ending_check									//Skip rest code to ending_check
next_c:
	//Range checker for summer
	cmp	season_cal, 290									//Comapre season_cal with 290
	b.gt	next_d										//If greather than, then branch to next_d
	
	mov	season_r, 2 									//If all above conditions are met then season is set to 2 (Summer)
	b	ending_check									//Skip rest code to ending_check
next_d:
	//Range checker for fall
	cmp	season_cal, 380									//Comapre season_cal with 380
	b.gt	next_e										//If greather than, then branch to next_e

	mov	season_r, 3 									//If all above conditions are met then season is set to 3 (Fall)
   	b	ending_check									//Branch to ending_check
next_e:	
	mov	season_r, 0									//If all above condition are not met then season is set to 0 (Winter)
 	

ending_check:
	//Compare to see if day is 1, 21, 31 to set suffix to st 
	//If it is equal branch to ending_st to set right suffix
	cmp	day_r, 1
	b.eq	ending_st
	cmp	day_r, 21
	b.eq	ending_st
	cmp	day_r, 31
	b.eq	ending_st

	//Compare to see if day is 2, 22 to set suffix to nd 
	//If it is equal branch to ending_nd to set right suffix
	cmp	day_r, 2
	b.eq	ending_nd
	cmp	day_r, 22
	b.eq	ending_nd

	//Compare to see if day is 3, 23 to set suffix to rd 
	//If it is equal branch to ending_rd to set right suffix
	cmp	day_r, 3
	b.eq	ending_rd
	cmp	day_r, 23
	b.eq	ending_rd
	
	//Else if it is non of the above then the suffix must be 'th'
	mov	ending_r, 2									//Set ending_r to 2 (th)
	b	display										//Branch to display
	
ending_st:
	mov	ending_r, 0									//Set ending_r to 0 (st)
	b	display										//Branch to display	
ending_nd:
	mov	ending_r, 1									//Set ending_r to 1 (nd)
	b	display										//Branch to display
ending_rd:
	mov	ending_r, 3									//Set ending_r to 3 (rd)
	b	display										//Branch to display


display:	
	adrp	x26, months									//Set months array in x26 			
	add	x26, x26, :lo12:months 								//Format lower 12 order bits

	adrp	x27, endings									//Set endings array in x27
	add	x27, x27, :lo12:endings 							//Format lower 12 order bits

	adrp	x28, seasons									//Set seasons array into x28
	add	x28, x28, :lo12:seasons								//Format lower 12 order bits

	sub	month_r, month_r, 1								//Decrement month_r for indexing of array

	adrp	x0, display_print								//Set display_print string in x0
	add	x0, x0, :lo12:display_print							//Format lower 12 order bits	
	ldr	x1, [x26, month_r, SXTW 3] 							//Load/pass in month into first print arguement
	mov	w2, day_r									//Pass day as second print arguement
	ldr	x3, [x27, ending_r, SXTW 3] 							//Load/pass in ending(suffix) into third print argument
	ldr	x4, [x28, season_r, SXTW 3] 							//Load/pass in season into fourth print argument	
	bl	printf										//Branch link to printf function
	b	exit_main									//Branch to exit_main

range_limit:
	adrp	x0, invalidRange								//Set invalidRange string into x0
	add	x0, x0, :lo12:invalidRange							//Format lower 12 order bits
	bl	printf										//Branch and link to printf function	
	b	exit_main									//Branch to exit_main

exit_main:
	mov	w0, 0										//Return w0 value
    	ldp    x29, x30, [sp], 16								//Deallocate 16 bytes of memory and load pairs x29, x30
    	ret											//Return to caller
