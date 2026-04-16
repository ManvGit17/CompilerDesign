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
    NODE_ASSIGNMENT
} NodeType;

// Binary Operators
typedef enum {
    OP_ADD,
    OP_SUBTRACT,
    OP_MULTIPLY,
    OP_DIVIDE
} Operator;

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
    } data;
    ASTNode* next;                    // For expression list
};

// Function declarations
ASTNode* create_number_node(int value);
ASTNode* create_identifier_node(char* name);
ASTNode* create_binary_op_node(Operator op, ASTNode* left, ASTNode* right);
ASTNode* create_assignment_node(char* name, ASTNode* expr);
void postorder_traversal(ASTNode* node);
void free_ast(ASTNode* node);
void print_ast_postorder(ASTNode* node);

#endif