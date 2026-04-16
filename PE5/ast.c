#include "ast.h"

ASTNode* create_number_node(int value) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_NUMBER;
    node->data.value = value;
    node->next = NULL;
    return node;
}

ASTNode* create_identifier_node(char* name) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_IDENTIFIER;
    node->data.name = strdup(name);
    node->next = NULL;
    return node;
}

ASTNode* create_binary_op_node(Operator op, ASTNode* left, ASTNode* right) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_BINARY_OP;
    node->data.binary.op = op;
    node->data.binary.left = left;
    node->data.binary.right = right;
    node->next = NULL;
    return node;
}

ASTNode* create_assignment_node(char* name, ASTNode* expr) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_ASSIGNMENT;
    node->data.assignment.var_name = strdup(name);
    node->data.assignment.expr = expr;
    node->next = NULL;
    return node;
}

void postorder_traversal(ASTNode* node) {
    if (!node) return;
    
    switch (node->type) {
        case NODE_NUMBER:
            printf("%d ", node->data.value);
            break;
            
        case NODE_IDENTIFIER:
            printf("%s ", node->data.name);
            break;
            
        case NODE_BINARY_OP:
            postorder_traversal(node->data.binary.left);
            postorder_traversal(node->data.binary.right);
            switch (node->data.binary.op) {
                case OP_ADD: printf("+ "); break;
                case OP_SUBTRACT: printf("- "); break;
                case OP_MULTIPLY: printf("* "); break;
                case OP_DIVIDE: printf("/ "); break;
            }
            break;
            
        case NODE_ASSIGNMENT:
            postorder_traversal(node->data.assignment.expr);
            printf("%s = ", node->data.assignment.var_name);
            break;
    }
}

void print_ast_postorder(ASTNode* node) {
    if (!node) return;
    
    // Remove the recursive call that goes to the end first
    // print_ast_postorder(node->next);  // Comment this out
    
    // Just print in order
    postorder_traversal(node);
    printf("\n");
    
    // Then process next
    if (node->next) {
        print_ast_postorder(node->next);
    }
}

void free_ast(ASTNode* node) {
    if (!node) return;
    
    free_ast(node->next);
    
    switch (node->type) {
        case NODE_IDENTIFIER:
            free(node->data.name);
            break;
            
        case NODE_BINARY_OP:
            free_ast(node->data.binary.left);
            free_ast(node->data.binary.right);
            break;
            
        case NODE_ASSIGNMENT:
            free(node->data.assignment.var_name);
            free_ast(node->data.assignment.expr);
            break;
            
        default:
            break;
    }
    
    free(node);
}