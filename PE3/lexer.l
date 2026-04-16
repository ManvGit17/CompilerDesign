%{
#include "parser.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int line_num = 1;
int col_num  = 1;

/* track column */
#define YY_USER_ACTION col_num += yyleng;
%}

%option noyywrap
%option yylineno
%option nounput
%option noinput

%%

"#"[^\n]*           { /* ignore preprocessor directives */ }

"//"[^\n]*          { /* ignore line comment */ }
"/*"([^*]|\*[^/])*"*/"  { /* ignore block comment */ }

"auto"              { strncpy(yylval.str, yytext, 63); return TOKEN_AUTO; }
"extern"            { strncpy(yylval.str, yytext, 63); return TOKEN_EXTERN; }
"register"          { strncpy(yylval.str, yytext, 63); return TOKEN_REGISTER; }
"static"            { strncpy(yylval.str, yytext, 63); return TOKEN_STATIC; }
"void"              { strncpy(yylval.str, yytext, 63); return TOKEN_VOID; }
"int"               { strncpy(yylval.str, yytext, 63); return TOKEN_INT; }
"float"             { strncpy(yylval.str, yytext, 63); return TOKEN_FLOAT; }
"char"              { strncpy(yylval.str, yytext, 63); return TOKEN_CHAR; }
"double"            { strncpy(yylval.str, yytext, 63); return TOKEN_DOUBLE; }
"long"              { strncpy(yylval.str, yytext, 63); return TOKEN_LONG; }
"short"             { strncpy(yylval.str, yytext, 63); return TOKEN_SHORT; }
"unsigned"          { strncpy(yylval.str, yytext, 63); return TOKEN_UNSIGNED; }
"signed"            { strncpy(yylval.str, yytext, 63); return TOKEN_SIGNED; }
"struct"            { strncpy(yylval.str, yytext, 63); return TOKEN_STRUCT; }
"union"             { strncpy(yylval.str, yytext, 63); return TOKEN_UNION; }
"typedef"           { strncpy(yylval.str, yytext, 63); return TOKEN_TYPEDEF; }
"enum"              { strncpy(yylval.str, yytext, 63); return TOKEN_ENUM; }
"if"                { return TOKEN_IF; }
"else"              { return TOKEN_ELSE; }
"do"                { return TOKEN_DO; }
"while"             { return TOKEN_WHILE; }
"for"               { return TOKEN_FOR; }
"switch"            { return TOKEN_SWITCH; }
"case"              { return TOKEN_CASE; }
"default"           { return TOKEN_DEFAULT; }
"break"             { return TOKEN_BREAK; }
"continue"          { return TOKEN_CONTINUE; }
"return"            { return TOKEN_RETURN; }
"sizeof"            { return TOKEN_SIZEOF; }

[a-zA-Z_][a-zA-Z0-9_]*  {
    strncpy(yylval.str, yytext, 63);
    yylval.str[63] = '\0';
    return TOKEN_IDENTIFIER;
}

[1-9][0-9]*|0[0-7]*|0[xX][0-9a-fA-F]+  {
    strncpy(yylval.str, yytext, 63);
    return TOKEN_INT_CONST;
}
[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?[fFlL]?  {
    strncpy(yylval.str, yytext, 63);
    return TOKEN_FLOAT_CONST;
}
L?'(\\.|[^'\\])'        { strncpy(yylval.str, yytext, 63); return TOKEN_CHAR_CONST; }
L?\"(\\.|[^"\\])*\"     { strncpy(yylval.str, yytext, 63); return TOKEN_STRING_LITERAL; }

"++"    { return TOKEN_INC; }
"--"    { return TOKEN_DEC; }
"+"     { return TOKEN_PLUS; }
"-"     { return TOKEN_MINUS; }
"*"     { return TOKEN_STAR; }
"/"     { return TOKEN_SLASH; }
"%"     { return TOKEN_PERCENT; }
"=="    { return TOKEN_EQ; }
"!="    { return TOKEN_NE; }
"<"     { return TOKEN_LT; }
">"     { return TOKEN_GT; }
"<="    { return TOKEN_LE; }
">="    { return TOKEN_GE; }
"&&"    { return TOKEN_AND; }
"||"    { return TOKEN_OR; }
"!"     { return TOKEN_NOT; }
"&"     { return TOKEN_BIT_AND; }
"~"     { return TOKEN_BIT_NOT; }
"|"     { return TOKEN_BIT_OR; }
"^"     { return TOKEN_BIT_XOR; }
"<<"    { return TOKEN_LSHIFT; }
">>"    { return TOKEN_RSHIFT; }
"."     { return TOKEN_DOT; }
"->"    { return TOKEN_ARROW; }
"?"     { return TOKEN_QUESTION; }
"="     { return TOKEN_ASSIGN; }
"+="    { return TOKEN_ADD_ASSIGN; }
"-="    { return TOKEN_SUB_ASSIGN; }
"*="    { return TOKEN_MUL_ASSIGN; }
"/="    { return TOKEN_DIV_ASSIGN; }
"%="    { return TOKEN_MOD_ASSIGN; }
"&="    { return TOKEN_AND_ASSIGN; }
"|="    { return TOKEN_OR_ASSIGN; }
"^="    { return TOKEN_XOR_ASSIGN; }
"<<="   { return TOKEN_LSHIFT_ASSIGN; }
">>="   { return TOKEN_RSHIFT_ASSIGN; }

";"     { return TOKEN_SEMICOLON; }
","     { return TOKEN_COMMA; }
"("     { return TOKEN_LPAREN; }
")"     { return TOKEN_RPAREN; }
"{"     { return TOKEN_LBRACE; }
"}"     { return TOKEN_RBRACE; }
"["     { return TOKEN_LBRACKET; }
"]"     { return TOKEN_RBRACKET; }
":"     { return TOKEN_COLON; }

[ \t\r]+    { /* ignore whitespace */ }
\n          { line_num++; col_num = 1; }

.   {
    fprintf(stderr, "Lexical error: Illegal character '%s' at line %d\n",
            yytext, line_num);
}

%%
