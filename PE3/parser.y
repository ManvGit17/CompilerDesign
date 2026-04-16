%{
/*
 * PE3: C Symbol Table Builder
 * Bison parser with full symbol table population.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

extern int yylex();
extern int yylineno;
extern char *yytext;
extern int  line_num;
extern int  col_num;

void yyerror(const char *s);
int  yylex_destroy(void);

static int syntax_error = 0;

/* ---------- helpers passed down during parsing ---------- */
/* current type context (base type + storage) */
static char   cur_base_type[64]  = "int";
static int    cur_is_pointer     = 0;
static StorageClass cur_storage  = STORAGE_AUTO;

/* small helper: duplicate a string (safe) */
static char *dupstr(const char *s) {
    char *r = malloc(strlen(s)+1);
    strcpy(r, s);
    return r;
}

/* ---- per-declarator temporary state ---- */
static int   decl_dims[MAX_DIMS];
static int   decl_ndim = 0;
static int   decl_ptr  = 0;
static char  decl_val[64] = "";
%}

/* ---- use a union so identifiers/constants carry their text ---- */
%union {
    char str[64];
    int  ival;
}

%token <str> TOKEN_IDENTIFIER
%token <str> TOKEN_INT_CONST TOKEN_FLOAT_CONST TOKEN_CHAR_CONST TOKEN_STRING_LITERAL

/* type keywords */
%token <str> TOKEN_INT TOKEN_FLOAT TOKEN_CHAR TOKEN_DOUBLE TOKEN_VOID
%token <str> TOKEN_LONG TOKEN_SHORT TOKEN_UNSIGNED TOKEN_SIGNED
%token <str> TOKEN_STRUCT TOKEN_UNION TOKEN_TYPEDEF TOKEN_ENUM

/* storage keywords */
%token <str> TOKEN_AUTO TOKEN_EXTERN TOKEN_REGISTER TOKEN_STATIC

/* control */
%token TOKEN_IF TOKEN_ELSE TOKEN_DO TOKEN_WHILE TOKEN_FOR TOKEN_SWITCH
%token TOKEN_CASE TOKEN_DEFAULT TOKEN_BREAK TOKEN_CONTINUE TOKEN_RETURN
%token TOKEN_SIZEOF

/* operators */
%token TOKEN_PLUS TOKEN_MINUS TOKEN_STAR TOKEN_SLASH TOKEN_PERCENT
%token TOKEN_INC TOKEN_DEC TOKEN_EQ TOKEN_NE TOKEN_LT TOKEN_GT
%token TOKEN_LE TOKEN_GE TOKEN_AND TOKEN_OR TOKEN_NOT
%token TOKEN_ASSIGN TOKEN_ADD_ASSIGN TOKEN_SUB_ASSIGN
%token TOKEN_MUL_ASSIGN TOKEN_DIV_ASSIGN TOKEN_MOD_ASSIGN
%token TOKEN_AND_ASSIGN TOKEN_OR_ASSIGN TOKEN_XOR_ASSIGN
%token TOKEN_LSHIFT_ASSIGN TOKEN_RSHIFT_ASSIGN
%token TOKEN_BIT_AND TOKEN_BIT_NOT TOKEN_BIT_OR TOKEN_BIT_XOR
%token TOKEN_LSHIFT TOKEN_RSHIFT
%token TOKEN_DOT TOKEN_ARROW TOKEN_QUESTION

/* punctuation */
%token TOKEN_SEMICOLON TOKEN_COMMA TOKEN_LPAREN TOKEN_RPAREN
%token TOKEN_LBRACE TOKEN_RBRACE TOKEN_LBRACKET TOKEN_RBRACKET
%token TOKEN_COLON

/* nonterminal types */
%type <str> type_specifier type_qualifier_list declarator
%type <str> constant primary_expression

%left TOKEN_COMMA
%right TOKEN_ASSIGN TOKEN_ADD_ASSIGN TOKEN_SUB_ASSIGN TOKEN_MUL_ASSIGN TOKEN_DIV_ASSIGN TOKEN_MOD_ASSIGN TOKEN_AND_ASSIGN TOKEN_OR_ASSIGN TOKEN_XOR_ASSIGN TOKEN_LSHIFT_ASSIGN TOKEN_RSHIFT_ASSIGN
%right TOKEN_QUESTION TOKEN_COLON
%left TOKEN_OR
%left TOKEN_AND
%left TOKEN_BIT_OR
%left TOKEN_BIT_XOR
%left TOKEN_BIT_AND
%left TOKEN_EQ TOKEN_NE
%left TOKEN_LT TOKEN_GT TOKEN_LE TOKEN_GE
%left TOKEN_LSHIFT TOKEN_RSHIFT
%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_STAR TOKEN_SLASH TOKEN_PERCENT
%right TOKEN_NOT TOKEN_BIT_NOT TOKEN_INC TOKEN_DEC
%left TOKEN_LBRACKET TOKEN_LPAREN TOKEN_DOT TOKEN_ARROW

%nonassoc TOKEN_ELSE

%start translation_unit

%%

/* ============================================================ */
translation_unit
    : /* empty */
    | translation_unit external_declaration
    ;

external_declaration
    : function_definition
    | declaration
    ;

/* ---- function definition ----------------------------------- */
function_definition
    : declaration_specifiers declarator_func
        TOKEN_LPAREN { sym_enter_scope(); } param_list_opt TOKEN_RPAREN
        compound_statement_noenter
        { sym_exit_scope(); }
    ;

declarator_func
    : TOKEN_IDENTIFIER
        {
            /* register function in outer scope */
            sym_add($1, KIND_FUNCTION, cur_base_type, 0,
                    0, NULL, cur_storage, yylineno, 1, "");
        }
    ;

param_list_opt
    : /* empty */
    | parameter_list
    ;

parameter_list
    : parameter_declaration
    | parameter_list TOKEN_COMMA parameter_declaration
    ;

parameter_declaration
    : declaration_specifiers param_declarator
    ;

param_declarator
    : TOKEN_IDENTIFIER
        {
            sym_add($1, KIND_PARAMETER, cur_base_type, 0,
                    0, NULL, STORAGE_AUTO, yylineno, 1, "");
        }
    | TOKEN_STAR TOKEN_IDENTIFIER
        {
            sym_add($2, KIND_PARAMETER, cur_base_type, 1,
                    0, NULL, STORAGE_AUTO, yylineno, 1, "");
        }
    | /* abstract (unnamed) */
    ;

/* ---- declarations ------------------------------------------ */
declaration
    : declaration_specifiers init_declarator_list TOKEN_SEMICOLON
    | declaration_specifiers TOKEN_SEMICOLON   /* e.g. struct S; */
    ;

declaration_specifiers
    : storage_class_specifier type_specifier
        { strncpy(cur_base_type, $2, 63); }
    | type_specifier
        { strncpy(cur_base_type, $1, 63); cur_storage = STORAGE_AUTO; }
    | storage_class_specifier type_qualifier_list type_specifier
        { strncpy(cur_base_type, $3, 63); }
    | type_qualifier_list type_specifier
        { strncpy(cur_base_type, $2, 63); cur_storage = STORAGE_AUTO; }
    ;

storage_class_specifier
    : TOKEN_AUTO     { cur_storage = STORAGE_AUTO; }
    | TOKEN_STATIC   { cur_storage = STORAGE_STATIC; }
    | TOKEN_EXTERN   { cur_storage = STORAGE_EXTERN; }
    | TOKEN_REGISTER { cur_storage = STORAGE_REGISTER; }
    | TOKEN_TYPEDEF  { cur_storage = STORAGE_AUTO; }
    ;

type_qualifier_list
    : type_qualifier { $$ [0] = '\0'; }
    | type_qualifier_list type_qualifier { $$ [0] = '\0'; }
    ;

type_qualifier : TOKEN_UNSIGNED | TOKEN_SIGNED | TOKEN_LONG | TOKEN_SHORT ;

type_specifier
    : TOKEN_INT    { strncpy($$, "int",    63); }
    | TOKEN_FLOAT  { strncpy($$, "float",  63); }
    | TOKEN_CHAR   { strncpy($$, "char",   63); }
    | TOKEN_DOUBLE { strncpy($$, "double", 63); }
    | TOKEN_VOID   { strncpy($$, "void",   63); }
    | TOKEN_LONG   { strncpy($$, "long",   63); }
    | TOKEN_SHORT  { strncpy($$, "short",  63); }
    | TOKEN_STRUCT TOKEN_IDENTIFIER
        {
            snprintf($$, sizeof($$), "struct %.50s", $2);
            sym_add($2, KIND_STRUCT_TAG, "struct", 0,
                    0, NULL, STORAGE_AUTO, yylineno, 1, "");
        }
    | TOKEN_UNION TOKEN_IDENTIFIER
        {
            snprintf($$, sizeof($$), "union %.50s", $2);
            sym_add($2, KIND_UNION_TAG, "union", 0,
                    0, NULL, STORAGE_AUTO, yylineno, 1, "");
        }
    ;

/* ---- init declarator list ---------------------------------- */
init_declarator_list
    : init_declarator
    | init_declarator_list TOKEN_COMMA init_declarator
    ;

init_declarator
    : declarator
    | declarator TOKEN_ASSIGN initializer_val
    ;

declarator
    : simple_declarator { $$ [0] = '\0'; }
    ;

simple_declarator
    : TOKEN_IDENTIFIER array_dims
        {
            sym_add($1, KIND_VARIABLE, cur_base_type, decl_ptr,
                    decl_ndim, decl_dims, cur_storage, yylineno, 1,
                    decl_val);
            decl_ptr = 0; decl_ndim = 0; decl_val[0] = '\0';
        }
    | TOKEN_STAR TOKEN_IDENTIFIER array_dims
        {
            sym_add($2, KIND_VARIABLE, cur_base_type, 1,
                    decl_ndim, decl_dims, cur_storage, yylineno, 1,
                    decl_val);
            decl_ptr = 0; decl_ndim = 0; decl_val[0] = '\0';
        }
    ;

array_dims
    : /* empty */         { decl_ndim = 0; }
    | array_dims TOKEN_LBRACKET TOKEN_INT_CONST TOKEN_RBRACKET
        {
            if (decl_ndim < MAX_DIMS)
                decl_dims[decl_ndim++] = atoi($3);
        }
    | array_dims TOKEN_LBRACKET TOKEN_RBRACKET
        {
            if (decl_ndim < MAX_DIMS)
                decl_dims[decl_ndim++] = 0;
        }
    ;

initializer_val
    : assignment_expression
    | TOKEN_LBRACE initializer_list_inner TOKEN_RBRACE
    | TOKEN_LBRACE initializer_list_inner TOKEN_COMMA TOKEN_RBRACE
    ;

initializer_list_inner
    : initializer_val
    | initializer_list_inner TOKEN_COMMA initializer_val
    ;

/* ---- compound statement ------------------------------------ */
compound_statement
    : TOKEN_LBRACE { sym_enter_scope(); } block_item_list TOKEN_RBRACE
        { sym_exit_scope(); }
    ;

/* version used by function_definition (scope already entered) */
compound_statement_noenter
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

/* ---- statements -------------------------------------------- */
statement
    : compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    | labeled_statement
    ;

labeled_statement
    : TOKEN_CASE constant_expression TOKEN_COLON statement
    | TOKEN_DEFAULT TOKEN_COLON statement
    ;

constant_expression
    : conditional_expression
    ;

expression_statement
    : TOKEN_SEMICOLON
    | expression TOKEN_SEMICOLON
    ;

selection_statement
    : TOKEN_IF TOKEN_LPAREN expression TOKEN_RPAREN statement
    | TOKEN_IF TOKEN_LPAREN expression TOKEN_RPAREN statement TOKEN_ELSE statement
    | TOKEN_SWITCH TOKEN_LPAREN expression TOKEN_RPAREN statement
    ;

iteration_statement
    : TOKEN_WHILE TOKEN_LPAREN expression TOKEN_RPAREN statement
    | TOKEN_DO statement TOKEN_WHILE TOKEN_LPAREN expression TOKEN_RPAREN TOKEN_SEMICOLON
    | TOKEN_FOR TOKEN_LPAREN for_init for_cond TOKEN_SEMICOLON for_step TOKEN_RPAREN statement
    ;

for_init
    : declaration
    | expression_statement
    ;

for_cond
    : /* empty */
    | expression
    ;

for_step
    : /* empty */
    | expression
    ;

jump_statement
    : TOKEN_BREAK TOKEN_SEMICOLON
    | TOKEN_CONTINUE TOKEN_SEMICOLON
    | TOKEN_RETURN TOKEN_SEMICOLON
    | TOKEN_RETURN expression TOKEN_SEMICOLON
    ;

/* ---- expressions ------------------------------------------- */
expression
    : assignment_expression
    | expression TOKEN_COMMA assignment_expression
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_op assignment_expression
    ;

assignment_op
    : TOKEN_ASSIGN | TOKEN_ADD_ASSIGN | TOKEN_SUB_ASSIGN
    | TOKEN_MUL_ASSIGN | TOKEN_DIV_ASSIGN | TOKEN_MOD_ASSIGN
    | TOKEN_AND_ASSIGN | TOKEN_OR_ASSIGN  | TOKEN_XOR_ASSIGN
    | TOKEN_LSHIFT_ASSIGN | TOKEN_RSHIFT_ASSIGN
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression TOKEN_QUESTION expression TOKEN_COLON conditional_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression TOKEN_OR logical_and_expression
    ;

logical_and_expression
    : bitwise_or_expression
    | logical_and_expression TOKEN_AND bitwise_or_expression
    ;

bitwise_or_expression
    : bitwise_xor_expression
    | bitwise_or_expression TOKEN_BIT_OR bitwise_xor_expression
    ;

bitwise_xor_expression
    : bitwise_and_expression
    | bitwise_xor_expression TOKEN_BIT_XOR bitwise_and_expression
    ;

bitwise_and_expression
    : equality_expression
    | bitwise_and_expression TOKEN_BIT_AND equality_expression
    ;

equality_expression
    : relational_expression
    | equality_expression TOKEN_EQ relational_expression
    | equality_expression TOKEN_NE relational_expression
    ;

relational_expression
    : shift_expression
    | relational_expression TOKEN_LT shift_expression
    | relational_expression TOKEN_GT shift_expression
    | relational_expression TOKEN_LE shift_expression
    | relational_expression TOKEN_GE shift_expression
    ;

shift_expression
    : additive_expression
    | shift_expression TOKEN_LSHIFT additive_expression
    | shift_expression TOKEN_RSHIFT additive_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression TOKEN_PLUS  multiplicative_expression
    | additive_expression TOKEN_MINUS multiplicative_expression
    ;

multiplicative_expression
    : cast_expression
    | multiplicative_expression TOKEN_STAR    cast_expression
    | multiplicative_expression TOKEN_SLASH   cast_expression
    | multiplicative_expression TOKEN_PERCENT cast_expression
    ;

cast_expression
    : unary_expression
    ;

unary_expression
    : postfix_expression
    | TOKEN_INC unary_expression
    | TOKEN_DEC unary_expression
    | TOKEN_NOT    cast_expression
    | TOKEN_MINUS  cast_expression
    | TOKEN_BIT_NOT cast_expression
    | TOKEN_BIT_AND cast_expression   /* address-of */
    | TOKEN_STAR    cast_expression   /* dereference */
    | TOKEN_SIZEOF unary_expression
    | TOKEN_SIZEOF TOKEN_LPAREN type_specifier TOKEN_RPAREN
    | TOKEN_SIZEOF TOKEN_LPAREN type_specifier TOKEN_STAR TOKEN_RPAREN
    ;

postfix_expression
    : primary_expression
    | postfix_expression TOKEN_LBRACKET expression TOKEN_RBRACKET
    | postfix_expression TOKEN_LPAREN arg_list_opt TOKEN_RPAREN
    | postfix_expression TOKEN_DOT   TOKEN_IDENTIFIER
    | postfix_expression TOKEN_ARROW TOKEN_IDENTIFIER
    | postfix_expression TOKEN_INC
    | postfix_expression TOKEN_DEC
    ;

arg_list_opt
    : /* empty */
    | argument_expression_list
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list TOKEN_COMMA assignment_expression
    ;

primary_expression
    : TOKEN_IDENTIFIER   { strncpy($$, $1, 63); }
    | constant           { strncpy($$, $1, 63); }
    | TOKEN_STRING_LITERAL { strncpy($$, $1, 63); }
    | TOKEN_LPAREN expression TOKEN_RPAREN { $$ [0] = '\0'; }
    ;

constant
    : TOKEN_INT_CONST    { strncpy($$, $1, 63); }
    | TOKEN_FLOAT_CONST  { strncpy($$, $1, 63); }
    | TOKEN_CHAR_CONST   { strncpy($$, $1, 63); }
    ;


%%

/* ============================================================ */
void yyerror(const char *s) {
    syntax_error = 1;
    fprintf(stderr, "Error: %s at line %d (token: '%s')\n",
            s, yylineno, yytext);
}

int main(int argc, char **argv) {
    extern FILE *yyin;

    sym_init();

    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { fprintf(stderr, "Cannot open %s\n", argv[1]); return 1; }
        yyin = f;
    }

    yyparse();

    sym_print_table();

    if (argc > 1) fclose(yyin);
    yylex_destroy();
    return syntax_error ? 1 : 0;
}
