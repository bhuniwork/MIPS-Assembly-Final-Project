#Jerry Lam, Brandon Ho, Christopher Tjahja, Duve Rodriguez-Garcia
#pseudorandom randomizer for picking what word is chosen
.include "commonMacros.asm"
.include "wordList.asm"

.data
gameStart: .asciiz "Welcome to Wordle! You will have 6 tries to guess the correct word.\n"
guessBuffer: .space 16 #enough for 16 bytes - 5 letters, newline, null terminator, and 9 extra
guessPrompt: .asciiz "\nPlease enter a 5-letter guess: "
invalidMsg: .asciiz "\nInvalid input. Please enter exactly 5 letters (A-Z)."
playAgain: .asciiz " Restart? \n(1)Yes \n(0)No"
youWin: .asciiz "Congratulations! The word is: "
youLose: .asciiz "You failed! The word was: "
wrongLetter: .asciiz " is not in the word!"
correctPlace: .asciiz " is in the correct place!"
wrongPlace: .asciiz " is in the wrong place!"
triesRemaining: .asciiz "Tries remaining: "
tries: .word 6

.text
main:
	printString(gameStart)
	jal getRandomWord
	jal getGuess
	
	li $t8, 6
	jal evaluateGuess
	
	#print guessBuffer for testing purposes - REMOVE IN SUBMISSION
	li $v0, 4
	la $a0, guessBuffer
	syscall
	exit

getRandomWord:
	li $v0, 30	#get system time and set $t0 to the value
	syscall
	move $t0, $a0
	
	li $t1, 60	#60 words, so the index should be time % 60
	divu $t0, $t1	#HI register is set to the remainder (0-59)
	mfhi $t2	#t2 = (0-59) random
	
	#load pointer to random word using value in $t2
	sll $t3, $t2, 2		#multiply $t2 by 4 and store in $t3 since each word is stored as 4 bytes - $t3 = offset from index 0
	
	la $s0, wordList
	addu $s0, $s0, $t3	#set $s0 pointer to 0 + offset in $t3
	lw $s1, 0($s0)		#chosen word is saved in $s1
	
	#print the chosen word for testing - REMOVE FOLLOWING LINES IN SUBMISSION
	move $a0, $s1
	li $v0, 4
	syscall
	
	jr $ra

#getGuess - reads user guess into guessBuffer
#ensures that length = 5, no characters/numbers, converts lowercase into uppercase
getGuess:
	printString(guessPrompt)	#print the prompt
	#read into buffer
	readString(guessBuffer, 16) #16 chars maximum
	
	la $s2, guessBuffer	#load address of guessBuffer into $s2
	li $t4, 0	#length counter

stripLoop:	#loop to strip new line character to ensure proper input
	lb $t5, 0($s2)	#load current char from input buffer
	beqz $t5, endStripLoop	#null terminator ASCII = 0, so end loop when $t5 = 0
	
	#check for newline
	li $t6, 10 #ASCII for \n = 10
	beq $t5, $t6, stripNewLine
	
	addi $t4, $t4, 1	#advance counter and pointer
	addi $s2, $s2, 1
	j stripLoop

stripNewLine:
	sb $zero, 0($s2)	#once at the location of \n, change value to 0
	j endStripLoop
	
endStripLoop:
	li $t6, 5
	bne $t4, $t6, invalidInput	#if the counter does not equal 5, invalid input
	
	la $s2, guessBuffer		#reset guessBuffer pointer to default

validateLoop:	#validate input for no chars/nums, convert lowercase to uppercase
	lb $t5, 0($s2)	#load current char from input buffer
	beqz $t5, validInput	#if reach end of input w/o issues, then it is valid
	
	#check lowercase - if not, then check that the char is an uppercase letter
	li $t6, 'a'
	blt $t5, $t6, checkUppercase
	
	li $t7, 'z'
	bgt $t5, $t7, checkUppercase
	
	addi $t5, $t5, -32	#to change characters from lowercase to uppercase, ASCII of uppercase is 32 less than lowercase
	sb $t5, 0($s2)
	j nextChar
	
checkUppercase:
	#check for uppercase A-Z, same process
	#if not uppercase A-Z, then invalid input
	li $t6, 'A'
	blt $t5, $t6, invalidInput
	
	li $t7, 'Z'
	bgt $t5, $t7, invalidInput

nextChar:
	addi $s2, $s2, 1
	j validateLoop

validInput:	
	jr $ra

invalidInput:
	printString(invalidMsg)
	j getGuess
	
evaluateGuess:
    la $t0, guessBuffer   
    move $t1, $s1         

    li $t2, 0             
    li $t3, 1             

evalLetterLoop:
    beq $t2, 5, evalDone  

    addu $t4, $t0, $t2
    lb $t5, 0($t4)       

    addu $t6, $t1, $t2
    lb $t7, 0($t6)       

    beq $t5, $t7, correctPlaceLabel
    li $s3, 0           

searchLoop:
    beq $s3, 5, notFoundInAnswer
    addu $t9, $t1, $s3
    lb $s4, 0($t9)
    beq $t5, $s4, wrongPlaceLabel
    addi $s3, $s3, 1
    j searchLoop

notFoundInAnswer:
    move $a0, $t5
    li $v0, 11
    syscall
    printString(wrongLetter)
    li $t3, 0           
    j nextEvalLetter

wrongPlaceLabel:
    move $a0, $t5
    li $v0, 11
    syscall
    printString(wrongPlace)
    li $t3, 0
    j nextEvalLetter

correctPlaceLabel:
    move $a0, $t5
    li $v0, 11
    syscall
    printString(correctPlace)
    j nextEvalLetter

nextEvalLetter:
    addi $t2, $t2, 1
    j evalLetterLoop

evalDone:
    move $v0, $t3   
    jr $ra

lose:
	#Print youLose string and the random word
	printString(youLose)
	li $v0, 4
	move $a0, $s1
	syscall
	
	#prompt user to play again
	j restart

win:
	#Print youWin string and the random word
	printString(youWin)
	li $v0, 4
	move $a0, $s1
	syscall
	
	#prompt user to play again
	j restart

restart:
	#ask user to play again or exit
	printString(playAgain)
	getInt
	move $t9, $v0
	
	beq $t9, 1, main
	beq $t9, 0, exit
	
exit:
	exit
	

	
	
