%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "attributes.h"
#include "icg.h"

int yylex(void);              /* Flex scanner feeding this grammar. */
void yyerror(const char *s);  /* Reports syntax errors. */

void gen_assign(const char *id, const char *expr_place) {
    emit2("=", expr_place, "_", id);  /* Emit three-address code for assignment. */
}

void gen_if_else(const char *a, const char *rel, const char *b) {
    char *ltrue = new_label();
    char *lfalse = new_label();
    char *lend = new_label();
    emit2(rel, a, b, ltrue);      /* Branch to true block when condition satisfied. */
    emit2("goto", "_", "_", lfalse);   /* Else jump. */
    emit2("label", "_", "_", ltrue);
    emit2("then", "_", "_", "_");      /* Placeholder marking THEN block start. */
    emit2("goto", "_", "_", lend);     /* Jump past ELSE after THEN completes. */
    emit2("label", "_", "_", lfalse);
    emit2("else", "_", "_", "_");
    emit2("label", "_", "_", lend);
}

void gen_do_while(const char *a, const char *rel, const char *b) {
    char *lstart = new_label();
    emit2("label", "_", "_", lstart);  /* Mark loop head. */
    emit2(rel, a, b, lstart);          /* Condition jumps back to head when true. */
}
%}

%union {
    char *sval;          /* Lexeme strings for identifiers/numbers/rel ops. */
    ExprAttr exprattr;   /* Expression attributes include temporary name + AST pointer. */
    StmtAttr stmtattr;   /* Statement attributes currently just wrap AST pointer. */
    ASTNode *node;       /* Direct AST pointer when productions naturally produce one. */
}

%token IF ELSE DO WHILE                    /* Control keywords. */
%token <sval> ID NUM REL                   /* ID/NUM carry lexemes; REL carries operator string. */
%token ASSIGN PLUS MINUS MUL DIV LPAREN RPAREN LBRACE RBRACE SEMI  /* Punctuation tokens. */

%type <exprattr> expr term factor cond       /* Non-terminals that produce expression attributes. */
%type <stmtattr> stmt block stmts           /* Statements share AST pointer wrapper. */
%type <node> assign_stmt if_stmt do_stmt    /* Some productions directly return AST pointers. */

%left PLUS MINUS   /* Addition/subtraction associativity. */
%left MUL DIV      /* Higher precedence for multiplication/division. */

%%

program
    : stmts
      {
          print_icg2();  /* After parsing finishes, dump the accumulated intermediate code. */
      }
    ;

stmts
    : stmts stmt
      {
          $$.node = make_node3("SEQ", $1.node, $2.node, NULL);  /* Build sequence nodes to preserve order. */
      }
    | stmt
      {
          $$.node = $1.node;
      }
    ;

stmt
    : assign_stmt
      {
          $$.node = $1;   /* Each statement production produces an AST pointer. */
      }
    | if_stmt
      {
          $$.node = $1;
      }
    | do_stmt
      {
          $$.node = $1;
      }
    ;

assign_stmt
    : ID ASSIGN expr SEMI
      {
          gen_assign($1, $3.place);                  /* Emit TAC using the synthesized expr temp. */
          $$ = make_node3("=", make_leaf($1), $3.node, NULL);  /* Mirror same structure in AST. */
          free($1);
      }
    ;

if_stmt
    : IF LPAREN cond RPAREN block ELSE block
      {
          gen_if_else($3.node->left->value, $3.node->value, $3.node->right->value);  /* Use cond AST to drive labels. */
          $$ = make_node3("IF_ELSE", $3.node, $5.node, $7.node);
          printf("AST Postorder: ");
          postorder3($$);  /* Emit tree for visualization immediately. */
          printf("\n");
      }
    ;

do_stmt
    : DO block WHILE LPAREN cond RPAREN SEMI
      {
          gen_do_while($5.node->left->value, $5.node->value, $5.node->right->value);  /* Generate looping TAC skeleton. */
          $$ = make_node3("DO_WHILE", $2.node, $5.node, NULL);
          printf("AST Postorder: ");
          postorder3($$);
          printf("\n");
      }
    ;

block
    : LBRACE stmts RBRACE
      {
          $$.node = $2.node;  /* A block is just the AST of its nested statements. */
      }
    ;

cond
    : ID REL ID
      {
          ASTNode *l = make_leaf($1);
          ASTNode *r = make_leaf($3);
          $$.node = make_node3($2, l, r, NULL);  /* Condition nodes capture operands + operator string. */
          $$.place = NULL;  /* REL nodes don't synthesize temps since they act directly on values. */
          free($1);
          free($2);
          free($3);
      }
    ;

expr
    : expr PLUS term
      {
          char *t = new_temp2();
          emit2("+", $1.place, $3.place, t);   /* Generate TAC for addition into new temp. */
          $$.place = t;
          $$.node = make_node3("+", $1.node, $3.node, NULL);
      }
    | expr MINUS term
      {
          char *t = new_temp2();
          emit2("-", $1.place, $3.place, t);
          $$.place = t;
          $$.node = make_node3("-", $1.node, $3.node, NULL);
      }
    | term
      {
          $$ = $1;
      }
    ;

term
    : term MUL factor
      {
          char *t = new_temp2();
          emit2("*", $1.place, $3.place, t);
          $$.place = t;
          $$.node = make_node3("*", $1.node, $3.node, NULL);
      }
    | term DIV factor
      {
          char *t = new_temp2();
          emit2("/", $1.place, $3.place, t);  /* Division currently assumes non-zero divisor; TAC mirrors AST. */
          $$.place = t;
          $$.node = make_node3("/", $1.node, $3.node, NULL);
      }
    | factor
      {
          $$ = $1;
      }
    ;

factor
    : ID
      {
          $$.place = $1;           /* Identifiers evaluate to themselves (no temp needed). */
          $$.node = make_leaf($1); /* AST leaf referencing identifier. */
      }
    | NUM
      {
          $$.place = $1;           /* Numeric literal similarly forwards lexeme as place. */
          $$.node = make_leaf($1);
      }
    | LPAREN expr RPAREN
      {
          $$ = $2;   /* Parentheses simply forward inner expression attributes. */
      }
    ;

%%

void yyerror(const char *s) {
    printf("Syntax error: %s\n", s);  /* Basic diagnostic helper for parser failures. */
}

int main(void) {
    yyparse();  /* Kick off parsing; lexer and semantic actions perform the heavy lifting. */
    return 0;
}
