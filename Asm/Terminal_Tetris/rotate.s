# \file		rotate.s
# \author	lemacs<ganxiangle@gmail.com>
# \date		2010.12.13  10:35
# \brief	funcion:rotate
#

# \fn		rotate
# \IN		global vars
# \func		rotate(or say, update) current_block if you can roate	
# \OUT		TRUE if can rotate, FALSE if not



.section .text
	.global rotate
	.type rotate, @function
rotate:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi

	call	copy_current_block_to_temp_block
	//// rotate temp_block (instead of current_block)
	//// clockwise rotate (cosA, sinA)--> (sinA, -consA), or (x, y)--> (y, -x)
	movl	$temp_block, %esi
	movw	(%esi), %ax
	movb	%ah, %bl
	movzx	%bl, %ebx
	movl	%ebx, %ecx
	addl	$2, %esi
rotate_coordinate:
	movw	(%esi), %bx
	movb	$0, %al
	subb	%bh, %al
	movb	%bl, %ah
	movw	%ax, (%esi)
	addl	$2, %esi
	loop	rotate_coordinate

	call	is_conflict
	cmpl	$1, %eax
	je	can_not_rotate
	//// if can rotate, update current block
	call	copy_temp_block_to_current_block
	jmp	can_rotate
	
can_rotate:
	movl	$1, %eax
	jmp	rotate_return
can_not_rotate:
	movl	$0, %eax
	jmp	rotate_return
rotate_return:	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret



	