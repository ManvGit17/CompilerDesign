#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// AST Node Types
typedef enum {
    NODE_NUMBER,
    NODE_IDENTIFIER,
    NODE_BINARY_OP,
    NODE_ASSIGNMENT,
    NODE_IF_ELSE,
    NODE_DO_WHILE,
    NODE_RELATIONAL,
    NODE_STATEMENT_LIST
} NodeType;

// Binary Operators for arithmetic
typedef enum {
    OP_ADD,
    OP_SUBTRACT,
    OP_MULTIPLY,
    OP_DIVIDE
} Operator;

// Relational Operators
typedef enum {
    REL_LT,
    REL_GT,
    REL_LE,
    REL_GE,
    REL_EQ,
    REL_NE
} RelationalOp;

// Forward declaration
typedef struct ASTNode ASTNode;

// AST Node Structure
struct ASTNode {
    NodeType type;
    union {
        int value;                    // For NODE_NUMBER
        char* name;                   // For NODE_IDENTIFIER
        struct {
            Operator op;              // For NODE_BINARY_OP
            ASTNode* left;
            ASTNode* right;
        } binary;
        struct {
            char* var_name;           // For NODE_ASSIGNMENT
            ASTNode* expr;
        } assignment;
        struct {
            ASTNode* condition;       // For NODE_IF_ELSE
            ASTNode* if_body;
            ASTNode* else_body;
        } if_else;
        struct {
            ASTNode* body;            // For NODE_DO_WHILE
            ASTNode* condition;
        } do_while;
        struct {
            ASTNode* left;            // For NODE_RELATIONAL
            RelationalOp op;
            ASTNode* right;
        } relational;
        struct {
            ASTNode* first;           // For NODE_STATEMENT_LIST
            ASTNode* rest;
        } statement_list;
    } data;
    ASTNode* next;                    // For statement list
};

// ICG Variables
extern int temp_count;
extern int label_count;

// Function declarations
ASTNode* create_number_node(int value);
ASTNode* create_identifier_node(char* name);
ASTNode* create_binary_op_node(Operator op, ASTNode* left, ASTNode* right);
ASTNode* create_assignment_node(char* name, ASTNode* expr);
ASTNode* create_if_else_node(ASTNode* condition, ASTNode* if_body, ASTNode* else_body);
ASTNode* create_do_while_node(ASTNode* body, ASTNode* condition);
ASTNode* create_relational_node(ASTNode* left, RelationalOp op, ASTNode* right);
ASTNode* create_statement_list_node(ASTNode* first, ASTNode* rest);

char* new_temp();
char* new_label();
char* relop_to_string(RelationalOp op);
void generate_ic(ASTNode* node);
void generate_ic_for_statement_list(ASTNode* node);
void free_ast(ASTNode* node);
void print_ast(ASTNode* node, int indent);

#endif