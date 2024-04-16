%{
#include <stdio.h>
int yylex();
void yyerror(const char* msg);
%}

%token TYPE_INT TYPE_DOUBLE TYPE_BOOL TYPE_CHAR
%token OP_PLUS OP_MINUS OP_MULTIPLE OP_DIVIDE OP_MOD OP_INCREMENT OP_DECREMENT OP_LESS OP_LESSEQUAL OP_GREATER OP_GREATEREQUAL OP_EQUAL OP_NOTEQUAL OP_ASSIGN OP_AND OP_OR OP_NOT OP_POINTER OP_ADDR
%token PUNC_COLON PUNC_SEMICOLON PUNC_COMMA PUNC_DOT PUNC_LEFTBRACKET PUNC_RIGHTBRACKET PUNC_LEFTPERAN PUNC_RIGHTPERAN PUNC_LEFTBRACE PUNC_RIGHTBRACE
%token KEY_VOID KEY_NULL KEY_FOR KEY_WHILE KEY_DO KEY_IF KEY_ELSE KEY_SWITCH KEY_RETURN KEY_BREAK KEY_CONTINUE KEY_CONST KEY_TRUE KEY_FALSE KEY_STRUCT KEY_CASE KEY_DEFAULT
%token TOKEN_IDENTIFIER TOKEN_STRING TOKEN_CHARACTER TOKEN_INTEGER TOKEN_DOUBLE

%nonassoc LOWER_THAN_ELSE
%nonassoc KEY_ELSE

%start main_program
%%

main_program
		: zero_or_more_declaration functions
		;

zero_or_more_declaration
		:
		| zero_or_more_declaration external_declaration	
		;

external_declaration
		: functions
		| declaration
		;

declaration_list
		: declaration
		| declaration_list declaration
		;

declaration
		: declaration_const /* only variables */
		| declaration_no_const /* variables and array */
		;

declaration_const
		: declaration_specifiers_const PUNC_SEMICOLON
		| declaration_specifiers_const init_declarator_list_const PUNC_SEMICOLON
		;

declaration_specifiers_const
		: type_const types
		;

types
		: TYPE_CHAR
		| TYPE_BOOL
		| TYPE_INT
		| TYPE_DOUBLE
		;


type_const
		: KEY_CONST
		;

init_declarator_list_const
		: init_declarator_const
		| init_declarator_list_const PUNC_COMMA init_declarator_const
		;

init_declarator_const
		: declarator_const OP_ASSIGN initializer
		| declarator_const
		;

declarator_const
		: direct_declarator_const
		;

direct_declarator_const
		: TOKEN_IDENTIFIER
		| PUNC_LEFTPERAN declarator_const PUNC_RIGHTPERAN
		| direct_declarator_const PUNC_LEFTPERAN PUNC_RIGHTPERAN
		| direct_declarator_const PUNC_LEFTPERAN parameter_list PUNC_RIGHTPERAN
		| direct_declarator_const PUNC_LEFTPERAN identifier_list PUNC_RIGHTPERAN
		;

declaration_no_const
		: declaration_specifiers_no_const PUNC_SEMICOLON
		| declaration_specifiers_no_const init_declarator_list_no_const PUNC_SEMICOLON
		;

declaration_specifiers_no_const
		: types
		| types declaration_specifiers_no_const
		;


init_declarator_list_no_const
		: init_declarator_no_const
		| init_declarator_list_no_const PUNC_COMMA init_declarator_no_const
		;

init_declarator_no_const
		: declarator_no_const OP_ASSIGN initializer
		| declarator_no_const
		;

declarator_no_const
		: direct_declarator_no_const
		; /* not support pointer */

direct_declarator_no_const
		: TOKEN_IDENTIFIER
		| PUNC_LEFTPERAN declarator_no_const PUNC_RIGHTPERAN
		| direct_declarator_no_const PUNC_LEFTBRACKET TOKEN_INTEGER PUNC_RIGHTBRACKET /* todo may need to let int > 0*/
		| direct_declarator_no_const PUNC_LEFTPERAN PUNC_RIGHTPERAN
		| direct_declarator_no_const PUNC_LEFTPERAN parameter_list PUNC_RIGHTPERAN
		| direct_declarator_no_const PUNC_LEFTPERAN identifier_list PUNC_RIGHTPERAN
		;


functions
		: declaration_specifiers_no_const declarator_no_const declaration_list compound_statement
		| declaration_specifiers_no_const declarator_no_const compound_statement
		| KEY_VOID declarator_no_const declaration_list compound_statement
		| KEY_VOID declarator_no_const compound_statement
		;



initializer
		: PUNC_LEFTBRACE PUNC_RIGHTBRACE
		| PUNC_LEFTBRACE initializer_list PUNC_RIGHTBRACE
		| PUNC_LEFTBRACE initializer_list PUNC_COMMA PUNC_RIGHTBRACE
		| assignment_expression_without_func
		;

initializer_list
		: designation initializer
		| initializer
		| initializer_list PUNC_COMMA designation initializer
		| initializer_list PUNC_COMMA initializer
		;

designation
		: designator_list OP_ASSIGN
		;

designator_list
		: designator
		| designator_list designator
		;

designator
		: PUNC_DOT TOKEN_IDENTIFIER
		;


identifier_list
		: TOKEN_IDENTIFIER
		| identifier_list PUNC_COMMA TOKEN_IDENTIFIER
		;


parameter_list
		: parameter_declaration
		| parameter_list PUNC_COMMA parameter_declaration
		;

parameter_declaration
		: declaration_specifiers_no_const declarator_no_const
		| declaration_specifiers_no_const
		; /* ignore abstract delaration here */

compound_statement
		: PUNC_LEFTBRACE block_item_list PUNC_RIGHTBRACE
		;

block_item_list
		: zero_or_more_declaration zero_or_more_statement
		;


zero_or_more_statement
		: /* empty */
		| zero_or_more_statement statement
		;

statement
		: compound_statement
		| expression_statement
		| selection_statement
		| iteration_statement
		| jump_statement
		;

expression_statement
		: PUNC_SEMICOLON
		| expression PUNC_SEMICOLON
		;

expression
		: assignment_expression
		| expression PUNC_COMMA assignment_expression
		;

assignment_expression
		: logical_or_expression
		| unary_expression OP_ASSIGN assignment_expression
		;

assignment_expression_without_func
		: logical_or_expression_without_func
		| unary_expression_without_func OP_ASSIGN assignment_expression_without_func
		;

logical_or_expression
		: logical_and_expression
		| logical_or_expression OP_OR logical_and_expression
		;

logical_and_expression
		: and_expression
		| logical_and_expression OP_AND and_expression
		;

and_expression
		: equality_expression
		| and_expression OP_ADDR equality_expression
		;

equality_expression
		: relational_expression
		| equality_expression OP_EQUAL relational_expression
		| equality_expression OP_NOTEQUAL relational_expression
		;

relational_expression
		: additive_expression
		| relational_expression OP_GREATER additive_expression
		| relational_expression OP_GREATEREQUAL additive_expression
		| relational_expression OP_LESS additive_expression
		| relational_expression OP_LESSEQUAL additive_expression
		;

additive_expression
		: multiplicative_expression
		| additive_expression OP_PLUS multiplicative_expression
		| additive_expression OP_MINUS multiplicative_expression
		;

multiplicative_expression
		: unary_expression
		| multiplicative_expression OP_MULTIPLE unary_expression
		| multiplicative_expression OP_DIVIDE unary_expression
		| multiplicative_expression OP_MOD unary_expression
		;

unary_expression
		: postfix_expression
		| OP_INCREMENT unary_expression
		| OP_DECREMENT unary_expression
		| unary_operator unary_expression
		; /* not support sizeof alignof */

unary_operator
		: OP_ADDR
		| OP_POINTER
		| OP_PLUS
		| OP_MINUS
		| OP_NOT
		;

postfix_expression
		: primary_expression
		| postfix_expression PUNC_LEFTBRACKET expression PUNC_RIGHTBRACKET
		| postfix_expression PUNC_LEFTPERAN PUNC_RIGHTPERAN
		| postfix_expression PUNC_LEFTPERAN argument_expression_list PUNC_RIGHTPERAN
		| postfix_expression PUNC_DOT TOKEN_IDENTIFIER
		| postfix_expression OP_INCREMENT
		| postfix_expression OP_DECREMENT
		;

primary_expression
		: TOKEN_IDENTIFIER
		| constant
		| TOKEN_STRING
		| PUNC_LEFTPERAN expression PUNC_RIGHTPERAN
		;

constant
		: TOKEN_INTEGER
		| TOKEN_DOUBLE
		;

logical_or_expression_without_func
		: logical_and_expression_without_func
		| logical_or_expression_without_func OP_OR logical_and_expression_without_func
		;

logical_and_expression_without_func
		: and_expression_without_func
		| logical_and_expression_without_func OP_AND and_expression_without_func
		;

and_expression_without_func
		: equality_expression_without_func
		| and_expression_without_func OP_ADDR equality_expression_without_func
		;

equality_expression_without_func
		: relational_expression_without_func
		| equality_expression_without_func OP_EQUAL relational_expression_without_func
		| equality_expression_without_func OP_NOTEQUAL relational_expression_without_func
		;

relational_expression_without_func
		: additive_expression_without_func
		| relational_expression_without_func OP_GREATER additive_expression_without_func
		| relational_expression_without_func OP_GREATEREQUAL additive_expression_without_func
		| relational_expression_without_func OP_LESS additive_expression_without_func
		| relational_expression_without_func OP_LESSEQUAL additive_expression_without_func
		;

additive_expression_without_func
		: multiplicative_expression_without_func
		| additive_expression_without_func OP_PLUS multiplicative_expression_without_func
		| additive_expression_without_func OP_MINUS multiplicative_expression_without_func
		;

multiplicative_expression_without_func
		: unary_expression_without_func
		| multiplicative_expression_without_func OP_MULTIPLE unary_expression_without_func
		| multiplicative_expression_without_func OP_DIVIDE unary_expression_without_func
		| multiplicative_expression_without_func OP_MOD unary_expression_without_func
		;

unary_expression_without_func
		: postfix_expression_without_func
		| OP_INCREMENT unary_expression_without_func
		| OP_DECREMENT unary_expression_without_func
		| unary_operator unary_expression_without_func
		; /* not support sizeof alignof */

postfix_expression_without_func
		: primary_expression_without_func
		| postfix_expression_without_func PUNC_LEFTBRACKET TOKEN_INTEGER PUNC_RIGHTBRACKET
		| postfix_expression_without_func PUNC_DOT TOKEN_IDENTIFIER
		| postfix_expression_without_func OP_INCREMENT
		| postfix_expression_without_func OP_DECREMENT
		; /* may need to support initializer list */

primary_expression_without_func
		: TOKEN_IDENTIFIER
		| constant
		| TOKEN_STRING
		| PUNC_LEFTPERAN expression PUNC_RIGHTPERAN
		;


argument_expression_list
		: assignment_expression
		| argument_expression_list PUNC_COMMA assignment_expression
		;

selection_statement
		: KEY_IF PUNC_LEFTPERAN expression PUNC_RIGHTPERAN statement KEY_ELSE statement
		| KEY_IF PUNC_LEFTPERAN expression PUNC_RIGHTPERAN statement %prec LOWER_THAN_ELSE
		| KEY_SWITCH PUNC_LEFTPERAN identifier_list PUNC_RIGHTPERAN PUNC_LEFTBRACE switch_content PUNC_RIGHTBRACE
		;

switch_content
		: one_or_more_case
		| one_or_more_case default_statement
		;

one_or_more_case
		: case_statement
		| one_or_more_case case_statement
		;

case_statement
		: KEY_CASE int_or_char_const PUNC_COLON zero_or_more_statement
		;

default_statement
		: KEY_DEFAULT PUNC_COLON zero_or_more_statement
		;

int_or_char_const
		: TOKEN_INTEGER
		| TOKEN_CHARACTER
		;

iteration_statement
		: KEY_WHILE PUNC_LEFTPERAN expression PUNC_RIGHTPERAN statement
		| KEY_DO statement KEY_WHILE PUNC_LEFTPERAN expression PUNC_RIGHTPERAN PUNC_SEMICOLON
		| KEY_FOR PUNC_LEFTPERAN expression_statement expression_statement PUNC_RIGHTPERAN statement
		| KEY_FOR PUNC_LEFTPERAN expression_statement expression_statement expression PUNC_RIGHTPERAN statement
		| KEY_FOR PUNC_LEFTPERAN declaration expression_statement PUNC_RIGHTPERAN statement
		| KEY_FOR PUNC_LEFTPERAN declaration expression_statement expression PUNC_RIGHTPERAN statement
		;

jump_statement
		: KEY_CONTINUE PUNC_SEMICOLON
		| KEY_BREAK PUNC_SEMICOLON
		| KEY_RETURN PUNC_SEMICOLON
		| KEY_RETURN expression PUNC_SEMICOLON
		;
%%
int main(){
	yyparse();
	printf("No syntax error!\n");
	return 0;
}
