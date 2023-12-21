%{
#include <stdio.h>
#include <stdlib.h>

int ROWS = 5; // Начальные значения, могут быть изменены
int COLS = 5;
char **grid;   // Изменено на указатель для динамического выделения памяти

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
    printf("\nGenerated C code:\n");
    printf("#include <stdio.h>\n");
    printf("#define ROWS %d\n", ROWS);
    printf("#define COLS %d\n\n", COLS);

    printf("int main() {\n");
    printf("    char grid[ROWS][COLS];\n\n");

    printf("    // Инициализация сетки\n");
    printf("    for (int i = 0; i < ROWS; ++i) {\n");
    printf("        for (int j = 0; j < COLS; ++j) {\n");
    printf("            grid[i][j] = 'F';\n");
    printf("        }\n");
    printf("    }\n\n");

    printf("    // Внесение изменений\n");
    for (int i = 0; i < ROWS; ++i) {
        for (int j = 0; j < COLS; ++j) {
            if (grid[i][j] != 'F') {
                printf("    grid[%d][%d] = '%c';\n", i, j, grid[i][j]);
            }
        }
    }

    printf("\n    // Вывод сетки\n");
    printf("    for (int i = 0; i < ROWS; ++i) {\n");
    printf("        for (int j = 0; j < COLS; ++j) {\n");
    printf("            printf(\"%%c \", grid[i][j]);\n");
    printf("        }\n");
    printf("        printf(\"\\n\");\n");
    printf("    }\n\n");

    printf("    return 0;\n");
    printf("}\n");
}

void setWall(int x, int y) {
    if (x >= 0 && x < ROWS && y >= 0 && y < COLS) {
        grid[x][y] = 'W';
    }
}

void setFloor(int x, int y) {
    if (x >= 0 && x < ROWS && y >= 0 && y < COLS) {
        grid[x][y] = 'F';
    }
}

void setDoor(int x, int y) {
    if (x >= 0 && x < ROWS && y >= 0 && y < COLS) {
        grid[x][y] = 'D';
    }
}

void setChest(int x, int y) {
    if (x >= 0 && x < ROWS && y >= 0 && y < COLS) {
        grid[x][y] = 'C';
    }
}

void setTrap(int x, int y) {
    if (x >= 0 && x < ROWS && y >= 0 && y < COLS) {
        grid[x][y] = 'T';
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
