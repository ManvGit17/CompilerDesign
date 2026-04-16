%{
#include "calc.tab.h"
#include <string.h>
%}

%option noyywrap

%%
[ \t]+          /* ignore whitespace */
\n              { return NEWLINE; }
[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return IDENTIFIER; }
"="             { return ASSIGN; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULT; }
"/"             { return DIV; }
"("             { return LPAREN; }
")"             { return RPAREN; }
";"             { return SEMICOLON; }
.               { /* ignore unknown characters */ }
%%
