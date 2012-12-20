# \file    global_structs.s
# \author  lemacs <ganxiangle@gmail.com>
# \date    2010.12.11  21:23
# \brief   Some internal structs used to implement Tetris
#
#
#      	       	  CELL(4 bytes)
#   +---------------+--------+---------+
#   |               | ocupy  | color   |
#   |               |        |         |     <----------------from high to low bytes---|
#   +---------------+--------+---------+
#
#		CELL TABLE
#	........................
#
#
#
#	|-----------------------from low to high bytes---------->
#
#	       	       	  Block(8 words, 7 cells)
#   +------+-------+------+-------+-------+-------+-------+-------+
#   | type | length|1)col |1)row  |2)col  |2)row  |3)col  |3)row  |
#   +------+-------+------+-------+-------+-------+-------+-------+
#   |4)col |4)row  |5)col |5)row  |6)col  |6)row  |7)col  |7)row  |
#   +------+-------+------+-------+-------+-------+-------+-------+
#
#
#
#	  Current Block/Temp Block(16+8 bytes){ Block, cell'colors }
#   +--------------+-----------------------------------------------+
#   |  	           |	    		        	                   |
#   +--------------+-----------------------------------------------+
#   |                            	   			       	           |
#   +-------+------+------+-------+-------+-------+-------+--------+
#   | length| (1)  |  (2) |  (3)  |  (4)  |  (5)  |  (6)  |  (7)   |
#   +-------+------+------+-------+-------+-------+-------+--------+
#
#
#    	  Current Pos/Temp Pos(4 bytes)
#	+--------------+--------+-------+
#   |              | ROW    |  COL  |  <----------|
#	+--------------+--------+-------+
#
#	  Block Table(16*n bytes)
#      +-------------------------------+
#      |            BLOCK              |
#      +-------------------------------+
#      |            BLOCK              |
#      +-------------------------------+
#      |            BLOCK              |
#      +-------------------------------+
#      |            BLOCK              |
#      +-------------------------------+
#
#

.include "some_macros.s"		
				
######## define cell
.macro Terminal_Tetris_Cell  cell_ocupy, cell_color
	.int  0xff00 & (\cell_color << 8) | (0x00ff & \cell_ocupy)
.endm

######## define cell table (n_row)*(n_col)


.global Tetris_Table

	.type	Tetris_Table, @object
	.size	Tetris_Table, (N_ROW * N_COL * 4)
		
.global Block_Table
	.type	Block_Table, @object
	.size	Block_Table, (24 * 9)
		
.global current_block
	.type	current_block, @object
	.size	current_block, 0x18
	
.global temp_block
	.type	temp_block, @object
	.size	temp_block, 0x18
	
.global current_pos
	.type	current_pos, @object
	.size	current_pos, 4
	
.global temp_pos
	.type	temp_pos, @object
	.size	temp_pos, 4

		.section .data
		.align	4
Tetris_Table:
.rep (N_ROW) * (N_COL)
	Terminal_Tetris_Cell  0x0, 0x0
.endr

######## define Block
.macro Block 	type, length, cell_1, cell_2, cell_3, cell_4, cell_5, cell_6, cell_7
	.short	(\type & 0x00ff) | ( (\length << 8) & 0xff00 )
	.short	\cell_1
	.short	\cell_2
	.short	\cell_3
	.short	\cell_4
	.short	\cell_5
	.short	\cell_6
	.short	\cell_7
.endm
######## Block_Table
		.align	16
Block_Table:
		Block	1, 1, 0x0000, 0, 0, 0, 0, 0, 0  /* Pos(0,0) */
		Block	2, 2, 0x0000, 0x0001, 0, 0, 0, 0, 0 /* Pos(0,0), Pos(0,1) */
		Block	3, 3, 0x0000, 0x0001, 0x0002, 0, 0, 0, 0 /* Pos(0,0), Pos(0,1), Pos(0,2) */
		Block	4, 3, 0x0000, 0x0001, 0x0100, 0, 0, 0, 0 /* Pos(0,0), Pos(0,1), pos(1,0) */
		Block	5, 4, 0x0000, 0x0001, 0x0002, 0x0003, 0, 0, 0 /* Pos(0,0), Pos(0,1), Pos(0,2), Pos(0,3) */
		Block	6, 4, 0x0000, 0x0001, 0x0002, 0x0102, 0, 0, 0 /* Pos(0,0), Pos(0,1), Pos(0,2), Pos(1,2) */
		Block	7, 4, 0x0000, 0x0001, 0x0002, 0x0100, 0, 0, 0 /* Pos(0,0), Pos(0,1), Pos(0,2), Pos(1,0) */
		Block	8, 4, 0x0000, 0x0001, 0x0002, 0x0101, 0, 0, 0 /* Pos(0,0), Pos(0,1), Pos(0,2), Pos(1,1) */
		Block	9, 4, 0x0000, 0x0001, 0x0100, 0x0101, 0, 0, 0 /* Pos(0,0), Pos(0,1), Pos(1,0), Pos(1,1) */

######## current Block
		.align	16
current_block:
	Block	0,0,0,0,0,0,0,0,0
.rep 8
	.byte	0
.endr
######## temp Block
		.align	16
temp_block:
	Block	0,0,0,0,0,0,0,0,0
.rep 8
	.byte	0
.endr
######## current Pos
		.align	4
current_pos:
	.int 0
######## temp_pos
		.align	4
temp_pos:
	.int 0

