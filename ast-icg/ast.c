#include "ast.h"

int temp_count = 0;
int label_count = 0;

char* new_temp() {
    char* temp = malloc(10);
    sprintf(temp, "t%d", temp_count++);
    return temp;
}

char* new_label() {
    char* label = malloc(10);
    sprintf(label, "L%d", label_count++);
    return label;
}

char* relop_to_string(RelationalOp op) {
    switch(op) {
        case REL_LT: return "<";
        case REL_GT: return ">";
        case REL_LE: return "<=";
        case REL_GE: return ">=";
        case REL_EQ: return "==";
        case REL_NE: return "!=";
        default: return "?";
    }
}

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

ASTNode* create_if_else_node(ASTNode* condition, ASTNode* if_body, ASTNode* else_body) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_IF_ELSE;
    node->data.if_else.condition = condition;
    node->data.if_else.if_body = if_body;
    node->data.if_else.else_body = else_body;
    node->next = NULL;
    return node;
}

ASTNode* create_do_while_node(ASTNode* body, ASTNode* condition) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_DO_WHILE;
    node->data.do_while.body = body;
    node->data.do_while.condition = condition;
    node->next = NULL;
    return node;
}

ASTNode* create_relational_node(ASTNode* left, RelationalOp op, ASTNode* right) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_RELATIONAL;
    node->data.relational.left = left;
    node->data.relational.op = op;
    node->data.relational.right = right;
    node->next = NULL;
    return node;
}

ASTNode* create_statement_list_node(ASTNode* first, ASTNode* rest) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = NODE_STATEMENT_LIST;
    node->data.statement_list.first = first;
    node->data.statement_list.rest = rest;
    node->next = NULL;
    return node;
}

void generate_ic(ASTNode* node) {
    if (!node) return;
    
    switch(node->type) {
        case NODE_NUMBER:
            {
                char* temp = new_temp();
                char num[32];
                sprintf(num, "%d", node->data.value);
                printf("  (:=, %s, _, %s)\n", num, temp);
                // Store temp for parent use (simplified)
            }
            break;
            
        case NODE_IDENTIFIER:
            // Just pass the name up
            break;
            
        case NODE_BINARY_OP:
            {
                generate_ic(node->data.binary.left);
                generate_ic(node->data.binary.right);
                char* temp = new_temp();
                char* op_str;
                switch(node->data.binary.op) {
                    case OP_ADD: op_str = "+"; break;
                    case OP_SUBTRACT: op_str = "-"; break;
                    case OP_MULTIPLY: op_str = "*"; break;
                    case OP_DIVIDE: op_str = "/"; break;
                }
                printf("  (%s, _, _, %s)\n", op_str, temp);
            }
            break;
            
        case NODE_ASSIGNMENT:
            {
                generate_ic(node->data.assignment.expr);
                printf("  (:=, _, _, %s)\n", node->data.assignment.var_name);
            }
            break;
            
        case NODE_IF_ELSE:
            {
                char* label_else = new_label();
                char* label_end = new_label();
                
                // Generate condition code
                generate_ic(node->data.if_else.condition);
                printf("  (ifFalse, _, _, %s)\n", label_else);
                
                // Generate if body
                generate_ic_for_statement_list(node->data.if_else.if_body);
                printf("  (goto, _, _, %s)\n", label_end);
                
                // Else label
                printf("  (label, _, _, %s)\n", label_else);
                
                // Generate else body if exists
                if (node->data.if_else.else_body) {
                    generate_ic_for_statement_list(node->data.if_else.else_body);
                }
                
                // End label
                printf("  (label, _, _, %s)\n", label_end);
            }
            break;
            
        case NODE_DO_WHILE:
            {
                char* label_start = new_label();
                char* label_end = new_label();
                
                printf("  (label, _, _, %s)\n", label_start);
                
                // Generate body
                generate_ic_for_statement_list(node->data.do_while.body);
                
                // Generate condition
                generate_ic(node->data.do_while.condition);
                printf("  (ifTrue, _, _, %s)\n", label_start);
                printf("  (label, _, _, %s)\n", label_end);
            }
            break;
            
        case NODE_RELATIONAL:
            {
                char* temp1 = new_temp();
                char* temp2 = new_temp();
                char* result = new_temp();
                // Simplified - in real implementation would evaluate expressions
                printf("  (rel, %s, %s, %s)\n", 
                       relop_to_string(node->data.relational.op), temp1, temp2);
            }
            break;
            
        default:
            break;
    }
}

void generate_ic_for_statement_list(ASTNode* node) {
    ASTNode* current = node;
    while (current) {
        if (current->type == NODE_STATEMENT_LIST) {
            generate_ic_for_statement_list(current->data.statement_list.first);
            current = current->data.statement_list.rest;
        } else {
            generate_ic(current);
            current = current->next;
        }
    }
}

void free_ast(ASTNode* node) {
    if (!node) return;
    
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
            
        case NODE_IF_ELSE:
            free_ast(node->data.if_else.condition);
            free_ast(node->data.if_else.if_body);
            if (node->data.if_else.else_body)
                free_ast(node->data.if_else.else_body);
            break;
            
        case NODE_DO_WHILE:
            free_ast(node->data.do_while.body);
            free_ast(node->data.do_while.condition);
            break;
            
        case NODE_RELATIONAL:
            free_ast(node->data.relational.left);
            free_ast(node->data.relational.right);
            break;
            
        case NODE_STATEMENT_LIST:
            free_ast(node->data.statement_list.first);
            free_ast(node->data.statement_list.rest);
            break;
            
        default:
            break;
    }
    
    free_ast(node->next);
    free(node);
}

void print_ast(ASTNode* node, int indent) {
    if (!node) return;
    
    for(int i = 0; i < indent; i++) printf("  ");
    
    switch(node->type) {
        case NODE_NUMBER:
            printf("Number: %d\n", node->data.value);
            break;
        case NODE_IDENTIFIER:
            printf("Identifier: %s\n", node->data.name);
            break;
        case NODE_BINARY_OP:
            printf("Binary Op: ");
            switch(node->data.binary.op) {
                case OP_ADD: printf("+\n"); break;
                case OP_SUBTRACT: printf("-\n"); break;
                case OP_MULTIPLY: printf("*\n"); break;
                case OP_DIVIDE: printf("/\n"); break;
            }
            print_ast(node->data.binary.left, indent + 1);
            print_ast(node->data.binary.right, indent + 1);
            break;
        case NODE_ASSIGNMENT:
            printf("Assignment: %s\n", node->data.assignment.var_name);
            print_ast(node->data.assignment.expr, indent + 1);
            break;
        case NODE_IF_ELSE:
            printf("If-Else Statement\n");
            printf("  Condition:\n");
            print_ast(node->data.if_else.condition, indent + 2);
            printf("  If Body:\n");
            print_ast(node->data.if_else.if_body, indent + 2);
            if (node->data.if_else.else_body) {
                printf("  Else Body:\n");
                print_ast(node->data.if_else.else_body, indent + 2);
            }
            break;
        case NODE_DO_WHILE:
            printf("Do-While Statement\n");
            printf("  Body:\n");
            print_ast(node->data.do_while.body, indent + 2);
            printf("  Condition:\n");
            print_ast(node->data.do_while.condition, indent + 2);
            break;
        case NODE_RELATIONAL:
            printf("Relational: %s\n", relop_to_string(node->data.relational.op));
            print_ast(node->data.relational.left, indent + 1);
            print_ast(node->data.relational.right, indent + 1);
            break;
        case NODE_STATEMENT_LIST:
            printf("Statement List\n");
            print_ast(node->data.statement_list.first, indent + 1);
            print_ast(node->data.statement_list.rest, indent + 1);
            break;
    }
    
    if (node->next && node->type != NODE_STATEMENT_LIST) {
        print_ast(node->next, indent);
    }
}