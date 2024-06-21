%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAXLEN 50

char *OPEN_SCALAR = "<scalar_decl>";
char *CLOSE_SCALAR = "</scalar_decl>";
char *OPEN_ARRAY = "<array_decl>";
char *CLOSE_ARRAY = "</array_decl>";
char *OPEN_FUNCDECL = "<func_decl>";
char *CLOSE_FUNCDECL = "</func_decl>";
char *OPEN_FUNCDEF = "<func_def>";
char *CLOSE_FUNCDEF = "</func_def>";
char *OPEN_EXPR = "<expr>";
char *CLOSE_EXPR = "</expr>";
char *OPEN_STMT = "<stmt>";
char *CLOSE_STMT = "</stmt>";

char *Concatenate(char *s1, char *s2, char *s3, char *s4, char *s5, char *s6, char *s7, char *s8) {
	char *buffer = malloc(strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5) + strlen(s6) + strlen(s7) + strlen(s8) + 1); 
	sprintf(buffer, "%s%s%s%s%s%s%s%s", s1, s2, s3, s4, s5, s6, s7, s8);
	return buffer;
}

%}

%union{
    int intVal;
    double douVal;
    char *strVal;
}

%token <strVal> TYPECONST TYPESIGNED TYPEUNSIGNED TYPELONG TYPESHORT TYPEINT TYPECHAR TYPEFLOAT TYPEDOUBLE TYPEVOID

%token <strVal> IF ELSE
%token <strVal> SWITCH CASE DEFAULT
%token <strVal> WHILE DO
%token <strVal> FOR
%token <strVal> RETURN BREAK CONTINUE
%token <strVal> NUL

%token <strVal> ID
%token <intVal> INT
%token <douVal> DOUBLE
%token <strVal> CHAR
%token <strVal> STRING

%token <strVal> '+' '-' '*' '/' '%' '=' '!' '~' '^' '&' '|'
%token <strVal> ':' ';' ',' '.' '[' ']' '(' ')' '{' '}'
%token <strVal> INCREMENT DECREMENT 
%token <strVal> LESSTHAN LESSEQUAL GREATERTHAN GREATEREQUAL EQUAL NOTEQUAL
%token <strVal> LOGICAND LOGICOR
%token <strVal> RIGHTSHIFT LEFTSHIFT

%start Start
%type <strVal> Start program
%type <strVal> type
%type <strVal> variable_declaration function_declaration function_definition
%type <strVal> scalar_declaration array_declaration
%type <strVal> idents ident_init ident
%type <strVal> arrays_init array_init array array_size array_contents array_elements array_element
%type <strVal> parameters parameter arguments

%type <strVal> expression statement 
%type <strVal> expr14 expr12 expr11 expr10 expr9 expr8 expr7 expr6 expr5 expr4 expr3 expr2 expr1 terminal
%type <strVal> stmts_and_declarations if_else_statement switch_statement while_statement for_statement for_inside return_break_continue_statement compound_statement
%type <strVal> switch_clauses switch_clause switch_clause_statements

%%

Start: program {printf("%s", $1);}

program: program variable_declaration {$$ = Concatenate($1, $2, "" , "" , "" , "" , "" , "");}
       | program function_declaration {$$ = Concatenate($1, $2, "" , "" , "" , "" , "" , "");}
       | program function_definition {$$ = Concatenate($1, $2, "" , "" , "" , "" , "" , "");}
       | /* empty */ {$$ = "";}
       ;

variable_declaration: scalar_declaration {$$ = $1;}
                    | array_declaration {$$ = $1;}
                    ;

scalar_declaration: type idents ';' {$$ = Concatenate(OPEN_SCALAR, $1, $2, $3, CLOSE_SCALAR, "" , "" , "");}
				  ;

type: TYPECONST TYPESIGNED TYPELONG TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, $4, $5, "" ,"" ,"");}
	| TYPECONST TYPESIGNED TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
	| TYPECONST TYPESIGNED TYPESHORT TYPEINT {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
	| TYPECONST TYPESIGNED TYPEINT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPEUNSIGNED TYPELONG TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, $4, $5, "" ,"" ,"");}
	| TYPECONST TYPEUNSIGNED TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
	| TYPECONST TYPEUNSIGNED TYPESHORT TYPEINT {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
	| TYPECONST TYPEUNSIGNED TYPEINT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPELONG TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
	| TYPECONST TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPESHORT TYPEINT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPEINT {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPESIGNED TYPELONG TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
	| TYPESIGNED TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPESIGNED TYPESHORT TYPEINT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPESIGNED TYPEINT {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPEUNSIGNED TYPELONG TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
	| TYPEUNSIGNED TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPEUNSIGNED TYPESHORT TYPEINT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPEUNSIGNED TYPEINT {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPELONG TYPELONG TYPEINT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPELONG TYPEINT {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPESHORT TYPEINT {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPEINT {$$ = $1;}
	| TYPECONST TYPESIGNED TYPELONG TYPELONG {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
	| TYPECONST TYPESIGNED TYPELONG {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPESIGNED TYPESHORT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPESIGNED TYPECHAR {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPEUNSIGNED TYPELONG TYPELONG {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
	| TYPECONST TYPEUNSIGNED TYPELONG {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPEUNSIGNED TYPESHORT {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPEUNSIGNED TYPECHAR {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPELONG TYPELONG {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPELONG {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPESHORT {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPECHAR {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPESIGNED TYPELONG TYPELONG {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPESIGNED TYPELONG {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPESIGNED TYPESHORT {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPESIGNED TYPECHAR {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPEUNSIGNED TYPELONG TYPELONG {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
	| TYPEUNSIGNED TYPELONG {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPEUNSIGNED TYPESHORT {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPEUNSIGNED TYPECHAR {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPELONG TYPELONG {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPELONG {$$ = $1;}
	| TYPESHORT {$$ = $1;}
	| TYPECHAR {$$ = $1;}
	| TYPECONST TYPESIGNED {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPEUNSIGNED {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPEFLOAT {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPEDOUBLE {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPECONST TYPEVOID {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
	| TYPESIGNED {$$ = $1;}
	| TYPEUNSIGNED {$$ = $1;}
	| TYPEFLOAT {$$ = $1;}
	| TYPEDOUBLE {$$ = $1;}
	| TYPEVOID {$$ = $1;}
	| TYPECONST {$$ = $1;}
	;

idents: idents ',' ident_init {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
      | ident_init {$$ = $1;}
      ;

ident_init: ident '=' expression {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
          | ident {$$ = $1;}
          ;

ident: '*' ID {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
     | ID {$$ = $1;}
     ;

array_declaration: type arrays_init ';' {$$ = Concatenate(OPEN_ARRAY, $1, $2, $3, CLOSE_ARRAY, "" ,"" ,"");}
                 ;

arrays_init: arrays_init ',' array_init {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
           | array_init {$$ = $1;}
           ;

array_init: array '=' array_contents {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
          | array {$$ = $1;}
          ;

array: ID array_size {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
     ;

array_size: array_size '[' expression ']' {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");}
          | '[' expression ']' {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
          ;

array_contents: '{' array_elements '}' {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
              ;

array_elements: array_elements ',' array_element {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
              | array_element {$$ = $1;}
              ;

array_element: array_contents {$$ = $1;}
             | expression {$$ = $1;}
             ;

function_declaration: type ident '(' parameters ')' ';' {$$ = Concatenate(OPEN_FUNCDECL, $1, $2, $3, $4, $5, $6, CLOSE_FUNCDECL);}
                    ;

parameters: parameters ',' parameter {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
          | parameter {$$ = $1;}
          | /* empty */ {$$ = "";}
          ;

parameter: type ident {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
         ;

function_definition: type ident '(' parameters ')' compound_statement {$$ = Concatenate(OPEN_FUNCDEF, $1, $2, $3, $4, $5, $6, CLOSE_FUNCDEF);}
                   ;

arguments: arguments ',' expression {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
		 | expression {$$ = $1;}
		 | /* empty */ {$$ = "";}
		 ;

expression: expr14 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, "" ,"" ,"" ,"" ,"");}
		  ;

expr14: expr12 '=' expr14 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	  | expr12 {}
	  ;
expr12: expr12 LOGICOR expr11 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	  | expr11 {}
	  ;
expr11: expr11 LOGICAND expr10 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	  | expr10 {}
	  ;
expr10: expr10 '|' expr9 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	  | expr9 {}
	  ;
expr9: expr9 '^' expr8 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr8 {}
	 ;
expr8: expr8 '&' expr7 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr7 {}
	 ;
expr7: expr7 EQUAL expr6 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr7 NOTEQUAL expr6 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr6 {}
	 ;
expr6: expr6 LESSTHAN expr5 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr6 LESSEQUAL expr5 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr6 GREATERTHAN expr5 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr6 GREATEREQUAL expr5 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr5 {}
	 ;
expr5: expr5 LEFTSHIFT expr4 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr5 RIGHTSHIFT expr4 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr4 {}
	 ;
expr4: expr4 '+' expr3 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr4 '-' expr3 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr3 {}
	 ;
expr3: expr3 '*' expr2 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr3 '/' expr2 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr3 '%' expr2 {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, OPEN_EXPR, $3, CLOSE_EXPR, "");}
	 | expr2 {}
	 ;
expr2: INCREMENT expr2 {$$ = Concatenate($1, OPEN_EXPR, $2, CLOSE_EXPR, "" ,"" ,"" ,"");}
	 | DECREMENT expr2 {$$ = Concatenate($1, OPEN_EXPR, $2, CLOSE_EXPR, "" ,"" ,"" ,"");}
	 | '+' expr2 {$$ = Concatenate($1, OPEN_EXPR, $2, CLOSE_EXPR, "" ,"" ,"" ,"");}
	 | '-' expr2 {$$ = Concatenate($1, OPEN_EXPR, $2, CLOSE_EXPR, "" ,"" ,"" ,"");}
	 | '!' expr2 {$$ = Concatenate($1, OPEN_EXPR, $2, CLOSE_EXPR, "" ,"" ,"" ,"");}
	 | '~' expr2 {$$ = Concatenate($1, OPEN_EXPR, $2, CLOSE_EXPR, "" ,"" ,"" ,"");}
	 | '(' type ')' expr2 {$$ = Concatenate($1, $2, $3, OPEN_EXPR, $4, CLOSE_EXPR, "" ,"");}
	 | '(' type '*' ')' expr2 {$$ = Concatenate($1, $2, $3, $4, OPEN_EXPR, $5, CLOSE_EXPR, "");}
	 | '*' expr2 {$$ = Concatenate($1, OPEN_EXPR, $2, CLOSE_EXPR, "" ,"" ,"" ,"");}
	 | '&' expr2 {$$ = Concatenate($1, OPEN_EXPR, $2, CLOSE_EXPR, "" ,"" ,"" ,"");}
	 | expr1 {}
	 ;
expr1: expr1 INCREMENT {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, "" ,"" ,"" ,"");}
	 | expr1 DECREMENT {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, "" ,"" ,"" ,"");}
	 | expr1 '(' arguments ')' {$$ = Concatenate(OPEN_EXPR, $1, CLOSE_EXPR, $2, $3, $4, "" ,"");}
	 | terminal {}
	 ;

terminal: ID {$$ = $1;}
	 	| array {$$ = $1;}
		| INT {
			char *buffer = malloc(MAXLEN); 
			sprintf(buffer, "%d", $1);
			$$ = buffer;
		}
		| DOUBLE {
			char *buffer = malloc(MAXLEN); 
			sprintf(buffer, "%f", $1);
			$$ = buffer;
		}
		| CHAR {$$ = $1;}
		| STRING {$$ = $1;}
		| NUL {$$ = "0";}
		| '(' expression ')' {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
		;

compound_statement: '{' stmts_and_declarations '}' {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
				  ;

stmts_and_declarations: stmts_and_declarations statement {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");} 
					  | stmts_and_declarations variable_declaration {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");} 
					  | /* empty */ {$$ = "";}
					  ;

statement: expression ';' {$$ = Concatenate(OPEN_STMT, $1, $2, CLOSE_STMT, "" ,"" ,"" ,"");}
		 | if_else_statement {$$ = Concatenate(OPEN_STMT, $1, CLOSE_STMT, "" ,"" ,"" ,"" ,"");}
		 | switch_statement {$$ = Concatenate(OPEN_STMT, $1, CLOSE_STMT, "" ,"" ,"" ,"" ,"");}
		 | while_statement {$$ = Concatenate(OPEN_STMT, $1, CLOSE_STMT, "" ,"" ,"" ,"" ,"");}
		 | for_statement {$$ = Concatenate(OPEN_STMT, $1, CLOSE_STMT, "" ,"" ,"" ,"" ,"");}
		 | return_break_continue_statement {$$ = Concatenate(OPEN_STMT, $1, CLOSE_STMT, "" ,"" ,"" ,"" ,"");}
		 | compound_statement {$$ = Concatenate(OPEN_STMT, $1, CLOSE_STMT, "" ,"" ,"" ,"" ,"");}
		 ;

if_else_statement: IF '(' expression ')' compound_statement {$$ = Concatenate($1, $2, $3, $4, $5, "" ,"" ,"");} 
				 | IF '(' expression ')' compound_statement ELSE compound_statement {$$ = Concatenate($1, $2, $3, $4, $5, $6, $7,"");}
				 ;

switch_statement: SWITCH '(' expression ')' '{' switch_clauses '}' {$$ = Concatenate($1, $2, $3, $4, $5, $6, $7,"");}
				;

switch_clauses: switch_clauses switch_clause {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
			  | /* empty */ {$$ = "";}
			  ;

switch_clause: CASE expression ':' switch_clause_statements {$$ = Concatenate($1, $2, $3, $4, "" ,"" ,"" ,"");} 
			 | DEFAULT ':' switch_clause_statements {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
			 ;

switch_clause_statements: switch_clause_statements statement {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");} 
						| /* empty */ {$$ = "";}
						;

while_statement: WHILE '(' expression ')' statement {$$ = Concatenate($1, $2, $3, $4, $5, "" ,"" ,"");}
			   | DO statement WHILE '(' expression ')' ';' {$$ = Concatenate($1, $2, $3, $4, $5, $6, $7,"");}
			   ;

for_statement: FOR '(' for_inside ';' for_inside ';' for_inside ')' statement {
				char *buffer = malloc(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+strlen($7)+strlen($8)+strlen($9)+1); 
				sprintf(buffer, "%s%s%s%s%s%s%s%s%s", $1, $2, $3, $4, $5, $6, $7, $8, $9);
				$$ = buffer;
			 }
			 ;

for_inside: expression {$$ = $1;}
		  | /* empty */ {$$ = "";}
		  ;

return_break_continue_statement: RETURN expression ';' {$$ = Concatenate($1, $2, $3, "" ,"" ,"" ,"" ,"");}
							   | RETURN ';' {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
							   | BREAK ';' {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
							   | CONTINUE ';' {$$ = Concatenate($1, $2, "" ,"" ,"" ,"" ,"" ,"");}
							   ;

%%

int main(void) {
    yyparse();
    return 0;
}

int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}