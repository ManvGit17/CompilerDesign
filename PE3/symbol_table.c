#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static Symbol table[MAX_SYMBOLS];
static int    count = 0;
static int    cur_scope = 0;

/* ------------------------------------------------------------------ */
static int base_size(const char *base) {
    if (strncmp(base, "int",    3) == 0) return 4;
    if (strncmp(base, "char",   4) == 0) return 1;
    if (strncmp(base, "float",  5) == 0) return 4;
    if (strncmp(base, "double", 6) == 0) return 8;
    if (strncmp(base, "long",   4) == 0) return 8;
    if (strncmp(base, "short",  5) == 0) return 2;
    if (strncmp(base, "void",   4) == 0) return 0;
    return 4;   /* unknown / struct — default */
}

static int compute_size(Symbol *s) {
    if (s->kind == KIND_FUNCTION) return 0;
    if (s->is_pointer)            return 8; /* pointer = 8 bytes (64-bit) */
    int sz = base_size(s->base_type);
    for (int i = 0; i < s->num_dims; i++)
        sz *= s->dims[i];
    return sz;
}

static const char *kind_str(SymKind k) {
    switch (k) {
        case KIND_VARIABLE:   return "variable";
        case KIND_FUNCTION:   return "function";
        case KIND_PARAMETER:  return "parameter";
        case KIND_TYPEDEF:    return "typedef";
        case KIND_ENUM_CONST: return "enum-const";
        case KIND_STRUCT_TAG: return "struct-tag";
        case KIND_UNION_TAG:  return "union-tag";
    }
    return "?";
}

static const char *storage_str(StorageClass sc) {
    switch (sc) {
        case STORAGE_AUTO:     return "auto";
        case STORAGE_STATIC:   return "static";
        case STORAGE_EXTERN:   return "extern";
        case STORAGE_REGISTER: return "register";
    }
    return "auto";
}

/* ------------------------------------------------------------------ */
void sym_init(void) { count = 0; cur_scope = 0; }

void sym_enter_scope(void) { cur_scope++; }
void sym_exit_scope(void)  { if (cur_scope > 0) cur_scope--; }
int  sym_current_scope(void) { return cur_scope; }

/* ------------------------------------------------------------------ */
int sym_add(const char *name, SymKind kind,
            const char *base_type, int is_pointer,
            int num_dims, int dims[],
            StorageClass storage,
            int line, int col,
            const char *value)
{
    /* Check for duplicate in same scope */
    for (int i = 0; i < count; i++) {
        if (table[i].active &&
            table[i].scope == cur_scope &&
            strcmp(table[i].name, name) == 0) {
            fprintf(stderr, "Warning: '%s' already declared in scope %d (line %d)\n",
                    name, cur_scope, line);
            return -1;
        }
    }
    if (count >= MAX_SYMBOLS) {
        fprintf(stderr, "Symbol table overflow!\n");
        return -1;
    }

    Symbol *s = &table[count];
    strncpy(s->name,      name,      MAX_NAME-1);
    strncpy(s->base_type, base_type, MAX_TYPE-1);
    strncpy(s->value,     value ? value : "", MAX_VALUE-1);
    s->kind       = kind;
    s->is_pointer = is_pointer;
    s->num_dims   = num_dims;
    for (int i = 0; i < num_dims && i < MAX_DIMS; i++)
        s->dims[i] = dims[i];
    s->storage = storage;
    s->scope   = cur_scope;
    s->line    = line;
    s->col     = col;
    s->active  = 1;
    s->size    = compute_size(s);

    return count++;
}

Symbol *sym_lookup(const char *name) {
    /* search from innermost scope outward */
    for (int sc = cur_scope; sc >= 0; sc--)
        for (int i = count-1; i >= 0; i--)
            if (table[i].active && table[i].scope == sc &&
                strcmp(table[i].name, name) == 0)
                return &table[i];
    return NULL;
}

/* ------------------------------------------------------------------ */
void sym_print_table(void) {
    /* Build full type string for display */
    printf("\nSYMBOL TABLE\n");
    printf("%-20s %-10s %-20s %-10s %-6s %-7s %-5s %-5s %-12s\n",
           "Name", "Kind", "Type", "Storage", "Size", "Scope", "Line", "Col", "Value");
    for (int i = 0; i < 100; i++) printf("-");
    printf("\n");

    for (int i = 0; i < count; i++) {
        Symbol *s = &table[i];

        /* Build display type */
        char type_disp[256];
        if (s->is_pointer) {
            snprintf(type_disp, sizeof(type_disp), "%s *", s->base_type);
        } else if (s->num_dims > 0) {
            char tmp[256];
            snprintf(tmp, sizeof(tmp), "%s", s->base_type);
            for (int d = 0; d < s->num_dims; d++) {
                char dim[16];
                if (s->dims[d] > 0)
                    snprintf(dim, sizeof(dim), "[%d]", s->dims[d]);
                else
                    snprintf(dim, sizeof(dim), "[]");
                strncat(tmp, dim, sizeof(tmp)-strlen(tmp)-1);
            }
            strncpy(type_disp, tmp, sizeof(type_disp)-1);
        } else {
            strncpy(type_disp, s->base_type, sizeof(type_disp)-1);
        }

        const char *scope_label;
        char scope_buf[16];
        if (s->scope == 0) scope_label = "global";
        else { snprintf(scope_buf, sizeof(scope_buf), "block-%d", s->scope); scope_label = scope_buf; }

        printf("%-20s %-10s %-20s %-10s %-6d %-7s %-5d %-5d %-12s\n",
               s->name,
               kind_str(s->kind),
               type_disp,
               storage_str(s->storage),
               s->size,
               scope_label,
               s->line, s->col,
               s->value[0] ? s->value : "-");
    }
}
