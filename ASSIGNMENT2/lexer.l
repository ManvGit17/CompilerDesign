%{

/* Summary: Tokenizes the ASSIGN2 language, emitting identifiers, keywords, operators, and relational tokens.
 * The scanner runs with %option noyywrap and uses ID/NUM macros for identifiers and numeric literals.
 */
#include "attributes.h"
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap

ID   [a-zA-Z_][a-zA-Z0-9_]*
NUM  [0-9]+

%%

"if"        { /* Control-flow keywords simply return their token enum. */ return IF; }
"else"      { return ELSE; }
"do"        { return DO; }
"while"     { return WHILE; }

{ID}        { /* Copy lexeme for semantic actions. */ yylval.sval = strdup(yytext); return ID; }
{NUM}       { yylval.sval = strdup(yytext); return NUM; }

"//".*      { /* Ignore single-line comments inside test programs. */ }

"=="        { /* All relational operators reuse the REL token with payload. */ yylval.sval = strdup("=="); return REL; }
"!="        { yylval.sval = strdup("!="); return REL; }
"<="        { yylval.sval = strdup("<="); return REL; }
">="        { yylval.sval = strdup(">="); return REL; }
"<"         { yylval.sval = strdup("<"); return REL; }
">"         { yylval.sval = strdup(">"); return REL; }

"="         { return ASSIGN; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MUL; }
"/"         { return DIV; }

"("         { /* Structural punctuation tokens. */ return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
";"         { return SEMI; }

[ \t\r\n]+  { /* Ignore whitespace entirely. */ }
.           { /* Pass other characters up for error reporting. */ return yytext[0]; }

%%
