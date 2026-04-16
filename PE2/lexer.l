%{
/*
 * Lexical Analyzer for Simplified C Syntax Validator
 * Provides tokens to the YACC parser
 */

#include "parser.tab.h"
#include <stdio.h>
#include <string.h>

extern int yylval;  /* Not used but required */
int line_num = 1;
%}

%option noyywrap
%option yylineno
%option nounput
%option noinput

%%

 /* Comments - ignore */
"//".*                  { /* ignore line comments */ }
"/*"([^*]|\*[^/])*"*/"  { /* ignore block comments */ }

 /* Keywords */
"int"                   { return TOKEN_INT; }
"float"                 { return TOKEN_FLOAT; }
"char"                  { return TOKEN_CHAR; }
"double"                { return TOKEN_DOUBLE; }
"if"                    { return TOKEN_IF; }
"else"                  { return TOKEN_ELSE; }
"do"                    { return TOKEN_DO; }
"while"                 { return TOKEN_WHILE; }

 /* Identifiers */
[a-zA-Z_][a-zA-Z0-9_]*  { return TOKEN_IDENTIFIER; }

 /* Constants */
[1-9][0-9]*|0[0-7]*|0[xX][0-9a-fA-F]+ { return TOKEN_INT_CONST; }
[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?[fFlL]?|[0-9]+\.[0-9]*([eE][+-]?[0-9]+)?[fFlL]?|[0-9]+[eE][+-]?[0-9]+[fFlL]? { return TOKEN_FLOAT_CONST; }
L?'(\\.|[^'\\])'        { return TOKEN_CHAR_CONST; }

 /* String Literals */
L?\"(\\.|[^"\\])*\"     { return TOKEN_STRING_LITERAL; }

 /* Operators */
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
"="                     { return TOKEN_ASSIGN; }
"+="                    { return TOKEN_ADD_ASSIGN; }
"-="                    { return TOKEN_SUB_ASSIGN; }
"*="                    { return TOKEN_MUL_ASSIGN; }
"/="                    { return TOKEN_DIV_ASSIGN; }
"%="                    { return TOKEN_MOD_ASSIGN; }

 /* Punctuators */
";"                     { return TOKEN_SEMICOLON; }
","                     { return TOKEN_COMMA; }
"("                     { return TOKEN_LPAREN; }
")"                     { return TOKEN_RPAREN; }
"{"                     { return TOKEN_LBRACE; }
"}"                     { return TOKEN_RBRACE; }
"["                     { return TOKEN_LBRACKET; }
"]"                     { return TOKEN_RBRACKET; }

 /* Whitespace */
[ \t\r]+                { /* ignore whitespace */ }

 /* Newline */
\n                      { line_num++; }

 /* Error handler for unrecognized characters */
.                       {
    fprintf(stderr, "Lexical error: Illegal character '%s' at line %d\n", 
            yytext, line_num);
    return 0;  /* Return invalid token */
}

%%