%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern int yylineno;
extern char* yytext;
int yylex();
void yyerror(const char* msg);

ASTNode* program_root = NULL;

%}

%union {
    int val;
    char* str;
    struct ASTNode* node;
}

%token <val> NUMBER
%token <str> IDENTIFIER
%token IF ELSE DO WHILE
%token ASSIGN PLUS MINUS MULTIPLY DIVIDE
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON
%token LT GT LE GE EQ NE

%type <node> program statement statement_list if_statement do_while_statement
%type <node> assignment_statement expression relational_expression

%left PLUS MINUS
%left MULTIPLY DIVIDE
%nonassoc LT GT LE GE EQ NE

%start program

%%

program:
    statement_list {
        program_root = $1;
    }
    ;

statement_list:
    statement {
        $$ = create_statement_list_node($1, NULL);
    }
    | statement_list statement {
        $$ = create_statement_list_node($1, $2);
    }
    ;

statement:
    assignment_statement {
        $$ = $1;
    }
    | if_statement {
        $$ = $1;
    }
    | do_while_statement {
        $$ = $1;
    }
    ;

assignment_statement:
    IDENTIFIER ASSIGN expression SEMICOLON {
        $$ = create_assignment_node($1, $3);
        free($1);
    }
    ;

if_statement:
    IF LPAREN relational_expression RPAREN LBRACE statement_list RBRACE {
        $$ = create_if_else_node($3, $6, NULL);
    }
    | IF LPAREN relational_expression RPAREN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE {
        $$ = create_if_else_node($3, $6, $10);
    }
    ;

do_while_statement:
    DO LBRACE statement_list RBRACE WHILE LPAREN relational_expression RPAREN SEMICOLON {
        $$ = create_do_while_node($3, $7);
    }
    ;

relational_expression:
    expression LT expression {
        $$ = create_relational_node($1, REL_LT, $3);
    }
    | expression GT expression {
        $$ = create_relational_node($1, REL_GT, $3);
    }
    | expression LE expression {
        $$ = create_relational_node($1, REL_LE, $3);
    }
    | expression GE expression {
        $$ = create_relational_node($1, REL_GE, $3);
    }
    | expression EQ expression {
        $$ = create_relational_node($1, REL_EQ, $3);
    }
    | expression NE expression {
        $$ = create_relational_node($1, REL_NE, $3);
    }
    ;

expression:
    NUMBER {
        $$ = create_number_node($1);
    }
    | IDENTIFIER {
        $$ = create_identifier_node($1);
        free($1);
    }
    | expression PLUS expression {
        $$ = create_binary_op_node(OP_ADD, $1, $3);
    }
    | expression MINUS expression {
        $$ = create_binary_op_node(OP_SUBTRACT, $1, $3);
    }
    | expression MULTIPLY expression {
        $$ = create_binary_op_node(OP_MULTIPLY, $1, $3);
    }
    | expression DIVIDE expression {
        $$ = create_binary_op_node(OP_DIVIDE, $1, $3);
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

%%

void yyerror(const char* msg) {
    fprintf(stderr, "Error at line %d: %s near '%s'\n", yylineno, msg, yytext);
}

int main(int argc, char** argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
    
    extern FILE* yyin;
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error: Cannot open file %s\n", argv[1]);
        return 1;
    }
    
    printf("\n╔══════════════════════════════════════════════════════════════╗\n");
    printf("║     IF-ELSE & DO-WHILE - Three Address Code Generator       ║\n");
    printf("╚══════════════════════════════════════════════════════════════╝\n\n");
    
    int result = yyparse();
    
    if (result == 0 && program_root) {
        printf(" AST Structure:\n");
        printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        print_ast(program_root, 0);
        
        printf("\n\n Three-Address Code (Quadruple Format):\n");
        printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        
        temp_count = 0;
        label_count = 0;
        generate_ic_for_statement_list(program_root);
        
        printf("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
        printf(" Statistics:\n");
        printf("   • Temporaries used: %d\n", temp_count);
        printf("   • Labels generated: %d\n", label_count);
        printf("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n");
        
        free_ast(program_root);
    }
    
    fclose(yyin);
    return result;
}