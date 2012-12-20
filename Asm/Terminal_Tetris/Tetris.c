#include <time.h>
#include <string.h>
#include <unistd.h>
#include <curses.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <sys/time.h>
#define SEC_DELAY 1
#define N_ROW 16
#define N_COL 16
#define BLOCK_TABLE_LENGTH  9
#define ACTION_LEFT  1
#define ACTION_RIGHT 2
#define ACTION_DOWN  3
#define ACTION_ROTATE 4
extern int temp_pos;
extern int current_pos;
extern int Tetris_Table[];

#define CELL_COLOR_RED     1
#define CELL_COLOR_CYAN    2
#define CELL_COLOR_YELLOW  3
#define CELL_COLOR_BLUE	   4
#define CELL_COLOR_MAGENTA 5
/// used for cell color
#define CELL_COLOR_LENGTH  5
/// used for backgroud color
#define CELL_COLOR_GREEN   6
#define CELL_COLOR_WHITE   7
#define PAIR_SCORE 8
#define POS_START_X_OF_TABLE  5
#define POS_START_Y_OF_TABLE  5
#define CELL_GET_COLOR(cell) ( (0xff000000 & cell) >> 24 )

void put_a_block_on_table();
void clear_a_block_on_table();
int put_a_block(int block_type, int a, int b, int c, int d, int e, int f, int g);
int rotate();
int down();
int move_to_left_or_right(int action);
int delete_complete_lines();
#define SCORE_WIN_START_X 5
#define SCORE_WIN_START_Y 2
#define SCORE_WIN_LENGTH  16
char score_str_h[] = "SCORE :";

int set_timer = 1;
int score = 0;
int action = ACTION_DOWN;		/* global variable */
WINDOW * score_win;	
static void signal_callback_alarm(int signo);
static void game_over();
static int generate_a_random_num(int max);
static void update_score_win();
WINDOW * new_window_at(int row, int col)
{
	WINDOW * p_new_window = newwin(N_ROW, N_COL * 2, col, row);
	
	int i;
	int j;
	int temp_cell;
	int temp_color;
	for(i = 0; i < N_ROW; i++){
		for(j = 0; j < N_COL; j++){
			temp_cell = Tetris_Table[i * N_COL + j];
			temp_color = CELL_GET_COLOR(temp_cell);
			wattrset(p_new_window, COLOR_PAIR( temp_color == 0 ? CELL_COLOR_WHITE : temp_color));
			mvwprintw(p_new_window, i, j*2, " ");
			mvwprintw(p_new_window, i, j*2 + 1, " ");
		}
	}
	return p_new_window;
}
void move_pos(int key)
{
	switch(key){
	case KEY_LEFT:
		action = ACTION_LEFT; break;
	case KEY_RIGHT:
		action = ACTION_RIGHT; break;
	case KEY_DOWN:
		action = ACTION_DOWN; break;
	case KEY_UP: 
		action = ACTION_ROTATE; break;
	default: break;
	}
		
	
}
int main(int argc, char ** argv)
{
	int i = 0;
	int j;
	
	/// init
	initscr();
	//// noblocking
	//nodelay(stdscr, TRUE);
   	cbreak();
	noecho();
	keypad(stdscr, TRUE);
	if(! has_colors()){
		endwin();
		fprintf(stderr, "No color support!\n");
		return -1;
	}
	//// init color and color pair
	start_color();
	init_pair(CELL_COLOR_RED, COLOR_RED, COLOR_RED);
	init_pair(CELL_COLOR_CYAN, COLOR_CYAN, COLOR_CYAN);
	init_pair(CELL_COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
	init_pair(CELL_COLOR_BLUE, COLOR_BLUE, COLOR_BLUE);
	init_pair(CELL_COLOR_MAGENTA, COLOR_MAGENTA, COLOR_MAGENTA);
	init_pair(CELL_COLOR_GREEN, COLOR_GREEN, COLOR_GREEN);
	init_pair(CELL_COLOR_WHITE, COLOR_WHITE, COLOR_WHITE);
	init_pair(PAIR_SCORE, COLOR_BLUE, COLOR_WHITE);
	//// set backgroud window to white.
	wattrset(stdscr, COLOR_PAIR(CELL_COLOR_GREEN));
	for(i = 0; i < LINES; i++){
		for(j = 0; j < COLS; j++){
			addch(' ');
		}
	}
	refresh();
	
	/// bind  timter function
	if(signal(SIGALRM, signal_callback_alarm) == SIG_ERR){
		endwin();
		fprintf(stderr, "Fail in signal()\n");
		return -1;
	}
	///set timer
	struct itimerval itimer;
	itimer.it_value.tv_sec = 0;
	itimer.it_value.tv_usec = 100000;
	itimer.it_interval.tv_sec = 0;
	itimer.it_interval.tv_usec = 500000;
	setitimer(ITIMER_REAL, & itimer, NULL);
	
	put_a_block(4,1,1,1,1,1,1,1);
	put_a_block_on_table();

	//// get key press event and procees.
	int key = KEY_DOWN;
	score_win = newwin(1, SCORE_WIN_LENGTH, SCORE_WIN_START_Y, SCORE_WIN_START_X);
	wattrset(score_win, COLOR_PAIR(PAIR_SCORE));
	for(i = 0; i < SCORE_WIN_LENGTH; i++){
		wprintf(score_win, " ");
	}
	
	while(key != ERR && key != 'q'){
		switch(key){
		case KEY_LEFT:
		case KEY_RIGHT: 
		case KEY_DOWN:
		case KEY_UP:
		default: 
			move_pos(key);
			break;
		}
		key = getch();
		
	}

	/// delete resources.
	endwin();
	return 0;
}

static void signal_callback_alarm(int signo)
{
	static int flag = 1;
	static int down_flag = 1;
	
	clear_a_block_on_table();
	if(action == ACTION_LEFT || action == ACTION_RIGHT){
		if(0 == move_to_left_or_right(action))
			action = ACTION_DOWN;
	}
	if(action == ACTION_ROTATE){
		if(0 == rotate())
			action = ACTION_DOWN;
	}
	if(action == ACTION_DOWN){
		down_flag = down();
		if(down_flag == 0){
			put_a_block_on_table();
			flag = put_a_block(generate_a_random_num(BLOCK_TABLE_LENGTH),
							   generate_a_random_num(CELL_COLOR_LENGTH),
							   generate_a_random_num(CELL_COLOR_LENGTH),
							   generate_a_random_num(CELL_COLOR_LENGTH),
							   generate_a_random_num(CELL_COLOR_LENGTH),
							   generate_a_random_num(CELL_COLOR_LENGTH),
							   generate_a_random_num(CELL_COLOR_LENGTH),
							   generate_a_random_num(CELL_COLOR_LENGTH));
												  
			if(flag == 0){
				game_over();
			}
			int a = delete_complete_lines();
			if(a > 0)score += a * a * 5;
			update_score_win();
			wrefresh(score_win);
			return;
		}
	}
	put_a_block_on_table();
	action = ACTION_DOWN;
	/// update the chess_table
	static WINDOW * p_new_window;
	update_score_win();
	wrefresh(score_win);
	delwin(p_new_window);
	p_new_window = new_window_at(POS_START_X_OF_TABLE,
								 POS_START_Y_OF_TABLE);
	/// reflesh the chess_table window
	wrefresh(p_new_window);
	move(LINES - 1, COLS - 1);
	/// put block of new pos on the table
	
}
static void game_over()
{
	endwin();
	fprintf(stderr, "Game over!\n");
	exit(1);
}
// return a random number 1 <= random <= max
static int generate_a_random_num(int max)
{
	static unsigned int diff = 1;
	srand((unsigned int)time(NULL) + diff);
	int result;
	result = (int)rand();
	++diff;
	return result % max + 1;
}
static void update_score_win()
{
	int i;
	wattrset(score_win, COLOR_PAIR(PAIR_SCORE) );
	for(i = 0; i < SCORE_WIN_LENGTH; i++){
		mvwaddch(score_win, 0, i, ' ');
	}
	mvwprintw(score_win, 0, 0, "%s", score_str_h );
	mvwprintw(score_win, 0, 8, "%d", score);
	wrefresh(score_win);
}
