%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%%
"int"       { return INT; }
"float"     { return FLOAT; }

[0-9]+      {
                yylval.num = atof(yytext);
                return NUMBER;
            }

[a-zA-Z_][a-zA-Z0-9_]* {
                yylval.str = strdup(yytext);
                return ID;
            }

"="     { return '='; }
","     { return ','; }
"("     { return '('; }
")"     { return ')'; }

"+"     { return '+'; }
"-"     { return '-'; }
"*"     { return '*'; }
"/"     { return '/'; }

[ \t\n] ;
. ;

%%