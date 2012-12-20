#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <curses.h>

#define SEC_DELAY 1
#define N_ROW 16
#define N_COL 16
#define ACTION_LEFT  1
#define ACTION_RIGHT 2
#define ACTION_DOWN  3
extern int temp_pos;
extern int current_pos;
extern int Tetris_Table[];
#define CELL_COLOR_BLACK	 0
#define CELL_COLOR_RED       1
#define CELL_COLOR_GREEN	 2
#define CELL_COLOR_YELLOW	 3
#define CELL_COLOR_BLUE	     4
#define CELL_COLOR_MAGENTA	 5
#define CELL_COLOR_CYAN	     6
#define CELL_COLOR_WHITE	 7

void put_a_block_on_table();
void clear_a_block_on_table();
int put_a_block(int block_type, int a, int b, int c, int d, int e, int f, int g);
int rotate();
int down();
int move_to_left_or_right(int action);
int delete_complete_lines();

void print_table();
static void signal_callback_alarm(int signo);
 int action = ACTION_DOWN;
int main(int argc, char ** argv)
{
	if(signal(SIGALRM, signal_callback_alarm) == SIG_ERR){
		return -1;
	}
	int i = 0;
	int j;
	int flag;
	put_a_block(4, 1, 2, 3, 4, 5, 6, 7);
	put_a_block_on_table();

	int key;
		alarm(SEC_DELAY);
		pause();
		while(1){
			pause();
		}

	return 0;
}
void print_table()
{
	int i;
	for(i = 0; i <0x7f; i++) printf("_");
	printf("\n");

	for(i = 0; i < N_ROW * N_COL; i++){
		printf("%x\t", Tetris_Table[i]);
		if((i+1) % N_COL == 0)printf("\n");
	}
	
	for(i = 0; i <0x7f; i++) printf("_");
	printf("\n");
	fflush(stdout);
}
static void signal_callback_alarm(int signo)
{

	static int flag = 1;
	static int down_flag = 1;
	if(down_flag)clear_a_block_on_table();
	else{
		flag = put_a_block(4,2,3,4,1,1,1,1);
		if(flag == 0) {
			printf("\n game over!\n");
			exit(-1);
		}
		down_flag = 1;
	}	
	if(action == ACTION_LEFT || action == ACTION_RIGHT)	{
		flag = move_to_left_or_right(action);
	}else if(action == ACTION_DOWN) {
		down_flag = down();
	}
	put_a_block_on_table();
	print_table();	

	alarm(SEC_DELAY);
	
}
