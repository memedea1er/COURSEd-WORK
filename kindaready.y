%{
#include <stdio.h>
void yyerror(const char *s);
extern int yylex();
extern FILE *yyout;
%}

%union {
    int num; 
}

%token <num> NUMBER 
%token BEGI SIZE WALL FLOOR EOL END
%type <num> placewall placefloor commands 

%%

commands
    : { $$ = 0; }
    | commands placefloor NUMBER EOL { fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp CHECK_%d\nADD R7, R4, #-%d\nBRnp CHECK_%d\nBRnzp PRINT_F\n", $$, $3, $$+1, $2, $$+1); $$ += 1;}
    | commands placewall NUMBER EOL { fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp CHECK_%d\nADD R7, R4, #-%d\nBRnp CHECK_%d\nBRnzp PRINT_W\n", $$, $3, $$+1, $2, $$+1); $$ += 1;}
    | commands placefloor NUMBER EOL END {fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp PRINT_F\nADD R7, R4, #-%d\nBRnp PRINT_F\nBRnzp PRINT_F\nDONE HALT\n.END", $$, $3, $2); YYACCEPT;}
    | commands placewall NUMBER EOL END {fprintf(yyout, "CHECK_%d\nADD R7, R2, #-%d\nBRnp PRINT_F\nADD R7, R4, #-%d\nBRnp PRINT_F\nBRnzp PRINT_W\nDONE HALT\n.END", $$, $3, $2); YYACCEPT;}
    | commands start EOL {; }
    ;
placefloor
    : FLOOR NUMBER { $$ = $2; }
    ;
placewall
    : WALL NUMBER { $$ = $2; }
    ;
start
    : BEGI {fprintf(yyout, ".ORIG x3000\nINIT LD R1, F_CHAR\nLD R5, NEWLINE\nLD R2, COUNT\nAND R4, R4, #0\nAND R3, R3, #0\nPRINT_NEXT_LINE\nADD R4, R4, #1\nBRnzp CHECK_0\n");}
    | SIZE NUMBER NUMBER {fprintf(yyout, "PRINT_W\nLD R0, W_CHAR\nBRnzp PRINT_CHAR\nPRINT_F  ADD R0, R1, #0\nPRINT_CHAR\nOUT\nADD R0, R4, #-%d\nBRz PRINT_NEW_LINE\n", $2);
    fprintf(yyout, "BR PRINT_NEXT_LINE\nPRINT_NEW_LINE\nADD R0, R5, #0\nOUT\nADD R2, R2, #-1\nBRz DONE\nAND R4, R4, #0\nADD R3, R3, #1\nBRnzp PRINT_NEXT_LINE\nF_CHAR .FILL x0046\n");
    fprintf(yyout, "W_CHAR .FILL x0057\nC_CHAR  .FILL x0043\nD_CHAR  .FILL x0044\nT_CHAR  .FILL x0054\nNEWLINE .FILL x000A\nCOUNT   .FILL #%d\nLINE_LEN .FILL #%d\n", $3, $2);}
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
