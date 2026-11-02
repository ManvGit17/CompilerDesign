%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

extern int yylineno;
void yyerror(const char* msg);
%}

%option noyywrap

%%

"if"            { return IF; }
"else"          { return ELSE; }
"do"            { return DO; }
"while"         { return WHILE; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}

[0-9]+ {
    yylval.val = atoi(yytext);
    return NUMBER;
}

"="             { return ASSIGN; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULTIPLY; }
"/"             { return DIVIDE; }
"("             { return LPAREN; }
")"             { return RPAREN; }
";"             { return SEMICOLON; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LE; }
">="            { return GE; }
"=="            { return EQ; }
"!="            { return NE; }

[ \t\n]+        { /* skip whitespace */ }
.               { /* ignore */ }

%%