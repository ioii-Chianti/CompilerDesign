%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror();

%}

%union {
  int intVal;
  double doubleVal;
  char* strVal;
}
/* operator */
%token<strVal> INCREASE DECREASE LESS_OR_EQUAL_THAN GREATER_OR_EQUAL_THAN SHIFT_LEFT SHIFT_RIGHT EQUAL NOT_EQUAL AND OR ADD MINUS 
%token<strVal> MULTIPLY DIVIDE MOD LOGICAL_NOT BITWISE_NOT LESS_THAN GREATER_THAN BITWISE_AND BITWISE_OR BITWISE_XOR ASSIGN 
%right ASSIGN
%left OR
%left AND
%left BITWISE_OR
%left BITWISE_XOR
%left BITWISE_AND
%left EQUAL NOT_EQUAL
%left GREATER_THAN GREATER_OR_EQUAL_THAN LESS_THAN LESS_OR_EQUAL_THAN
%left SHIFT_LEFT SHIFT_RIGHT
%left ADD MINUS
%left MULTIPLY DIVIDE MOD
%nonassoc UMINUS UADD UMULTI UANDOP
%nonassoc INCPOST DECPOST

/* keyword */
%token IF ELSE SWITCH CASE DEFAULT WHILE DO FOR RETURN BREAK CONTINUE

/* punctuation */
%token<strVal> SEMICOLON COMMA COLON L_PARENTHESIS R_PARENTHESIS L_BRACKET R_BRACKET L_BRACE R_BRACE

/* expression */
%type<strVal> expression primary_expression suffix_expression multidim_arr_list assignment_expression logical_or_expression logical_and_expression bitwise_or_expression
%type<strVal> bitwise_xor_expression bitwise_and_expression equality_expression relational_expression shift_expression additive_expression multiplicative_expression specifier_qualifier_list
%type<strVal> type_name prefix_expression argument_expression_list

/* statement */
%type<strVal> statement_declaration_list compound_statement return_statement continue_statement break_statement jump_statement emptiable_expression
%type<strVal> for_statement do_while_statement while_statement iteration_statement statement_list switch_clause switch_clause_list
%type<strVal> switch_statement if_statement selection_statement expression_statement statement

/* declaration */
%token<strVal> INT CHAR FLOAT DOUBLE VOID SIGNED UNSIGNED LONG SHORT CONST
%type<strVal> declaration declaration_specifiers  type_specifier 
%type<strVal> scalar_decl array_decl func_decl
%type<strVal> parameter_list parameter_declaration  scalar_declarator scalar_init_declarator scalar_init_declarator_list
%type<strVal> func_init_declarator_list

/* universal */
%type<strVal> function_definition trans_unit extern_decl func_init_declarator func_declarator func_direct_declarator array_init_declarator_list array_init_declarator array_declarator array_content array_expression
%token<strVal> IDENTIFIER CHAR_LITERAL STRING_LITERAL NL
%token<intVal> INT_LITERAL
%token<doubleVal> FLOAT_LITERAL
%type<strVal> LITERAL
%start program

%%

/* declaration */
program:
	trans_unit { printf("%s", $1); }
	;

trans_unit:
	extern_decl { $$ = $1; }
    | trans_unit extern_decl {
		$$ = (char *)malloc((strlen($1) + strlen($2)) * sizeof(char) + 1);
		strcat($$, $1);
		strcat($$, $2);
    }
	;

extern_decl
    : declaration { $$ = $1; }
    | function_definition { $$ = $1; } 
    ;   

function_definition
    : declaration_specifiers func_declarator L_BRACE R_BRACE { 
        $$ = (char *)malloc(sizeof(char) * (strlen($1) + strlen($2) + 30));
        strcpy($$, "<func_def>");
        strcat($$, $1);
        strcat($$, $2);
        strcat($$, "{}");
        strcat($$, "</func_def>");
    }
    | declaration_specifiers func_declarator L_BRACE statement_declaration_list R_BRACE {  
        $$ = (char *)malloc(sizeof(char) * (strlen($1) + strlen($2) + strlen($4) + 30));
        strcpy($$, "<func_def>");
        strcat($$, $1);
        strcat($$, $2);
        strcat($$, "{");
        strcat($$, $4);
        strcat($$,  "}");
        strcat($$, "</func_def>");
    }
    ;

declaration : scalar_decl { $$ = $1; }
            | array_decl { $$ = $1; }
            | func_decl { $$ = $1; }
            ;

declaration_specifiers
    : type_specifier { $$ = $1; } /* e.g. int */
      /* e.g. signed int */
    | type_specifier declaration_specifiers {
		$$ = (char *)malloc((strlen($1) + strlen($2)) * sizeof(char) + 1);
		strcat($$, $1);
		strcat($$, $2);
    }
      /* i.e. const */
    | CONST { $$ = $1; }
      /* e.g. const int */
    | CONST declaration_specifiers {
		$$ = (char *)malloc((strlen($1) + strlen($2)) * sizeof(char) + 1);
		strcat($$, $1);
		strcat($$, $2);
    }
    ;

// terminals: fundamental types
type_specifier
    : INT 
    | CHAR
    | FLOAT
    | DOUBLE
    | VOID
    | SIGNED
    | UNSIGNED
    | LONG
    | SHORT
    ;
LITERAL:
      INT_LITERAL {
        $$ = (char *) malloc (sizeof(char) * 100);
        sprintf($$, "%d" , $1);
      }
    | FLOAT_LITERAL {
        $$ = (char *) malloc (sizeof(char) * 100);
        sprintf($$, "%f" , $1);
    }
    | CHAR_LITERAL {
        $$ = $1;
    }
    | STRING_LITERAL {
        $$ = $1;
    }
    ;
/* scalar */
scalar_decl : declaration_specifiers scalar_init_declarator_list SEMICOLON {
    $$ = (char *)malloc((strlen($1) + strlen($2) + 30) * sizeof(char) + 1);
    strcat($$, "<scalar_decl>");
    strcat($$, $1);
    strcat($$, $2);
    strcat($$, ";");
    strcat($$, "</scalar_decl>");
}
;

scalar_init_declarator_list
    : scalar_init_declarator { $$ = $1; }
    | scalar_init_declarator COMMA scalar_init_declarator_list {
        $$ = (char *)malloc((strlen($1) + strlen($3) + 2) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, ",");
        strcat($$, $3);
    }
    ;


scalar_init_declarator
    : scalar_declarator { $$ = $1; }
    | scalar_declarator ASSIGN expression {
        $$ = (char *)malloc((strlen($1) + strlen($3) + 2) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, "=");
        strcat($$, $3);
    }
    ;


scalar_declarator
    : IDENTIFIER { $$ = $1; }
    | MULTIPLY IDENTIFIER {
        $$ = (char *)malloc((strlen($2) + 2) * sizeof(char) + 1);
        strcat($$, "*");
        strcat($$, $2);
    }
    ;

/* scalar */

/* func */
func_decl : declaration_specifiers func_init_declarator_list SEMICOLON {
    $$ = (char *)malloc((strlen($1) + strlen($2) + 30) * sizeof(char) + 1);
    strcat($$, "<func_decl>");
    strcat($$, $1);
    strcat($$, $2);
    strcat($$, ";");
    strcat($$, "</func_decl>");
}
;

func_init_declarator_list
    : func_init_declarator { $$ = $1; }
    | func_init_declarator COMMA func_init_declarator_list {
        $$ = (char *)malloc((strlen($1) + strlen($3) + 2) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, ",");
        strcat($$, $3);
    }
    ;


func_init_declarator
    : func_declarator { $$ = $1; }
    | func_declarator ASSIGN expression {
        $$ = (char *)malloc((strlen($1) + strlen($3) + 2) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, "=");
        strcat($$, $3);
    }
    ;


func_declarator
    : func_direct_declarator { $$ = $1; }
    | MULTIPLY func_direct_declarator {
        $$ = (char *)malloc((strlen($2) + 2) * sizeof(char) + 1);
        strcat($$, "*");
        strcat($$, $2);
    }
    ;


func_direct_declarator
    : IDENTIFIER L_PARENTHESIS R_PARENTHESIS {
        $$ = (char *)malloc((strlen($1) + 3) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, "()");
    }
    | IDENTIFIER L_PARENTHESIS parameter_list R_PARENTHESIS {
        $$ = (char *)malloc((strlen($1) + strlen($3) + 3) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, "(");
        strcat($$, $3);
        strcat($$, ")");
    }
    ;

parameter_list
    : parameter_declaration { $$ = $1; }
    | parameter_declaration COMMA parameter_list { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 2) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, ",");
        strcat($$, $3);
    }
    ;

parameter_declaration
    : declaration_specifiers scalar_declarator {

        $$ = (char *)malloc((strlen($1) + strlen($2) + 2) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, $2);
    }
    ;
/* func */

/* array */
array_decl : declaration_specifiers array_init_declarator_list SEMICOLON {
    $$ = (char *)malloc((strlen($1) + strlen($2) + 30) * sizeof(char) + 1);
    strcat($$, "<array_decl>");
    strcat($$, $1);
    strcat($$, $2);
    strcat($$, ";");
    strcat($$, "</array_decl>");
}
;

array_init_declarator_list
    : array_init_declarator { $$ = $1; }
    | array_init_declarator COMMA array_init_declarator_list { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 2) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, ",");
        strcat($$, $3);
    }
    ;


array_init_declarator
    : array_declarator { $$ = $1; }
    | array_declarator ASSIGN array_content { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 2) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, "=");
        strcat($$, $3);
    }
    ;

array_declarator
    : IDENTIFIER L_BRACKET expression R_BRACKET {
        $$ = (char *)malloc((strlen($1) + strlen($3) + 3) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, "[");
        strcat($$, $3);
        strcat($$, "]");
    }
    | array_declarator L_BRACKET expression R_BRACKET {
        $$ = (char *)malloc((strlen($1) + strlen($3) + 3) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, "[");
        strcat($$, $3);
        strcat($$, "]");
    }
    ;

array_content
    : L_BRACE array_expression R_BRACE { 
        $$ = (char *)malloc((strlen($2) + 3) * sizeof(char) + 1);
        strcat($$, "{");
        strcat($$, $2);
        strcat($$, "}");
    }
    | L_BRACE array_content COMMA array_content R_BRACE {
        $$ = (char *)malloc((strlen($2) + strlen($4) + 4) * sizeof(char) + 1);
        strcat($$, "{");
        strcat($$, $2);
        strcat($$, ",");
        strcat($$, $4);
        strcat($$, "}");
    }
    | L_BRACE array_content COMMA array_expression R_BRACE {
        $$ = (char *)malloc((strlen($2) + strlen($4) + 4) * sizeof(char) + 1);
        strcat($$, "{");
        strcat($$, $2);
        strcat($$, ",");
        strcat($$, $4);
        strcat($$, "}");
    }
    | L_BRACE array_content R_BRACE {
        $$ = (char *)malloc((strlen($2) + 3) * sizeof(char) + 1);
        strcat($$, "{");
        strcat($$, $2);
        strcat($$, "}");
    }
    ;

array_expression
    : expression { $$ = $1; }
    | array_expression COMMA expression {
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        //strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, ",");
        strcat($$, $3);
        //strcat($$, "</expr>");
    }
    ;
/* array */

/* expression */
// highest precedence, should not be separated
primary_expression
    : IDENTIFIER {
        $$ = (char *)malloc((strlen($1) + 15) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "</expr>");
    }
    | LITERAL { 
        $$ = (char *)malloc((strlen($1) + 15) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "</expr>");
    }
    | L_PARENTHESIS expression R_PARENTHESIS    { 

        $$ = (char *)malloc((strlen($2) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, "(");
        strcat($$, $2);
        strcat($$, ")");
        strcat($$, "</expr>");
    }
    | NL {
        $$ = (char *)malloc((strlen($1) + 15) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "</expr>"); 
    }

    ;

    /* Right precedence (Right to Left) */



multidim_arr_list
    : L_BRACKET expression R_BRACKET                        {  

        $$ = (char *)malloc((strlen($2) + 20) * sizeof(char) + 1);
        //strcat($$, "<expr>");
        strcat($$, "[");
        strcat($$, $2);
        strcat($$, "]");
        //strcat($$, "</expr>");
    }
    | L_BRACKET expression R_BRACKET multidim_arr_list      {
        $$ = (char *)malloc((strlen($2) + strlen($4) + 20) * sizeof(char) + 1);
        //strcat($$, "<expr>");
        strcat($$, "[");
        strcat($$, $2);
        strcat($$, "]");
        strcat($$, $4);
        //strcat($$, "</expr>");
    }
    ;

argument_expression_list
    : assignment_expression  { $$ = $1; }
    | assignment_expression COMMA argument_expression_list { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        //strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, ",");
        strcat($$, $3);
        //strcat($$, "</expr>");
    }
    ;

type_name
    : specifier_qualifier_list { $$ = $1; }
    | specifier_qualifier_list MULTIPLY {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 4) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, "*");
    }
    ;

specifier_qualifier_list
    : CONST { $$ = $1; }
    | CONST specifier_qualifier_list {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 4) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, $2);
    }
    | type_specifier { $$ = $1; }
    | type_specifier specifier_qualifier_list {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 4) * sizeof(char) + 1);
        strcat($$, $1);
        strcat($$, $2);
    }
    ;

suffix_expression
    : primary_expression { $$ = $1; }
    | suffix_expression INCREASE %prec INCPOST {  
        $$ = (char *) malloc(sizeof(char) * (strlen($1) + 20));
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "++");
        strcat($$, "</expr>");
    }
    | suffix_expression DECREASE %prec DECPOST { 
        $$ = (char *) malloc(sizeof(char) * (strlen($1) + 20));
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "--");
        strcat($$, "</expr>");
    }
    | suffix_expression L_PARENTHESIS R_PARENTHESIS                  { 
        $$ = (char *) malloc(sizeof(char) * (strlen($1) + 20));
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "()");
        strcat($$, "</expr>");
    }
    | suffix_expression L_PARENTHESIS argument_expression_list R_PARENTHESIS       { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "(");
        strcat($$, $3);
        strcat($$, ")");
        strcat($$, "</expr>");
    }
      /* array: hw spec differs from c / c++ spec */
    | IDENTIFIER  multidim_arr_list {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, $2);
        strcat($$, "</expr>");
    }
    ;

prefix_expression
    : suffix_expression  { $$ = $1; }
    | INCREASE prefix_expression              { 

        $$ = (char *) malloc(sizeof(char) * (strlen($2) + 20));
        strcat($$, "<expr>");
        strcat($$, "++");
        strcat($$, $2);
        strcat($$, "</expr>");
    }
    | DECREASE prefix_expression              { 

        $$ = (char *) malloc(sizeof(char) * (strlen($2) + 20));
        strcat($$, "<expr>");
        strcat($$, "--");
        strcat($$, $2);
        strcat($$, "</expr>");
    }
    | ADD prefix_expression %prec UADD  { 

        $$ = (char *) malloc(sizeof(char) * (strlen($2) + 20));
        strcat($$, "<expr>");
        strcat($$, "+");
        strcat($$, $2);
        strcat($$, "</expr>");
    }
    | MINUS prefix_expression %prec UMINUS { 

        $$ = (char *) malloc(sizeof(char) * (strlen($2) + 20));
        strcat($$, "<expr>");
        strcat($$, "-");
        strcat($$, $2);
        strcat($$, "</expr>");
    }
    | LOGICAL_NOT prefix_expression { 
        $$ = (char *) malloc(sizeof(char) * (strlen($2) + 20));
        strcat($$, "<expr>");
        strcat($$, "!");
        strcat($$, $2);
        strcat($$, "</expr>");
    }
    | BITWISE_NOT prefix_expression { 
        $$ = (char *) malloc(sizeof(char) * (strlen($2) + 20));
        strcat($$, "<expr>");
        strcat($$, "~");
        strcat($$, $2);
        strcat($$, "</expr>");
    }
    | MULTIPLY prefix_expression %prec UMULTI { 
        $$ = (char *) malloc(sizeof(char) * (strlen($2) + 20));
        strcat($$, "<expr>");
        strcat($$, "*");
        strcat($$, $2);
        strcat($$, "</expr>");
    }
    | BITWISE_AND prefix_expression %prec UANDOP { 
        $$ = (char *) malloc(sizeof(char) * (strlen($2) + 20));
        strcat($$, "<expr>");
        strcat($$, "&");
        strcat($$, $2);
        strcat($$, "</expr>");
    }
    | L_PARENTHESIS type_name R_PARENTHESIS prefix_expression   {
        $$ = (char *)malloc((strlen($2) + strlen($4) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, "(");
        strcat($$, $2);
        strcat($$, ")");
        strcat($$, $4);
        strcat($$, "</expr>");
    }
    ;

    /* Left precedence (Left to Right) */

multiplicative_expression
    : prefix_expression { $$ = $1; }
    | multiplicative_expression MULTIPLY prefix_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "*");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    | multiplicative_expression DIVIDE prefix_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "/");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    | multiplicative_expression MOD prefix_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "%");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

additive_expression
    : multiplicative_expression { $$ = $1; }
    | additive_expression ADD multiplicative_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "+");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    | additive_expression MINUS multiplicative_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "-");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

shift_expression
    : additive_expression { $$ = $1; }
    | shift_expression SHIFT_LEFT additive_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "<<");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    | shift_expression SHIFT_RIGHT additive_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, ">>");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

relational_expression
    : shift_expression { $$ = $1; }
    | relational_expression LESS_THAN shift_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "<");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    | relational_expression LESS_OR_EQUAL_THAN shift_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "<=");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    | relational_expression GREATER_THAN shift_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, ">");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    | relational_expression GREATER_OR_EQUAL_THAN shift_expression     { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, ">=");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

equality_expression
    : relational_expression { $$ = $1; }
    | equality_expression EQUAL relational_expression   { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "==");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    | equality_expression NOT_EQUAL relational_expression  { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "!=");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

bitwise_and_expression
    : equality_expression { $$ = $1; }
    | bitwise_and_expression BITWISE_AND equality_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "&");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

bitwise_xor_expression
    : bitwise_and_expression { $$ = $1; }
    | bitwise_xor_expression BITWISE_XOR bitwise_and_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "^");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

bitwise_or_expression
    : bitwise_xor_expression { $$ = $1; }
    | bitwise_or_expression BITWISE_OR bitwise_xor_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "|");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

logical_and_expression
    : bitwise_or_expression { $$ = $1; }
    | logical_and_expression AND bitwise_or_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "&&");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

logical_or_expression
    : logical_and_expression { $$ = $1; }
    | logical_or_expression OR logical_and_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "||");
        strcat($$, $3);
        strcat($$, "</expr>");
     }
    ;


    /* Right precedence (Right to Left) */

assignment_expression
    : logical_or_expression { $$ = $1; }
    | logical_or_expression ASSIGN assignment_expression { 
        $$ = (char *)malloc((strlen($1) + strlen($3) + 20) * sizeof(char) + 1);
        strcat($$, "<expr>");
        strcat($$, $1);
        strcat($$, "=");
        strcat($$, $3);
        strcat($$, "</expr>");
    }
    ;

// lowest precedence, includes everything
// comma not supported
expression
    : assignment_expression { 
        $$ = (char *) malloc(sizeof(char) * (strlen($1) + 2));
       // strcat($$, "<expr>");
        strcat($$, $1);
       // strcat($$, "</expr>");
    }
    ;
/* expression */

/* statement */
statement
    : expression_statement {$$ = $1; }
    | selection_statement {$$ = $1; }
    | iteration_statement {$$ = $1; }
    | jump_statement {$$ = $1; }
    | compound_statement {$$ = $1; }
    ;

expression_statement
    : expression SEMICOLON { 
        $$ = (char *) malloc (sizeof(char) * (5 + strlen($1)));
        strcat($$, $1);
        strcat($$, ";");
    }
    ;

selection_statement
    : if_statement { $$ = $1; }
    | switch_statement { $$ = $1; }
    ;

if_statement
    : IF L_PARENTHESIS expression R_PARENTHESIS compound_statement { 
        $$ = (char *) malloc (sizeof(char) * (50 + strlen($3) + strlen($5)));
        strcat($$, "if(");
        strcat($$, $3);
        strcat($$, ")");
        strcat($$, $5);
    }
    | IF L_PARENTHESIS expression R_PARENTHESIS compound_statement ELSE compound_statement {
        $$ = (char *) malloc (sizeof(char) * (50 + strlen($3) + strlen($7) + strlen($5)));
        strcat($$, "if(");
        strcat($$, $3);
        strcat($$, ")");
        strcat($$, $5);
        strcat($$, "else");
        strcat($$, $7);
    }
    ;

switch_statement
    : SWITCH L_PARENTHESIS expression R_PARENTHESIS L_BRACE R_BRACE {
        $$ = (char *) malloc (sizeof(char) * (50 + strlen($3)));
        strcat($$, "switch(");
        strcat($$, $3);
        strcat($$, "){}");
    }
    | SWITCH L_PARENTHESIS expression R_PARENTHESIS L_BRACE switch_clause_list R_BRACE {
        $$ = (char *) malloc (sizeof(char) * (50 + strlen($3) + strlen($6)));
        strcat($$, "switch(");
        strcat($$, $3);
        strcat($$, "){");
        strcat($$, $6);
        strcat($$, "}");
    }
    ;

switch_clause_list
    : switch_clause { $$ = $1; }
    | switch_clause switch_clause_list      {  
        $$ = (char *) malloc (sizeof(char) * (5 + strlen($2) + strlen($1)));
        strcat($$, $1);
        strcat($$, $2);
    }
    ;

switch_clause
    : CASE expression COLON                   {  
        $$ = (char *) malloc (sizeof(char) * (15 + strlen($2)));
        strcat($$, "case");
        strcat($$, $2);
        strcat($$, ":");
    }
    | CASE expression COLON statement_list    {  
        $$ = (char *) malloc (sizeof(char) * (15 + strlen($2) + strlen($4)));
        strcat($$, "case");
        strcat($$, $2);
        strcat($$, ":");
        strcat($$, $4);
    }
    | DEFAULT COLON                            {  
        $$ = (char *) malloc (sizeof(char) * (15));
        strcat($$, "default:");
    }
    | DEFAULT COLON statement_list            { 
        $$ = (char *) malloc (sizeof(char) * (15 + strlen($3)));
        strcat($$, "default:");
        strcat($$, $3);
    }
    ;

statement_list
    : statement { 
        $$ = (char *) malloc(sizeof(char) * (strlen($1) + 30));
        strcat($$, "<stmt>");
        strcat($$, $1);
        strcat($$, "</stmt>");
    }
    | statement statement_list  { 
        $$ = (char *) malloc(sizeof(char) * (strlen($1) + strlen($2) + 30));
        strcat($$, "<stmt>");
        strcat($$, $1);
        strcat($$, "</stmt>");
        strcat($$, $2);
    }
    ;

iteration_statement
    : while_statement { $$ = $1; }
    | do_while_statement { $$ = $1; }
    | for_statement { $$ = $1; }
    ;

while_statement
    : WHILE L_PARENTHESIS expression R_PARENTHESIS statement {  
        $$ = (char *) malloc (sizeof(char) * (50 + strlen($3) + strlen($5)));
        strcat($$, "while(");
        strcat($$, $3);
        strcat($$, ")");
        strcat($$, "<stmt>");
        strcat($$, $5);
        strcat($$, "</stmt>");
    }
    ;

do_while_statement
    : DO statement WHILE L_PARENTHESIS expression R_PARENTHESIS SEMICOLON { 
        $$ = (char *) malloc (sizeof(char) * (30 + strlen($2) + strlen($5)));
        strcat($$, "do");
        strcat($$, "<stmt>");
        strcat($$, $2);
        strcat($$, "</stmt>");
        strcat($$, "while(");
        strcat($$, $5);
        strcat($$, ")");
        strcat($$, ";");
    }
    ;

for_statement
    : FOR L_PARENTHESIS emptiable_expression SEMICOLON emptiable_expression SEMICOLON emptiable_expression R_PARENTHESIS statement {
        $$ = (char *) malloc (sizeof(char) * (30 + strlen($3) + strlen($5) + strlen($7) + strlen($9)));
        strcat($$, "for");
        strcat($$, "(");
        strcat($$, $3);
        strcat($$, ";");
        strcat($$, $5);
        strcat($$, ";");
        strcat($$, $7);
        strcat($$, ")");
        strcat($$, "<stmt>");
        strcat($$, $9);
        strcat($$, "</stmt>");
    }
    ;

emptiable_expression
    : /* empty */   { $$ =""; }
    | expression {$$ = $1; }
    ;

jump_statement
    : break_statement {$$ = $1; }
    | continue_statement {$$ = $1; }
    | return_statement {$$ = $1; }
    ;

break_statement
    : BREAK SEMICOLON     { 
        $$ = (char *) malloc (sizeof(char) * 10);
        strcat($$, "break;");
    }
    ;

continue_statement
    : CONTINUE SEMICOLON  { 
        $$ = (char *) malloc (sizeof(char) * 10);
        strcat($$, "continue;");
    }
    ;

return_statement
    : RETURN SEMICOLON                { 
        $$ = (char *) malloc (sizeof(char) * 10);
        strcat($$, "return;");
    }
    | RETURN expression SEMICOLON     {
        $$ = (char *) malloc (sizeof(char) * (10 + strlen($2)));
        strcat($$, "return");
        strcat($$, $2);
        strcat($$, ";");
    }
    ;

compound_statement
    : L_BRACE R_BRACE                               { 
        $$ = (char *) malloc (sizeof(char) * 4);
        strcat($$, "{}");
     }
    | L_BRACE statement_declaration_list R_BRACE    { 
        $$ = (char *) malloc (sizeof(char) * (4 + strlen($2)));
        strcat($$, "{");
        strcat($$, $2);
        strcat($$, "}");
     }
    ;

statement_declaration_list
    : statement {
        $$ = (char *) malloc(sizeof(char) * (strlen($1) + 30));
        strcat($$, "<stmt>");
        strcat($$, $1);
        strcat($$, "</stmt>");
    }
    | statement statement_declaration_list {
        $$ = (char *) malloc(sizeof(char) * (strlen($1) + strlen($2) + 30));
        strcat($$, "<stmt>");
        strcat($$, $1);
        strcat($$, "</stmt>");
        strcat($$, $2);
    }
    | declaration { $$ = $1; }
    | declaration statement_declaration_list { 
        $$ = (char *) malloc(sizeof(char) * (strlen($1) + strlen($2) + 3));
        strcat($$, $1);
        strcat($$, $2);
    }
    ;
/* statement */

%%

int main(void) {
    yyparse();
    return 0;
}
int yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    return 0;
}