%{
#include <stdio.h>
#include <stdlib.h>

int ROWS = 5; // Начальные значения, могут быть изменены
int COLS = 5;
char **grid;   // Изменено на указатель для динамического выделения памяти
int n = 0;
int t = 0;

void allocateGrid() {
    grid = malloc(ROWS * sizeof(char *));
    for (int i = 0; i < ROWS; ++i) {
        grid[i] = malloc(COLS * sizeof(char));
        for (int j = 0; j < COLS; ++j) {
            grid[i][j] = 'F'; // Инициализация как пол ('F')
        }
    }
}

void freeGrid() {
    for (int i = 0; i < ROWS; ++i) {
        free(grid[i]);
    }
    free(grid);
}

void generateCCode() {
    printf("\n.ORIG x3000\n");
    printf("INIT    LD R1, F_CHAR\n");
    printf("        LD R6, W_CHAR\n");
    printf("        LD R5, NEWLINE\n");
    printf("        LD R2, COUNT\n");
    printf("        AND R4, R4, #0\n");
    printf("        AND R3, R3, #0\n");
    printf("PRINT_NEXT_LINE\n");
    printf("        ADD R4, R4, #1\n");
    for (int i = 0; i < ROWS; ++i) {
        for (int j = 0; j < COLS; ++j) {
            if (grid[i][j] != 'F') {
                if (t == 0) {
                    printf("        BRnzp CHECK_%d\n", t);
                }
                printf("CHECK_%d\n", t);
                printf("        ADD R7, R2, #-%d\n",COLS-j);
                if (t == n-1){
                    printf("        BRnp PRINT_F\n");
                }
                else{
                    printf("        BRnp CHECK_%d\n",t+1);
                }
                printf("        ADD R7, R4, #-%d\n",i+1);
                    if (t == n-1){
                    printf("        BRnp PRINT_F\n");
                }
                else{
                    printf("        BRnp CHECK_%d\n",t+1);
                }
                if (grid[i][j]=='W'){
                    printf("        BRnzp PRINT_WALL_CHAR\n");
                }
                else if (grid[i][j]=='D'){
                    printf("        BRnzp PRINT_DOOR_CHAR\n");
                }
                else if (grid[i][j]=='C'){
                    printf("        BRnzp PRINT_CHEST_CHAR\n");
                }
                else if (grid[i][j]=='T'){
                    printf("        BRnzp PRINT_TRAP_CHAR\n");
                }
                t += 1;      
            }
        }
    }
    if (t == 0){
        printf("        BRnzp PRINT_F\n");
    }
    printf("PRINT_WALL_CHAR\n");
printf("        LD R0, W_CHAR\n");
printf("        BRnzp PRINT_CHAR\n");

printf("PRINT_CHEST_CHAR\n");
printf("        LD R0, C_CHAR\n");
printf("        BRnzp PRINT_CHAR\n");

printf("PRINT_DOOR_CHAR\n");
printf("        LD R0, D_CHAR\n");
printf("        BRnzp PRINT_CHAR\n");

printf("PRINT_TRAP_CHAR\n");
printf("        LD R0, T_CHAR\n");
printf("        BRnzp PRINT_CHAR\n");

printf("PRINT_F  ADD R0, R1, #0\n");

printf("PRINT_CHAR\n");
printf("        OUT\n");
printf("        ADD R0, R4, #-%d\n",ROWS);
printf("        BRz PRINT_NEW_LINE\n");
printf("        BR PRINT_NEXT_LINE\n");

printf("PRINT_NEW_LINE\n");
printf("        ADD R0, R5, #0\n");
printf("        OUT\n");
printf("        ADD R2, R2, #-1\n");
printf("        BRz DONE\n");
printf("        AND R4, R4, #0\n");
printf("        ADD R3, R3, #1\n");
printf("        BRnzp PRINT_NEXT_LINE\n");

printf("DONE    HALT\n");

printf("; Данные и константы\n");
printf("F_CHAR  .FILL x0046\n");
printf("W_CHAR  .FILL x0057\n");
printf("C_CHAR  .FILL x0043\n");
printf("D_CHAR  .FILL x0044\n");
printf("T_CHAR  .FILL x0054\n");
printf("NEWLINE .FILL x000A\n");
printf("COUNT   .FILL #%d\n",COLS);
printf("LINE_LEN .FILL #%d\n",ROWS);

printf(".END\n");
}

void setWall(int x, int y) {
    if (x > 0 && x <= ROWS && y > 0 && y <= COLS) {
        grid[x-1][y-1] = 'W';
        n++;
    }
}

void setFloor(int x, int y) {
    if (x > 0 && x <= ROWS && y > 0 && y <= COLS) {
        grid[x-1][y-1] = 'F';
        n++;
    }
}

void setDoor(int x, int y) {
    if (x > 0 && x <= ROWS && y > 0 && y <= COLS) {
        grid[x-1][y-1] = 'D';
        n++;
    }
}

void setChest(int x, int y) {
    if (x > 0 && x <= ROWS && y > 0 && y <= COLS) {
        grid[x-1][y-1] = 'C';
        n++;
    }
}

void setTrap(int x, int y) {
    if (x > 0 && x <= ROWS && y > 0 && y <= COLS) {
        grid[x-1][y-1] = 'T';
        n++;
    }
}

void yyerror(const char *s);
int yylex();
%}

%union {
    int num; // Для использования в Bison правилах
}

%token <num> NUMBER SIZE
%token WALL FLOOR DOOR CHEST TRAP EOL QUIT

%%

commands
    : /* пусто */
    | commands command EOL
    ;

command
    : SIZE NUMBER NUMBER { ROWS = $2; COLS = $3; allocateGrid(); }
    | WALL NUMBER NUMBER { setWall($2, $3); }
    | FLOOR NUMBER NUMBER { setFloor($2, $3); }
    | DOOR NUMBER NUMBER { setDoor($2, $3); }
    | CHEST NUMBER NUMBER { setChest($2, $3); }
    | TRAP NUMBER NUMBER { setTrap($2, $3); }
    | QUIT { YYACCEPT; } // Завершить обработку при получении команды QUIT
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    allocateGrid();
    yyparse();
    generateCCode();
    freeGrid();
    return 0;
}
