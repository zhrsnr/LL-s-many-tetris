# \file		delete_complete_lines.s
# \author	lemacs<ganxiangle@gmail.com>
# \date		2010.12.13  20:05
# \brief	function delete_complete_lines
#

# \fn	delete_complete_lines
# \param	NULL(extern Tetris_Table)
# \func		check if there are some completed lines, if one, delete it.(invoke delete_a_line_at and find_a_complete_line)
# \return	how many lines have been delete, 0 if no
	
# \fn	delete_a_line_at
# \param	line_index
# \func		delete a line at line_index
# \return	NULL
	
# \fn	find_a_complete_line
# \param	NULL
# \func		find a complete line from downside up, until one find or until reaching top.
# \return	-1 if not find a one, line_index of complete one if find one.
.include "some_macros.s"	
.section .text
	.global delete_complete_lines
	.type delete_complete_lines, @function
	.type delete_a_line_at, @function
	.type find_a_complete_line, @function
delete_complete_lines:	
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi

	movl	$0, %ecx
loop_find_a_line_to_delete:
	pushl	%ecx
	call	find_a_complete_line
	popl	%ecx
	cmpl	$0, %eax
	//// if there is no complete lines
	jl		delete_complete_lines_return
	//// if there is a complete line still
	pushl	%ecx
	push	%eax
	call	delete_a_line_at
	addl	$4, %esp
	popl	%ecx
	inc		%ecx
	jmp	loop_find_a_line_to_delete

delete_complete_lines_return:
	movl	%ecx, %eax	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret


	
delete_a_line_at:
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi

	movl	8(%ebp), %eax
	cmpl	$0, %eax
	jz		delete_first_line
		
	movl	%eax, %edx
	//// save %edx before function call
	pushl	%edx
		
	pushl	$0
	pushl	%edx
	call	get_offset_on_table_at
	addl	$8, %esp
	popl	%edx
	movl	%eax, %edi
	addl	$Tetris_Table, %edi

	subl	$1, %edx
	pushl	$0
	pushl	%edx
	call	get_offset_on_table_at
	addl	$8, %esp
	movl	%eax, %esi
	addl	$Tetris_Table, %esi
		
	movl	8(%ebp), %ecx
	addl	$1, %ecx
	
	cld
loop_copy_line_to_line:
	pushl	%edi
	pushl	%esi
	pushl	%ecx
		
	movl	$N_COL, %ecx
	rep	movsl
		
	popl	%ecx
	popl	%esi
	popl	%edi

	movb	$N_COL, %bl
	movl	$4, %eax
	mulb	%bl
	
	subl	%eax, %esi
	subl	%eax, %edi
	loop	loop_copy_line_to_line
delete_first_line:		
	//// now delete the first line
	movl	$0x0, %eax
	movl	$N_COL, %ecx
	movl	$Tetris_Table, %edi
	rep stosl
	jmp	delete_a_line_at_return
	
delete_a_line_at_return:	
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret



	
find_a_complete_line:	
	push	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi

	xorl	%ecx, %ecx
	movb	$N_ROW, %cl

	//// %edi counts the ocupy cells of a line.
	movl	$0, %edi
loop_row:
	movl	%ecx, %ebx
	subl	$1, %ebx
	//// save %ecx before call another function
	pushl	%ecx
	pushl	$0
	pushl	%ebx
	call	get_offset_on_table_at
	addl	$8, %esp
	popl	%ecx
		
	movl	%eax, %esi
	addl	$Tetris_Table, %esi
	movl	$N_COL, %ebx
loop_col:
	cmpl	$0, %ebx
	jz	loop_row_next
	movl	(%esi), %edx
	andl	$0x00010000, %edx
	cmp		$0, %edx
	//// find one not ocupy , move to next row
	je		loop_row_next
	//// find one cell ocupy, increace count by 1.
	inc		%edi
	cmp		$N_COL, %edi
	je		found
		
	dec		%ebx
	addl	$4, %esi
	jmp		loop_col


	
loop_row_next:

		
	xor		%edi, %edi
	loop	loop_row	
	jmp		not_a_line_complete
		
found:
	movl	%ecx, %eax
	dec		%eax
	jmp		find_a_complete_line_return
	
not_a_line_complete:
	movl	$-1, %eax
	jmp	find_a_complete_line_return
find_a_complete_line_return:
	popl	%edi
	popl	%esi
	popl	%ebx
	movl	%ebp, %esp
	popl	%ebp
	ret
	 