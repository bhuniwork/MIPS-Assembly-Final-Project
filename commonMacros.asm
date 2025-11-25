#common macros
.macro printString(%string)
	li $v0, 4
	la $a0, %string
	syscall
.end_macro

.macro printInt(%reg)
	li $v0, 1
	move $a0, %reg
	syscall
.end_macro

.macro getInt
	li $v0, 5
	syscall
.end_macro

.macro getString
	li $v0, 8
	syscall
.end_macro

.macro readString(%buffer, %length)
	li $v0, 8
	la $a0, %buffer
	li $a1, %length
	syscall
.end_macro

.macro exit
	li $v0, 10
	syscall
.end_macro
