# \file		put_a_block.s
# \author	lemacs<ganxiangle@gmail.com>
# \date		2010.12.12  23:01
# \brief	implement put_a_block function 


# \fn		put_a_block
# \param	block_type(4 bytes)	
# \param	colors 1--7(4*7 bytes)
# \func		choose a block from block table acording to input block_type, copy to temp block, set temp pos to (1,1), check it, if not conflict, put this block at
#			pos (1,1), that is, update current_block and current pos, while conflict, just return FALSE, don't update current_block and current pos.
# \return 	1(TRUE) if ok, 0(FALSE) if conflict		
# 		
#


# \fn		choose_a_block_from_block_table_to_temp_block
# \param	block_type
# \func		just as the name
# \return 	NULL
# 		
.section .text
	.global	put_a_block
	.type put_a_block, @function
	
	.global choose_a_block_from_block_table_to_temp_block
	.type choose_a_block_from_block_table_to_temp_block, @function
	
	.global copy_temp_block_to_current_block
	.type copy_temp_block_to_current_block, @function
	
	.global copy_current_block_to_temp_block
	.type copy_current_block_to_temp_block, @function
	
put_a_block:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi

	//// copy block to temp_block
	pushl	8(%ebp)
	call	choose_a_block_from_block_table_to_temp_block
	addl	$4, %esp
	//// set colors
	movl	$7, %ecx
	movl	$3, %edi
	lea	(%ebp, %edi, 4), %esi
	movl	$temp_block, %edi
	movw	(%edi), %ax
	addl	$0x10, %edi
	//// set length
	movb	%ah, (%edi)
	addl	$1, %edi
	cld
copy_color_loop:
	movl	(%esi), %eax
	stosb
	addl	$4, %esi
	loop	copy_color_loop

		
	//// set temp_pos to (1,1)
	movl	$0x0101, temp_pos
	//// check if conflict
	call	is_conflict
	cmpl	$1, %eax
	je	you_can_not_put_a_block_because_of_conflict
		
	//// if success update current_block, current_pos
	movl	temp_pos, %eax
	movl	%eax, current_pos
	call	copy_temp_block_to_current_block
	jmp	success_to_put_a_block
	

success_to_put_a_block:
	movl	$1, %eax
	jmp	put_a_block_return
you_can_not_put_a_block_because_of_conflict:
	movl	$0, %eax
	jmp	put_a_block_return
put_a_block_return:	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret

	
choose_a_block_from_block_table_to_temp_block:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi

	movl	$0, %edi
	movl	$Block_Table, %esi
	xorl	%eax, %eax
	movl	8(%ebp), %eax
	decb	%al
	movb	$16, %bl
	mul	%bl
	addl	%eax, %esi
	//// now eax contains byte index of Block_Table (at request block_type)

	//// copy start...
	movl	$temp_block, %edi
	movl	$16, %ecx
	rep movsb
	

	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
	
copy_temp_block_to_current_block:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi
	
	movl	$current_block, %edi
	movl	$temp_block, %esi
	movl	$0x18, %ecx
	cld
	rep movsb
	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret


copy_current_block_to_temp_block:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi
	
	movl	$current_block, %esi
	movl	$temp_block, %edi
	movl	$0x18, %ecx
	cld
	rep movsb
	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
