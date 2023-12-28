%{
#include "robottest.tab.h"
%}

%%

"BEGIN"      { return BEGI; }
"SIZE"       { return SIZE; }
"WALL"       { return WALL; }
"FLOOR"      { return FLOOR; }
[0-9]+       { yylval.num = atoi(yytext); return NUMBER; }
\n           { return EOL; }
"END"        { return END; }
[ \t]+
.          { printf("Invalid input\n"); }

%%
