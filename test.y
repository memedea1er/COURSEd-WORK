%{
#include <stdio.h>
void yyerror(const char *s);
extern int yylex();
extern FILE *yyout;
%}

%union {
    int num; 
    struct Array {
        int arr[2];
    } array;
    struct Arrray2 {
        int arr[2];
    } forarr;
}

%token <num> NUMBER 
%token BEGI SIZE WALL FLOOR SEM END PLACEBEGIN PLACEEND FOR VAR LBR RBR
%type <num> commands flooriy floorxi walliy wallxi 
%type <array> placewall placefloor setsize
%type <forarr> floorlist walllist

%%

input:
    | commands END SEM { fprintf(yyout,"DONE HALT\n.END"); YYACCEPT;}
    ;

commands
    : { $$ = 0; }
    | commands PLACEBEGIN SEM placefloor SEM { fprintf(yyout, "PRINT_NEXT_LINE\nADD R4, R4, #1\nBRnzp CHECK_0\nCHECK_0\nADD R7, R2, #-%d\nBRnp CHECK_1\nADD R7, R4, #-%d\nBRnp CHECK_1\nBRnzp PRINT_F\n", $4.arr[1], $4.arr[0]); $$ += 1;}
    | commands PLACEBEGIN SEM placewall SEM { fprintf(yyout, "PRINT_NEXT_LINE\nADD R4, R4, #1\nBRnzp CHECK_0\nCHECK_0\nADD R7, R2, #-%d\nBRnp CHECK_1\nADD R7, R4, #-%d\nBRnp CHECK_1\nBRnzp PRINT_W\n", $4.arr[1], $4.arr[0]); $$ += 1;}
    | commands placefloor SEM { fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp CHECK_%d\nADD R7, R4, #-%d\nBRnp CHECK_%d\nBRnzp PRINT_F\n", $$, $2.arr[1], $$+1, $2.arr[0], $$+1); $$ += 1;}
    | commands placewall SEM { fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp CHECK_%d\nADD R7, R4, #-%d\nBRnp CHECK_%d\nBRnzp PRINT_W\n", $$, $2.arr[1], $$+1, $2.arr[0], $$+1); $$ += 1;}
    | commands placefloor SEM PLACEEND SEM {fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp PRINT_F\nADD R7, R4, #-%d\nBRnp PRINT_F\nBRnzp PRINT_F\n", $$, $2.arr[1], $2.arr[0]);}
    | commands placewall SEM PLACEEND SEM {fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp PRINT_F\nADD R7, R4, #-%d\nBRnp PRINT_F\nBRnzp PRINT_W\n", $$, $2.arr[1], $2.arr[0]);}
    | commands setsize SEM {fprintf(yyout, "PRINT_W\nLD R0, W_CHAR\nBRnzp PRINT_CHAR\nPRINT_F \nADD R0, R1, #0\nPRINT_CHAR\nOUT\nADD R0, R4, #-%d\nBRz PRINT_NEW_LINE\n", $2.arr[0]);
    fprintf(yyout, "BR PRINT_NEXT_LINE\nPRINT_NEW_LINE\nADD R0, R5, #0\nOUT\nADD R2, R2, #-1\nBRz DONE\nAND R4, R4, #0\nADD R3, R3, #1\nBRnzp PRINT_NEXT_LINE\nF_CHAR .FILL x0046\n");
    fprintf(yyout, "W_CHAR .FILL x0057\n.FILL x0054\nNEWLINE .FILL x000A\nCOUNT   .FILL #%d\nLINE_LEN .FILL #%d\n", $2.arr[1], $2.arr[0]);}
    | commands startprogram SEM {fprintf(yyout, ".ORIG x3000\nINIT\nLD R1, F_CHAR\nLD R5, NEWLINE\nLD R2, COUNT\nAND R4, R4, #0\nAND R3, R3, #0\n");}
    | commands loopfloor LBR floorlist RBR { $$ += 1; }
    | commands loopwall LBR walllist RBR { $$ += 1; }
    ;
placefloor
    : FLOOR NUMBER NUMBER { $$.arr[0] = $2; $$.arr[1] = $3; }
    ;
placewall
    : WALL NUMBER NUMBER { $$.arr[0] = $2; $$.arr[1] = $3; }
    ;
setsize
    : SIZE NUMBER NUMBER { $$.arr[0] = $2; $$.arr[1] = $3; }
    ;
startprogram
    : BEGI
    ;
loopfloor
    : FOR VAR NUMBER NUMBER 
    ;
loopwall
    : FOR VAR NUMBER NUMBER 
    ;
floorlist
    : flooriy SEM { $$.arr[0] = $1; $$.arr[1] = 2; }
    | floorxi SEM { $$.arr[0] = $1; $$.arr[1] = 3; }
    | floorlist flooriy SEM { $$.arr[0] = $2; $$.arr[1] = 2; }
    | floorlist floorxi SEM { $$.arr[0] = $2; $$.arr[1] = 3; }
    | walllist flooriy SEM { $$.arr[0] = $2; $$.arr[1] = 2; }
    | walllist floorxi SEM { $$.arr[0] = $2; $$.arr[1] = 3; }
    ;
walllist
    : flooriy SEM { $$.arr[0] = $1; $$.arr[1] = 2; }
    | floorxi SEM { $$.arr[0] = $1; $$.arr[1] = 3; }
    | floorlist walliy SEM { $$.arr[0] = $2; $$.arr[1] = 2; }
    | floorlist wallxi SEM { $$.arr[0] = $2; $$.arr[1] = 3; }
    | walllist walliy SEM { $$.arr[0] = $2; $$.arr[1] = 2; }
    | walllist wallxi SEM { $$.arr[0] = $2; $$.arr[1] = 3; }
    ;
flooriy
    : FLOOR VAR NUMBER { $$ = $3; }
    ;
floorxi
    : FLOOR NUMBER VAR { $$ = $2; }
    ;
walliy
    : WALL VAR NUMBER { $$ = $3; }
    ;
wallxi
    : WALL NUMBER VAR { $$ = $2; }
    ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyout = fopen("maze.asm", "w");
    yyparse();
    fclose(yyout);
    return 0;
}
