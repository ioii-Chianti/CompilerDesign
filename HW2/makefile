.PHONY: all clean

all: parser

parser: lex.yy.c y.tab.c
	gcc -o parser lex.yy.c y.tab.c -lfl

lex.yy.c: scanner.l
	flex scanner.l

y.tab.c: parser.y
	byacc -d parser.y

clean:
	rm -f parser lex.yy.c y.tab.c y.tab.h