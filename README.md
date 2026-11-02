# Compiler Design Programming Exercises

A collection of programming exercises and assignments for a Compiler Design course, built with **Flex** and **Bison/Yacc**. Together they walk through the front-end stages of a compiler: lexical analysis, parsing, symbol tables, abstract syntax trees, and intermediate code generation.

## Contents

| Directory | Topic |
|-----------|-------|
| [`PE1`](PE1) | Lexical analyzer (tokenizer) for C source |
| [`PE2`](PE2) | Simplified C syntax validator (declarations, `if`/`else`, `do-while`) |
| [`PE3`](PE3) | Symbol table builder driven by the parser |
| [`PE4`](PE4) | Symbol table with an expanded grammar |
| [`PE5`](PE5) | AST construction and expression evaluation |
| [`PE6`](PE6) | Three-address code for a simple calculator |
| [`c-syntax-validator`](c-syntax-validator) | Extended C syntax validator: `for`, `while`, `switch`, arrays, initialization |
| [`ast-icg`](ast-icg) | AST construction with intermediate code generation |
| [`attribute-grammar-icg`](attribute-grammar-icg) | Attribute-based compiler: lexer, parser, AST and ICG (quadruples) |

## Prerequisites

- `flex` (or `lex`)
- `bison` (or `yacc`)
- `gcc`
- `make` (only for `attribute-grammar-icg`)

On Debian/Ubuntu:

```bash
sudo apt install flex bison gcc make
```

## Building and running

Each directory is self-contained. The exact build and run steps are listed in its `commands.txt`, and typically look like:

```bash
cd c-syntax-validator
bison -d parser.y
flex lexer.l
gcc lex.yy.c parser.tab.c -o parser -lfl
./parser < test.c
```

`attribute-grammar-icg` ships a Makefile:

```bash
cd attribute-grammar-icg
make        # build and run on input.txt
make clean
```

## Contributing

Issues and pull requests are welcome. Please keep each exercise self-contained and do not commit generated files (`lex.yy.c`, `parser.tab.*`) or binaries.

## License

Released under the [MIT License](LICENSE).
