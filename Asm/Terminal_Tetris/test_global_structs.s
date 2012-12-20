# \file 	test_global_structs.s
# \author 	lemacs<ganxiangle@gmail.com>
# \date   	2010.12.12  00:34
# \brief  	just test the global_structs.s functionality.

.section .data
length:
	.int 0
.section .text
	.global _start
_start:
	movl  $Tetris_Table, %esi
	movl  $0, %edi
	movl  $136, %ecx
loop_1:	//cmpb  $0x32,(%esi, %edi, 1)
	//je   end
	movl  $4, %eax
	movl  $1, %ebx
	pushl %ecx
	movl  %esi, %ecx
	movl  $1, %edx
	int   $0x80
	popl  %ecx
	inc   %esi
	//jmp   loop
	loop loop_1
	
end:	
	movl  $1, %eax
	movl  $0, %ebx
	int  $0x80

	