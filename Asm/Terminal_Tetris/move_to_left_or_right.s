# \file		move_to_left_and_right
# \author	lemacs<ganxiangle@gmail.com>
# \date		2010.12.13
# \brief	function move_to_left_or_right 


# \fn		move_to_left_or_right
# \param	int(ACTION_LEFT or ACTION_RIGHT)
# \func		check if current block can go left/right one step, if ok, update current pos(not update current_block), if not, do nothing.
# \return	TRUE if ok, FALSE if conflict

.include "some_macros.s"	
.section .text
	.global move_to_left_or_right
	.type move_to_left_or_right, @function
move_to_left_or_right:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi

	movl	8(%ebp), %eax
	cmpl	$ACTION_LEFT, %eax
	je		move_to_left
	cmpl	$ACTION_RIGHT, %eax
	je		move_to_right
		
move_to_left:	
	movl	current_pos, %eax
	addl	$-1, %eax
	jmp		next
move_to_right:
	movl	current_pos, %eax
	addl	$1, %eax
	jmp		next
next:	
	movl	%eax, temp_pos
	//// copy current_block to temp_block
	call	copy_current_block_to_temp_block

	//// check if conflict
	call	is_conflict
	cmpl	$1, %eax
	je	move_to_left_or_right_false
	//// if can move_to_left_or_right, update current pos
	movl	temp_pos, %eax
	movl	%eax, current_pos

move_to_left_or_right_true:
	movl	$1, %eax
	jmp	move_to_left_or_right_return
move_to_left_or_right_false:
	movl	$0, %eax
	jmp	move_to_left_or_right_return
		
move_to_left_or_right_return:	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
