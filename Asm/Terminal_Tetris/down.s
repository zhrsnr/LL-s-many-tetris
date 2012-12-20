# \file		donw.s
# \author	lemacs<ganxiangle@gmail.com>
# \date		2010.12.13
# \brief	function down 


# \fn		down
# \param	NULL
# \func		check if current block can go down one step, if ok, update current pos, if not, do nothing.
# \return	TRUE if ok, FALSE if conflict

	
.section .text
	.global down
	.type down, @function
down:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi
	//// copy current_pos to temp_pos, add 1 to x(row index)
	movl	current_pos, %eax
	//// when use "subl	$0x00000100, %eax", just the block up one position, instead of down
	addl	$0x00000100, %eax
	movl	%eax, temp_pos
	//// copy current_block to temp_block
	call	copy_current_block_to_temp_block

	//// check if conflict
	call	is_conflict
	cmpl	$1, %eax
	je	down_false
	//// if can down, update current pos
	movl	temp_pos, %eax
	movl	%eax, current_pos

down_true:
	movl	$1, %eax
	jmp	down_return
down_false:
	movl	$0, %eax
	jmp	down_return
		
down_return:	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
