/* Summary: Provides simple ternary AST helpers for the ICG compiler (node creation, traversal, cleanup). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* Allocates a node with up to three children (used for statements such as IF/ELSE). */
ASTNode* make_node3(const char *value, ASTNode *a, ASTNode *b, ASTNode *c) {
    ASTNode *n = (ASTNode*)malloc(sizeof(ASTNode));
    strcpy(n->value, value);  /* Store operator/label for debugging prints. */
    n->left = a;
    n->right = b;
    n->third = c;
    return n;
}

ASTNode* make_leaf(const char *value) {
    return make_node3(value, NULL, NULL, NULL);  /* Leaves simply hold literal/identifier names. */
}

/* Prints nodes in postorder, extending to the optional third child pointer. */
void postorder3(ASTNode *root) {
    if (!root) return;
    postorder3(root->left);   /* Visit children before printing this node's value. */
    postorder3(root->right);
    postorder3(root->third);
    printf("%s ", root->value);
}

/* Deallocates every node reachable from root (up to three children each). */
void free_ast3(ASTNode *root) {
    if (!root) return;
    free_ast3(root->left);   /* Release entire subtree recursively to avoid leaks. */
    free_ast3(root->right);
    free_ast3(root->third);
    free(root);
}
