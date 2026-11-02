/* Summary: Shared semantic attribute structs bridging lexer, parser, AST, and ICG layers. */
#ifndef ATTRIBUTES_H
#define ATTRIBUTES_H

#include "ast.h"

/* Attribute records shared by lexer, parser, and semantic/ICG modules. */
typedef struct ExprAttr {
    char *place;
    ASTNode *node;
} ExprAttr;

typedef struct StmtAttr {
    ASTNode *node;
} StmtAttr;

#endif
