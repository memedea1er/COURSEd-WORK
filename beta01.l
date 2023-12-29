%{
#include "test.tab.h"
%}

%%

"PLACEBEGIN"    { return PLACEBEGIN; }
"PLACEEND"      { return PLACEEND; }
"BEGIN"         { return BEGI; }
"SIZE"          { return SIZE; }
"WALL"          { return WALL; }
"FLOOR"         { return FLOOR; }
[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }
";"             { return SEM; }
"("             { return LBR; }
")"             { return RBR; }
"END"           { return END; }
[ \t\n]+
.               { printf("Invalid input\n"); }

%%
