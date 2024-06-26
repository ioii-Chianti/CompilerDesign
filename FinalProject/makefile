LEX = flex
YACC = byacc
COMPILER = gcc
INPUT = input.c

all: codegen

codegen: lex.yy.c y.tab.c code.c
	$(COMPILER) -o codegen lex.yy.c y.tab.c code.c -lfl

lex.yy.c: scanner.l
	$(LEX) scanner.l

y.tab.c: parser.y
	$(YACC) -d parser.y

clean:
	rm -f codegen lex.yy.c y.tab.c y.tab.h

test:
	./codegen < $(INPUT)
	riscv32-unknown-elf-gcc -o output_prog main.c codegen.S
	qemu-riscv32 output_prog