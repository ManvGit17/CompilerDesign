%{
/*
 * Extended C Syntax Validator with for, while, switch, arrays, and initialization
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern char* yytext;

void yyerror(const char *s);
int yylex_destroy(void);

/* Global variables for error reporting */
int syntax_error = 0;
%}

/* Token definitions */
%token TOKEN_INT TOKEN_FLOAT TOKEN_CHAR TOKEN_DOUBLE
%token TOKEN_IF TOKEN_ELSE TOKEN_DO TOKEN_WHILE TOKEN_FOR TOKEN_SWITCH
%token TOKEN_CASE TOKEN_DEFAULT TOKEN_BREAK TOKEN_CONTINUE TOKEN_RETURN
%token TOKEN_SIZEOF
%token TOKEN_IDENTIFIER
%token TOKEN_INT_CONST TOKEN_FLOAT_CONST TOKEN_CHAR_CONST
%token TOKEN_STRING_LITERAL

/* Operators */
%token TOKEN_PLUS TOKEN_MINUS TOKEN_STAR TOKEN_SLASH TOKEN_PERCENT
%token TOKEN_INC TOKEN_DEC TOKEN_EQ TOKEN_NE TOKEN_LT TOKEN_GT
%token TOKEN_LE TOKEN_GE TOKEN_AND TOKEN_OR TOKEN_NOT
%token TOKEN_ASSIGN TOKEN_ADD_ASSIGN TOKEN_SUB_ASSIGN
%token TOKEN_MUL_ASSIGN TOKEN_DIV_ASSIGN TOKEN_MOD_ASSIGN
%token TOKEN_BIT_AND  /* Added for address-of operator */

/* Punctuators */
%token TOKEN_SEMICOLON TOKEN_COMMA TOKEN_LPAREN TOKEN_RPAREN
%token TOKEN_LBRACE TOKEN_RBRACE TOKEN_LBRACKET TOKEN_RBRACKET
%token TOKEN_COLON

/* Precedence and associativity */
%left TOKEN_COMMA
%right TOKEN_ASSIGN TOKEN_ADD_ASSIGN TOKEN_SUB_ASSIGN TOKEN_MUL_ASSIGN TOKEN_DIV_ASSIGN TOKEN_MOD_ASSIGN
%left TOKEN_AND TOKEN_OR
%left TOKEN_LT TOKEN_GT TOKEN_LE TOKEN_GE TOKEN_EQ TOKEN_NE
%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_STAR TOKEN_SLASH TOKEN_PERCENT
%right TOKEN_NOT TOKEN_INC TOKEN_DEC
%left TOKEN_LBRACKET TOKEN_RBRACKET TOKEN_LPAREN TOKEN_RPAREN

%nonassoc TOKEN_ELSE

%start program

%%

/* Program is a sequence of declarations and statements */
program
    : /* empty */
    | program function_definition
    | program declaration
    | program statement
    ;

/* Function definition */
function_definition
    : type_specifier TOKEN_IDENTIFIER TOKEN_LPAREN parameter_list TOKEN_RPAREN compound_statement
    | type_specifier TOKEN_IDENTIFIER TOKEN_LPAREN TOKEN_RPAREN compound_statement
    ;

parameter_list
    : parameter_declaration
    | parameter_list TOKEN_COMMA parameter_declaration
    ;

parameter_declaration
    : type_specifier TOKEN_IDENTIFIER
    | type_specifier TOKEN_STAR TOKEN_IDENTIFIER
    ;

/* Variable declarations with initialization */
declaration
    : type_specifier init_declarator_list TOKEN_SEMICOLON
    ;

type_specifier
    : TOKEN_INT
    | TOKEN_FLOAT
    | TOKEN_CHAR
    | TOKEN_DOUBLE
    ;

init_declarator_list
    : init_declarator
    | init_declarator_list TOKEN_COMMA init_declarator
    ;

init_declarator
    : declarator
    | declarator TOKEN_ASSIGN initializer
    ;

declarator
    : TOKEN_IDENTIFIER
    | TOKEN_STAR TOKEN_IDENTIFIER
    | declarator array_dimension
    ;

array_dimension
    : TOKEN_LBRACKET TOKEN_INT_CONST TOKEN_RBRACKET
    | TOKEN_LBRACKET TOKEN_RBRACKET  /* for incomplete arrays */
    | array_dimension TOKEN_LBRACKET TOKEN_INT_CONST TOKEN_RBRACKET
    ;

initializer
    : assignment_expression
    | TOKEN_LBRACE initializer_list TOKEN_RBRACE
    | TOKEN_LBRACE initializer_list TOKEN_COMMA TOKEN_RBRACE
    ;

initializer_list
    : initializer
    | initializer_list TOKEN_COMMA initializer
    ;

/* Statements */
statement
    : compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    | labeled_statement
    ;

/* Labeled statements (for switch) */
labeled_statement
    : TOKEN_CASE constant_expression TOKEN_COLON statement
    | TOKEN_DEFAULT TOKEN_COLON statement
    ;

constant_expression
    : conditional_expression
    ;

compound_statement
    : TOKEN_LBRACE block_item_list TOKEN_RBRACE
    ;

block_item_list
    : /* empty */
    | block_item_list block_item
    ;

block_item
    : declaration
    | statement
    ;

expression_statement
    : TOKEN_SEMICOLON
    | expression TOKEN_SEMICOLON
    ;

/* Selection statements */
selection_statement
    : TOKEN_IF TOKEN_LPAREN expression TOKEN_RPAREN statement
    | TOKEN_IF TOKEN_LPAREN expression TOKEN_RPAREN statement TOKEN_ELSE statement
    | TOKEN_SWITCH TOKEN_LPAREN expression TOKEN_RPAREN statement
    ;

/* Iteration statements */
iteration_statement
    : TOKEN_WHILE TOKEN_LPAREN expression TOKEN_RPAREN statement
    | TOKEN_DO statement TOKEN_WHILE TOKEN_LPAREN expression TOKEN_RPAREN TOKEN_SEMICOLON
    | TOKEN_FOR TOKEN_LPAREN for_init_statement for_control_expression TOKEN_SEMICOLON for_expression TOKEN_RPAREN statement
    ;

for_init_statement
    : declaration
    | expression_statement
    ;

for_control_expression
    : /* empty */  /* for(;;) */
    | expression
    ;

for_expression
    : /* empty */
    | expression
    ;

/* Jump statements */
jump_statement
    : TOKEN_BREAK TOKEN_SEMICOLON
    | TOKEN_CONTINUE TOKEN_SEMICOLON
    | TOKEN_RETURN TOKEN_SEMICOLON
    | TOKEN_RETURN expression TOKEN_SEMICOLON
    ;

/* Expressions */
expression
    : assignment_expression
    | expression TOKEN_COMMA assignment_expression
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;

assignment_operator
    : TOKEN_ASSIGN
    | TOKEN_ADD_ASSIGN
    | TOKEN_SUB_ASSIGN
    | TOKEN_MUL_ASSIGN
    | TOKEN_DIV_ASSIGN
    | TOKEN_MOD_ASSIGN
    ;

conditional_expression
    : logical_or_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression TOKEN_OR logical_and_expression
    ;

logical_and_expression
    : equality_expression
    | logical_and_expression TOKEN_AND equality_expression
    ;

equality_expression
    : relational_expression
    | equality_expression TOKEN_EQ relational_expression
    | equality_expression TOKEN_NE relational_expression
    ;

relational_expression
    : additive_expression
    | relational_expression TOKEN_LT additive_expression
    | relational_expression TOKEN_GT additive_expression
    | relational_expression TOKEN_LE additive_expression
    | relational_expression TOKEN_GE additive_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression TOKEN_PLUS multiplicative_expression
    | additive_expression TOKEN_MINUS multiplicative_expression
    ;

multiplicative_expression
    : unary_expression
    | multiplicative_expression TOKEN_STAR unary_expression
    | multiplicative_expression TOKEN_SLASH unary_expression
    | multiplicative_expression TOKEN_PERCENT unary_expression
    ;

unary_expression
    : postfix_expression
    | TOKEN_INC unary_expression
    | TOKEN_DEC unary_expression
    | unary_operator unary_expression
    | TOKEN_SIZEOF unary_expression
    | TOKEN_SIZEOF TOKEN_LPAREN type_specifier declarator TOKEN_RPAREN
    ;

unary_operator
    : TOKEN_NOT
    | TOKEN_MINUS
    | TOKEN_STAR
    | TOKEN_BIT_AND
    ;

postfix_expression
    : primary_expression
    | postfix_expression TOKEN_LBRACKET expression TOKEN_RBRACKET
    | postfix_expression TOKEN_LPAREN argument_expression_list TOKEN_RPAREN
    | postfix_expression TOKEN_LPAREN TOKEN_RPAREN
    | postfix_expression TOKEN_INC
    | postfix_expression TOKEN_DEC
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list TOKEN_COMMA assignment_expression
    ;

primary_expression
    : TOKEN_IDENTIFIER
    | constant
    | TOKEN_STRING_LITERAL
    | TOKEN_LPAREN expression TOKEN_RPAREN
    ;

constant
    : TOKEN_INT_CONST
    | TOKEN_FLOAT_CONST
    | TOKEN_CHAR_CONST
    ;

%%

void yyerror(const char *s) {
    syntax_error = 1;
    fprintf(stderr, "Syntax error at line %d, token '%s': %s\n", 
            yylineno, yytext, s);
}

int main(int argc, char **argv) {
    extern FILE *yyin;
    
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Error: Cannot open file %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    
    printf("Parsing started...\n");
    
    if (yyparse() == 0 && !syntax_error) {
        printf("Syntax valid.\n");
    } else {
        printf("Parsing failed.\n");
    }
    
    if (argc > 1) {
        fclose(yyin);
    }
    
    yylex_destroy();
    return (syntax_error) ? 1 : 0;
}