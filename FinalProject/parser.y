%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "code.h"

FILE *f_asm;
int currentArgumentIndex;
int branchCnt = 0;
int yylex();
%}

%union{
    int intVal;
    double doubleVal;
    char *strVal;
}

// demo signals
%token <strVal> LOW HIGH
// type
%token <strVal> TYPECONST TYPESIGNED TYPEUNSIGNED TYPELONG TYPESHORT TYPEINT TYPECHAR TYPEFLOAT TYPEDOUBLE TYPEVOID
// keyword
%token <strVal> IF ELSE SWITCH CASE DEFAULT WHILE DO FOR RETURN BREAK CONTINUE NL
// literal
%token <strVal> ID
%token <intVal> INT
%token <doubleVal> DOUBLE
%token <strVal> CHAR
%token <strVal> STRING
// op
%token <strVal> '+' '-' '*' '/' '%' '=' '!' '~' '^' '&' '|'
%token <strVal> INC DEC LESSTHAN LESSEQUAL GREATERTHAN GREATEREQUAL EQUAL NOTEQUAL RIGHTSHIFT LEFTSHIFT
// puntuation
%token <strVal> ':' ';' ',' '.' '[' ']' '(' ')' '{' '}'

%start program
%type <strVal> program
%type <strVal> datatype
%type <strVal> optional_const optional_signed optional_length base_type

%type <strVal> variable_declaration function_declaration function_definition
%type <strVal> scalar_declaration array_declaration
%type <strVal> identifiers identifier_init identifier
%type <strVal> arrays_init array_init
%type <strVal> parameters parameter arguments

%type <strVal> expression statement 
%type <strVal> expression_2 expression_1 terminal
%type <strVal> stmts_and_declarations if_else_statement switch_statement while_statement for_statement for_body return_break_continue_statement compound_statement
%type <strVal> switch_clauses switch_clause switch_clause_statements

%right '='
%left EQUAL NOTEQUAL
%left LESSTHAN LESSEQUAL GREATERTHAN GREATEREQUAL
%left RIGHTSHIFT LEFTSHIFT
%left '+' '-'
%left '*' '/' '%'

%%

program: program variable_declaration
       | program function_declaration
       | program function_definition
       | /* empty */ {$$ = "";}
       ;

variable_declaration: scalar_declaration
                    | array_declaration
                    ;

scalar_declaration: datatype identifiers ';'
				  ;

datatype: optional_const optional_signed optional_length base_type
		;

optional_const: TYPECONST
			  | /* empty */ {$$ = "";}
			  ;

optional_signed: TYPESIGNED
			   | TYPEUNSIGNED
			   | /* empty */ {$$ = "";}
			   ;

optional_length: TYPELONG TYPELONG
			   | TYPELONG
			   | TYPESHORT
			   | /* empty */ {$$ = "";}
			   ;

base_type: TYPEINT
         | TYPECHAR
         | TYPEFLOAT
         | TYPEDOUBLE
         | TYPEVOID
         ;

identifiers: identifiers ',' identifier_init
      | identifier_init
      ;

identifier_init: identifier '=' expression {
			int idx = LookUpSymbol($1);
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\tsw t0, %d(s0)\n", Table[idx].offset * (-4) - 48);
		  }
          | identifier
          ;

identifier: '*' ID {
		InstallSymbol($2);
		$$ = $2;
	 }
     | ID {
		InstallSymbol($1);
		$$ = $1;
	 }
     ;

array_declaration: datatype arrays_init ';'
                 ;

arrays_init: arrays_init ',' array_init
           | array_init
           ;

array_init: ID '[' INT ']' {
			InstallArray($1, $3);
		  }
		  ;

function_declaration: datatype ID '(' parameters ')' ';' {
						fprintf(f_asm, ".global %s\n", $2);
					}
                    ;

parameters: parameters ',' parameter
          | parameter
          | /* empty */ {$$ = "";}
          ;

parameter: datatype identifier
		 ;


function_definition: datatype ID '(' parameters ')' {
						currentScope++;
				   		SetParameters($2);
						GenFunctionHeader($2);
				   } compound_statement {
						PopUpSymbol(currentScope);
						GenFunctionEnding();
						currentScope--;
				   }
                   ;

arguments: arguments ',' expression {
			fprintf(f_asm, "\tlw a%d, 0(sp)\n", currentArgumentIndex);
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			currentArgumentIndex++;
		 }
		 | expression {
			fprintf(f_asm, "\tlw a%d, 0(sp)\n", currentArgumentIndex);
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			currentArgumentIndex++;
		 }
		 | /* empty */ {$$ = "";}
		 ;

expression: ID '=' expression {
			int idx = LookUpSymbol($1);
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tsw t0, %d(s0)\n", Table[idx].offset * (-4) - 48);
		  }
		  | '*' ID '=' expression {
			int idx = LookUpSymbol($2);
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, %d(s0)\n", Table[idx].offset * (-4) - 48);
			fprintf(f_asm, "\tadd t1, t1, s0\n");
			fprintf(f_asm, "\tsw t0, 0(t1)\n");
		  }
		  | ID '[' expression ']' '=' expression {
			int idx = LookUpSymbol($1);
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tli t2, 4\n");
			fprintf(f_asm, "\tmul t1, t2, t1\n");
			fprintf(f_asm, "\tsub t1, s0, t1\n");
			fprintf(f_asm, "\tsw t0, %d(t1)\n", Table[idx].offset * (-4) - 48);
		  }
		  | expression EQUAL expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tbeq t1, t0, body%d\n", branchCnt);
			fprintf(f_asm, "\tjal zero, exit%d\n", branchCnt);
		  }
		  | expression NOTEQUAL expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tbne t1, t0, body%d\n", branchCnt);
			fprintf(f_asm, "\tjal zero, exit%d\n", branchCnt);
		  }
		  | expression LESSTHAN expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tblt t1, t0, body%d\n", branchCnt);
			fprintf(f_asm, "\tjal zero, exit%d\n", branchCnt);
		  }
		  | expression LESSEQUAL expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tble t1, t0, body%d\n", branchCnt);
			fprintf(f_asm, "\tjal zero, exit%d\n", branchCnt);
		  }
		  | expression GREATERTHAN expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tbgt t1, t0, body%d\n", branchCnt);
			fprintf(f_asm, "\tjal zero, exit%d\n", branchCnt);
		  }
		  | expression GREATEREQUAL expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tbge t1, t0, body%d\n", branchCnt);
			fprintf(f_asm, "\tjal zero, exit%d\n", branchCnt);
		  }
		  | expression LEFTSHIFT expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tsll t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression RIGHTSHIFT expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tsrl t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression '+' expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tadd t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression '-' expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tsub t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression '*' expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tmul t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression '/' expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tdiv t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression '%' expression {
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tlw t1, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\trem t0, t1, t0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		  }
		  | expression_2
		  ;
		  
expression_2: INC expression_2
	 | DEC expression_2
	 | '+' expression_2 {
		fprintf(f_asm, "\tlw t0, 0(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, 4\n");
		fprintf(f_asm, "\tsw t0, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");	
	 }
	 | '-' expression_2 {
		fprintf(f_asm, "\tlw t0, 0(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, 4\n");
		fprintf(f_asm, "\tsub t0, zero, t0\n");
		fprintf(f_asm, "\tsw t0, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");
	 }
	 | '*' expression_2 {
		int idx = LookUpSymbol($2);
		fprintf(f_asm, "\tlw t0, %d(s0)\n", Table[idx].offset * (-4) - 48);
		fprintf(f_asm, "\tadd t0, t0, s0\n");
		fprintf(f_asm, "\tlw t0, 0(t0)\n");
		fprintf(f_asm, "\tsw t0, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");
	 }
	 | '&' expression_2 {
		int idx = LookUpSymbol($2);
		fprintf(f_asm, "\tli t0, %d\n", Table[idx].offset * (-4) - 48);
		fprintf(f_asm, "\tsw t0, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");
	 }
	 | expression_1
	 ;

expression_1: expression_1 INC
	 | expression_1 DEC
	 | ID {
		currentArgumentIndex = 0;
	 } '(' arguments ')' {
		fprintf(f_asm, "\tsw ra, -4(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, -4\n");
		fprintf(f_asm, "\tjal ra, %s\n", $1);
		fprintf(f_asm, "\tlw ra, 0(sp)\n");
		fprintf(f_asm, "\taddi sp, sp, 4\n");
	 }
	 | terminal
	 ;

terminal: ID {
			int idx = LookUpSymbol($1);
			fprintf(f_asm, "\tlw t0, %d(s0)\n", Table[idx].offset * (-4) - 48);
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| INT {
			fprintf(f_asm, "\tli t0, %d\n", $1);
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| ID '[' expression ']' {
			int idx = LookUpSymbol($1);
			fprintf(f_asm, "\tlw t0, 0(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, 4\n");
			fprintf(f_asm, "\tli t1, 4\n");
			fprintf(f_asm, "\tmul t0, t1, t0\n");
			fprintf(f_asm, "\tsub t0, s0, t0\n");
			fprintf(f_asm, "\tlw t0, %d(t0)\n", Table[idx].offset * (-4) - 48);
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| LOW {
			fprintf(f_asm, "\tli t0, 0\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| HIGH {
			fprintf(f_asm, "\tli t0, 1\n");
			fprintf(f_asm, "\tsw t0, -4(sp)\n");
			fprintf(f_asm, "\taddi sp, sp, -4\n");
		}
		| '(' expression ')'
		| DOUBLE
		| CHAR
		| STRING
		| NL
		;

compound_statement: '{' stmts_and_declarations '}'
				  ;

stmts_and_declarations: stmts_and_declarations statement 
					  | stmts_and_declarations variable_declaration 
					  | /* empty */ {$$ = "";}
					  ;

statement: expression ';'
		 | if_else_statement
		 | switch_statement
		 | while_statement
		 | for_statement
		 | return_break_continue_statement
		 | compound_statement
		 ;

if_else_statement: IF '(' expression ')' compound_statement 
				 | IF '(' expression ')' compound_statement ELSE compound_statement
				 ;

switch_statement: SWITCH '(' expression ')' '{' switch_clauses '}'
				;

switch_clauses: switch_clauses switch_clause
			  | /* empty */ {$$ = "";}
			  ;

switch_clause: CASE expression ':' switch_clause_statements 
			 | DEFAULT ':' switch_clause_statements
			 ;

switch_clause_statements: switch_clause_statements statement 
						| /* empty */ {$$ = "";}
						;

while_statement: WHILE '(' expression ')' statement
			   | DO statement WHILE '(' expression ')' ';'
			   ;

for_statement: FOR {
				fprintf(f_asm, ".global condition_%d\n", branchCnt);
				fprintf(f_asm, ".global body_%d\n", branchCnt);
				fprintf(f_asm, ".global increment_%d\n", branchCnt);
				fprintf(f_asm, ".global exit%d\n", branchCnt);
			 } '(' for_body ';' {
				fprintf(f_asm, "condition_%d:\n", branchCnt);
			 } for_body ';' {
				fprintf(f_asm, "increment_%d:\n", branchCnt);
			 } for_body ')' {
				fprintf(f_asm, "\tjal zero, condition_%d\n", branchCnt);
				fprintf(f_asm, "body_%d:\n", branchCnt);
			 } statement {
				fprintf(f_asm, "\tjal zero, increment_%d\n", branchCnt);
				fprintf(f_asm, "exit%d:\n", branchCnt);
				branchCnt++;
			 }
			 ;

for_body: expression
		  | /* empty */ {$$ = "";}
		  ;

return_break_continue_statement: RETURN expression ';'
							   | RETURN ';'
							   | BREAK ';'
							   | CONTINUE ';'
							   ;

%%

int main(void) {
	f_asm = fopen("codegen.S", "w");
    yyparse();
	fclose(f_asm);
    return 0;
}

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}