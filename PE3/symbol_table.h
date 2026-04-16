#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_NAME      64
#define MAX_TYPE      128
#define MAX_VALUE     64
#define MAX_FILE      128
#define MAX_SYMBOLS   1024
#define MAX_DIMS      8

typedef enum {
    KIND_VARIABLE,
    KIND_FUNCTION,
    KIND_PARAMETER,
    KIND_TYPEDEF,
    KIND_ENUM_CONST,
    KIND_STRUCT_TAG,
    KIND_UNION_TAG
} SymKind;

typedef enum {
    STORAGE_AUTO,
    STORAGE_STATIC,
    STORAGE_EXTERN,
    STORAGE_REGISTER
} StorageClass;

typedef struct {
    char     name[MAX_NAME];
    SymKind  kind;
    char     base_type[MAX_TYPE];  /* e.g. "int", "double *", "int[15]" */
    int      is_pointer;
    int      num_dims;
    int      dims[MAX_DIMS];       /* array dimensions */
    StorageClass storage;
    int      size;                 /* size in bytes */
    int      scope;                /* 0 = global, 1+ = nested blocks */
    int      line;
    int      col;
    char     value[MAX_VALUE];     /* initializer if known, else "" */
    int      active;               /* 1 = in scope */
} Symbol;

/* ---- public API ---- */
void sym_init(void);
void sym_enter_scope(void);
void sym_exit_scope(void);
int  sym_current_scope(void);

/* returns index or -1 on duplicate */
int  sym_add(const char *name, SymKind kind,
             const char *base_type, int is_pointer,
             int num_dims, int dims[],
             StorageClass storage,
             int line, int col,
             const char *value);

Symbol *sym_lookup(const char *name);
void    sym_print_table(void);

#endif
