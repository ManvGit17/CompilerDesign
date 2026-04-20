/* Summary: Implements a lightweight quadruple-based intermediate code generator for ICG. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "icg.h"

typedef struct {
    char op[16];
    char arg1[32];
    char arg2[32];
    char result[32];
} Quad2;  /* Stores one three-address-style quadruple. */

static Quad2 q[1000];
static int qc = 0;  /* Count of emitted quadruples. */
static int tc = 0;  /* Temporary counter for new_temp2. */
static int lc = 0;  /* Label counter for new_label. */

/* Allocates and returns a unique temporary identifier string. Caller owns the memory. */
char* new_temp2(void) {
    char *s = (char*)malloc(16);
    sprintf(s, "t%d", tc++);  /* t0, t1, ... */
    return s;
}

/* Allocates and returns a unique label for control-flow edges. */
char* new_label(void) {
    char *s = (char*)malloc(16);
    sprintf(s, "L%d", lc++);  /* L0, L1, ... */
    return s;
}

/* Records a quadruple describing a single intermediate-code operation. */
void emit2(const char *op, const char *arg1, const char *arg2, const char *result) {
    strcpy(q[qc].op, op ? op : "_");
    strcpy(q[qc].arg1, arg1 ? arg1 : "_");
    strcpy(q[qc].arg2, arg2 ? arg2 : "_");
    strcpy(q[qc].result, result ? result : "_");
    qc++;  /* Advance write index after storing the quadruple. */
}

/* Dumps every recorded quadruple so the user can inspect generated code. */
void print_icg2(void) {
    int i;
    printf("\nICG Quadruples:\n");
    for (i = 0; i < qc; i++) {
        printf("(%s, %s, %s, %s)\n", q[i].op, q[i].arg1, q[i].arg2, q[i].result);
    }
}
