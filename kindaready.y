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
}

%token <num> NUMBER 
%token BEGI SIZE WALL FLOOR EOL END PLACEBEGIN PLACEEND
%type <num> commands 
%type <array> placewall placefloor setsize

%%

input:
    | commands END { fprintf(yyout,"DONE HALT\n.END"); YYACCEPT;}
    ;

commands
    : { $$ = 0; }
    | commands PLACEBEGIN EOL placefloor EOL { fprintf(yyout, "PRINT_NEXT_LINE\nADD R4, R4, #1\nBRnzp CHECK_0\nCHECK_0\nADD R7, R2, #-%d\nBRnp CHECK_1\nADD R7, R4, #-%d\nBRnp CHECK_1\nBRnzp PRINT_F\n", $4.arr[1], $4.arr[0]); $$ += 1;}
    | commands PLACEBEGIN EOL placewall EOL { fprintf(yyout, "PRINT_NEXT_LINE\nADD R4, R4, #1\nBRnzp CHECK_0\nCHECK_0\nADD R7, R2, #-%d\nBRnp CHECK_1\nADD R7, R4, #-%d\nBRnp CHECK_1\nBRnzp PRINT_W\n", $4.arr[1], $4.arr[0]); $$ += 1;}
    | commands placefloor EOL { fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp CHECK_%d\nADD R7, R4, #-%d\nBRnp CHECK_%d\nBRnzp PRINT_F\n", $$, $2.arr[1], $$+1, $2.arr[0], $$+1); $$ += 1;}
    | commands placewall EOL { fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp CHECK_%d\nADD R7, R4, #-%d\nBRnp CHECK_%d\nBRnzp PRINT_W\n", $$, $2.arr[1], $$+1, $2.arr[0], $$+1); $$ += 1;}
    | commands placefloor EOL PLACEEND EOL {fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp PRINT_F\nADD R7, R4, #-%d\nBRnp PRINT_F\nBRnzp PRINT_F\n", $$, $2.arr[1], $2.arr[0]);}
    | commands placewall EOL PLACEEND EOL {fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp PRINT_F\nADD R7, R4, #-%d\nBRnp PRINT_F\nBRnzp PRINT_W\n", $$, $2.arr[1], $2.arr[0]);}
    | commands setsize EOL {fprintf(yyout, "PRINT_W\nLD R0, W_CHAR\nBRnzp PRINT_CHAR\nPRINT_F \nADD R0, R1, #0\nPRINT_CHAR\nOUT\nADD R0, R4, #-%d\nBRz PRINT_NEW_LINE\n", $2.arr[0]);
    fprintf(yyout, "BR PRINT_NEXT_LINE\nPRINT_NEW_LINE\nADD R0, R5, #0\nOUT\nADD R2, R2, #-1\nBRz DONE\nAND R4, R4, #0\nADD R3, R3, #1\nBRnzp PRINT_NEXT_LINE\nF_CHAR .FILL x0046\n");
    fprintf(yyout, "W_CHAR .FILL x0057\n.FILL x0054\nNEWLINE .FILL x000A\nCOUNT   .FILL #%d\nLINE_LEN .FILL #%d\n", $2.arr[1], $2.arr[0]);}
    | commands startprogram EOL {fprintf(yyout, ".ORIG x3000\nINIT\nLD R1, F_CHAR\nLD R5, NEWLINE\nLD R2, COUNT\nAND R4, R4, #0\nAND R3, R3, #0\n");}
    ;
placefloor
    : FLOOR NUMBER NUMBER { 
        $$.arr[0] = $2; 
        $$.arr[1] = $3; 
      }
    ;
placewall
    : WALL NUMBER NUMBER { 
        $$.arr[0] = $2; 
        $$.arr[1] = $3; 
      }
    ;
setsize
    :  SIZE NUMBER NUMBER { 
        $$.arr[0] = $2; 
        $$.arr[1] = $3; 
      }
    ;
startprogram
    : BEGI
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
