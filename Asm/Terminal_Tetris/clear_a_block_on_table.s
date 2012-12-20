# \file		clear_a_block_on_table.s
# \author	lemacs<ganxiangle@gmail.com
# \date		2010.12.24
# \brief	global funtion put_a_block_on_table

# \fn		clear_a_block_on_table.s
# \param  	extern current_block, Tetris_Table, current_pos
# \func  	clear the current_block at current_pos from Tetris_Table
# \return 	 NULL
# \note		
# \extern	get_offset_on_table_at
.include "some_macros.s"
.section .text
		.global	clear_a_block_on_table
		.type	clear_a_block_on_table, @function

clear_a_block_on_table:
		push	%ebp
		movl	%esp, %ebp
		pushl	%ebx
		pushl	%esi
		pushl	%edi

	movl	current_pos, %eax
	movl	$current_block, %ebx
	
	xorl	%ecx, %ecx
	addl	$1, %ebx
	movb	(%ebx), %cl
	addl	$1, %ebx
	//// now %ecx contains current block's length, or say, total cell num
loop_clear_a_cell:	
	movw	(%ebx), %dx
	addb	%ah, %dh
	addb	%al, %dl
	//// now %dh is x, %dl is y

	//// when x < 0, jump to next.
	cmpb	$0, %dh
	jl	loop_clear_a_cell_next
	cmpb	$0, %dl
	jl	loop_clear_a_cell_next
	//// %eax maintain the current_pos value, so save it before function call
	//// so does %ecx
	pushl	%eax
	pushl	%ecx
	pushl	%edx
	
	xorl	%edi, %edi
	movzx	%dl, %edi
	pushl	%edi
	movzx	%dh, %edi
	pushl	%edi
	call	get_offset_on_table_at
	addl	$8, %esp

	//// now the %eax = dest cell offset
	//// get color info, and update the cell (use the color)
	addl	$Tetris_Table, %eax
	//// set cell's ocupy-byte = 1
	movl	$0x00000000, (%eax)
		
	popl	%edx
	popl	%ecx	
	popl	%eax
loop_clear_a_cell_next:	
	addl	$2, %ebx
	loop	loop_clear_a_cell
		
clear_a_block_on_table_return:
		popl	%edi
		popl	%esi
		popl	%ebx
		movl	%ebp, %esp
		popl	%ebp
		ret
