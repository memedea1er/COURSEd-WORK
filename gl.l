%{
#include "gl.tab.h"
%}

%%

SIZE      { return SIZE; }
WALL       { return WALL; }
FLOOR      { return FLOOR; }
DOOR      { return DOOR; }
CHEST      { return CHEST; }
TRAP      { return TRAP; }
[0-9]+     { yylval.num = atoi(yytext); return NUMBER; }
\n         { return EOL; }
QUIT       { return QUIT; }

[ \t]+     ; // Игнорировать пробелы и табуляции
.          { printf("Invalid input\n"); }

%%

int yywrap() {
    return 1;
}
