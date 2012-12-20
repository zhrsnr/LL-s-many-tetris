# \file  put_a_block_on_table.s  
# \author  lemacs<ganxiangle@gmail.com
# \date  2010.12.14
# \brief  global funtion put_a_block_on_table

# \fn	put_a_block_on_table
# \param  	extern current_block, Tetris_Table, current_pos
# \func  	put the current_block at current_pos to Tetris_Table(ignore the conflict)
# \return 	 NULL
# \note		assumes that the current block's cell's y and all greater or equal to 0 , lower or equal to N_ROW/N_COL.
#			but x can bellow 0, it just don't put that cell on table.			
		
# \fn	get_offset_on_table_at
# \param  row,col
# \return  byte offset at(row, col) of Tetris_Table 
#

.include "some_macros.s"		
.section .text
	.global put_a_block_on_table
	.type put_a_block_on_table, @function
	.global get_offset_on_table_at
	.type get_offset_on_table_at, @function
put_a_block_on_table:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi

	movl	current_pos, %eax
	movl	$current_block, %ebx
	movl	%ebx, %esi
	addl	$0x11, %esi
	
	xorl	%ecx, %ecx
	addl	$1, %ebx
	movb	(%ebx), %cl
	addl	$1, %ebx
	//// now %ecx contains current block's length, or say, total cell num
loop_put_a_cell:	
	movw	(%ebx), %dx
	addb	%ah, %dh
	addb	%al, %dl
	//// now %dh is x, %dl is y
	cmpb	$0, %dh
	jl	loop_put_a_cell_next
		
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
	movl	$0x00010000, (%eax)
	addl	$3, %eax
	movb	(%esi), %cl
	movb	%cl, (%eax)

	popl	%edx
	popl	%ecx	
	popl	%eax
loop_put_a_cell_next:	
	addl	$2, %ebx
	incl	%esi
	loop	loop_put_a_cell


put_a_block_on_table_return:
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret


get_offset_on_table_at:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi

	movl	8(%ebp), %esi
	movl	12(%ebp), %edi
	movl	%esi, %edx
	movl	%edi, %ebx

	xor		%eax, %eax
	movb	%dl, %al
	movb	$N_COL, %ch
	mulb	%ch
	//// now %ax=row * N_COL
	addw	%bx, %ax
	//// now %ax = row * N_COL + col
	xor		%edx, %edx
	movw	$4, %cx
	mulw	%cx
	//// now %dx:ax=(row * N_COL + col)* 4
	or		%edx, %eax
	//// now %eax = (row * N_COL + col)* 4
	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
