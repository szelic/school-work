.data
#layout
separation: .asciiz	" | "
line: .asciiz		" ------------- "
newline: .asciiz 	"\n"
doubleline: .asciiz 	"\n\n"

#general
welcomeMsg: .asciiz     "Welcome to Team No One's Casino!!!"
printBank:  .asciiz     "\nCURRENT BANK: "
mainMenuMsg: .asciiz	"\nEnter 1 for Blackjack, 2 for Slot Machines, 0 to exit.\n"
playerEnd: .asciiz      "\nGame over. You have run out of money.\n"

#slots
playerChoice: .asciiz   "\nSelect the number of slot plays you would like by choosing a number from 1 to 10.\n\n"
continuePlay: .asciiz   "\nEnter 1 to continue playing or 0 to exit.\n"
askforBet:  .asciiz     "\nPlease enter an integer value for your bet\n"

#blackjack
playerBusted: .asciiz 	"\nYou busted, better luck next time\n"
dealerBusted: .asciiz 	"\nDealer busts you win!\n"
playersHand: .asciiz 	"\nYour hand is: "
dealersHand: .asciiz 	"Dealer's hand is: "
blackjackWelcome: .asciiz "Welcome to the Blackjack table.\n"
playerWin: .asciiz 	"\nYou had the better hand, well done!\n"
dealerWin: .asciiz 	"\nSorry, beat you this time :(\n"
hit:	.asciiz 	"\nEnter 1 to hit or 0 to compare hands.\n"

#errors
wrongBet: .asciiz	"\n**Bet exceeds funds or less than 0. Please re-enter a new bet.**"
wrongInput: .asciiz 	"\n**Incorrect input. Please try again.**\n"

.text
initialize:	#**Initialize bank and bet**
		li $s1, 25			# initialize $s1 as bank, set at 25
		li $s2, 0			# initialize $s2 as bet, set at 0

welcome:	#**Prints welcome message to console**
		li $v0, 4			# print welcome message
		la $a0, welcomeMsg		
		syscall
		
begin_bank:	#**Display starting bank amount**
		li $v0, 4			# print string for bank balance		
		la $a0, printBank		
		syscall
		
		li $v0, 1			# print out bank balance
		move $a0, $s1			
		syscall
		
		li $v0, 4			# print newline
		la $a0, newline			
		syscall
		
main_menu:	#**Main menu to choose slots or blackjack**
		li $v0, 4			# prints main menu message
		la $a0, mainMenuMsg		
		syscall
		
		li $v0, 5                       # get player's choice for which game
                syscall
                move $t8, $v0                   # store the result
                
                beq $t8, 1, blackJackGame	# 1 for blackjack
                beq $t8, 2, slot_bet		# 2 for slots
                beq $t8, 0, exit		# 0 to exit
                b main_menu			# otherwise keep asking for input

				#~**************************~
				#~** SLOT MACHINE SECTION **~
				#~**************************~
			
slot_bet: 	#**Ask player for bet amount
		li $v0, 4			# print message asking player for bet		
		la $a0, askforBet		
		syscall

		li $v0, 5			# get player's integer -> the bet amount
		syscall						
		move $s2, $v0			# store the result
		
		bgt $s2, $s1, bet_error		# branch to error if bet > bank
		bltz $s2, bet_error		# branch to error if bet < 0

slot_spin:	#**Asks for the number of spins**
		li $v0, 4			# print message asking player how many spins they want		
		la $a0, playerChoice		
		syscall

		li $v0, 5			# get player's integer -> the number of spins
		syscall						
		move $t9, $v0			# store the result
		
		blez $t9, slot_spin		# if number is less than or equal to zero branch back to program entry to ask again
		bgt $t9, 10, slot_spin		# if number is greater than 10, branch back to program entry to ask again

slot_round:	#**Play loop, spins slots then decrement number of specified spins until less than 0**
		add $t9, $t9, -1		# decrement value in $t9 by 1
		bltz $t9, exit_round 		# exit if $t9 is less than 0
		bgez $t9, random           	# go to random when $t9 greater than or equal to 0	

#**SPIN SECTION**			
random:		#**Generate random numbers for spin**
		li $v0, 4			# print top of slot
		la $a0, line
		syscall	
		
		li $v0, 4			# print newline
		la $a0, newline
		syscall

		li $v0, 4			# print line to separate numbers
		la $a0, separation
		syscall	
		
		li $v0, 42			# 42 is the system call to generate random int with a range
		li $a1, 10			# the upper bound set to 10 (max excluded)
		syscall    			

		move $t1, $a0			# move generated number to $t1
		li $v0, 1			# print generated number
		syscall
		
		li $v0, 4			# print line to separate numbers
		la $a0, separation
		syscall			

		li $v0, 42			# 42 is the system call to generate random int with a range
		li $a1, 10			# the upper bound set to 10 (max excluded)
		syscall    

		move $t2, $a0			# move generated number to $t2
		li $v0, 1			# print generated number
		syscall		

		li $v0, 4			# print line to separate numbers
		la $a0, separation
		syscall
		
		li $v0, 42			# 42 is the system call to generate random int with a range
		li $a1, 10			# the upper bound set to 10 (max excluded)
		syscall    

		move $t3, $a0			# move generated number to $t3
		li $v0, 1			# print generated number
		syscall		

		li $v0, 4			# print line to separate numbers
		la $a0, separation
		syscall
		
		li $v0, 4			# print newline
		la $a0, newline
		syscall
		
		li $v0, 4			# print bottom of slot
		la $a0, line
		syscall

#**COMPARISON SECTION**		
compare:	#**Compare the numbers to check for matches**
		beq $t1, $t2, first_second	# first and second numbers are the same
		beq $t1, $t3, first_last	# first and last numbers are the same
		beq $t2, $t3, second_last	# second and last numbers are the same
		j no_matches			# otherwise, none of the numbers are the same

first_second:	
		beq $t1, $t3, all_the_same	# since $t1 = $t2, if $t1 = $t3 then all the same
		j two_same			# otherwise, jump to calculate winnings for 2 matches

first_last:
		beq $t1, $t2, all_the_same	# since $t1 = $t3, if $t1 = $t2 then all the same
		j two_same			# otherwise, jump to calculate winnings for 2 matches

second_last:
		beq $t1, $t2, all_the_same	# since $t2 = $t3, if $t2 = $t1 then all the same
		j two_same			# otherwise, jump to calculate winnings for 2 matches

all_the_same:
		li $t4, 7
		beq $t1, $t4, all_sevens	# since $t1 = $t2 = $t3, if $t1 = 7 then it is jackpot (all sevens)
		j three_same			# otherwise, jump to calculate winnings for 3 matches

#**WINNINGS CALCULATION SECTION**			
all_sevens:	#**Calculate bank total if player wins all sevens**
		addi $t0, $zero, 7
		mul $t1, $s2, $t0		# player wins bet multiplied by 7
		add $s1, $s1, $t1		# add bet plus winnings for new bank total
		j print_bank			# go to print_bank to display bank total 
		
three_same:	#**Calculate bank total if player wins three of same numbers excluding seven**
		addi $t0, $zero, 3
		mul $t1, $s2, $t0		# player wins bet multiplied by 3
		add $s1, $s1, $t1		# add bet plus winnings for new bank total
		j print_bank			# go to print_bank to display bank total 
		
two_same:	#**Calculate bank total if player wins matching numbers**
		addi $t0, $zero, 2
		mul $t1, $s2, $t0		# player wins bet multiplied by 2	
		add $s1, $s1, $t1		# add bet plus winnings for new bank total
		j print_bank			# go to print_bank to display bank total 
				
no_matches:	#**Calculate bank total if player receives no matches** 
		sub $s1, $s1, $s2		# player loses amount bet
		j print_bank			# go to print_bank to display bank total 


print_bank:	#**Prints bank balance**
		li $v0, 4					
		la $a0, printBank		# print string for bank balance
		syscall
		
		li $v0, 1			# print out bank balance
		move $a0, $s1
		syscall
		
		li $v0, 4			# print 2 newlines
		la $a0, doubleline
		syscall
		
		blez $s1, gameover		# check if player bankrupts, if so go to gameover
		
		j slot_round			# go back to the start of spin, and continue until all spins are done

exit_round:	#**End play loop, ask if continue, if not then go to gameover**
		li $v0, 4			# ask the player if they like to continue playing		
		la $a0, continuePlay		
		syscall
		
		li $v0, 5			# get player's integer for play continuation
		syscall						
	
		move $t5, $v0			# store the result
		beqz $t5, main_menu		# if player enters zero, then branch to the menu
		beq $t5, 1, slot_bet		# if player enters 1, jump to slot_bet label and ask for the new bet to repeat
		b exit_round			


				#~***********************~
				#~** BLACKJACK SECTION **~
				#~***********************~

blackJackGame:	#**Start of the blackjack game**

bj_bet:		#**Place bet for blackjack game**
		li $v0, 4			# print message to ask player for bet		
		la $a0, askforBet		
		syscall

		li $v0, 5			# get player's integer (i.e. the bet amount)
		syscall						
	
		move $s3, $v0			# moves player's chosen amount into bet
		
		bgt $s3, $s1, bet_error		# branch to error if bet > bank
		bltz $2, bet_error		# branch to error if bet < 0
		
bj_startHand:	#**Start blackjack hands**
		li $t0, 0			# dealer hand
		li $t7, 0			# player hand

		li $a1, 10			# generate random number
		li $v0, 42
		syscall
		add $a0, $a0, 2
	
		add $t0, $t0, $a0		# add to dealer hand
	
		li $a1, 10			# generate random number
		li $v0, 42
		syscall
		add $a0, $a0, 2
	
		add $t0, $t0, $a0		# dealer hand is now set
	
		li $a1, 10			# generate random number
		li $v0, 42
		syscall
		add $a0, $a0, 2
	
		add $t7, $t7, $a0		# add to player hand
	
		li $a1, 10			# generate random number
		li $v0, 42
		syscall
		add $a0, $a0, 2
	
		add $t7, $t7, $a0		# player hand is now set
	
		li $v0, 4
		la $a0, playersHand		# print players hand message
		syscall
	
		li $v0, 1
		move $a0, $t7			# print player hand
		syscall
		
		bge $t7, 22, bj_playerBust
		
		li $v0, 4
		la $a0, hit			# ask if the player would like to hit
		syscall
	
		li $v0, 5                       # get player's integer for deciding to hit
        	syscall

        	move $t4, $v0                   # store the result
		
		beq $t4, 1, bj_playerHit	# if player enters 1 then generate new number and add to hand
		bgt $t4, 1, input_error		# if player enters more than 1 then go to error
		blt $t4, 0, input_error		# if player enters less than 0 then go to error 
		b bj_checkHands			# otherwise check hands
		
bj_playerHit: 	#**When player hits**
		li $a1, 10			# generate random number
		li $v0, 42
		syscall
		add $a0, $a0, 2
	
		add $t7, $t7, $a0		# add to player hand

	
		li $v0, 4
		la $a0, playersHand		# print players hand message
		syscall
		
		li $v0, 1
		move $a0, $t7			# print out the current value of the player hand
		syscall
	
		bge $t7, 22, bj_playerBust	# if player hand is greater than or equal to 21 player loses
		b bj_hitOrPass
	 
bj_hitOrPass:	#**Choose to hit or pass**	
		li $v0, 4
		la $a0, hit			# ask if the player would like to hit
		syscall

		li $v0, 5                       # get player's integer for deciding to hit
        	syscall

        	move $t4, $v0                   # store the result
        	
		beq $t4, 1, bj_playerHit	# if player enters 1 then go back and generate another random number
		bgt $t4, 1, input_error		# if player enters more than 1 then go to error
		blt $t4, 0, input_error		# if player enters less than 0 then go to error 
		b bj_checkHands			# otherwise check hands
	
bj_checkHands:	#**Check who won**
		bge $t0, 22, bj_dealerBust
		bge $t0, $t7, bj_lost
		b bj_win
	
bj_win:		#**When player wins**
	        li $v0, 4
                la $a0, playerWin		# print the player win message
                syscall
	
	        li $v0, 4
                la $a0, dealersHand		# print the dealer's hand
                syscall
                
                li $v0, 1
                move $a0, $t0			# print the dealers hand number
                syscall
                
                li $v0, 4
                la $a0, playersHand		# print the player's hand
                syscall
               
                li $v0, 1
                move $a0, $t7			# print player's hand number
                syscall
                
                add $s1, $s1, $s3		# player won so add bet to the bank
                
                
		li $v0, 4					
		la $a0, printBank		# print string for bank balance
		syscall
		
		li $v0, 1			# print out bank balance
		move $a0, $s1
		syscall
        
		b bj_continue
                
bj_lost: 	#**When player loses**
		li $v0, 4
		la $a0, dealerWin
		syscall
		
	        li $v0, 4
                la $a0, dealersHand		# print the dealer's hand
                syscall
                
                li $v0, 1
                move $a0, $t0			# print the dealers hand number
                syscall
                
                li $v0, 4
                la $a0, playersHand		# print the player's hand
                syscall
               
                li $v0, 1
                move $a0, $t7			# print player's hand number
                syscall
                
                sub $s1, $s1, $s3		# player lost so subtract bet from the bank
                
                
		li $v0, 4					
		la $a0, printBank		# print string for bank balance
		syscall
		
		li $v0, 1			# print out bank balance
		move $a0, $s1
		syscall                

        	b bj_continue
        	
bj_playerBust:	#**Player busts**
        	li $v0, 4
        	la $a0, playerBusted
        	syscall
        	
                sub $s1, $s1, $s3		# player lost so subtract bet from the bank
                
                
		li $v0, 4					
		la $a0, printBank		# print string for bank balance
		syscall
		
		li $v0, 1			# print out bank balance
		move $a0, $s1
		syscall
        	
        	b bj_continue        
        	
        	
bj_dealerBust:	#**Dealer busts**
        	li $v0, 4
        	la $a0, dealerBusted
        	syscall
        	
                add $s1, $s1, $s3		# player won so add bet to the bank
                
                
		li $v0, 4					
		la $a0, printBank		# print string for bank balance
		syscall
		
		li $v0, 1			# print out bank balance
		move $a0, $s1
		syscall
        	
        	b bj_continue
        	
bj_continue:	#**Determine if player wishes to continue**
                blez $s1, gameover		# when the bank is 0 or below, game is over
      
                li $v0, 4
                la $a0, continuePlay            # ask the player if they like to continue playing
                syscall

		li $v0, 5                       # get player's integer for play continuation
        	syscall
        	move $t0, $v0                   # store the result

		beqz $t0, main_menu		# if player enters zero, then branch to the menu
		beq $t0, 1, bj_bet		# if player enters 1, jump to slot_bet label and ask for the new bet to repeat
		b bj_continue

gameover: 	#**Situation when player bankrupts**
		li $v0, 4
	  	la $a0, playerEnd		# print message when player bankrupts
		syscall						
		j exit				# branch to exit

exit:		#**Quit program**
		li $v0, 10			# quit
		syscall


					#~*******************~
					#~** ERROR SECTION **~
					#~*******************~

bet_error:	#**When player enters a bet > available bank**
		li $v0, 4
		la $a0, wrongBet		# notifies player that bet exceeds the amount of funds
		syscall
		
		beq $t8, 1, bj_bet		# user is playing blackjack, branch back to blackjack betting
		beq $t8, 2, slot_bet		# user is playing slots, branch back to slot betting

input_error:	#**When player enters an invalid option for compare hands**
		li $v0, 4
		la $a0, wrongInput		# notifies player that input is incorrect
		syscall
		j bj_hitOrPass



