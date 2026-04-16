%{
/*
 * C Lexical Analyzer using FLEX
 * Recognizes all valid C tokens
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Token types enumeration */
typedef enum {
    /* Keywords */
    TOKEN_AUTO = 1, TOKEN_BREAK, TOKEN_CASE, TOKEN_CHAR, TOKEN_CONST,
    TOKEN_CONTINUE, TOKEN_DEFAULT, TOKEN_DO, TOKEN_DOUBLE, TOKEN_ELSE,
    TOKEN_ENUM, TOKEN_EXTERN, TOKEN_FLOAT, TOKEN_FOR, TOKEN_GOTO,
    TOKEN_IF, TOKEN_INT, TOKEN_LONG, TOKEN_REGISTER, TOKEN_RETURN,
    TOKEN_SHORT, TOKEN_SIGNED, TOKEN_SIZEOF, TOKEN_STATIC, TOKEN_STRUCT,
    TOKEN_SWITCH, TOKEN_TYPEDEF, TOKEN_UNION, TOKEN_UNSIGNED, TOKEN_VOID,
    TOKEN_VOLATILE, TOKEN_WHILE,
    
    /* Identifiers */
    TOKEN_IDENTIFIER,
    
    /* Constants */
    TOKEN_INT_CONST, TOKEN_FLOAT_CONST, TOKEN_CHAR_CONST,
    
    /* String Literals */
    TOKEN_STRING_LITERAL,
    
    /* Operators */
    TOKEN_PLUS, TOKEN_MINUS, TOKEN_STAR, TOKEN_SLASH, TOKEN_PERCENT,
    TOKEN_INC, TOKEN_DEC, TOKEN_EQ, TOKEN_NE, TOKEN_LT, TOKEN_GT,
    TOKEN_LE, TOKEN_GE, TOKEN_AND, TOKEN_OR, TOKEN_NOT, TOKEN_BIT_AND,
    TOKEN_BIT_OR, TOKEN_BIT_XOR, TOKEN_BIT_NOT, TOKEN_LSHIFT, TOKEN_RSHIFT,
    TOKEN_ASSIGN, TOKEN_ADD_ASSIGN, TOKEN_SUB_ASSIGN, TOKEN_MUL_ASSIGN,
    TOKEN_DIV_ASSIGN, TOKEN_MOD_ASSIGN, TOKEN_AND_ASSIGN, TOKEN_OR_ASSIGN,
    TOKEN_XOR_ASSIGN, TOKEN_LSHIFT_ASSIGN, TOKEN_RSHIFT_ASSIGN,
    TOKEN_COND_OP, TOKEN_DOT, TOKEN_ARROW,
    
    /* Punctuators */
    TOKEN_SEMICOLON, TOKEN_COMMA, TOKEN_LPAREN, TOKEN_RPAREN,
    TOKEN_LBRACE, TOKEN_RBRACE, TOKEN_LBRACKET, TOKEN_RBRACKET,
    TOKEN_COLON, TOKEN_ELLIPSIS,
    
    /* Special */
    TOKEN_PREPROCESSOR, TOKEN_ERROR, TOKEN_EOF
} TokenType;

/* Token structure */
typedef struct {
    TokenType type;
    char* lexeme;
    int line;
    int column;
} Token;

/* Function prototypes */
void print_token(Token token);
const char* get_token_name(TokenType type);
void handle_error(const char* msg);

/* Global variables */
int line_num = 1;
int col_num = 1;
int output_format = 0; /* 0: readable, 1: JSON, 2: CSV */
%}

/* Options */
%option noyywrap
%option yylineno
%option nounput
%option noinput

/* No named regular expressions - using direct patterns */

%%

 /* Preprocessor directives */
^[ \t]*#.*\n          {
    Token t = {TOKEN_PREPROCESSOR, strdup(yytext), line_num, col_num};
    print_token(t);
    free(t.lexeme);
    line_num++;
    col_num = 1;
}

 /* Comments */
"//".*                {
    /* ignore line comments */
    col_num += yyleng;
}

"/*"([^*]|\*[^/])*"*/" {
    /* ignore block comments */
    int i;
    for(i = 0; i < yyleng; i++) {
        if(yytext[i] == '\n') {
            line_num++;
            col_num = 1;
        } else {
            col_num++;
        }
    }
}

 /* Keywords */
"auto"                { Token t = {TOKEN_AUTO, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"break"               { Token t = {TOKEN_BREAK, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"case"                { Token t = {TOKEN_CASE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"char"                { Token t = {TOKEN_CHAR, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"const"               { Token t = {TOKEN_CONST, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"continue"            { Token t = {TOKEN_CONTINUE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"default"             { Token t = {TOKEN_DEFAULT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"do"                  { Token t = {TOKEN_DO, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"double"              { Token t = {TOKEN_DOUBLE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"else"                { Token t = {TOKEN_ELSE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"enum"                { Token t = {TOKEN_ENUM, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"extern"              { Token t = {TOKEN_EXTERN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"float"               { Token t = {TOKEN_FLOAT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"for"                 { Token t = {TOKEN_FOR, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"goto"                { Token t = {TOKEN_GOTO, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"if"                  { Token t = {TOKEN_IF, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"int"                 { Token t = {TOKEN_INT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"long"                { Token t = {TOKEN_LONG, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"register"            { Token t = {TOKEN_REGISTER, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"return"              { Token t = {TOKEN_RETURN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"short"               { Token t = {TOKEN_SHORT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"signed"              { Token t = {TOKEN_SIGNED, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"sizeof"              { Token t = {TOKEN_SIZEOF, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"static"              { Token t = {TOKEN_STATIC, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"struct"              { Token t = {TOKEN_STRUCT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"switch"              { Token t = {TOKEN_SWITCH, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"typedef"             { Token t = {TOKEN_TYPEDEF, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"union"               { Token t = {TOKEN_UNION, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"unsigned"            { Token t = {TOKEN_UNSIGNED, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"void"                { Token t = {TOKEN_VOID, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"volatile"            { Token t = {TOKEN_VOLATILE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"while"               { Token t = {TOKEN_WHILE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }

 /* Identifiers */
[a-zA-Z_][a-zA-Z0-9_]* {
    Token t = {TOKEN_IDENTIFIER, strdup(yytext), line_num, col_num};
    print_token(t);
    free(t.lexeme);
    col_num += yyleng;
}

 /* Integer Constants */
[1-9][0-9]*|0[0-7]*|0[xX][0-9a-fA-F]+ {
    Token t = {TOKEN_INT_CONST, strdup(yytext), line_num, col_num};
    print_token(t);
    free(t.lexeme);
    col_num += yyleng;
}

 /* Float Constants */
[0-9]*\.[0-9]+([eE][+-]?[0-9]+)?[fFlL]?|[0-9]+\.[0-9]*([eE][+-]?[0-9]+)?[fFlL]?|[0-9]+[eE][+-]?[0-9]+[fFlL]? {
    Token t = {TOKEN_FLOAT_CONST, strdup(yytext), line_num, col_num};
    print_token(t);
    free(t.lexeme);
    col_num += yyleng;
}

 /* Character Constants */
L?'(\\.|[^'\\])' {
    Token t = {TOKEN_CHAR_CONST, strdup(yytext), line_num, col_num};
    print_token(t);
    free(t.lexeme);
    col_num += yyleng;
}

 /* String Literals */
L?\"(\\.|[^"\\])*\" {
    Token t = {TOKEN_STRING_LITERAL, strdup(yytext), line_num, col_num};
    print_token(t);
    free(t.lexeme);
    col_num += yyleng;
}

 /* Operators (longest first) */
"++"                  { Token t = {TOKEN_INC, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"--"                  { Token t = {TOKEN_DEC, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"->"                  { Token t = {TOKEN_ARROW, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"<<="                 { Token t = {TOKEN_LSHIFT_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
">>="                 { Token t = {TOKEN_RSHIFT_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"+="                  { Token t = {TOKEN_ADD_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"-="                  { Token t = {TOKEN_SUB_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"*="                  { Token t = {TOKEN_MUL_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"/="                  { Token t = {TOKEN_DIV_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"%="                  { Token t = {TOKEN_MOD_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"&="                  { Token t = {TOKEN_AND_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"|="                  { Token t = {TOKEN_OR_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"^="                  { Token t = {TOKEN_XOR_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"<<"                  { Token t = {TOKEN_LSHIFT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
">>"                  { Token t = {TOKEN_RSHIFT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"<="                  { Token t = {TOKEN_LE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
">="                  { Token t = {TOKEN_GE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"=="                  { Token t = {TOKEN_EQ, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"!="                  { Token t = {TOKEN_NE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"&&"                  { Token t = {TOKEN_AND, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"||"                  { Token t = {TOKEN_OR, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"..."                 { Token t = {TOKEN_ELLIPSIS, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"?"                   { Token t = {TOKEN_COND_OP, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
":"                   { Token t = {TOKEN_COLON, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"."                   { Token t = {TOKEN_DOT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"+"                   { Token t = {TOKEN_PLUS, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"-"                   { Token t = {TOKEN_MINUS, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"*"                   { Token t = {TOKEN_STAR, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"/"                   { Token t = {TOKEN_SLASH, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"%"                   { Token t = {TOKEN_PERCENT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"="                   { Token t = {TOKEN_ASSIGN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"<"                   { Token t = {TOKEN_LT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
">"                   { Token t = {TOKEN_GT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"!"                   { Token t = {TOKEN_NOT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"&"                   { Token t = {TOKEN_BIT_AND, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"|"                   { Token t = {TOKEN_BIT_OR, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"^"                   { Token t = {TOKEN_BIT_XOR, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"~"                   { Token t = {TOKEN_BIT_NOT, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }

 /* Punctuators */
";"                   { Token t = {TOKEN_SEMICOLON, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
","                   { Token t = {TOKEN_COMMA, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"("                   { Token t = {TOKEN_LPAREN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
")"                   { Token t = {TOKEN_RPAREN, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"{"                   { Token t = {TOKEN_LBRACE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"}"                   { Token t = {TOKEN_RBRACE, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"["                   { Token t = {TOKEN_LBRACKET, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }
"]"                   { Token t = {TOKEN_RBRACKET, strdup(yytext), line_num, col_num}; print_token(t); free(t.lexeme); col_num += yyleng; }

 /* Whitespace */
[ \t\r]+              { col_num += yyleng; }

 /* Newline */
\n                    { line_num++; col_num = 1; }

 /* Error handler for unrecognized characters */
.                     {
    char error_msg[100];
    sprintf(error_msg, "Illegal character '%s' at line %d, column %d", 
            yytext, line_num, col_num);
    handle_error(error_msg);
    Token t = {TOKEN_ERROR, strdup(yytext), line_num, col_num};
    print_token(t);
    free(t.lexeme);
    col_num++;
}

%%

/* Helper function implementations */

const char* get_token_name(TokenType type) {
    switch(type) {
        case TOKEN_AUTO: return "AUTO";
        case TOKEN_BREAK: return "BREAK";
        case TOKEN_CASE: return "CASE";
        case TOKEN_CHAR: return "CHAR";
        case TOKEN_CONST: return "CONST";
        case TOKEN_CONTINUE: return "CONTINUE";
        case TOKEN_DEFAULT: return "DEFAULT";
        case TOKEN_DO: return "DO";
        case TOKEN_DOUBLE: return "DOUBLE";
        case TOKEN_ELSE: return "ELSE";
        case TOKEN_ENUM: return "ENUM";
        case TOKEN_EXTERN: return "EXTERN";
        case TOKEN_FLOAT: return "FLOAT";
        case TOKEN_FOR: return "FOR";
        case TOKEN_GOTO: return "GOTO";
        case TOKEN_IF: return "IF";
        case TOKEN_INT: return "INT";
        case TOKEN_LONG: return "LONG";
        case TOKEN_REGISTER: return "REGISTER";
        case TOKEN_RETURN: return "RETURN";
        case TOKEN_SHORT: return "SHORT";
        case TOKEN_SIGNED: return "SIGNED";
        case TOKEN_SIZEOF: return "SIZEOF";
        case TOKEN_STATIC: return "STATIC";
        case TOKEN_STRUCT: return "STRUCT";
        case TOKEN_SWITCH: return "SWITCH";
        case TOKEN_TYPEDEF: return "TYPEDEF";
        case TOKEN_UNION: return "UNION";
        case TOKEN_UNSIGNED: return "UNSIGNED";
        case TOKEN_VOID: return "VOID";
        case TOKEN_VOLATILE: return "VOLATILE";
        case TOKEN_WHILE: return "WHILE";
        case TOKEN_IDENTIFIER: return "IDENTIFIER";
        case TOKEN_INT_CONST: return "INT_CONST";
        case TOKEN_FLOAT_CONST: return "FLOAT_CONST";
        case TOKEN_CHAR_CONST: return "CHAR_CONST";
        case TOKEN_STRING_LITERAL: return "STRING_LITERAL";
        case TOKEN_PLUS: return "PLUS";
        case TOKEN_MINUS: return "MINUS";
        case TOKEN_STAR: return "STAR";
        case TOKEN_SLASH: return "SLASH";
        case TOKEN_PERCENT: return "PERCENT";
        case TOKEN_INC: return "INC";
        case TOKEN_DEC: return "DEC";
        case TOKEN_EQ: return "EQ";
        case TOKEN_NE: return "NE";
        case TOKEN_LT: return "LT";
        case TOKEN_GT: return "GT";
        case TOKEN_LE: return "LE";
        case TOKEN_GE: return "GE";
        case TOKEN_AND: return "AND";
        case TOKEN_OR: return "OR";
        case TOKEN_NOT: return "NOT";
        case TOKEN_BIT_AND: return "BIT_AND";
        case TOKEN_BIT_OR: return "BIT_OR";
        case TOKEN_BIT_XOR: return "BIT_XOR";
        case TOKEN_BIT_NOT: return "BIT_NOT";
        case TOKEN_LSHIFT: return "LSHIFT";
        case TOKEN_RSHIFT: return "RSHIFT";
        case TOKEN_ASSIGN: return "ASSIGN";
        case TOKEN_ADD_ASSIGN: return "ADD_ASSIGN";
        case TOKEN_SUB_ASSIGN: return "SUB_ASSIGN";
        case TOKEN_MUL_ASSIGN: return "MUL_ASSIGN";
        case TOKEN_DIV_ASSIGN: return "DIV_ASSIGN";
        case TOKEN_MOD_ASSIGN: return "MOD_ASSIGN";
        case TOKEN_AND_ASSIGN: return "AND_ASSIGN";
        case TOKEN_OR_ASSIGN: return "OR_ASSIGN";
        case TOKEN_XOR_ASSIGN: return "XOR_ASSIGN";
        case TOKEN_LSHIFT_ASSIGN: return "LSHIFT_ASSIGN";
        case TOKEN_RSHIFT_ASSIGN: return "RSHIFT_ASSIGN";
        case TOKEN_COND_OP: return "COND_OP";
        case TOKEN_DOT: return "DOT";
        case TOKEN_ARROW: return "ARROW";
        case TOKEN_SEMICOLON: return "SEMICOLON";
        case TOKEN_COMMA: return "COMMA";
        case TOKEN_LPAREN: return "LPAREN";
        case TOKEN_RPAREN: return "RPAREN";
        case TOKEN_LBRACE: return "LBRACE";
        case TOKEN_RBRACE: return "RBRACE";
        case TOKEN_LBRACKET: return "LBRACKET";
        case TOKEN_RBRACKET: return "RBRACKET";
        case TOKEN_COLON: return "COLON";
        case TOKEN_ELLIPSIS: return "ELLIPSIS";
        case TOKEN_PREPROCESSOR: return "PREPROCESSOR";
        case TOKEN_ERROR: return "ERROR";
        case TOKEN_EOF: return "EOF";
        default: return "UNKNOWN";
    }
}

void print_token(Token token) {
    switch(output_format) {
        case 1: /* JSON */
            printf("{\n  \"type\": \"%s\",\n  \"lexeme\": \"%s\",\n  \"line\": %d,\n  \"column\": %d\n}\n", 
                   get_token_name(token.type), token.lexeme, token.line, token.column);
            break;
        case 2: /* CSV */
            printf("%s,%s,%d,%d\n", 
                   get_token_name(token.type), token.lexeme, token.line, token.column);
            break;
        default: /* Readable format */
            printf("%-20s: '%s' [line=%d, col=%d]\n", 
                   get_token_name(token.type), token.lexeme, token.line, token.column);
    }
}

void handle_error(const char* msg) {
    fprintf(stderr, "Lexical Error: %s\n", msg);
}

int main(int argc, char** argv) {
    FILE *fp = NULL;

    /* Handle output format flags */
    if(argc > 1) {
        if(strcmp(argv[1], "-json") == 0) {
            output_format = 1;
        } else if(strcmp(argv[1], "-csv") == 0) {
            output_format = 2;
        } else {
            /* Treat argument as input file */
            fp = fopen(argv[1], "r");
            if(fp == NULL) {
                perror("Error opening file");
                return 1;
            }
            yyin = fp;
        }
    }

    /* If second argument exists and is not format, treat as file */
    if(argc > 2 && fp == NULL) {
        fp = fopen(argv[2], "r");
        if(fp == NULL) {
            perror("Error opening file");
            return 1;
        }
        yyin = fp;
    }

    if(output_format == 0) {
        printf("C Lexical Analyzer - Token Output\n");
        printf("==================================\n");
        printf("Format: TOKEN_TYPE: 'lexeme' [line=#, col=#]\n\n");
    }

    yylex();

    if(fp != NULL) {
        fclose(fp);
    }

    return 0;
}