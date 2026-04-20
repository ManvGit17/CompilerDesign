/* Summary: Defines a ternary AST node structure and helper prototypes for ICG. */
#ifndef AST_H
#define AST_H

typedef struct ASTNode {
    char value[32];          /* Operator or operand string label. */
    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *third;   /* Third child for constructs like IF-ELSE and DO-WHILE. */
} ASTNode;

ASTNode* make_node3(const char *value, ASTNode *a, ASTNode *b, ASTNode *c); /* Create node with up to three children. */
ASTNode* make_leaf(const char *value);  /* Convenience wrapper for leaves with no children. */
void postorder3(ASTNode *root);         /* Prints tree in postorder for debugging. */
void free_ast3(ASTNode *root);          /* Recursively frees entire AST. */

#endif
