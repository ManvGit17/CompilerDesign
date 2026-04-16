%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

extern int yylineno;
void yyerror(const char* msg);

int line = 1;
int col = 1;

%}

%option noyywrap

%%

"int"|"float"|"char"|"void" {
    return TYPE;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}

[0-9]+ {
    yylval.val = atoi(yytext);
    return NUMBER;
}

"=" {
    return ASSIGN;
}

"+" {
    return PLUS;
}

"-" {
    return MINUS;
}

"*" {
    return MULTIPLY;
}

"/" {
    return DIVIDE;
}

"(" {
    return LPAREN;
}

")" {
    return RPAREN;
}

";" {
    return SEMICOLON;
}

[ \t]+ { col += yyleng; }
"\n" { 
    line++; 
    col = 1; 
    yylineno = line;
}
. { 
    col++; 
}

%%