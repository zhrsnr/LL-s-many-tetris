# \file		is_conflict.s
# \author	lemacs<ganxiangle@gmail.com>
# \date	2010.12.12	16:34
# \brief	function is_conflict check is temp_block at temp_pos is conflict with cell_table now.(using temp_block instead of current_block to simplify operations)
		
# \fn 		is_conflict
# \input	(extern) temp_block, Tetris_Table, temp_pos
# \brief	see file head.				
# \return	1 if TRUE, 0 if FALSE
# \note		block's cell's x < N_ROW(but can below 0, because -1 mean not down in table, not conflict), and 0 <= y < N_COL
.include "some_macros.s"		
/////////  data section /////////	
.section .data
current_pos_r:
	.byte	0
current_pos_c:
	.byte	0
temp_pos_r:
	.byte	0
temp_pos_c:
	.byte	0
////////   text section ////////	
.section .text
		.global is_conflict
		.type is_conflict, @function

is_conflict:
		push	%ebp
		movl	%esp, %ebp
		pushl	%ebx
		pushl	%esi
		pushl	%edi
		////  init or reset data(not global)
		movb	$0, current_pos_r
		movb	$0, current_pos_c
		movb	$0, temp_pos_r
		movb	$0, temp_pos_c
		//// get temp_block's type and length
		movl	$temp_block, %esi
		movl	$0, %edi
		movw	(%esi, %edi, 1), %ax
		
		//// if temp_block's length is 0, return FALSE
		cmpb	$0, %ah
		jz	temp_block_length_is_0

		////	store length in ecx
		shrw	$8, %ax
		andl	$0x000000ff, %eax
		movl	%eax, %ecx

		////	start check
		movl	$Tetris_Table, %esi

		movl	$1, %edi
		////	use ecx to hold length(count)
		////	use esi,ebp to hold base addr
		////	use edi to hold index(from 1 to n)
		movl	temp_pos, %ebx
		movb	%bh, current_pos_r
		movb	%bl, current_pos_c
check_conflict:
		movl	$temp_block, %ebx
		
		cmpl	$0, %ecx
		jz	check_all_but_not_conflict
		movw	(%ebx, %edi, 2), %ax
		movb	%ah, temp_pos_r
		movb	%al, temp_pos_c
		////	now just eax,ebx,edx available
		movb	current_pos_r, %ah
		movb	current_pos_c, %al
		addb	temp_pos_r, %ah
		addb	temp_pos_c, %al
		//// now %ah store y, %al store x
		xor		%ebx, %ebx
		xor		%edx, %edx
		movb	%al, %dl
		movb	%ah, %bl

		//// must  x < N_ROW, 0 <= y < N_COL
		cmpb	$0, %bl
		jl	check_conflict_next
		cmpb	$(N_ROW - 1), %bl
		jg	conflict_true
		cmpb	$0, %dl
		jl	conflict_true
		cmpb	$(N_COL - 1), %dl
		jg	conflict_true
		
		/// bl contains y
		/// dl contains x
		/// save register before function call
		pushl	%eax
		pushl	%ecx
		pushl	%edx
				
		pushl	%edx
		pushl	%ebx
		call	get_offset_on_table_at
		addl	$8, %esp
		/// now %eax contains Table offset at a cell
		addl	$Tetris_Table, %eax
		movl	(%eax), %eax
		////	now eax contains the coresponding cell
		andl	$0x10000, %eax
		jnz		conflict_true
		
		popl	%edx
		popl	%ecx
		popl	%eax
		


		
check_conflict_next:	
		decl	%ecx
		incl	%edi
		jmp	check_conflict
	
		
conflict_true:
		movl	$1, %eax
		jmp	is_conflict_return
conflict_false:
		movl	$0, %eax
		jmp	is_conflict_return
check_all_but_not_conflict:
		movl	$0, %eax
		jmp	is_conflict_return
	
temp_block_length_is_0:
		movl	$0, %eax
		jmp	is_conflict_return
		
is_conflict_return:		
		popl	%edi
		popl	%esi
		popl	%ebx
		movl	%ebp, %esp
		popl	%ebp
		ret
	