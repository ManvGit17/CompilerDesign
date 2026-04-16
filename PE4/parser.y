%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

extern int yylex();
void yyerror(const char *s);

%}

%union {
    float num;
    char *str;
}

%token <num> NUMBER
%token <str> ID
%token INT FLOAT

%type <num> expr

%left '+' '-'
%left '*' '/'

%%

program:
    stmt_list { display(); }
  | /* empty */
;
stmt_list:
    stmt
  | stmt_list ',' stmt
;

stmt:
    declaration
  | assignment
;

declaration:
    INT ID {
        insert($2, "int");
    }
  | FLOAT ID {
        insert($2, "float");
    }
;

assignment:
    ID '=' expr {
        int idx = lookup($1);

        if (idx == -1) {
            printf("Error: Variable '%s' not declared\n", $1);
        } else {
            // type check
            if (strcmp(table[idx].type, "int") == 0) {
                update($1, (int)$3);
            } else {
                update($1, $3);
            }
        }
    }
;

expr:
    expr '+' expr { $$ = $1 + $3; }
  | expr '-' expr { $$ = $1 - $3; }
  | expr '*' expr { $$ = $1 * $3; }
  | expr '/' expr {
        if ($3 == 0) {
            printf("Error: Division by zero\n");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
  | '(' expr ')' { $$ = $2; }

  | NUMBER { $$ = $1; }

  | ID {
        int idx = lookup($1);
        if (idx == -1) {
            printf("Error: Variable '%s' not declared\n", $1);
            $$ = 0;
        } else if (!table[idx].initialized) {
            printf("Error: Variable '%s' used uninitialized\n", $1);
            $$ = 0;
        } else {
            $$ = table[idx].value;
        }
    }
;

%%

void yyerror(const char *s) {
    printf("Syntax Error: %s\n", s);
}

int main() {
    printf("Enter expressions:\n");
    yyparse();
    return 0;
}