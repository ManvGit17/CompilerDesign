%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int temp_count = 0;

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int yylex();

char* new_temp() {
    char *temp = malloc(10);
    sprintf(temp, "t%d", temp_count++);
    return temp;
}

void emit(char *op, char *arg1, char *arg2, char *result) {
    if (arg2 == NULL)
        printf("(%s, %s, _, %s)\n", op, arg1, result);
    else
        printf("(%s, %s, %s, %s)\n", op, arg1, arg2, result);
}
%}

%union {
    int num;
    char *id;
}

%token <num> NUMBER
%token <id> IDENTIFIER
%token ASSIGN PLUS MINUS MULT DIV LPAREN RPAREN SEMICOLON NEWLINE

%type <id> expression

%left PLUS MINUS
%left MULT DIV

%start program

%%

program:
    | program statement NEWLINE
    | program NEWLINE
    ;

statement:
    IDENTIFIER ASSIGN expression SEMICOLON {
        emit("=", $3, NULL, $1);
        free($3);
    }
    ;

expression:
    NUMBER {
        char *temp = new_temp();
        char num[32];
        sprintf(num, "%d", $1);
        emit("=", num, NULL, temp);
        $$ = temp;
    }
    | IDENTIFIER {
        $$ = strdup($1);
    }
    | expression PLUS expression {
        char *temp = new_temp();
        emit("+", $1, $3, temp);
        free($1);
        free($3);
        $$ = temp;
    }
    | expression MINUS expression {
        char *temp = new_temp();
        emit("-", $1, $3, temp);
        free($1);
        free($3);
        $$ = temp;
    }
    | expression MULT expression {
        char *temp = new_temp();
        emit("*", $1, $3, temp);
        free($1);
        free($3);
        $$ = temp;
    }
    | expression DIV expression {
        char *temp = new_temp();
        emit("/", $1, $3, temp);
        free($1);
        free($3);
        $$ = temp;
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

%%

int main() {
    printf("\nThree-Address Code (Quadruple Format):\n");
    printf("---------------------------------------\n");
    yyparse();
    printf("---------------------------------------\n");
    printf("Temporaries used: %d\n", temp_count);
    return 0;
}