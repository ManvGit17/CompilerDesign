#include <stdio.h>
#include <string.h>
#include "symbol_table.h"

Symbol table[MAX_SYMBOLS];
int symbol_count = 0;

int lookup(char *name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(table[i].name, name) == 0)
            return i;
    }
    return -1;
}

void insert(char *name, char *type) {
    if (lookup(name) != -1) return;

    strcpy(table[symbol_count].name, name);
    strcpy(table[symbol_count].type, type);
    table[symbol_count].initialized = 0;
    symbol_count++;
}

void update(char *name, float value) {
    int i = lookup(name);
    if (i != -1) {
        table[i].value = value;
        table[i].initialized = 1;
    }
}

void display() {
    printf("\nSYMBOL TABLE\n");
    printf("---------------------------\n");
    printf("Name\tType\tValue\n");
    printf("---------------------------\n");

    for (int i = 0; i < symbol_count; i++) {
        if (table[i].initialized)
            printf("%s\t%s\t%.2f\n", table[i].name, table[i].type, table[i].value);
        else
            printf("%s\t%s\tUNINIT\n", table[i].name, table[i].type);
    }
}