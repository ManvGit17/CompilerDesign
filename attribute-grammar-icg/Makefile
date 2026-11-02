# Summary: Builds the ASSIGN2 compiler (parser + lexer + AST + ICG) and runs it on sample input.

all: compiler   # Default goal ensures executable is created and exercised.

compiler:
	bison -d parser.y                          # Generate parser implementation/header.
	flex lexer.l                               # Generate scanner compatible with parser tokens.
	gcc parser.tab.c lex.yy.c ast.c icg.c -o assign2  # Link supporting modules.
	./assign2 < input.txt                      # Demo run with canonical input program.

clean:
	rm -f lex.yy.c assign2 parser.tab.c parser.tab.h  # Remove derived artifacts.
