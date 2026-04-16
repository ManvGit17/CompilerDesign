#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_SYMBOLS 100

typedef struct Symbol {
    char name[50];
    char type[10];   // int or float
    float value;     // store evaluated value
    int initialized;
} Symbol;

extern Symbol table[MAX_SYMBOLS];
extern int symbol_count;

int lookup(char *name);
void insert(char *name, char *type);
void update(char *name, float value);
void display();

#endif
