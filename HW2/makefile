# Makefile for Lex and Yacc parser

# Compiler and tools
LEX = flex
YACC = bison
CC = gcc

# Files
LEX_SRC = scanner.l
YACC_SRC = parser.y
YACC_HEADER = parser.h
LEX_OUT = lex.yy.c
YACC_OUT = parser.tab.c
EXEC = parser

# Targets
all: $(EXEC)

$(LEX_OUT): $(LEX_SRC)
	$(LEX) $(LEX_SRC)

$(YACC_OUT): $(YACC_SRC)
	$(YACC) -d $(YACC_SRC)

$(EXEC): $(LEX_OUT) $(YACC_OUT)
	$(CC) -o $(EXEC) $(LEX_OUT) $(YACC_OUT) -ll

clean:
	rm -f $(LEX_OUT) $(YACC_OUT) $(YACC_HEADER) $(EXEC)

.PHONY: all clean