/* Summary: Declares intermediate-code generation helpers for ASSIGN2. */
#ifndef ICG_H
#define ICG_H

char* new_temp2(void);  /* Allocates a unique temporary name (t0, t1, ...). */
char* new_label(void);  /* Allocates a unique label name (L0, L1, ...). */
void emit2(const char *op, const char *arg1, const char *arg2, const char *result);  /* Append a quadruple. */
void print_icg2(void);  /* Dump the accumulated quadruples to stdout. */

#endif
