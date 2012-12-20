
AS:= as
CC:= gcc
LD:= ld
all: main.exe
dump_main.exe.txt: main.exe
	objdump -D $< > $@
main.exe: global_structs.o put_a_block.o put_a_block_on_table.o is_conflict.o rotate.o down.o move_to_left_or_right.o delete_complete_lines.o clear_a_block_on_table.o Tetris.o -lcurses
	$(CC) $^ -o $@ -lcurses
global_structs.o: global_structs.s some_macros.s
	$(AS) -gstabs -o $@ $<
is_conflict.o: is_conflict.s some_macros.s
	$(AS) -gstabs -o $@ $<
put_a_block.o: put_a_block.s
	$(AS) -gstabs -o $@ $<
put_a_block_on_table.o: put_a_block_on_table.s some_macros.s
	$(AS) -gstabs -o $@ $<
delete_complete_lines.o: delete_complete_lines.s some_macros.s
	$(AS) -gstabs -o $@ $<
rotate.o: rotate.s
	$(AS) -gstabs -o $@ $<
down.o: down.s
	$(AS) -gstabs -o $@ $<
main.o: main.c
	$(CC) -gstabs -c -o $@ $<
move_to_left_or_right.o: move_to_left_or_right.s
	$(AS) -gstabs -o $@ $<
clear_a_block_on_table.o: clear_a_block_on_table.s some_macros.s
	$(AS) -gstabs -o $@ $<
Tetris.o: Tetris.c
	$(CC) -gstabs -c -o $@ $<