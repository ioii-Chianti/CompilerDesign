LEX = flex
CC = gcc

LEX_FILE = scanner.l
EXECUTABLE = scanner
TESTCASE = sample_testcase.txt

scanner: lex.yy.c
	$(CC) -o $(EXECUTABLE) lex.yy.c -lfl

lex.yy.c: $(LEX_FILE)
	$(LEX) $(LEX_FILE)

test: scanner
	./$(EXECUTABLE) < $(TESTCASE)

test1: scanner
	./$(EXECUTABLE) < test1.txt

test2: scanner
	./$(EXECUTABLE) < test2.txt

test3: scanner
	./$(EXECUTABLE) < test3.txt

test4: scanner
	./$(EXECUTABLE) < test4.txt

test5: scanner
	./$(EXECUTABLE) < test5.txt

clean:
	rm -f lex.yy.c $(EXECUTABLE)