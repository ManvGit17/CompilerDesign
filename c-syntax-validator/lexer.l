%{
#include "parser.tab.h"
#include <stdio.h>
#include <string.h>

extern int yylval;
int line_num = 1;
%}

%option noyywrap
%option yylineno
%option nounput
%option noinput

%%

"#".*    { /* ignore preprocessor directives */ }

"//".*                  { /* ignore */ }
"/*"([^*]|\*[^/])*"*/"  { /* ignore */ }

"int"                   { return TOKEN_INT; }
"float"                 { return TOKEN_FLOAT; }
"char"                  { return TOKEN_CHAR; }
"double"                { return TOKEN_DOUBLE; }
"if"                    { return TOKEN_IF; }
"else"                  { return TOKEN_ELSE; }
"do"                    { return TOKEN_DO; }
"while"                 { return TOKEN_WHILE; }
"for"                   { return TOKEN_FOR; }
"switch"                { return TOKEN_SWITCH; }
"case"                  { return TOKEN_CASE; }
"default"               { return TOKEN_DEFAULT; }
"break"                 { return TOKEN_BREAK; }
"continue"              { return TOKEN_CONTINUE; }
"return"                { return TOKEN_RETURN; }
"sizeof"                { return TOKEN_SIZEOF; }

[a-zA-Z_][a-zA-Z0-9_]*  { return TOKEN_IDENTIFIER; }

[1-9][0-9]*|0[0-7]*|0[xX][0-9a-fA-F]+ { return TOKEN_INT_CONST; }
[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?[fFlL]? { return TOKEN_FLOAT_CONST; }
L?'(\\.|[^'\\])'        { return TOKEN_CHAR_CONST; }
L?\"(\\.|[^"\\])*\"     { return TOKEN_STRING_LITERAL; }

"++"                    { return TOKEN_INC; }
"--"                    { return TOKEN_DEC; }
"+"                     { return TOKEN_PLUS; }
"-"                     { return TOKEN_MINUS; }
"*"                     { return TOKEN_STAR; }
"/"                     { return TOKEN_SLASH; }
"%"                     { return TOKEN_PERCENT; }
"=="                    { return TOKEN_EQ; }
"!="                    { return TOKEN_NE; }
"<"                     { return TOKEN_LT; }
">"                     { return TOKEN_GT; }
"<="                    { return TOKEN_LE; }
">="                    { return TOKEN_GE; }
"&&"                    { return TOKEN_AND; }
"||"                    { return TOKEN_OR; }
"!"                     { return TOKEN_NOT; }
"&"                     { return TOKEN_BIT_AND; }
"="                     { return TOKEN_ASSIGN; }
"+="                    { return TOKEN_ADD_ASSIGN; }
"-="                    { return TOKEN_SUB_ASSIGN; }
"*="                    { return TOKEN_MUL_ASSIGN; }
"/="                    { return TOKEN_DIV_ASSIGN; }
"%="                    { return TOKEN_MOD_ASSIGN; }

";"                     { return TOKEN_SEMICOLON; }
","                     { return TOKEN_COMMA; }
"("                     { return TOKEN_LPAREN; }
")"                     { return TOKEN_RPAREN; }
"{"                     { return TOKEN_LBRACE; }
"}"                     { return TOKEN_RBRACE; }
"["                     { return TOKEN_LBRACKET; }
"]"                     { return TOKEN_RBRACKET; }
":"                     { return TOKEN_COLON; }

[ \t\r]+                { /* ignore */ }
\n                      { line_num++; }

.                       {
    fprintf(stderr, "Lexical error: Illegal character '%s' at line %d\n", 
            yytext, line_num);
    return 0;
}

%%