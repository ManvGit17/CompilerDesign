%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

extern int yylineno;
extern char* yytext;
int yylex();
void yyerror(const char* msg);

ASTNode* expression_list = NULL;

void add_expression(ASTNode* expr) {
    if (!expression_list) {
        expression_list = expr;
    } else {
        ASTNode* temp = expression_list;
        while (temp->next) {
            temp = temp->next;
        }
        temp->next = expr;
    }
}

%}

%union {
    int val;
    char* str;
    struct ASTNode* node;  // Use struct ASTNode* instead of ASTNode*
}

%token <val> NUMBER
%token <str> IDENTIFIER
%token TYPE
%token ASSIGN PLUS MINUS MULTIPLY DIVIDE
%token LPAREN RPAREN SEMICOLON

%type <node> expression assignment_statement program statement statements

%left PLUS MINUS
%left MULTIPLY DIVIDE

%start program

%%

program:
    statements {
        expression_list = $1;
    }
    ;

statements:
    statement {
        $$ = $1;
    }
    | statements statement {
        if ($1) {
            struct ASTNode* temp = $1;
            while (temp->next) temp = temp->next;
            temp->next = $2;
        }
        $$ = $1;
    }
    ;

statement:
    assignment_statement {
        $$ = $1;
    }
    | error {
        yyerror("Syntax error");
        yyerrok;
        $$ = NULL;
    }
    ;

assignment_statement:
    IDENTIFIER ASSIGN expression SEMICOLON {
        struct ASTNode* expr_node = $3;
        struct ASTNode* assign_node = create_assignment_node($1, expr_node);
        $$ = assign_node;
        printf("Assignment: %s\n", $1);
        free($1);
    }
    ;

expression:
    NUMBER {
        $$ = create_number_node($1);
        printf("Number: %d\n", $1);
    }
    | IDENTIFIER {
        $$ = create_identifier_node($1);
        printf("Identifier: %s\n", $1);
        free($1);
    }
    | expression PLUS expression {
        $$ = create_binary_op_node(OP_ADD, $1, $3);
        printf("Binary Op: +\n");
    }
    | expression MINUS expression {
        $$ = create_binary_op_node(OP_SUBTRACT, $1, $3);
        printf("Binary Op: -\n");
    }
    | expression MULTIPLY expression {
        $$ = create_binary_op_node(OP_MULTIPLY, $1, $3);
        printf("Binary Op: *\n");
    }
    | expression DIVIDE expression {
        $$ = create_binary_op_node(OP_DIVIDE, $1, $3);
        printf("Binary Op: /\n");
    }
    | LPAREN expression RPAREN {
        $$ = $2;
        printf("Parentheses\n");
    }
    ;

%%

void yyerror(const char* msg) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, msg);
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
    
    printf("\n========== AST Construction Started ==========\n\n");
    
    int result = yyparse();
    
    printf("\n========== Postorder Traversal (Reverse Polish) ==========\n");
    if (expression_list) {
        print_ast_postorder(expression_list);
    } else {
        printf("No expressions found\n");
    }
    
    printf("\n========== AST Visualization ==========\n");
    printf("(Expressions evaluated in order)\n");
    
    // Clean up
    if (expression_list) {
        free_ast(expression_list);
    }
    fclose(yyin);
    
    return result;
}